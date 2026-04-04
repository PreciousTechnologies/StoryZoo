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

## Deploy On Render (Docker)

This repository includes a root `render.yaml` and backend container config:
- `render.yaml`
- `backend/Dockerfile`
- `backend/start.sh`

### What happens at deploy
- Container builds Django + Gunicorn and installs Piper binary.
- On boot, `start.sh` downloads Piper English/Swahili voice models to `/var/data/piper` if missing.
- Django migrations run automatically.
- App starts with Gunicorn on Render's `PORT`.

### Render setup
1. Push this repo to GitHub.
2. In Render, create a Blueprint from the repo root (uses `render.yaml`).
3. Add a PostgreSQL service in Render and set these backend env vars:
	- `POSTGRES_DB`
	- `POSTGRES_USER`
	- `POSTGRES_PASSWORD`
	- `POSTGRES_HOST`
	- `POSTGRES_PORT`
4. Set Django host/origin vars to your Render backend domain:
	- `DJANGO_ALLOWED_HOSTS=your-service.onrender.com`
	- `DJANGO_CSRF_TRUSTED_ORIGINS=https://your-service.onrender.com`
5. Set Pesapal vars (production/live values):
	- `PESAPAL_BASE_URL=https://pay.pesapal.com/v3`
	- `PESAPAL_CONSUMER_KEY=...`
	- `PESAPAL_CONSUMER_SECRET=...`
	- `PESAPAL_CALLBACK_URL=https://your-service.onrender.com/api/payments/callback/`
	- `PESAPAL_IPN_URL=https://your-service.onrender.com/api/payments/ipn/`
	- `PESAPAL_IPN_ID=...`

### Notes
- A persistent disk is mounted at `/var/data` (configured in `render.yaml`) so Piper models are downloaded once and reused.
- If you want different voices, override `PIPER_MODEL_URL_*` and `PIPER_MODEL_CONFIG_URL_*` in Render env vars.
