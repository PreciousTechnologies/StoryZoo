# Generated manually for user-isolated normal user data

import django.db.models.deletion
from django.conf import settings
from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('stories', '0004_authorprofile_user_email_identity'),
        migrations.swappable_dependency(settings.AUTH_USER_MODEL),
    ]

    operations = [
        migrations.SeparateDatabaseAndState(
            state_operations=[
                migrations.CreateModel(
                    name='UserProfile',
                    fields=[
                        ('id', models.BigAutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                        ('display_name', models.CharField(blank=True, max_length=255)),
                        ('avatar_url', models.URLField(blank=True)),
                        ('preferred_language', models.CharField(default='sw', max_length=16)),
                        ('theme_mode', models.CharField(default='light', max_length=16)),
                        ('created_at', models.DateTimeField(auto_now_add=True)),
                        ('updated_at', models.DateTimeField(auto_now=True)),
                        ('user', models.OneToOneField(on_delete=django.db.models.deletion.CASCADE, related_name='profile', to=settings.AUTH_USER_MODEL)),
                    ],
                    options={
                        'ordering': ['-updated_at'],
                    },
                ),
            ],
            database_operations=[],
        ),
        migrations.AddField(
            model_name='userprofile',
            name='theme_mode',
            field=models.CharField(default='light', max_length=16),
        ),
        migrations.CreateModel(
            name='UserAudioProgress',
            fields=[
                ('id', models.BigAutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('position_seconds', models.PositiveIntegerField(default=0)),
                ('total_seconds', models.PositiveIntegerField(default=0)),
                ('playback_speed', models.FloatField(default=1.0)),
                ('updated_at', models.DateTimeField(auto_now=True)),
                ('story', models.ForeignKey(on_delete=django.db.models.deletion.CASCADE, related_name='audio_progress', to='stories.story')),
                ('user', models.ForeignKey(on_delete=django.db.models.deletion.CASCADE, related_name='audio_progress', to=settings.AUTH_USER_MODEL)),
            ],
            options={
                'ordering': ['-updated_at'],
                'constraints': [models.UniqueConstraint(fields=('user', 'story'), name='unique_user_story_audio_progress')],
            },
        ),
        migrations.CreateModel(
            name='UserBookProgress',
            fields=[
                ('id', models.BigAutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('current_chapter_order', models.PositiveIntegerField(default=1)),
                ('chapter_progress', models.FloatField(default=0)),
                ('updated_at', models.DateTimeField(auto_now=True)),
                ('book', models.ForeignKey(on_delete=django.db.models.deletion.CASCADE, related_name='user_progress', to='stories.book')),
                ('user', models.ForeignKey(on_delete=django.db.models.deletion.CASCADE, related_name='book_progress', to=settings.AUTH_USER_MODEL)),
            ],
            options={
                'ordering': ['-updated_at'],
                'constraints': [models.UniqueConstraint(fields=('user', 'book'), name='unique_user_book_progress')],
            },
        ),
        migrations.CreateModel(
            name='UserSavedStory',
            fields=[
                ('id', models.BigAutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('created_at', models.DateTimeField(auto_now_add=True)),
                ('story', models.ForeignKey(on_delete=django.db.models.deletion.CASCADE, related_name='saved_by_users', to='stories.story')),
                ('user', models.ForeignKey(on_delete=django.db.models.deletion.CASCADE, related_name='saved_stories', to=settings.AUTH_USER_MODEL)),
            ],
            options={
                'ordering': ['-created_at'],
                'constraints': [models.UniqueConstraint(fields=('user', 'story'), name='unique_user_saved_story')],
            },
        ),
    ]
