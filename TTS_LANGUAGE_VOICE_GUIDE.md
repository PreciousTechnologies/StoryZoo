# Language-Specific TTS Voice Implementation Guide

## Overview

StoryZoo now uses **language-specific Piper TTS voices** to provide native audio pronunciation for its two supported languages: **Swahili** and **English**.

## Voice Models

| Language | Voice Model | Provider | Gender | Details |
|----------|-------------|----------|--------|---------|
| **Kiswahili** | `sw_CD-lanfrica-medium` | LanAfrica (Rwanda) | - | High-quality Congolese Swahili |
| **English** | `en_US-lessac-medium` | Thorsten (Lessac) | Male | Clear, professional American English |

## Architecture

### 1. **TTSService** (`lib/core/services/tts_service.dart`)
Central service managing voice model configuration and URL building.

**Key Methods:**
- `getVoiceModel(languageCode)` - Returns PiperVoiceModel for language
- `buildStoryTtsUrl(storyId, languageCode)` - Builds API endpoint for story TTS
- `buildTextTtsUrl(text, languageCode)` - Builds API endpoint for text TTS
- `getVoiceDisplayName(languageCode)` - Returns user-friendly voice name

**Voice Configuration:**
```dart
const _voiceModels = {
  'sw': PiperVoiceModel(
    code: 'sw_CD-lanfrica-medium',
    language: 'Kiswahili',
    displayName: 'Kiswahili (sw_CD-lanfrica-medium)',
  ),
  'en': PiperVoiceModel(
    code: 'en_US-lessac-medium',
    language: 'English',
    displayName: 'English (en_US-lessac-medium)',
  ),
};
```

### 2. **Audio Player Integration** (`lib/features/audio_player/audio_player_screen.dart`)
The audio player automatically uses the user's selected language for TTS.

**Implementation Flow:**
```
1. User plays audio story
   ↓
2. _setupAudio() reads AuthProvider.preferredLanguage
   ↓
3. Calls TTSService.buildStoryTtsUrl(storyId, languageCode)
   ↓
4. Backend Django endpoint receives ?voice=sw_CD-lanfrica-medium (or en_US-lessac-medium)
   ↓
5. Piper TTS generates audio in selected language
   ↓
6. Audio is downloaded and played
```

### 3. **Language Selection** (`lib/features/profile/language_screen.dart`)
Language screen now displays:
- Current UI language
- Current app content language
- **Active audio voice model** (new)

**Voice Info Card:**
Shows which voice model is currently active:
- "English (en_US-lessac-medium)" for English
- "Kiswahili (sw_CD-lanfrica-medium)" for Kiswahili

When user changes language → `AuthProvider.updatePreferredLanguage()` → All future audio uses new language's voice.

### 4. **User Preference Storage** (`lib/core/auth/auth_provider.dart`)
AuthProvider maintains `preferredLanguage` ('sw' or 'en'):
- Default: 'sw' (Kiswahili)
- Persisted in secure storage
- Updated via `updatePreferredLanguage(String languageCode)`
- Accessible in all screens via `context.read<AuthProvider>().preferredLanguage`

## How It Works

### Scenario 1: User Selects Kiswahili
```
1. User goes to Language Screen
2. Selects "Kiswahili"
3. updatePreferredLanguage('sw')
4. Next time user plays story:
   - Audio player reads preferredLanguage = 'sw'
   - Calls TTSService.buildStoryTtsUrl(id, 'sw')
   - API endpoint: /api/tts/story/123/?voice=sw_CD-lanfrica-medium
   - Piper generates Swahili audio
   - User hears Swahili voice
```

### Scenario 2: User Changes to English
```
1. User goes to Language Screen
2. Selects "English"
3. updatePreferredLanguage('en')
4. Next time user plays story:
   - Audio player reads preferredLanguage = 'en'
   - Calls TTSService.buildStoryTtsUrl(id, 'en')
   - API endpoint: /api/tts/story/123/?voice=en_US-lessac-medium
   - Piper generates English audio
   - User hears English voice
```

## Backend Integration

Django backend must support the `voice` query parameter in TTS endpoints:

### Story TTS Endpoint (Modified)
```
GET /api/tts/story/{story_id}/
Query Parameters:
  - voice: str (optional, default: en_US-lessac-medium)
           Examples: "sw_CD-lanfrica-medium", "en_US-lessac-medium"

Returns:
  - Audio file generated with specified Piper voice model
```

### Example Request
```bash
# Swahili voice
GET http://localhost:8000/api/tts/story/123/?voice=sw_CD-lanfrica-medium

# English voice
GET http://localhost:8000/api/tts/story/123/?voice=en_US-lessac-medium
```

## Affected Screens

### ✅ Home Screen (`home_screen.dart`)
- Story cards show audio play button
- When clicked → AudioPlayerScreen
- Uses language-specific voice

### ✅ Explore Screen (`explore_screen.dart`)
- Browse stories by category
- Story cards have audio play button
- Uses language-specific voice

### ✅ Story Details (`story_details_screen.dart`)
- Detailed story view
- Audio play button
- Uses language-specific voice

### ✅ Saved Stories (`saved_screen.dart`)
- User's saved/purchased stories
- Audio play button
- Uses language-specific voice

### ✅ Audio Player (`audio_player_screen.dart`)
- Dedicated audio playback
- **Core implementation** - uses TTSService

## File Modifications Summary

| File | Changes | Status |
|------|---------|--------|
| `lib/core/services/tts_service.dart` | NEW - Voice model configuration | ✅ Complete |
| `lib/features/audio_player/audio_player_screen.dart` | Import TTSService, use in _setupAudio() | ✅ Complete |
| `lib/features/profile/language_screen.dart` | Added voice info card, updated UI message | ✅ Complete |
| `lib/core/auth/auth_provider.dart` | No changes (already has preferredLanguage) | ✅ Ready |

## Testing Checklist

### Unit Tests
```dart
// Test TTSService voice model retrieval
test('TTSService returns correct Swahili voice model', () {
  final model = TTSService.getVoiceModel('sw');
  expect(model.code, equals('sw_CD-lanfrica-medium'));
});

test('TTSService returns correct English voice model', () {
  final model = TTSService.getVoiceModel('en');
  expect(model.code, equals('en_US-lessac-medium'));
});

// Test URL building
test('Story TTS URL includes language voice parameter', () {
  final url = TTSService.buildStoryTtsUrl(storyId: 123, languageCode: 'sw');
  expect(url, contains('voice=sw_CD-lanfrica-medium'));
});
```

### Integration Tests
1. **Language Switch Test**
   - Start with Kiswahili selected
   - Play audio story
   - Listen/verify Swahili voice
   - Go to Language Screen
   - Switch to English
   - Play same story
   - Verify English voice

2. **Voice Info Test**
   - Open Language Screen
   - Verify voice model displayed correctly
   - Change language
   - Verify voice model updates

3. **All Screens Test**
   - Play audio from Home Screen
   - Play audio from Explore Screen
   - Play audio from Saved Screen
   - Play audio from Story Details
   - Verify correct voice in each case

## Troubleshooting

### Error: "Imeshindikana kupakia sauti..."
**Cause:** Piper TTS not responding or voice parameter not supported

**Solution:**
1. Verify Django backend is running: `python manage.py runserver`
2. Check Piper TTS is installed: `pip list | grep piper`
3. Verify voice models are available:
   ```bash
   # Check installed voices
   ls ~/.local/share/piper/models/ | grep sw_CD
   ls ~/.local/share/piper/models/ | grep en_US
   ```

### Error: Voice name shows as "Unknown"
**Cause:** Invalid language code passed to TTSService

**Solution:**
- Only use 'sw' for Swahili
- Only use 'en' for English
- Check AuthProvider.preferredLanguage value

### Audio plays in wrong language
**Cause:** AuthProvider not updated or cached preference

**Solution:**
1. Verify AuthProvider.updatePreferredLanguage() called
2. Check user_preferences stored correctly
3. Restart app to reload preferences

## Performance Notes

- **Audio caching:** Downloaded TTS files cached in temp directory
- **First play:** ~2-3 seconds (generation + download)
- **Subsequent plays:** Instant (cached)
- **Voice switching:** No cache flush needed, uses new voice on next play

## Future Enhancements

- [ ] Add more language voices as available
- [ ] Voice preview button in Language Screen
- [ ] Voice quality selection (fast vs high-quality)
- [ ] Offline voice models
- [ ] Voice speed adjustment per language

## Dependencies

- **Framework:** Flutter
- **Audio:** audioplayers package
- **Backend:** Django + Piper TTS
- **State Management:** Provider (AuthProvider)
- **API Communication:** http package

## Related Files

- [Audio Player Screen](lib/features/audio_player/audio_player_screen.dart)
- [TTS Service](lib/core/services/tts_service.dart)
- [Language Screen](lib/features/profile/language_screen.dart)
- [Auth Provider](lib/core/auth/auth_provider.dart)
- [App I18n](lib/core/i18n/app_i18n.dart)
