from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('stories', '0005_user_isolated_data_models'),
    ]

    operations = [
        migrations.SeparateDatabaseAndState(
            state_operations=[
                migrations.AddField(
                    model_name='userprofile',
                    name='is_child_mode',
                    field=models.BooleanField(default=False),
                ),
                migrations.AddField(
                    model_name='userprofile',
                    name='onboarding_completed',
                    field=models.BooleanField(default=False),
                ),
            ],
            database_operations=[],
        ),
    ]
