# Generated manually for email/account-based author identity

from django.conf import settings
from django.db import migrations, models
import django.db.models.deletion


class Migration(migrations.Migration):

    dependencies = [
        ('stories', '0003_authorprofile'),
        migrations.swappable_dependency(settings.AUTH_USER_MODEL),
    ]

    operations = [
        migrations.AddField(
            model_name='authorprofile',
            name='user',
            field=models.OneToOneField(blank=True, null=True, on_delete=django.db.models.deletion.CASCADE, related_name='author_profile', to=settings.AUTH_USER_MODEL),
        ),
        migrations.AlterField(
            model_name='authorprofile',
            name='phone',
            field=models.CharField(blank=True, max_length=32),
        ),
    ]
