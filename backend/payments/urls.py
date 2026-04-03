from django.urls import path

from .views import InitiatePaymentAPIView, PaymentCallbackAPIView, PaymentStatusAPIView

urlpatterns = [
    path('initiate/', InitiatePaymentAPIView.as_view(), name='payments-initiate'),
    path('callback/', PaymentCallbackAPIView.as_view(), name='payments-callback'),
    path('status/', PaymentStatusAPIView.as_view(), name='payments-status'),
]
