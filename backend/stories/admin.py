from django.contrib import admin

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


@admin.register(Story)
class StoryAdmin(admin.ModelAdmin):
	list_display = ('id', 'title', 'author', 'category', 'is_published', 'published_at')
	list_filter = ('is_published', 'category', 'has_audio')
	search_fields = ('title', 'author', 'description')


class ChapterInline(admin.TabularInline):
	model = Chapter
	extra = 1


@admin.register(Book)
class BookAdmin(admin.ModelAdmin):
	list_display = ('id', 'title', 'author', 'category', 'price', 'status', 'created_at')
	list_filter = ('status', 'category')
	search_fields = ('title', 'author__username', 'description')
	inlines = [ChapterInline]


@admin.register(Purchase)
class PurchaseAdmin(admin.ModelAdmin):
	list_display = ('id', 'user', 'book', 'purchased_at')
	list_filter = ('purchased_at',)
	search_fields = ('user__username', 'book__title')


@admin.register(Chapter)
class ChapterAdmin(admin.ModelAdmin):
	list_display = ('id', 'book', 'order', 'title')
	list_filter = ('book',)
	search_fields = ('title', 'book__title')


@admin.register(AuthorProfile)
class AuthorProfileAdmin(admin.ModelAdmin):
	list_display = ('id', 'user', 'full_name', 'phone', 'status', 'is_active_author', 'updated_at')
	list_filter = ('status', 'is_active_author')
	search_fields = ('full_name', 'phone', 'bio', 'payout_account', 'user__email', 'user__username')


@admin.register(UserProfile)
class UserProfileAdmin(admin.ModelAdmin):
	list_display = ('id', 'user', 'display_name', 'preferred_language', 'theme_mode', 'updated_at')
	search_fields = ('user__email', 'user__username', 'display_name')


@admin.register(UserBookProgress)
class UserBookProgressAdmin(admin.ModelAdmin):
	list_display = ('id', 'user', 'book', 'current_chapter_order', 'chapter_progress', 'updated_at')
	search_fields = ('user__email', 'book__title')


@admin.register(UserAudioProgress)
class UserAudioProgressAdmin(admin.ModelAdmin):
	list_display = ('id', 'user', 'story', 'position_seconds', 'total_seconds', 'playback_speed', 'updated_at')
	search_fields = ('user__email', 'story__title')


@admin.register(UserSavedStory)
class UserSavedStoryAdmin(admin.ModelAdmin):
	list_display = ('id', 'user', 'story', 'created_at')
	search_fields = ('user__email', 'story__title')


@admin.register(UserNotificationPreference)
class UserNotificationPreferenceAdmin(admin.ModelAdmin):
	list_display = (
		'id',
		'user',
		'push_notifications',
		'email_notifications',
		'new_stories',
		'promotions',
		'comments',
		'likes',
		'updated_at',
	)
	search_fields = ('user__email', 'user__username')
