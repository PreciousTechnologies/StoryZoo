# Story Zoo

A digital storytelling platform for Kiswahili literature.

## Features

- Interactive reading and listening experience
- Glassmorphism, Neumorphism, and Claymorphism UI design
- Multiple user roles (Reader, Child, Parent, Author, Narrator, Admin)
- Offline story access
- Audio narration support
- Author monetization platform

## Getting Started

### Prerequisites

- Flutter SDK (>=3.0.0)
- Dart SDK
- Android Studio / Xcode

### Installation

```bash
flutter pub get
flutter run
```

## Project Structure

```
lib/
├── core/           # Core utilities, constants, themes
├── features/       # Feature-based modules
├── models/         # Data models
├── services/       # API and business logic services
├── shared/         # Shared widgets and components
└── main.dart       # App entry point
```

## Tech Stack

- **Frontend**: Flutter (Dart)
- **Frontend**: Flutter (Dart)
- **Backend**: Not included (frontend-only). To enable auth and server features, provide a REST API and set `AppConstants.apiBaseUrl` in `lib/core/constants/app_constants.dart`.

	Required auth endpoints (example):
	- `POST /auth/request-otp`  — body: `{ "email": "user@example.com" }`
	- `POST /auth/verify-otp`   — body: `{ "email": "user@example.com", "otp": "123456" }` → response: `{ "token": "..." }`
	- `POST /auth/logout`       — header: `Authorization: Bearer <token>`
- **State Management**: Provider
