# StoryZoo Django Backend

This backend replaces Firebase and serves Story data via Django REST API with PostgreSQL.

## Endpoints
- `GET /api/stories/?published=true&limit=50`

## Setup
1. Copy `.env.example` to `.env`.
2. Update PostgreSQL credentials in `.env`.
3. Run migrations and start server:

```bash
cd backend
../.venv/Scripts/python.exe manage.py makemigrations
../.venv/Scripts/python.exe manage.py migrate
../.venv/Scripts/python.exe manage.py runserver
```

## Admin
Create admin user:

```bash
../.venv/Scripts/python.exe manage.py createsuperuser
```

Open `http://127.0.0.1:8000/admin/` and add stories.

## Story fields expected by Flutter
- `is_published` (bool)
- `published_at` (datetime)
- `title`, `description`, `author`, `author_id`, `category`, `cover_image`
- `price`, `rating`, `total_reviews`, `has_audio`

API serializer returns snake_case fields consumed by Flutter.
