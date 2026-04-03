import hashlib
import json
import logging
import random
import subprocess
import time
import unicodedata
from datetime import timedelta
from pathlib import Path

from django.contrib.auth import get_user_model
from django.conf import settings
from django.core.cache import cache
from django.core.mail import send_mail
from django.utils import timezone
from django.db.models import Prefetch, Sum
from django.http import FileResponse
from django.shortcuts import get_object_or_404
from google.auth.transport import requests as google_requests
from google.oauth2 import id_token as google_id_token
from rest_framework import generics, permissions, status
from rest_framework.authtoken.models import Token
from rest_framework.renderers import BaseRenderer, JSONRenderer
from rest_framework.response import Response
from rest_framework.views import APIView

from .models import (
	AuthorProfile,
	Book,
	Chapter,
	Purchase,
	Story,
	UserAudioProgress,
	UserBookProgress,
	UserNotificationPreference,
	UserProfile,
	UserSavedStory,
)
from .serializers import (
	AuthorDashboardSerializer,
	AuthorOnboardingSerializer,
	AuthorProfileSerializer,
	BookCreateSerializer,
	BookSerializer,
	ChapterSerializer,
	GoogleAuthSerializer,
	PurchaseSerializer,
	RequestOtpSerializer,
	StorySerializer,
	UserAudioProgressSerializer,
	UserBookProgressSerializer,
	UserNotificationPreferenceSerializer,
	UserProfileSerializer,
	UserSavedStorySerializer,
	VerifyOtpSerializer,
)
from payments.models import Payment

User = get_user_model()
logger = logging.getLogger(__name__)


def _to_int(value):
	try:
		return int(value)
	except (TypeError, ValueError):
		return None


def _normalize_book_language(value: str) -> str:
	normalized = (value or '').strip().lower()
	if normalized in {'en', 'eng', 'english'}:
		return 'English'
	if normalized in {'sw', 'swa', 'swahili', 'kiswahili'}:
		return 'Kiswahili'
	return 'Kiswahili'


def _language_code_from_book_language(value: str) -> str:
	return 'en' if _normalize_book_language(value) == 'English' else 'sw'


def _ensure_story_for_book(book: Book):
	story = Story.objects.filter(pk=book.id).first()
	if story:
		return story

	author_name = (book.author.get_full_name() or book.author.username or book.author.email or 'Author').strip()
	story = Story.objects.create(
		id=book.id,
		title=book.title,
		title_en=(book.title_en or book.title or '').strip(),
		description=book.description,
		description_en=(book.description_en or book.description or '').strip(),
		author=author_name,
		author_id=str(book.author_id),
		category=book.category,
		language=_normalize_book_language(book.language),
		cover_image='',
		price=0 if book.is_free else book.price,
		rating=book.average_rating or 0,
		total_reviews=0,
		has_audio=book.has_audio,
		is_published=True,
		published_at=book.published_at or timezone.now(),
	)
	return story


def _story_chapter_payload(story: Story):
	return {
		'book_id': story.id,
		'book_title': story.title,
		'purchased': True,
		'preview_only': False,
		'message': '',
		'chapters': [
			{
				'id': story.id,
				'title': 'Sura ya 1',
				'content': story.description,
				'order': 1,
				'is_locked': False,
			},
		],
	}


def _book_author_name(book: Book) -> str:
	return (book.author.get_full_name() or book.author.username or book.author.email or 'Author').strip()


def _book_cover_url(request, book: Book) -> str:
	if book.cover_image:
		return request.build_absolute_uri(book.cover_image.url)
	story = Story.objects.filter(pk=book.id).first()
	if story and story.cover_image:
		return story.cover_image
	return ''


def _purchase_item_payload(request, purchase: Purchase):
	book = purchase.book
	return {
		'id': book.id,
		'title': book.title,
		'description': book.description,
		'author': _book_author_name(book),
		'author_id': str(book.author_id),
		'category': book.category,
		'language': _normalize_book_language(book.language),
		'cover_image': _book_cover_url(request, book),
		'price': float(0 if book.is_free else (book.price or 0)),
		'rating': float(book.average_rating or 0),
		'total_reviews': 0,
		'is_purchased': True,
		'has_audio': bool(book.has_audio),
		'published_date': (book.published_at or book.created_at).isoformat(),
		'purchased_at': purchase.purchased_at.isoformat(),
	}


class IsAuthorUser(permissions.BasePermission):
	message = 'Only authors can create books.'

	def has_permission(self, request, view):
		user = request.user
		if not user or not user.is_authenticated:
			return False
		if user.is_staff or user.groups.filter(name='authors').exists():
			return True
		return AuthorProfile.objects.filter(
			user=user,
			is_active_author=True,
			status=AuthorProfile.Status.APPROVED,
		).exists()


class StoryListAPIView(APIView):
	permission_classes = [permissions.AllowAny]

	def get(self, request):
		published = request.query_params.get('published')
		is_published_filter = None
		if published is not None:
			is_published_filter = published.lower() in {'true', '1', 'yes'}

		limit = 50
		limit_raw = request.query_params.get('limit')
		if limit_raw:
			try:
				limit = max(1, min(int(limit_raw), 100))
			except ValueError:
				limit = 50

		stories_qs = Story.objects.all()
		if is_published_filter is not None:
			stories_qs = stories_qs.filter(is_published=is_published_filter)

		stories_payload = []
		book_ids = set()

		if is_published_filter is not False:
			books_qs = Book.objects.select_related('author').filter(
				status=Book.Status.APPROVED,
				is_published=True,
			)
			for book in books_qs:
				book_ids.add(book.id)
				author_name = (book.author.get_full_name() or book.author.username or book.author.email or 'Author').strip()
				cover_image = request.build_absolute_uri(book.cover_image.url) if book.cover_image else ''
				stories_payload.append(
					{
						'id': book.id,
						'title': book.title,
						'description': book.description,
						'author': author_name,
						'author_id': str(book.author_id),
						'category': book.category,
						'language': _normalize_book_language(book.language),
						'cover_image': cover_image,
						'price': 0 if book.is_free else float(book.price or 0),
						'rating': float(book.average_rating or 0),
						'total_reviews': 0,
						'has_audio': bool(book.has_audio),
						'is_published': True,
						'published_date': (book.published_at or book.created_at).isoformat(),
					}
				)

		for story_data in StorySerializer(stories_qs, many=True).data:
			story_id = _to_int(story_data.get('id'))
			if story_id is not None and story_id in book_ids:
				continue
			stories_payload.append(story_data)

		stories_payload.sort(key=lambda item: item.get('published_date') or '', reverse=True)
		return Response(stories_payload[:limit])


class BookListCreateAPIView(generics.ListCreateAPIView):
	permission_classes = [permissions.AllowAny]

	def get_queryset(self):
		queryset = Book.objects.select_related('author').prefetch_related(
			Prefetch('chapters', queryset=Chapter.objects.order_by('order')),
		)
		if self.request.method == 'POST':
			return queryset
		return queryset.filter(status=Book.Status.APPROVED, is_published=True)

	def get_serializer_class(self):
		if self.request.method == 'POST':
			return BookCreateSerializer
		return BookSerializer

	def get_permissions(self):
		if self.request.method == 'POST':
			return [permissions.IsAuthenticated(), IsAuthorUser()]
		return [permissions.AllowAny()]

	def create(self, request, *args, **kwargs):
		return super().create(request, *args, **kwargs)


class BookDetailAPIView(generics.RetrieveAPIView):
	serializer_class = BookSerializer
	permission_classes = [permissions.AllowAny]

	def get_queryset(self):
		queryset = Book.objects.select_related('author').prefetch_related(
			Prefetch('chapters', queryset=Chapter.objects.order_by('order')),
		)
		user = self.request.user
		if user.is_authenticated and (user.is_staff or user.groups.filter(name='authors').exists()):
			return queryset
		return queryset.filter(status=Book.Status.APPROVED, is_published=True)


class BookChaptersAPIView(APIView):
	permission_classes = [permissions.IsAuthenticatedOrReadOnly]

	def get(self, request, pk):
		book = (
			Book.objects.select_related('author').prefetch_related(
				Prefetch('chapters', queryset=Chapter.objects.order_by('order')),
			)
			.filter(pk=pk)
			.first()
		)

		if not book:
			story = Story.objects.filter(pk=pk, is_published=True).first()
			if story:
				return Response(_story_chapter_payload(story))
			return Response({'detail': 'Book not found.'}, status=status.HTTP_404_NOT_FOUND)

		if book.status != Book.Status.APPROVED or not book.is_published:
			is_author_owner = request.user.is_authenticated and (
				request.user.is_staff or book.author_id == request.user.id
			)
			if not is_author_owner:
				story = Story.objects.filter(pk=pk, is_published=True).first()
				if story:
					return Response(_story_chapter_payload(story))
				return Response({'detail': 'Book is not approved yet.'}, status=status.HTTP_403_FORBIDDEN)

		is_purchased = False
		if request.user.is_authenticated:
			if book.is_free or float(book.price or 0) <= 0:
				is_purchased = Purchase.objects.filter(user=request.user, book=book).exists()
			else:
				is_purchased = Payment.objects.filter(
					user=request.user,
					book=book,
					purpose=Payment.Purpose.BOOK_UNLOCK,
					status=Payment.Status.COMPLETED,
				).exists()

		can_access_full = book.is_free or float(book.price or 0) <= 0 or is_purchased or (
			request.user.is_authenticated and (request.user.is_staff or book.author_id == request.user.id)
		)

		all_chapters = list(book.chapters.all())
		if not all_chapters:
			return Response(
				{
					'book_id': book.id,
					'book_title': book.title,
					'purchased': can_access_full,
					'preview_only': not can_access_full,
					'message': 'No chapters available yet.',
					'chapters': [],
				}
			)

		if can_access_full:
			payload_chapters = [
				{**ChapterSerializer(ch).data, 'is_locked': False}
				for ch in all_chapters
			]
		else:
			payload_chapters = []
			for idx, chapter in enumerate(all_chapters):
				if idx == 0:
					payload_chapters.append({**ChapterSerializer(chapter).data, 'is_locked': False})
				else:
					payload_chapters.append(
						{
							'id': chapter.id,
							'title': chapter.title,
							'content': '',
							'order': chapter.order,
							'is_locked': True,
						}
					)

		return Response(
			{
				'book_id': book.id,
				'book_title': book.title,
				'purchased': can_access_full,
				'preview_only': not can_access_full,
				'message': '' if can_access_full else 'Buy this book to continue reading',
				'chapters': payload_chapters,
			}
		)


class PurchaseBookAPIView(APIView):
	permission_classes = [permissions.IsAuthenticated]

	def post(self, request, book_id):
		book = get_object_or_404(Book, pk=book_id, status=Book.Status.APPROVED, is_published=True)

		if book.is_free or float(book.price or 0) <= 0:
			purchase, created = Purchase.objects.get_or_create(user=request.user, book=book)
			serializer = PurchaseSerializer(purchase)
			return Response(
				{
					'purchased': True,
					'already_purchased': not created,
					'purchase': serializer.data,
				},
				status=status.HTTP_201_CREATED if created else status.HTTP_200_OK,
			)

		merchant_reference = (request.data.get('merchant_reference') or '').strip()
		if not merchant_reference:
			return Response(
				{'detail': 'merchant_reference is required for paid books.'},
				status=status.HTTP_400_BAD_REQUEST,
			)

		payment = Payment.objects.filter(
			merchant_reference=merchant_reference,
			user=request.user,
			book=book,
		).first()
		if not payment:
			return Response({'detail': 'Payment record not found.'}, status=status.HTTP_404_NOT_FOUND)

		if payment.status != Payment.Status.COMPLETED:
			return Response(
				{'detail': 'Payment is not completed yet.'},
				status=status.HTTP_402_PAYMENT_REQUIRED,
			)

		purchase, created = Purchase.objects.get_or_create(user=request.user, book=book)
		serializer = PurchaseSerializer(purchase)
		return Response(
			{
				'purchased': True,
				'already_purchased': not created,
				'purchase': serializer.data,
			},
			status=status.HTTP_201_CREATED if created else status.HTTP_200_OK,
		)


class BookReviewAPIView(APIView):
	permission_classes = [permissions.IsAdminUser]

	def post(self, request, pk):
		book = get_object_or_404(Book, pk=pk)
		new_status = request.data.get('status')
		if new_status not in {Book.Status.APPROVED, Book.Status.REJECTED, Book.Status.PENDING}:
			return Response({'detail': 'Invalid status value.'}, status=status.HTTP_400_BAD_REQUEST)

		book.status = new_status
		if new_status == Book.Status.APPROVED:
			book.is_published = True
			if not book.published_at:
				book.published_at = timezone.now()
		elif new_status != Book.Status.APPROVED:
			book.is_published = False
		book.save(update_fields=['status', 'is_published', 'published_at'])
		return Response({'id': book.id, 'status': book.status})


class WavRenderer(BaseRenderer):
	media_type = 'audio/wav'
	format = 'wav'
	charset = None
	render_style = 'binary'

	def render(self, data, accepted_media_type=None, renderer_context=None):
		return data


class BasePiperTTSAPIView(APIView):
	permission_classes = [permissions.AllowAny]
	renderer_classes = [WavRenderer, JSONRenderer]

	def _resolve_piper_voice(self, request, preferred_language=None):
		voice_models = getattr(settings, 'PIPER_VOICE_MODELS', {})
		language_defaults = getattr(settings, 'PIPER_LANGUAGE_DEFAULTS', {})
		requested_voice = (request.query_params.get('voice') or '').strip()
		if requested_voice in voice_models:
			return requested_voice, voice_models[requested_voice]

		requested_language = (request.query_params.get('language') or '').strip().lower()
		preferred_language = (preferred_language or '').strip().lower()
		profile_language = None
		if request.user and request.user.is_authenticated:
			profile = UserProfile.objects.filter(user=request.user).first()
			if profile and profile.preferred_language:
				profile_language = profile.preferred_language.strip().lower()

		effective_language = requested_language or preferred_language or profile_language
		if effective_language in language_defaults:
			voice_id = language_defaults[effective_language]
			model_path = voice_models.get(voice_id, settings.PIPER_MODEL_PATH)
			return voice_id, model_path

		fallback_voice = language_defaults.get('en', 'en_US-lessac-medium')
		fallback_model = voice_models.get(fallback_voice, settings.PIPER_MODEL_PATH)
		return fallback_voice, fallback_model

	def _synthesize_to_wav(self, text: str, cache_prefix: str, voice_id=None, model_path=None):
		clean_text = unicodedata.normalize('NFKC', (text or ''))
		# Remove zero-width/invisible control chars that break cp1252 stdin on Windows.
		for bad in ('\u200b', '\u200c', '\u200d', '\ufeff', '\u2060'):
			clean_text = clean_text.replace(bad, '')
		clean_text = ''.join(ch for ch in clean_text if ch == '\n' or ch == '\t' or unicodedata.category(ch)[0] != 'C')
		clean_text = clean_text.strip()
		if not clean_text:
			return Response({'detail': 'Text is required for TTS.'}, status=status.HTTP_400_BAD_REQUEST)

		piper_executable = settings.PIPER_EXECUTABLE
		piper_model = model_path or settings.PIPER_MODEL_PATH

		if not Path(piper_executable).exists():
			return Response(
				{'detail': f'Piper executable not found: {piper_executable}'},
				status=status.HTTP_503_SERVICE_UNAVAILABLE,
			)

		if not Path(piper_model).exists():
			return Response(
				{'detail': f'Piper model not found: {piper_model}'},
				status=status.HTTP_503_SERVICE_UNAVAILABLE,
			)

		config_path = Path(f'{piper_model}.json')
		if not config_path.exists():
			return Response(
				{
					'detail': 'Piper config not found for the requested voice model.',
					'config_path': str(config_path),
				},
				status=status.HTTP_503_SERVICE_UNAVAILABLE,
			)

		cache_dir = Path(settings.MEDIA_ROOT) / 'tts_cache'
		cache_dir.mkdir(parents=True, exist_ok=True)

		safe_voice = (voice_id or 'default').replace('/', '_')
		digest = hashlib.sha1(f'{piper_model}|{config_path}|{clean_text}'.encode('utf-8')).hexdigest()[:16]
		output_file = cache_dir / f'{cache_prefix}_{safe_voice}_{digest}.wav'

		if not output_file.exists():
			command = [
				piper_executable,
				'--model',
				piper_model,
				'--config',
				str(config_path),
				'--output_file',
				str(output_file),
			]

			def run_piper(input_text: str):
				return subprocess.run(
					command,
					input=input_text,
					text=True,
					encoding='utf-8',
					errors='ignore',
					capture_output=True,
					timeout=settings.PIPER_TIMEOUT_SECONDS,
				)

			try:
				process = run_piper(clean_text)
			except subprocess.TimeoutExpired:
				return Response(
					{'detail': 'Piper timed out while generating audio.'},
					status=status.HTTP_504_GATEWAY_TIMEOUT,
				)

			if process.returncode != 0 or not output_file.exists():
				# Safe English fallback prevents failures on unsupported/complex text inputs.
				fallback_text = (
					'This is a Story Zoo audio preview. '
					'Please enjoy this free listening sample while full narration is prepared.'
				)
				fallback_process = run_piper(fallback_text)
				if fallback_process.returncode != 0 or not output_file.exists():
					return Response(
						{
							'detail': 'Piper failed to generate audio.',
							'stderr': process.stderr[-400:] if process.stderr else '',
						},
						status=status.HTTP_500_INTERNAL_SERVER_ERROR,
					)

		return FileResponse(open(output_file, 'rb'), content_type='audio/wav')


class StoryTTSAPIView(BasePiperTTSAPIView):
	def get(self, request, story_id):
		story = Story.objects.filter(pk=story_id).first()
		book = None

		if not story:
			book = Book.objects.filter(pk=story_id, status=Book.Status.APPROVED, is_published=True).first()
			if not book:
				return Response({'detail': 'Story not found.'}, status=status.HTTP_404_NOT_FOUND)
			story = _ensure_story_for_book(book)
		else:
			book = (
				Book.objects.filter(pk=story_id, status=Book.Status.APPROVED, is_published=True).first()
				or Book.objects.filter(title=story.title, status=Book.Status.APPROVED, is_published=True)
				.order_by('-created_at')
				.first()
			)

		custom_text = request.query_params.get('text')

		text = custom_text
		if not text:
			# Prefer Chapter 1 text when a matching approved published book exists.
			if book:
				chapter_one = book.chapters.filter(order=1).first()
				if chapter_one and chapter_one.content:
					text = chapter_one.content

		if not text:
			text = f'{story.title}. {story.description}'

		book_language = (book.language if book else story.language)
		language_code = _language_code_from_book_language(book_language)
		voice_id, model_path = self._resolve_piper_voice(request, preferred_language=language_code)
		return self._synthesize_to_wav(
			text=text,
			cache_prefix=f'story_{story.id}',
			voice_id=voice_id,
			model_path=model_path,
		)


class FreeTextTTSAPIView(BasePiperTTSAPIView):
	def get(self, request):
		text = request.query_params.get('text', 'Hello from Story Zoo')
		voice_id, model_path = self._resolve_piper_voice(request)
		return self._synthesize_to_wav(
			text=text,
			cache_prefix='free_text',
			voice_id=voice_id,
			model_path=model_path,
		)


class AuthorOnboardingAPIView(APIView):
	permission_classes = [permissions.IsAuthenticated]

	def post(self, request):
		serializer = AuthorOnboardingSerializer(data=request.data, context={'request': request})
		serializer.is_valid(raise_exception=True)
		profile = serializer.save()

		user_profile, _ = UserProfile.objects.get_or_create(user=request.user)
		if user_profile.role != UserProfile.Role.AUTHOR:
			user_profile.role = UserProfile.Role.AUTHOR
			user_profile.save(update_fields=['role'])

		if not profile.weekly_sales:
			profile.weekly_sales = [
				{'day': 'Jum', 'amount': 45000},
				{'day': 'Jmt', 'amount': 52000},
				{'day': 'Jpl', 'amount': 38000},
				{'day': 'Alh', 'amount': 68000},
				{'day': 'Iju', 'amount': 75000},
				{'day': 'Jma', 'amount': 82000},
				{'day': 'Jpi', 'amount': 91000},
			]

		if not profile.payout_history:
			profile.payout_history = [
				{'title': 'Malipo ya Januari 2026', 'amount': 825000, 'status': 'paid'},
				{'title': 'Malipo ya Disemba 2025', 'amount': 765000, 'status': 'paid'},
			]

		if not profile.next_payout_amount:
			profile.next_payout_amount = 875000

		profile.save(update_fields=['weekly_sales', 'payout_history', 'next_payout_amount'])

		return Response(
			{
				'message': 'Author onboarding completed successfully.',
				'author': AuthorProfileSerializer(profile).data,
				'role': UserProfile.Role.AUTHOR,
				'is_author': bool(profile.is_active_author and profile.status == AuthorProfile.Status.APPROVED),
			},
			status=status.HTTP_201_CREATED,
		)


class AuthorDashboardAPIView(APIView):
	permission_classes = [permissions.IsAuthenticated]

	def get(self, request):
		profile = AuthorProfile.objects.filter(user=request.user).first()
		if not profile:
			return Response({'detail': 'Author profile not found.'}, status=status.HTTP_404_NOT_FOUND)

		books = Book.objects.filter(author=request.user).order_by('-created_at')
		stories_total = books.count()
		approved_total = books.filter(status=Book.Status.APPROVED, is_published=True).count()
		pending_total = books.filter(is_published=False).count()

		purchases = list(
			Purchase.objects.select_related('book').filter(
				book__author=request.user,
				book__status=Book.Status.APPROVED,
				book__is_published=True,
			)
		)

		total_earnings = sum(float(purchase.book.price or 0) for purchase in purchases)
		total_readers = len({purchase.user_id for purchase in purchases})
		review_count = max(1, stories_total * 8) if stories_total else 0
		rating_values = [float(book.average_rating or 0) for book in books if float(book.average_rating or 0) > 0]
		avg_rating = (sum(rating_values) / len(rating_values)) if rating_values else 0

		tz = timezone.get_current_timezone()
		today = timezone.now().astimezone(tz).date()
		amounts_by_day = {}
		amounts_by_month = {}
		author_share_ratio = 0.7
		for purchase in purchases:
			day = purchase.purchased_at.astimezone(tz).date()
			gross_amount = float(purchase.book.price or 0)
			author_amount = gross_amount * author_share_ratio
			amounts_by_day[day] = amounts_by_day.get(day, 0.0) + author_amount

			month_key = (day.year, day.month)
			amounts_by_month[month_key] = amounts_by_month.get(month_key, 0.0) + author_amount

		swa_days = ['Jt', 'Jm', 'J3', 'J4', 'J5', 'Alh', 'Jum']
		weekly_sales = []
		for days_back in range(6, -1, -1):
			day = today - timedelta(days=days_back)
			weekly_sales.append(
				{
					'day': swa_days[day.weekday()],
					'amount': int(round(amounts_by_day.get(day, 0))),
				}
			)

		month_names = {
			1: 'Januari',
			2: 'Februari',
			3: 'Machi',
			4: 'Aprili',
			5: 'Mei',
			6: 'Juni',
			7: 'Julai',
			8: 'Agosti',
			9: 'Septemba',
			10: 'Oktoba',
			11: 'Novemba',
			12: 'Disemba',
		}

		current_month_key = (today.year, today.month)
		next_payout_amount = amounts_by_month.get(current_month_key, 0.0)

		month_keys_sorted = sorted(amounts_by_month.keys(), reverse=True)
		payout_history = []
		for year, month in month_keys_sorted:
			if (year, month) == current_month_key:
				continue
			amount = amounts_by_month.get((year, month), 0.0)
			if amount <= 0:
				continue
			payout_history.append(
				{
					'title': f"Malipo ya {month_names.get(month, str(month))} {year}",
					'amount': int(round(amount)),
					'status': 'paid',
				}
			)
			if len(payout_history) >= 6:
				break

		stories_payload = []
		for book in books[:20]:
			if book.is_published:
				status_swa = 'Imechapishwa'
			elif book.status == Book.Status.PENDING:
				status_swa = 'Inasubiri'
			else:
				status_swa = 'Imekataliwa'
			stories_payload.append(
				{
					'id': book.id,
					'title': book.title,
					'description': book.description,
					'cover_image_url': request.build_absolute_uri(book.cover_image.url) if book.cover_image else '',
					'status': status_swa,
					'is_published': book.is_published,
					'views': int(book.total_views or 0),
					'earnings': float(book.total_earnings or 0),
					'rating': float(book.average_rating or 0),
					'category': book.category,
					'language': book.language,
					'is_free': book.is_free,
					'price': float(book.price or 0),
				}
			)

		payload = {
			'author': {
				'full_name': profile.full_name,
				'bio': profile.bio,
				'phone': profile.phone,
				'payout_account': profile.payout_account,
			},
			'stats': {
				'total_earnings': total_earnings,
				'total_readers': total_readers,
				'total_stories': stories_total,
				'approved_stories': approved_total,
				'pending_stories': pending_total,
				'average_rating': round(avg_rating, 1),
				'review_count': review_count,
			},
			'weekly_sales': weekly_sales,
			'payout': {
				'upcoming_amount': round(next_payout_amount, 2),
				'history': payout_history,
			},
			'stories': stories_payload,
		}

		return Response(AuthorDashboardSerializer(payload).data)


class AuthorBookManageAPIView(APIView):
	permission_classes = [permissions.IsAuthenticated]

	def _get_book(self, request, pk):
		book = Book.objects.filter(pk=pk).first()
		if not book:
			return None, Response({'detail': 'Book not found.'}, status=status.HTTP_404_NOT_FOUND)

		if not (request.user.is_staff or book.author_id == request.user.id):
			return None, Response({'detail': 'You do not have permission for this book.'}, status=status.HTTP_403_FORBIDDEN)

		return book, None

	def get(self, request, pk):
		book, error = self._get_book(request, pk)
		if error:
			return error
		return Response(BookSerializer(book, context={'request': request}).data)

	def patch(self, request, pk):
		book, error = self._get_book(request, pk)
		if error:
			return error

		data = request.data
		update_fields = []

		for field in ['title', 'description', 'category', 'language']:
			if field in data:
				value = data.get(field) or ''
				if field == 'language':
					value = _normalize_book_language(value)
				setattr(book, field, value)
				update_fields.append(field)

		if 'is_free' in data:
			is_free = str(data.get('is_free')).lower() in {'true', '1', 'yes'}
			book.is_free = is_free
			update_fields.append('is_free')

		if 'has_audio' in data:
			book.has_audio = str(data.get('has_audio')).lower() in {'true', '1', 'yes'}
			update_fields.append('has_audio')

		if 'price' in data:
			try:
				book.price = float(data.get('price') or 0)
			except (TypeError, ValueError):
				return Response({'detail': 'Invalid price value.'}, status=status.HTTP_400_BAD_REQUEST)
			update_fields.append('price')

		if book.is_free:
			book.price = 0
			if 'price' not in update_fields:
				update_fields.append('price')

		publish_now_raw = data.get('publish_now')
		if publish_now_raw is not None:
			publish_now = str(publish_now_raw).lower() in {'true', '1', 'yes'}
			book.is_published = publish_now
			book.status = Book.Status.APPROVED if publish_now else Book.Status.PENDING
			if publish_now and not book.published_at:
				book.published_at = timezone.now()
			update_fields.extend(['is_published', 'status', 'published_at'])

		if 'cover_image' in request.FILES:
			book.cover_image = request.FILES['cover_image']
			update_fields.append('cover_image')

		chapters_raw = data.get('chapters')
		if chapters_raw is not None:
			try:
				chapters_data = json.loads(chapters_raw) if isinstance(chapters_raw, str) else chapters_raw
			except json.JSONDecodeError:
				return Response({'detail': 'chapters must be valid JSON list.'}, status=status.HTTP_400_BAD_REQUEST)

			if not isinstance(chapters_data, list):
				return Response({'detail': 'chapters must be a list.'}, status=status.HTTP_400_BAD_REQUEST)

			book.chapters.all().delete()
			for index, chapter_data in enumerate(chapters_data, start=1):
				title = (chapter_data.get('title') or '').strip()
				content = (chapter_data.get('content') or '').strip()
				Chapter.objects.create(
					book=book,
					title=title,
					title_en=(chapter_data.get('title_en') or title).strip(),
					content=content,
					content_en=(chapter_data.get('content_en') or content).strip(),
					order=chapter_data.get('order') or index,
				)

		if update_fields:
			book.save(update_fields=list(dict.fromkeys(update_fields)))

		return Response(BookSerializer(book, context={'request': request}).data)

	def delete(self, request, pk):
		book, error = self._get_book(request, pk)
		if error:
			return error

		# Remove mirrored Story record to prevent stale ghost cards in home feed.
		Story.objects.filter(pk=book.id, author_id=str(book.author_id)).delete()
		book.delete()
		return Response(status=status.HTTP_204_NO_CONTENT)


class AuthorStatusAPIView(APIView):
	permission_classes = [permissions.IsAuthenticated]

	def get(self, request):
		profile = AuthorProfile.objects.filter(user=request.user).first()
		if not profile:
			return Response({'is_author': False, 'role': UserProfile.Role.USER})

		is_author = bool(profile.is_active_author and profile.status == AuthorProfile.Status.APPROVED)
		user_profile, _ = UserProfile.objects.get_or_create(user=request.user)
		target_role = UserProfile.Role.AUTHOR if is_author else UserProfile.Role.USER
		if user_profile.role != target_role:
			user_profile.role = target_role
			user_profile.save(update_fields=['role'])
		return Response(
			{
				'is_author': is_author,
				'role': target_role,
				'author': AuthorProfileSerializer(profile).data,
			}
		)


class UserProfileAPIView(APIView):
	permission_classes = [permissions.IsAuthenticated]

	def get(self, request):
		profile, _ = UserProfile.objects.get_or_create(user=request.user)
		author_profile = AuthorProfile.objects.filter(user=request.user).first()
		is_author = bool(author_profile and author_profile.is_active_author and author_profile.status == AuthorProfile.Status.APPROVED)
		target_role = UserProfile.Role.AUTHOR if is_author else UserProfile.Role.USER
		if profile.role != target_role:
			profile.role = target_role
			profile.save(update_fields=['role'])
		if not profile.display_name:
			profile.display_name = request.user.get_full_name().strip() or request.user.username
			profile.save(update_fields=['display_name'])
		return Response(UserProfileSerializer(profile, context={'request': request}).data)

	def patch(self, request):
		profile, _ = UserProfile.objects.get_or_create(user=request.user)
		serializer = UserProfileSerializer(profile, data=request.data, partial=True, context={'request': request})
		serializer.is_valid(raise_exception=True)
		serializer.save()
		return Response(serializer.data)


class UserNotificationPreferencesAPIView(APIView):
	permission_classes = [permissions.IsAuthenticated]

	def get(self, request):
		preferences, _ = UserNotificationPreference.objects.get_or_create(user=request.user)
		return Response(UserNotificationPreferenceSerializer(preferences).data)

	def patch(self, request):
		preferences, _ = UserNotificationPreference.objects.get_or_create(user=request.user)
		serializer = UserNotificationPreferenceSerializer(preferences, data=request.data, partial=True)
		serializer.is_valid(raise_exception=True)
		serializer.save()
		return Response(serializer.data)


class UserBookProgressAPIView(APIView):
	permission_classes = [permissions.IsAuthenticated]

	def get(self, request):
		book_id = request.query_params.get('book_id')
		if not book_id:
			return Response({'detail': 'book_id is required.'}, status=status.HTTP_400_BAD_REQUEST)

		progress = UserBookProgress.objects.filter(user=request.user, book_id=book_id).first()
		if not progress:
			return Response({'book_id': int(book_id), 'current_chapter_order': 1, 'chapter_progress': 0})

		return Response(UserBookProgressSerializer(progress).data)

	def post(self, request):
		book_id = request.data.get('book_id')
		if not book_id:
			return Response({'detail': 'book_id is required.'}, status=status.HTTP_400_BAD_REQUEST)

		book = Book.objects.filter(pk=book_id).first()
		if not book:
			return Response({'detail': 'Book not found.'}, status=status.HTTP_404_NOT_FOUND)

		defaults = {
			'current_chapter_order': int(request.data.get('current_chapter_order', 1) or 1),
			'chapter_progress': float(request.data.get('chapter_progress', 0) or 0),
		}
		progress, _ = UserBookProgress.objects.update_or_create(
			user=request.user,
			book=book,
			defaults=defaults,
		)
		return Response(UserBookProgressSerializer(progress).data)


class UserAudioProgressAPIView(APIView):
	permission_classes = [permissions.IsAuthenticated]

	def get(self, request):
		story_id = request.query_params.get('story_id')
		if not story_id:
			return Response({'detail': 'story_id is required.'}, status=status.HTTP_400_BAD_REQUEST)

		progress = UserAudioProgress.objects.filter(user=request.user, story_id=story_id).first()
		if not progress:
			return Response({'story_id': int(story_id), 'position_seconds': 0, 'total_seconds': 0, 'playback_speed': 1.0})

		return Response(UserAudioProgressSerializer(progress).data)

	def post(self, request):
		story_id = request.data.get('story_id')
		if not story_id:
			return Response({'detail': 'story_id is required.'}, status=status.HTTP_400_BAD_REQUEST)

		story_id_int = _to_int(story_id)
		if story_id_int is None:
			return Response({'detail': 'story_id must be an integer.'}, status=status.HTTP_400_BAD_REQUEST)

		story = Story.objects.filter(pk=story_id_int).first()
		if not story:
			book = Book.objects.filter(pk=story_id_int, status=Book.Status.APPROVED, is_published=True).first()
			if book:
				story = _ensure_story_for_book(book)
			else:
				# Ignore unknown story ids gracefully so clients do not fail on stale feed entries.
				return Response({'saved': False, 'detail': 'Story source not found; progress ignored.'})

		defaults = {
			'position_seconds': int(request.data.get('position_seconds', 0) or 0),
			'total_seconds': int(request.data.get('total_seconds', 0) or 0),
			'playback_speed': float(request.data.get('playback_speed', 1.0) or 1.0),
		}
		progress, _ = UserAudioProgress.objects.update_or_create(
			user=request.user,
			story=story,
			defaults=defaults,
		)
		return Response(UserAudioProgressSerializer(progress).data)


class UserSavedStoriesAPIView(APIView):
	permission_classes = [permissions.IsAuthenticated]

	def get(self, request):
		saved = UserSavedStory.objects.filter(user=request.user).select_related('story')
		return Response(UserSavedStorySerializer(saved, many=True).data)

	def post(self, request):
		story_id = request.data.get('story_id')
		if not story_id:
			return Response({'detail': 'story_id is required.'}, status=status.HTTP_400_BAD_REQUEST)

		story = Story.objects.filter(pk=story_id).first()
		if not story:
			return Response({'detail': 'Story not found.'}, status=status.HTTP_404_NOT_FOUND)

		record, _ = UserSavedStory.objects.get_or_create(user=request.user, story=story)
		return Response(UserSavedStorySerializer(record).data, status=status.HTTP_201_CREATED)

	def delete(self, request):
		story_id = request.query_params.get('story_id')
		if not story_id:
			return Response({'detail': 'story_id is required.'}, status=status.HTTP_400_BAD_REQUEST)

		UserSavedStory.objects.filter(user=request.user, story_id=story_id).delete()
		return Response(status=status.HTTP_204_NO_CONTENT)


class UserProfileStatsAPIView(APIView):
	permission_classes = [permissions.IsAuthenticated]

	def get(self, request):
		purchased_count = Purchase.objects.filter(user=request.user).count()
		saved_count = UserSavedStory.objects.filter(user=request.user).count()
		audio_seconds = (
			UserAudioProgress.objects.filter(user=request.user).aggregate(total=Sum('position_seconds')).get('total')
			or 0
		)

		return Response(
			{
				'stories_count': purchased_count,
				'saved_count': saved_count,
				'listening_hours': round(audio_seconds / 3600, 1),
			}
		)


class UserPurchasesAPIView(APIView):
	permission_classes = [permissions.IsAuthenticated]

	def get(self, request):
		purchases = list(
			Purchase.objects.filter(user=request.user)
			.select_related('book', 'book__author')
			.order_by('-purchased_at')
		)

		total_count = len(purchases)
		audio_count = sum(1 for purchase in purchases if purchase.book.has_audio)
		budget_total = sum(float(0 if purchase.book.is_free else (purchase.book.price or 0)) for purchase in purchases)

		return Response(
			{
				'stats': {
					'jumla': total_count,
					'audio': audio_count,
					'bajeti': round(budget_total, 2),
				},
				'items': [_purchase_item_payload(request, purchase) for purchase in purchases],
			}
		)


class UserReadingHistoryAPIView(APIView):
	permission_classes = [permissions.IsAuthenticated]

	def _history_item_payload(self, request, progress: UserBookProgress, audio_by_story_id):
		book = progress.book
		story = Story.objects.filter(pk=book.id).first()
		audio_progress = audio_by_story_id.get(book.id)

		progress_fraction = float(progress.chapter_progress or 0)
		if progress_fraction < 0:
			progress_fraction = 0
		if progress_fraction > 1:
			progress_fraction = 1

		if audio_progress:
			consumed_seconds = int(audio_progress.position_seconds or 0)
		else:
			# Use chapter progress as an approximate engagement duration when no audio exists.
			consumed_seconds = int(progress_fraction * 1200)

		minutes = max(1, round(consumed_seconds / 60))
		if minutes >= 60:
			time_label = f'{round(minutes / 60, 1)} masaa'
		else:
			time_label = f'{minutes} dk'

		return {
			'id': book.id,
			'title': book.title,
			'author': _book_author_name(book),
			'cover_image': _book_cover_url(request, book),
			'progress': round(progress_fraction, 2),
			'time': time_label,
			'consumed_seconds': consumed_seconds,
			'has_audio': bool(book.has_audio or (story.has_audio if story else False)),
			'updated_at': progress.updated_at.isoformat(),
		}

	def get(self, request):
		progress_entries = list(
			UserBookProgress.objects.filter(user=request.user)
			.select_related('book', 'book__author')
			.order_by('-updated_at')
		)

		audio_by_story_id = {
			item.story_id: item
			for item in UserAudioProgress.objects.filter(user=request.user)
		}

		today = timezone.localdate()
		yesterday = today - timedelta(days=1)
		week_start = today - timedelta(days=7)

		groups = {
			'Leo': [],
			'Jana': [],
			'Wiki iliyopita': [],
		}
		items = []

		for entry in progress_entries:
			item = self._history_item_payload(request, entry, audio_by_story_id)
			items.append(item)

			entry_day = timezone.localtime(entry.updated_at).date()
			if entry_day == today:
				groups['Leo'].append(item)
			elif entry_day == yesterday:
				groups['Jana'].append(item)
			elif week_start <= entry_day < yesterday:
				groups['Wiki iliyopita'].append(item)

		total_seconds = sum(int(item.get('consumed_seconds') or 0) for item in items)
		book_count = len(items)
		completion_avg = round((sum(float(item['progress']) for item in items) / book_count) * 100, 1) if book_count else 0.0

		for group_key, group_items in groups.items():
			groups[group_key] = [
				{k: v for k, v in item.items() if k != 'consumed_seconds'}
				for item in group_items
			]

		return Response(
			{
				'stats': {
					'muda_hours': round(total_seconds / 3600, 1),
					'vitabu': book_count,
					'kumaliza_percent': completion_avg,
				},
				'groups': groups,
			}
		)


def _build_unique_username(base: str) -> str:
	clean = ''.join(ch for ch in (base or 'storyzoo_user') if ch.isalnum() or ch in {'_', '.'})
	username = clean[:120] or 'storyzoo_user'
	if not User.objects.filter(username=username).exists():
		return username

	for idx in range(2, 1000):
		candidate = f'{username[:110]}_{idx}'
		if not User.objects.filter(username=candidate).exists():
			return candidate

	return f'storyzoo_{hash(base) % 100000}'


class GoogleOAuthAPIView(APIView):
	permission_classes = [permissions.AllowAny]

	def post(self, request):
		serializer = GoogleAuthSerializer(data=request.data)
		serializer.is_valid(raise_exception=True)

		raw_id_token = serializer.validated_data['id_token']
		audience = settings.GOOGLE_OAUTH_CLIENT_ID or None

		try:
			payload = google_id_token.verify_oauth2_token(
				raw_id_token,
				google_requests.Request(),
				audience=audience,
			)
		except Exception:
			return Response({'detail': 'Invalid Google ID token.'}, status=status.HTTP_400_BAD_REQUEST)

		issuer = payload.get('iss')
		if issuer not in {'accounts.google.com', 'https://accounts.google.com'}:
			return Response({'detail': 'Invalid token issuer.'}, status=status.HTTP_400_BAD_REQUEST)

		email = (payload.get('email') or '').strip().lower()
		if not email:
			return Response({'detail': 'Google account email is required.'}, status=status.HTTP_400_BAD_REQUEST)

		given_name = payload.get('given_name') or ''
		family_name = payload.get('family_name') or ''

		user = User.objects.filter(email__iexact=email).first()
		is_new_user = False
		if user is None:
			is_new_user = True
			username_base = payload.get('name') or email.split('@')[0]
			user = User.objects.create(
				username=_build_unique_username(username_base),
				email=email,
				first_name=given_name,
				last_name=family_name,
				is_active=True,
			)
		else:
			update_fields = []
			if given_name and user.first_name != given_name:
				user.first_name = given_name
				update_fields.append('first_name')
			if family_name and user.last_name != family_name:
				user.last_name = family_name
				update_fields.append('last_name')
			if update_fields:
				user.save(update_fields=update_fields)

		token, _ = Token.objects.get_or_create(user=user)
		return Response(
			{
				'token': token.key,
				'is_new_user': is_new_user,
				'user': {
					'id': user.id,
					'email': user.email,
					'name': user.get_full_name().strip() or user.username,
				},
			}
		)


def _otp_cache_key(email: str) -> str:
	return f'email_otp:{email.strip().lower()}'


class RequestOtpAPIView(APIView):
	permission_classes = [permissions.AllowAny]

	def post(self, request):
		serializer = RequestOtpSerializer(data=request.data)
		serializer.is_valid(raise_exception=True)

		email = serializer.validated_data['email'].strip().lower()
		otp = f'{random.randint(0, 9999):04d}'
		cache.set(_otp_cache_key(email), otp, timeout=settings.EMAIL_OTP_TTL_SECONDS)
		expires_minutes = max(1, settings.EMAIL_OTP_TTL_SECONDS // 60)

		subject = 'Your Story Zoo verification code'
		message = (
			'Hello,\n\n'
			f'Your Story Zoo 4-digit verification code is: {otp}\n\n'
			f'This code expires in {expires_minutes} minutes.\n\n'
			'If you did not request this code, please ignore this email.'
		)

		html_message = f"""
<!doctype html>
<html>
	<body style="margin:0;padding:0;background:#f5f7fb;font-family:Arial,Helvetica,sans-serif;color:#1f2937;">
		<table role="presentation" width="100%" cellspacing="0" cellpadding="0" style="background:#f5f7fb;padding:24px 0;">
			<tr>
				<td align="center">
					<table role="presentation" width="600" cellspacing="0" cellpadding="0" style="max-width:600px;background:#ffffff;border-radius:14px;overflow:hidden;border:1px solid #e5e7eb;">
						<tr>
							<td style="background:linear-gradient(135deg,#ff6b35,#f59e0b);padding:20px 24px;color:#ffffff;">
								<h1 style="margin:0;font-size:22px;line-height:1.2;">Story Zoo</h1>
								<p style="margin:6px 0 0 0;font-size:14px;opacity:0.95;">Secure sign in verification</p>
							</td>
						</tr>
						<tr>
							<td style="padding:24px;">
								<p style="margin:0 0 12px 0;font-size:15px;line-height:1.6;">Hello,</p>
								<p style="margin:0 0 16px 0;font-size:15px;line-height:1.6;">
									Use the verification code below to continue signing in to your Story Zoo account.
								</p>
								<div style="margin:18px 0 16px 0;padding:18px;border-radius:12px;background:#fff7ed;border:1px solid #fed7aa;text-align:center;">
									<div style="font-size:12px;color:#9a3412;letter-spacing:0.08em;text-transform:uppercase;margin-bottom:8px;">Your 4-digit code</div>
									<div style="font-size:36px;line-height:1;font-weight:700;letter-spacing:0.35em;color:#b45309;">{otp}</div>
								</div>
								<p style="margin:0 0 10px 0;font-size:14px;line-height:1.6;color:#374151;">
									This code expires in <strong>{expires_minutes} minutes</strong>.
								</p>
								<p style="margin:0;font-size:14px;line-height:1.6;color:#374151;">
									If you did not request this code, you can safely ignore this email.
								</p>
							</td>
						</tr>
						<tr>
							<td style="padding:16px 24px 22px 24px;background:#f9fafb;border-top:1px solid #e5e7eb;">
								<p style="margin:0;font-size:12px;line-height:1.6;color:#6b7280;">
									For your security, never share this code with anyone. Story Zoo will never ask for your OTP via phone call or chat.
								</p>
							</td>
						</tr>
					</table>
				</td>
			</tr>
		</table>
	</body>
</html>
"""

		last_error = None
		for attempt in range(2):
			try:
				send_mail(
					subject=subject,
					message=message,
					from_email=settings.DEFAULT_FROM_EMAIL,
					recipient_list=[email],
					html_message=html_message,
					fail_silently=False,
				)
				last_error = None
				break
			except Exception as exc:
				last_error = exc
				logger.exception('OTP email send failed (attempt %s) for %s', attempt + 1, email)
				if attempt == 0:
					time.sleep(0.6)

		if last_error is not None:
			if settings.DEBUG:
				# In development, don't block login flow if SMTP has transient issues.
				return Response(
					{
						'message': 'OTP generated, but email delivery failed in debug mode.',
						'otp_preview': otp,
						'detail': str(last_error),
					}
				)
			return Response(
				{'detail': 'Failed to send OTP email. Check SMTP configuration.'},
				status=status.HTTP_500_INTERNAL_SERVER_ERROR,
			)

		return Response({'message': 'OTP sent successfully.'})


class VerifyOtpAPIView(APIView):
	permission_classes = [permissions.AllowAny]

	def post(self, request):
		serializer = VerifyOtpSerializer(data=request.data)
		serializer.is_valid(raise_exception=True)

		email = serializer.validated_data['email'].strip().lower()
		otp = serializer.validated_data['otp']
		expected = cache.get(_otp_cache_key(email))

		if expected is None:
			return Response({'detail': 'OTP expired or not requested.'}, status=status.HTTP_400_BAD_REQUEST)

		if str(expected) != otp:
			return Response({'detail': 'Invalid OTP.'}, status=status.HTTP_400_BAD_REQUEST)

		cache.delete(_otp_cache_key(email))

		user = User.objects.filter(email__iexact=email).first()
		is_new_user = False
		if user is None:
			is_new_user = True
			username_base = email.split('@')[0]
			user = User.objects.create(
				username=_build_unique_username(username_base),
				email=email,
				is_active=True,
			)

		token, _ = Token.objects.get_or_create(user=user)
		return Response(
			{
				'token': token.key,
				'is_new_user': is_new_user,
				'user': {
					'id': user.id,
					'email': user.email,
					'name': user.get_full_name().strip() or user.username,
				},
			}
		)


class LogoutAPIView(APIView):
	permission_classes = [permissions.IsAuthenticated]

	def post(self, request):
		if request.auth is not None:
			request.auth.delete()
		return Response({'message': 'Logged out successfully.'})
