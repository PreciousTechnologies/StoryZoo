from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('stories', '0008_author_dashboard_fields'),
    ]

    operations = [
        migrations.AddField(
            model_name='userprofile',
            name='role',
            field=models.CharField(choices=[('user', 'User'), ('author', 'Author')], default='user', max_length=20),
        ),
    ]
