# Story Zoo - Setup & Run Guide

## 📋 Prerequisites

Before running the app, ensure you have:

- **Flutter SDK** (>=3.0.0) - [Install Flutter](https://flutter.dev/docs/get-started/install)
- **Dart SDK** (included with Flutter)
- **Android Studio** or **VS Code** with Flutter extensions
- **Android Emulator** or **Physical Device** for testing

## 🚀 Quick Start

### 1. Install Dependencies

```bash
cd /home/mzaliwa/Desktop/StoryZoo
flutter pub get
```

### 2. Add Font Files (Optional but Recommended)

Download the Poppins font family from [Google Fonts](https://fonts.google.com/specimen/Poppins) and add these files to `assets/fonts/`:

- `Poppins-Regular.ttf`
- `Poppins-Medium.ttf`
- `Poppins-SemiBold.ttf`
- `Poppins-Bold.ttf`

**Note:** The app will work without custom fonts, using the system default instead.

### 3. Run the App

```bash
# Check connected devices
flutter devices

# Run on connected device/emulator
flutter run

# Or run in debug mode with hot reload
flutter run -d <device-id>
```

## 📁 Project Structure

```
lib/
├── core/                      # Core utilities and configuration
│   ├── constants/
│   │   ├── app_colors.dart   # Color palette
│   │   └── app_constants.dart # App-wide constants
│   └── theme/
│       └── app_theme.dart    # Theme configuration
├── features/                  # Feature-based modules
│   ├── welcome/
│   │   └── welcome_screen.dart
│   └── home/
│       └── home_screen.dart
├── models/                    # Data models
│   └── story.dart
├── shared/                    # Shared widgets
│   └── widgets/
│       ├── glassmorphic_container.dart
│       ├── neumorphic_widgets.dart
│       └── clay_widgets.dart
└── main.dart                  # App entry point
```

## 🎨 Design System

### Color Palette

The app uses a warm, savanna-inspired color scheme:

- **Primary**: Sunset oranges (`#FF6B35`, `#E63946`)
- **Secondary**: Savanna greens (`#2D6A4F`, `#74C69D`)
- **Neutrals**: Earth tones (`#F4E4C1`, `#D4A574`)
- **Clay Colors**: Soft pastels for child UI

### Custom Widgets

1. **GlassmorphicContainer** - Frosted glass effect with blur
2. **NeumorphicButton/Card** - 3D extruded components with dual shadows
3. **ClayContainer/Button** - Soft, clay-like 3D effects

## 🔧 Build Commands

### Debug Build
```bash
flutter build apk --debug
```

### Release Build
```bash
flutter build apk --release
flutter build appbundle --release  # For Play Store
```

### iOS Build (macOS only)
```bash
flutter build ios --release
```

## 🧪 Testing

```bash
# Run all tests
flutter test

# Run with coverage
flutter test --coverage
```

## 📱 Screens Implemented

### ✅ Welcome Screen
- Glassmorphic logo container
- Animated background with floating elements
- Neumorphic "Get Started" button
- Glass "Login" button

### ✅ Home Library Screen
- Featured stories carousel with 3D effect
- Category filter chips (glassmorphism)
- Story grid with neumorphic cards
- Bottom navigation bar (glass effect)

## 🔜 Next Steps

To complete the app, you'll need to implement:

1. **Story Details Screen** - CustomScrollView with SliverAppBar
2. **Audiobook Player** - Rotating cover, neumorphic controls
3. **Author Dashboard** - Statistics cards, upload functionality
4. **Child UI** - Simplified, colorful interface with clay components
5. **Authentication** - Login/Register screens
6. **Backend Integration** - Set your API base URL via `--dart-define API_BASE_URL=http://<YOUR_LAN_IP>:8000`

	Auth endpoints available:

	- `POST /api/auth/google/` — body: `{ "id_token": "<google-id-token>" }` → response: `{ "token": "..." }`
	- `POST /auth/request-otp` — body: `{ "email": "user@example.com" }` (legacy flow)
	- `POST /auth/verify-otp`  — body: `{ "email": "user@example.com", "otp": "123456" }` (legacy flow)

## 🔐 Google OAuth2 Setup

1. Create OAuth client IDs in Google Cloud Console (or Firebase Auth):
	- Android client ID for app sign-in
	- Web client ID (used as `serverClientId` and backend audience)
2. Set backend env variable in `backend/.env`:
	- `GOOGLE_OAUTH_CLIENT_ID=<YOUR_WEB_CLIENT_ID>`
3. Run backend migrations (for token auth table):

```bash
cd backend
python manage.py migrate
```

4. Run Flutter app with Google web client id:

```bash
flutter run \
  --dart-define API_BASE_URL=http://<YOUR_LAN_IP>:8000 \
  --dart-define GOOGLE_WEB_CLIENT_ID=<YOUR_WEB_CLIENT_ID>
```

5. Restart Django server after changing `.env`.
## 🐛 Troubleshooting

### "Package not found" errors
```bash
flutter clean
flutter pub get
```

### Build errors
```bash
flutter doctor
flutter doctor --android-licenses  # Accept Android licenses
```

### Hot reload not working
- Press `R` in terminal to hot reload
- Press `Shift + R` for hot restart

## 📚 Resources

- [Flutter Documentation](https://flutter.dev/docs)
- [Dart Language Tour](https://dart.dev/guides/language/language-tour)
- [Material Design](https://material.io/design)
- [Glassmorphism UI](https://pub.dev/packages/glassmorphism_ui)

## 🎯 Features Overview

- ✅ Beautiful UI with multiple design styles
- ✅ Smooth animations and transitions
- ✅ Responsive layout
- ✅ Material Design 3
- ⏳ Backend integration (pending)
- ⏳ Audio playback (pending)
- ⏳ Offline support (pending)
- ⏳ Payment integration (pending)

## 💡 Tips

1. **Hot Reload**: Use `r` for quick UI updates during development
2. **DevTools**: Run `flutter pub global activate devtools` for debugging tools
3. **Performance**: Use `flutter run --profile` to test performance
4. **Widgets Inspector**: Enable in IDE to inspect widget tree

## 📞 Support

For issues or questions:
- Check Flutter documentation
- Review code comments
- Consult the project's comprehensive design document

---

**Happy Coding! 🎉**

Built with ❤️ using Flutter
