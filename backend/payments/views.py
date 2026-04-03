import uuid

from django.conf import settings
from django.db import IntegrityError, transaction
from rest_framework import permissions, status
from rest_framework.response import Response
from rest_framework.views import APIView

from .models import Payment
from .serializers import PaymentInitiateSerializer
from stories.models import Book, Purchase
from .services.pesapal import (
    get_access_token,
    get_transaction_status,
    normalize_status,
    register_ipn_url,
    submit_order_request,
)


class InitiatePaymentAPIView(APIView):
    permission_classes = [permissions.IsAuthenticated]

    def post(self, request):
        serializer = PaymentInitiateSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)

        book_id = serializer.validated_data['book_id']
        book = Book.objects.filter(pk=book_id, status=Book.Status.APPROVED, is_published=True).first()
        if not book:
            return Response({'detail': 'Book not found or unavailable for purchase.'}, status=status.HTTP_404_NOT_FOUND)

        amount = book.price
        if amount <= 0:
            Purchase.objects.get_or_create(user=request.user, book=book)
            return Response(
                {
                    'already_purchased': True,
                    'book_id': book.id,
                    'merchant_reference': '',
                    'redirect_url': '',
                },
                status=status.HTTP_200_OK,
            )

        has_completed_payment = Payment.objects.filter(
            user=request.user,
            book=book,
            purpose=Payment.Purpose.BOOK_UNLOCK,
            status=Payment.Status.COMPLETED,
        ).exists()
        if has_completed_payment:
            Purchase.objects.get_or_create(user=request.user, book=book)
            return Response(
                {
                    'already_purchased': True,
                    'book_id': book.id,
                    'merchant_reference': '',
                    'redirect_url': '',
                },
                status=status.HTTP_200_OK,
            )

        email = serializer.validated_data.get('email') or request.user.email
        if not email:
            return Response({'detail': 'A valid email is required for payment.'}, status=status.HTTP_400_BAD_REQUEST)

        currency = getattr(settings, 'PESAPAL_CURRENCY', 'TZS')
        description = f"Story Zoo unlock: {book.title}"

        merchant_reference = self._generate_reference()

        try:
            with transaction.atomic():
                payment = Payment.objects.create(
                    merchant_reference=merchant_reference,
                    amount=amount,
                    currency=currency,
                    email=email,
                    purpose=Payment.Purpose.BOOK_UNLOCK,
                    user=request.user,
                    book=book,
                    status=Payment.Status.PENDING,
                )
        except IntegrityError:
            merchant_reference = self._generate_reference()
            payment = Payment.objects.create(
                merchant_reference=merchant_reference,
                amount=amount,
                currency=currency,
                email=email,
                purpose=Payment.Purpose.BOOK_UNLOCK,
                user=request.user,
                book=book,
                status=Payment.Status.PENDING,
            )

        try:
            access_token = get_access_token()
            ipn_id = register_ipn_url(access_token)
            submit_response = submit_order_request(
                access_token=access_token,
                amount=payment.amount,
                currency=payment.currency,
                description=description,
                merchant_reference=payment.merchant_reference,
                email=payment.email,
                callback_url=settings.PESAPAL_CALLBACK_URL,
                ipn_id=ipn_id,
            )
        except RuntimeError as exc:
            payment.status = Payment.Status.FAILED
            payment.save(update_fields=['status', 'updated_at'])
            return Response({'detail': str(exc)}, status=status.HTTP_502_BAD_GATEWAY)

        order_tracking_id = submit_response.get('order_tracking_id') or submit_response.get('orderTrackingId')
        redirect_url = submit_response.get('redirect_url') or submit_response.get('redirectUrl')

        if not order_tracking_id or not redirect_url:
            payment.status = Payment.Status.FAILED
            payment.save(update_fields=['status', 'updated_at'])
            return Response({'detail': 'Pesapal returned an invalid response.'}, status=status.HTTP_502_BAD_GATEWAY)

        payment.order_tracking_id = order_tracking_id
        payment.save(update_fields=['order_tracking_id', 'updated_at'])

        return Response(
            {
                'redirect_url': redirect_url,
                'order_tracking_id': order_tracking_id,
                'merchant_reference': payment.merchant_reference,
                'book_id': book.id,
            }
        )

    def _generate_reference(self) -> str:
        return f"SZ-{uuid.uuid4().hex[:12].upper()}"


class PaymentCallbackAPIView(APIView):
    permission_classes = [permissions.AllowAny]

    def get(self, request):
        return self._handle_callback(request)

    def post(self, request):
        return self._handle_callback(request)

    def _handle_callback(self, request):
        order_tracking_id = (
            request.query_params.get('OrderTrackingId')
            or request.query_params.get('orderTrackingId')
            or request.data.get('OrderTrackingId')
            or request.data.get('orderTrackingId')
            or request.data.get('order_tracking_id')
        )

        if not order_tracking_id:
            return Response({'detail': 'OrderTrackingId is required.'}, status=status.HTTP_400_BAD_REQUEST)

        payment = Payment.objects.filter(order_tracking_id=order_tracking_id).first()
        if not payment:
            return Response({'detail': 'Payment not found.'}, status=status.HTTP_404_NOT_FOUND)

        try:
            access_token = get_access_token()
            status_response = get_transaction_status(access_token, order_tracking_id)
        except RuntimeError as exc:
            return Response({'detail': str(exc)}, status=status.HTTP_502_BAD_GATEWAY)

        raw_status = (
            status_response.get('payment_status_description')
            or status_response.get('status')
            or status_response.get('payment_status')
        )
        normalized = normalize_status(raw_status)

        payment.status = normalized
        payment.save(update_fields=['status', 'updated_at'])

        if normalized == Payment.Status.COMPLETED and payment.user_id and payment.book_id:
            Purchase.objects.get_or_create(user_id=payment.user_id, book_id=payment.book_id)

        return Response(
            {
                'merchant_reference': payment.merchant_reference,
                'order_tracking_id': payment.order_tracking_id,
                'status': normalized,
            }
        )


class PaymentStatusAPIView(APIView):
    permission_classes = [permissions.IsAuthenticated]

    def get(self, request):
        merchant_reference = (request.query_params.get('merchant_reference') or '').strip()
        if not merchant_reference:
            return Response({'detail': 'merchant_reference is required.'}, status=status.HTTP_400_BAD_REQUEST)

        payment = Payment.objects.filter(merchant_reference=merchant_reference, user=request.user).first()
        if not payment:
            return Response({'detail': 'Payment not found.'}, status=status.HTTP_404_NOT_FOUND)

        if payment.order_tracking_id:
            try:
                access_token = get_access_token()
                status_response = get_transaction_status(access_token, payment.order_tracking_id)
                raw_status = (
                    status_response.get('payment_status_description')
                    or status_response.get('status')
                    or status_response.get('payment_status')
                )
                payment.status = normalize_status(raw_status)
                payment.save(update_fields=['status', 'updated_at'])
            except RuntimeError:
                # Keep last known status if upstream check fails.
                pass

        if payment.status == Payment.Status.COMPLETED and payment.user_id and payment.book_id:
            Purchase.objects.get_or_create(user_id=payment.user_id, book_id=payment.book_id)

        return Response(
            {
                'merchant_reference': payment.merchant_reference,
                'order_tracking_id': payment.order_tracking_id,
                'status': payment.status,
                'book_id': payment.book_id,
            }
        )
