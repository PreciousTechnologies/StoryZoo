from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('stories', '0012_sync_book_translation_fields'),
    ]

    operations = [
        migrations.SeparateDatabaseAndState(
            database_operations=[
                migrations.RunSQL(
                    sql=(
                        "ALTER TABLE stories_story "
                        "ADD COLUMN IF NOT EXISTS title_en varchar(255) NOT NULL DEFAULT '';"
                    ),
                    reverse_sql="ALTER TABLE stories_story DROP COLUMN IF EXISTS title_en;",
                ),
                migrations.RunSQL(
                    sql=(
                        "ALTER TABLE stories_story "
                        "ADD COLUMN IF NOT EXISTS description_en text NOT NULL DEFAULT '';"
                    ),
                    reverse_sql="ALTER TABLE stories_story DROP COLUMN IF EXISTS description_en;",
                ),
                migrations.RunSQL(
                    sql=(
                        "ALTER TABLE stories_chapter "
                        "ADD COLUMN IF NOT EXISTS title_en varchar(255) NOT NULL DEFAULT '';"
                    ),
                    reverse_sql="ALTER TABLE stories_chapter DROP COLUMN IF EXISTS title_en;",
                ),
                migrations.RunSQL(
                    sql=(
                        "ALTER TABLE stories_chapter "
                        "ADD COLUMN IF NOT EXISTS content_en text NOT NULL DEFAULT '';"
                    ),
                    reverse_sql="ALTER TABLE stories_chapter DROP COLUMN IF EXISTS content_en;",
                ),
                migrations.RunSQL(
                    sql=(
                        "UPDATE stories_story "
                        "SET title_en = COALESCE(NULLIF(title_en, ''), title), "
                        "description_en = COALESCE(NULLIF(description_en, ''), description);"
                    ),
                    reverse_sql=migrations.RunSQL.noop,
                ),
                migrations.RunSQL(
                    sql=(
                        "UPDATE stories_chapter "
                        "SET title_en = COALESCE(NULLIF(title_en, ''), title), "
                        "content_en = COALESCE(NULLIF(content_en, ''), content);"
                    ),
                    reverse_sql=migrations.RunSQL.noop,
                ),
            ],
            state_operations=[
                migrations.AddField(
                    model_name='story',
                    name='title_en',
                    field=models.CharField(blank=True, default='', max_length=255),
                ),
                migrations.AddField(
                    model_name='story',
                    name='description_en',
                    field=models.TextField(blank=True, default=''),
                ),
                migrations.AddField(
                    model_name='chapter',
                    name='title_en',
                    field=models.CharField(blank=True, default='', max_length=255),
                ),
                migrations.AddField(
                    model_name='chapter',
                    name='content_en',
                    field=models.TextField(blank=True, default=''),
                ),
            ],
        ),
    ]
