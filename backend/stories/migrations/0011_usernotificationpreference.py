from django.conf import settings
from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('stories', '0010_book_has_audio_book_is_free_book_is_published_and_more'),
        migrations.swappable_dependency(settings.AUTH_USER_MODEL),
    ]

    operations = [
        migrations.CreateModel(
            name='UserNotificationPreference',
            fields=[
                ('id', models.BigAutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('push_notifications', models.BooleanField(default=True)),
                ('email_notifications', models.BooleanField(default=False)),
                ('new_stories', models.BooleanField(default=True)),
                ('promotions', models.BooleanField(default=True)),
                ('author_updates', models.BooleanField(default=False)),
                ('comments', models.BooleanField(default=True)),
                ('likes', models.BooleanField(default=False)),
                ('sound_effects', models.BooleanField(default=True)),
                ('vibration', models.BooleanField(default=True)),
                ('updated_at', models.DateTimeField(auto_now=True)),
                ('user', models.OneToOneField(on_delete=models.deletion.CASCADE, related_name='notification_preferences', to=settings.AUTH_USER_MODEL)),
            ],
            options={
                'ordering': ['-updated_at'],
            },
        ),
    ]
