from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('stories', '0006_sync_userprofile_legacy_fields'),
    ]

    operations = [
        migrations.AddField(
            model_name='userprofile',
            name='avatar_image',
            field=models.ImageField(blank=True, null=True, upload_to='profiles/avatars/'),
        ),
    ]
