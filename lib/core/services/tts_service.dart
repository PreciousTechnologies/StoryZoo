import '../constants/app_constants.dart';

/// Piper TTS Voice Models Configuration
class PiperVoiceModel {
  final String languageCode;
  final String voiceModel;
  final String displayName;
  final String description;

  const PiperVoiceModel({
    required this.languageCode,
    required this.voiceModel,
    required this.displayName,
    required this.description,
  });
}

/// TTS Service - Manages language-specific Piper TTS voices
class TTSService {
  static const Map<String, PiperVoiceModel> _voiceModels = {
    'sw': PiperVoiceModel(
      languageCode: 'sw',
      voiceModel: 'sw_CD-lanfrica-medium',
      displayName: 'Kiswahili (Lanfrica)',
      description: 'Natural Swahili voice powered by Lanfrica',
    ),
    'en': PiperVoiceModel(
      languageCode: 'en',
      voiceModel: 'en_US-lessac-medium',
      displayName: 'English (Lessac)',
      description: 'Natural English voice',
    ),
  };

  /// Get Piper voice model for language
  static PiperVoiceModel getVoiceModel(String languageCode) {
    final normalized = normalizeLanguageCode(languageCode);
    return _voiceModels[normalized] ?? _voiceModels['sw']!;
  }

  /// Normalize various language labels/codes to supported short code.
  static String normalizeLanguageCode(String value) {
    final normalized = value.toLowerCase().trim();
    if (normalized == 'en' || normalized == 'english') {
      return 'en';
    }
    if (normalized == 'sw' || normalized == 'swahili' || normalized == 'kiswahili') {
      return 'sw';
    }
    return 'sw';
  }

  static String languageTagLabel(String value) {
    return normalizeLanguageCode(value) == 'en' ? 'ENGLISH' : 'SWAHILI';
  }

  /// Build TTS URL for story with language-specific voice
  /// 
  /// Returns URL like:
  /// - For Swahili: http://localhost:8000/api/tts/story/123/?voice=sw_CD-lanfrica-medium
  /// - For English: http://localhost:8000/api/tts/story/123/?voice=en_US-lessac-medium
  static String buildStoryTtsUrl({
    required int storyId,
    required String languageCode,
  }) {
    final voiceModel = getVoiceModel(languageCode);
    return '${AppConstants.apiBaseUrl}${AppConstants.apiVersion}/tts/story/$storyId/?voice=${voiceModel.voiceModel}';
  }

  /// Build TTS URL for text generation with language-specific voice
  static String buildTextTtsUrl({
    required String text,
    required String languageCode,
  }) {
    final voiceModel = getVoiceModel(languageCode);
    return Uri.parse(
      '${AppConstants.apiBaseUrl}${AppConstants.apiVersion}/tts/generate/',
    ).replace(
      queryParameters: {
        'text': text,
        'voice': voiceModel.voiceModel,
      },
    ).toString();
  }

  /// Get voice display name for UI
  static String getVoiceDisplayName(String languageCode) {
    return getVoiceModel(languageCode).displayName;
  }

  /// Get voice description for UI
  static String getVoiceDescription(String languageCode) {
    return getVoiceModel(languageCode).description;
  }

  /// Check if language is supported
  static bool isLanguageSupported(String languageCode) {
    return _voiceModels.containsKey(languageCode.toLowerCase());
  }

  /// Get all available voices
  static List<PiperVoiceModel> getAllVoices() {
    return _voiceModels.values.toList();
  }

  /// Get Piper voice model name only (useful for API calls)
  static String getVoiceModelName(String languageCode) {
    return getVoiceModel(languageCode).voiceModel;
  }
}
