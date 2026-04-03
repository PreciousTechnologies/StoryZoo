from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('stories', '0007_userprofile_avatar_image'),
    ]

    operations = [
        migrations.AddField(
            model_name='authorprofile',
            name='next_payout_amount',
            field=models.DecimalField(decimal_places=2, default=0, max_digits=12),
        ),
        migrations.AddField(
            model_name='authorprofile',
            name='payout_history',
            field=models.JSONField(blank=True, default=list),
        ),
        migrations.AddField(
            model_name='authorprofile',
            name='weekly_sales',
            field=models.JSONField(blank=True, default=list),
        ),
        migrations.AddField(
            model_name='book',
            name='average_rating',
            field=models.DecimalField(decimal_places=2, default=0, max_digits=3),
        ),
        migrations.AddField(
            model_name='book',
            name='total_earnings',
            field=models.DecimalField(decimal_places=2, default=0, max_digits=12),
        ),
        migrations.AddField(
            model_name='book',
            name='total_views',
            field=models.PositiveIntegerField(default=0),
        ),
    ]
