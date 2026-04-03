import json

from django.utils import timezone
from rest_framework import serializers

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


class StorySerializer(serializers.ModelSerializer):
    published_date = serializers.DateTimeField(source='published_at', read_only=True)

    class Meta:
        model = Story
        fields = [
            'id',
            'title',
            'title_en',
            'description',
            'description_en',
            'author',
            'author_id',
            'category',
            'language',
            'cover_image',
            'price',
            'rating',
            'total_reviews',
            'has_audio',
            'is_published',
            'published_date',
        ]


class ChapterSerializer(serializers.ModelSerializer):
    class Meta:
        model = Chapter
        fields = ['id', 'title', 'title_en', 'content', 'content_en', 'order']


class ChapterCreateSerializer(serializers.ModelSerializer):
    class Meta:
        model = Chapter
        fields = ['title', 'title_en', 'content', 'content_en', 'order']


class BookSerializer(serializers.ModelSerializer):
    author_name = serializers.CharField(source='author.get_full_name', read_only=True)
    author_id = serializers.IntegerField(source='author.id', read_only=True)
    chapters = ChapterSerializer(many=True, read_only=True)
    cover_image_url = serializers.SerializerMethodField()

    class Meta:
        model = Book
        fields = [
            'id',
            'title',
            'title_en',
            'description',
            'description_en',
            'category',
            'language',
            'cover_image',
            'cover_image_url',
            'price',
            'is_free',
            'has_audio',
            'is_published',
            'published_at',
            'total_views',
            'total_earnings',
            'average_rating',
            'author_id',
            'author_name',
            'status',
            'created_at',
            'chapters',
        ]

    def get_cover_image_url(self, obj):
        if not obj.cover_image:
            return ''
        request = self.context.get('request')
        if request is None:
            return obj.cover_image.url
        return request.build_absolute_uri(obj.cover_image.url)


class BookCreateSerializer(serializers.ModelSerializer):
    chapters = ChapterCreateSerializer(many=True, required=False)
    publish_now = serializers.BooleanField(required=False, default=True, write_only=True)

    class Meta:
        model = Book
        fields = [
            'title',
            'title_en',
            'description',
            'description_en',
            'category',
            'language',
            'cover_image',
            'price',
            'is_free',
            'has_audio',
            'publish_now',
            'chapters',
        ]

    def validate_chapters(self, value):
        if isinstance(value, str):
            try:
                parsed = json.loads(value)
            except json.JSONDecodeError:
                raise serializers.ValidationError('chapters must be valid JSON list.')
            if not isinstance(parsed, list):
                raise serializers.ValidationError('chapters must be a list.')
            serializer = ChapterCreateSerializer(data=parsed, many=True)
            serializer.is_valid(raise_exception=True)
            return serializer.validated_data
        return value

    def validate(self, attrs):
        # Multipart/form submissions can send chapters as a JSON string field.
        # In that case DRF may not map it into attrs for nested serializers,
        # so parse it explicitly from the raw payload.
        if not attrs.get('chapters'):
            raw_chapters = self.initial_data.get('chapters')
            if isinstance(raw_chapters, str) and raw_chapters.strip():
                try:
                    parsed = json.loads(raw_chapters)
                except json.JSONDecodeError:
                    raise serializers.ValidationError({'chapters': 'chapters must be valid JSON list.'})
                if not isinstance(parsed, list):
                    raise serializers.ValidationError({'chapters': 'chapters must be a list.'})
                chapter_serializer = ChapterCreateSerializer(data=parsed, many=True)
                chapter_serializer.is_valid(raise_exception=True)
                attrs['chapters'] = chapter_serializer.validated_data

        is_free = attrs.get('is_free', False)
        publish_now = attrs.get('publish_now', True)
        chapters = attrs.get('chapters', [])

        if is_free:
            attrs['price'] = 0
        else:
            price = attrs.get('price')
            if price is None:
                raise serializers.ValidationError({'price': 'Price is required when book is paid.'})
            if float(price) < 0:
                raise serializers.ValidationError({'price': 'Price cannot be negative.'})

        if publish_now and not chapters:
            raise serializers.ValidationError({'chapters': 'Add at least one chapter before publishing.'})

        return attrs

    def validate_language(self, value):
        normalized = (value or '').strip().lower()
        if normalized in {'en', 'eng', 'english'}:
            return 'English'
        if normalized in {'sw', 'swa', 'swahili', 'kiswahili'}:
            return 'Kiswahili'
        raise serializers.ValidationError('Language must be either English or Kiswahili.')

    def create(self, validated_data):
        chapters_data = validated_data.pop('chapters', [])
        publish_now = validated_data.pop('publish_now', True)
        is_published = bool(publish_now)

        # Keep english fields non-null even when client submits only one language.
        title = (validated_data.get('title') or '').strip()
        description = (validated_data.get('description') or '').strip()
        validated_data['title_en'] = (validated_data.get('title_en') or title).strip()
        validated_data['description_en'] = (validated_data.get('description_en') or description).strip()

        book = Book.objects.create(
            author=self.context['request'].user,
            status=Book.Status.APPROVED if is_published else Book.Status.PENDING,
            is_published=is_published,
            published_at=timezone.now() if is_published else None,
            **validated_data,
        )

        for index, chapter_data in enumerate(chapters_data, start=1):
            order = chapter_data.get('order') or index
            chapter_title = (chapter_data.get('title') or '').strip()
            chapter_content = (chapter_data.get('content') or '').strip()
            Chapter.objects.create(
                book=book,
                title=chapter_title,
                title_en=(chapter_data.get('title_en') or chapter_title).strip(),
                content=chapter_content,
                content_en=(chapter_data.get('content_en') or chapter_content).strip(),
                order=order,
            )
        return book


class PurchaseSerializer(serializers.ModelSerializer):
    class Meta:
        model = Purchase
        fields = ['id', 'user', 'book', 'purchased_at']
        read_only_fields = ['id', 'user', 'purchased_at']


class AuthorProfileSerializer(serializers.ModelSerializer):
    user_id = serializers.IntegerField(source='user.id', read_only=True)
    email = serializers.EmailField(source='user.email', read_only=True)

    class Meta:
        model = AuthorProfile
        fields = [
            'id',
            'user_id',
            'email',
            'full_name',
            'bio',
            'phone',
            'payout_account',
            'status',
            'is_active_author',
            'next_payout_amount',
            'payout_history',
            'weekly_sales',
            'created_at',
            'updated_at',
        ]
        read_only_fields = ['id', 'status', 'is_active_author', 'created_at', 'updated_at']


class AuthorOnboardingSerializer(serializers.ModelSerializer):
    class Meta:
        model = AuthorProfile
        fields = ['full_name', 'bio', 'phone', 'payout_account']

    def create(self, validated_data):
        user = self.context['request'].user
        profile, _ = AuthorProfile.objects.update_or_create(
            user=user,
            defaults={
                'full_name': validated_data['full_name'],
                'bio': validated_data.get('bio', ''),
                'phone': validated_data.get('phone', ''),
                'payout_account': validated_data.get('payout_account', ''),
                'status': AuthorProfile.Status.APPROVED,
                'is_active_author': True,
            },
        )
        return profile


class GoogleAuthSerializer(serializers.Serializer):
    id_token = serializers.CharField()


class RequestOtpSerializer(serializers.Serializer):
    email = serializers.EmailField()


class VerifyOtpSerializer(serializers.Serializer):
    email = serializers.EmailField()
    otp = serializers.RegexField(regex=r'^\d{4}$')


class UserProfileSerializer(serializers.ModelSerializer):
    email = serializers.EmailField(source='user.email', read_only=True)
    role = serializers.CharField(read_only=True)
    avatar_image = serializers.ImageField(required=False, allow_null=True, write_only=True)

    class Meta:
        model = UserProfile
        fields = [
            'email',
            'role',
            'display_name',
            'avatar_url',
            'avatar_image',
            'preferred_language',
            'theme_mode',
            'updated_at',
        ]
        read_only_fields = ['email', 'updated_at']

    def update(self, instance, validated_data):
        avatar_image = validated_data.pop('avatar_image', None)
        instance = super().update(instance, validated_data)
        if avatar_image is not None:
            instance.avatar_image = avatar_image
            # Prefer uploaded media over external URL when an image file is provided.
            instance.avatar_url = ''
            instance.save(update_fields=['avatar_image', 'avatar_url', 'updated_at'])
        return instance

    def to_representation(self, instance):
        data = super().to_representation(instance)
        request = self.context.get('request')

        if instance.avatar_image:
            image_url = instance.avatar_image.url
            data['avatar_url'] = request.build_absolute_uri(image_url) if request else image_url

        return data


class UserNotificationPreferenceSerializer(serializers.ModelSerializer):
    class Meta:
        model = UserNotificationPreference
        fields = [
            'push_notifications',
            'email_notifications',
            'new_stories',
            'promotions',
            'author_updates',
            'comments',
            'likes',
            'sound_effects',
            'vibration',
            'updated_at',
        ]
        read_only_fields = ['updated_at']


class UserBookProgressSerializer(serializers.ModelSerializer):
    book_id = serializers.IntegerField(source='book.id')

    class Meta:
        model = UserBookProgress
        fields = ['book_id', 'current_chapter_order', 'chapter_progress', 'updated_at']
        read_only_fields = ['updated_at']


class UserAudioProgressSerializer(serializers.ModelSerializer):
    story_id = serializers.IntegerField(source='story.id')

    class Meta:
        model = UserAudioProgress
        fields = ['story_id', 'position_seconds', 'total_seconds', 'playback_speed', 'updated_at']
        read_only_fields = ['updated_at']


class UserSavedStorySerializer(serializers.ModelSerializer):
    story_id = serializers.IntegerField(source='story.id', read_only=True)
    story_title = serializers.CharField(source='story.title', read_only=True)

    class Meta:
        model = UserSavedStory
        fields = ['story_id', 'story_title', 'created_at']


class AuthorDashboardSerializer(serializers.Serializer):
    author = serializers.DictField()
    stats = serializers.DictField()
    weekly_sales = serializers.ListField(child=serializers.DictField())
    payout = serializers.DictField()
    stories = serializers.ListField(child=serializers.DictField())
