from django.db import models
from django.contrib.auth import get_user_model


User = get_user_model()


class Story(models.Model):
	title = models.CharField(max_length=255)
	title_en = models.CharField(max_length=255, default='', blank=True)
	description = models.TextField()
	description_en = models.TextField(default='', blank=True)
	author = models.CharField(max_length=255)
	author_id = models.CharField(max_length=100)
	category = models.CharField(max_length=120)
	language = models.CharField(max_length=32, default='Kiswahili')
	cover_image = models.URLField(blank=True)
	price = models.DecimalField(max_digits=10, decimal_places=2, default=0)
	rating = models.DecimalField(max_digits=3, decimal_places=2, default=0)
	total_reviews = models.IntegerField(default=0)
	has_audio = models.BooleanField(default=False)
	is_published = models.BooleanField(default=False)
	published_at = models.DateTimeField(null=True, blank=True)
	created_at = models.DateTimeField(auto_now_add=True)
	updated_at = models.DateTimeField(auto_now=True)

	class Meta:
		ordering = ['-published_at', '-created_at']

	def __str__(self):
		return self.title


class Book(models.Model):
	class Status(models.TextChoices):
		PENDING = 'pending', 'Pending'
		APPROVED = 'approved', 'Approved'
		REJECTED = 'rejected', 'Rejected'

	title = models.CharField(max_length=255)
	title_en = models.CharField(max_length=255, default='', blank=True)
	description = models.TextField()
	description_en = models.TextField(default='', blank=True)
	category = models.CharField(max_length=120)
	cover_image = models.ImageField(upload_to='books/covers/', blank=True, null=True)
	price = models.DecimalField(max_digits=10, decimal_places=2, default=0)
	is_free = models.BooleanField(default=False)
	language = models.CharField(max_length=32, default='Kiswahili')
	has_audio = models.BooleanField(default=False)
	is_published = models.BooleanField(default=False)
	published_at = models.DateTimeField(null=True, blank=True)
	total_views = models.PositiveIntegerField(default=0)
	total_earnings = models.DecimalField(max_digits=12, decimal_places=2, default=0)
	average_rating = models.DecimalField(max_digits=3, decimal_places=2, default=0)
	author = models.ForeignKey(User, on_delete=models.CASCADE, related_name='books')
	status = models.CharField(max_length=20, choices=Status.choices, default=Status.PENDING)
	created_at = models.DateTimeField(auto_now_add=True)

	class Meta:
		ordering = ['-created_at']

	def __str__(self):
		return self.title


class Chapter(models.Model):
	book = models.ForeignKey(Book, on_delete=models.CASCADE, related_name='chapters')
	title = models.CharField(max_length=255)
	title_en = models.CharField(max_length=255, default='', blank=True)
	content = models.TextField()
	content_en = models.TextField(default='', blank=True)
	order = models.PositiveIntegerField(default=1)

	class Meta:
		ordering = ['order', 'id']
		constraints = [
			models.UniqueConstraint(fields=['book', 'order'], name='unique_book_chapter_order'),
		]

	def __str__(self):
		return f'{self.book.title} - {self.title}'


class Purchase(models.Model):
	user = models.ForeignKey(User, on_delete=models.CASCADE, related_name='purchases')
	book = models.ForeignKey(Book, on_delete=models.CASCADE, related_name='purchases')
	purchased_at = models.DateTimeField(auto_now_add=True)

	class Meta:
		ordering = ['-purchased_at']
		constraints = [
			models.UniqueConstraint(fields=['user', 'book'], name='unique_user_book_purchase'),
		]

	def __str__(self):
		return f'{self.user_id}:{self.book_id}'


class AuthorProfile(models.Model):
	class Status(models.TextChoices):
		PENDING = 'pending', 'Pending'
		APPROVED = 'approved', 'Approved'
		REJECTED = 'rejected', 'Rejected'

	user = models.OneToOneField(User, on_delete=models.CASCADE, related_name='author_profile', null=True, blank=True)

	full_name = models.CharField(max_length=255)
	bio = models.TextField(blank=True)
	phone = models.CharField(max_length=32, blank=True)
	payout_account = models.CharField(max_length=255, blank=True)
	status = models.CharField(max_length=20, choices=Status.choices, default=Status.APPROVED)
	is_active_author = models.BooleanField(default=True)
	next_payout_amount = models.DecimalField(max_digits=12, decimal_places=2, default=0)
	payout_history = models.JSONField(default=list, blank=True)
	weekly_sales = models.JSONField(default=list, blank=True)
	created_at = models.DateTimeField(auto_now_add=True)
	updated_at = models.DateTimeField(auto_now=True)

	class Meta:
		ordering = ['-updated_at', '-created_at']

	def __str__(self):
		identity = self.user.email if self.user and self.user.email else (self.phone or 'no-contact')
		return f'{self.full_name} ({identity})'


class UserProfile(models.Model):
	class Role(models.TextChoices):
		USER = 'user', 'User'
		AUTHOR = 'author', 'Author'

	user = models.OneToOneField(User, on_delete=models.CASCADE, related_name='profile')
	display_name = models.CharField(max_length=255, blank=True)
	avatar_url = models.URLField(blank=True)
	avatar_image = models.ImageField(upload_to='profiles/avatars/', blank=True, null=True)
	role = models.CharField(max_length=20, choices=Role.choices, default=Role.USER)
	preferred_language = models.CharField(max_length=16, default='sw')
	is_child_mode = models.BooleanField(default=False)
	onboarding_completed = models.BooleanField(default=False)
	theme_mode = models.CharField(max_length=16, default='light')
	created_at = models.DateTimeField(auto_now_add=True)
	updated_at = models.DateTimeField(auto_now=True)

	class Meta:
		ordering = ['-updated_at']

	def __str__(self):
		return self.user.email or self.user.username


class UserBookProgress(models.Model):
	user = models.ForeignKey(User, on_delete=models.CASCADE, related_name='book_progress')
	book = models.ForeignKey(Book, on_delete=models.CASCADE, related_name='user_progress')
	current_chapter_order = models.PositiveIntegerField(default=1)
	chapter_progress = models.FloatField(default=0)
	updated_at = models.DateTimeField(auto_now=True)

	class Meta:
		ordering = ['-updated_at']
		constraints = [
			models.UniqueConstraint(fields=['user', 'book'], name='unique_user_book_progress'),
		]


class UserAudioProgress(models.Model):
	user = models.ForeignKey(User, on_delete=models.CASCADE, related_name='audio_progress')
	story = models.ForeignKey(Story, on_delete=models.CASCADE, related_name='audio_progress')
	position_seconds = models.PositiveIntegerField(default=0)
	total_seconds = models.PositiveIntegerField(default=0)
	playback_speed = models.FloatField(default=1.0)
	updated_at = models.DateTimeField(auto_now=True)

	class Meta:
		ordering = ['-updated_at']
		constraints = [
			models.UniqueConstraint(fields=['user', 'story'], name='unique_user_story_audio_progress'),
		]


class UserSavedStory(models.Model):
	user = models.ForeignKey(User, on_delete=models.CASCADE, related_name='saved_stories')
	story = models.ForeignKey(Story, on_delete=models.CASCADE, related_name='saved_by_users')
	created_at = models.DateTimeField(auto_now_add=True)

	class Meta:
		ordering = ['-created_at']
		constraints = [
			models.UniqueConstraint(fields=['user', 'story'], name='unique_user_saved_story'),
		]


class UserNotificationPreference(models.Model):
	user = models.OneToOneField(User, on_delete=models.CASCADE, related_name='notification_preferences')
	push_notifications = models.BooleanField(default=True)
	email_notifications = models.BooleanField(default=False)
	new_stories = models.BooleanField(default=True)
	promotions = models.BooleanField(default=True)
	author_updates = models.BooleanField(default=False)
	comments = models.BooleanField(default=True)
	likes = models.BooleanField(default=False)
	sound_effects = models.BooleanField(default=True)
	vibration = models.BooleanField(default=True)
	updated_at = models.DateTimeField(auto_now=True)

	class Meta:
		ordering = ['-updated_at']

	def __str__(self):
		return f'notifications:{self.user_id}'
