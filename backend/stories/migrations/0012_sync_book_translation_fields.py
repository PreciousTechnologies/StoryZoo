from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('stories', '0011_usernotificationpreference'),
    ]

    operations = [
        migrations.SeparateDatabaseAndState(
            database_operations=[
                migrations.RunSQL(
                    sql=(
                        "ALTER TABLE stories_book "
                        "ADD COLUMN IF NOT EXISTS title_en varchar(255) NOT NULL DEFAULT '';"
                    ),
                    reverse_sql="ALTER TABLE stories_book DROP COLUMN IF EXISTS title_en;",
                ),
                migrations.RunSQL(
                    sql=(
                        "ALTER TABLE stories_book "
                        "ADD COLUMN IF NOT EXISTS description_en text NOT NULL DEFAULT '';"
                    ),
                    reverse_sql="ALTER TABLE stories_book DROP COLUMN IF EXISTS description_en;",
                ),
                migrations.RunSQL(
                    sql=(
                        "UPDATE stories_book "
                        "SET title_en = COALESCE(NULLIF(title_en, ''), title), "
                        "description_en = COALESCE(NULLIF(description_en, ''), description);"
                    ),
                    reverse_sql=migrations.RunSQL.noop,
                ),
            ],
            state_operations=[
                migrations.AddField(
                    model_name='book',
                    name='title_en',
                    field=models.CharField(blank=True, default='', max_length=255),
                ),
                migrations.AddField(
                    model_name='book',
                    name='description_en',
                    field=models.TextField(blank=True, default=''),
                ),
            ],
        ),
    ]
