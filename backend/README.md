# StoryZoo Django Backend

REST API backend for the StoryZoo Flutter app, built with **Django** and **Django REST Framework**.

## Features

- JWT authentication (register / login / token refresh)
- Story listing with category & search filters
- Story details and creation (authenticated authors)
- Purchase management
- CORS configured to allow the Flutter app to connect

## Quick Start

```bash
# 1. Install dependencies
cd backend
pip install -r requirements.txt

# 2. Apply migrations
python manage.py migrate

# 3. Seed sample data (optional)
python manage.py seed_data

# 4. Start the development server
python manage.py runserver
```

The API will be available at `http://127.0.0.1:8000/`.

## API Endpoints

| Method | Path | Auth | Description |
|--------|------|------|-------------|
| GET | `/api/v1/health/` | None | Health check |
| POST | `/api/v1/auth/register/` | None | Register a new user |
| POST | `/api/v1/auth/login/` | None | Obtain JWT tokens |
| POST | `/api/v1/auth/refresh/` | None | Refresh access token |
| GET/PATCH | `/api/v1/auth/profile/` | JWT | Get/update own profile |
| GET | `/api/v1/stories/` | None | List stories (supports `?category=`, `?search=`, `?featured=true`) |
| GET | `/api/v1/stories/<id>/` | None | Get a single story |
| POST | `/api/v1/stories/create/` | JWT | Create a new story |
| GET | `/api/v1/categories/` | None | List categories |
| POST | `/api/v1/stories/<id>/purchase/` | JWT | Purchase a story |
| GET | `/api/v1/my-purchases/` | JWT | List my purchased stories |

## Admin

After running `seed_data` you can log into the Django admin at `http://127.0.0.1:8000/admin/` with:

- **Username:** `admin`
- **Password:** `admin1234`

## Flutter Connection

The Flutter app's `ApiClient` (`lib/core/services/api_client.dart`) connects to `http://127.0.0.1:8000` by default (configured in `AppConstants.apiBaseUrl`).

> **Physical device:** Replace `127.0.0.1` with your machine's LAN IP in `lib/core/constants/app_constants.dart`.

## Environment Variables

Copy `.env.example` to `.env` and update values before deploying:

```bash
cp .env.example .env
```
