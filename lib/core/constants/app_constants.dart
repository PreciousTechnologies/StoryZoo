import 'package:flutter/foundation.dart';

class AppConstants {
  AppConstants._();

  static const String _apiBaseUrlOverride = String.fromEnvironment('API_BASE_URL', defaultValue: '');
  static const String googleWebClientId = String.fromEnvironment('GOOGLE_WEB_CLIENT_ID', defaultValue: '');

  // API Configuration (Django backend)
  static String get apiBaseUrl {
    if (_apiBaseUrlOverride.isNotEmpty) return _apiBaseUrlOverride;
    if (kIsWeb) return 'http://127.0.0.1:8000';
    // Real Android phones need your computer's LAN IP, not localhost.
    if (defaultTargetPlatform == TargetPlatform.android) return 'http://192.168.1.100:8000';
    return 'http://127.0.0.1:8000';
  }
  static const String apiVersion = '/api';
  
  // App Info
  static const String appName = 'Story Zoo';
  static const String appVersion = '1.0.0';
  
  // Pagination
  static const int storiesPerPage = 20;
  static const int categoriesPerPage = 10;
  
  // Animation Durations
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 300);
  static const Duration longAnimation = Duration(milliseconds: 500);
  
  // Spacing
  static const double paddingSmall = 8.0;
  static const double paddingMedium = 16.0;
  static const double paddingLarge = 24.0;
  static const double paddingXLarge = 32.0;
  
  // Border Radius
  static const double radiusSmall = 12.0;
  static const double radiusMedium = 20.0;
  static const double radiusLarge = 30.0;
  static const double radiusXLarge = 40.0;
  
  // Image Sizes
  static const double iconSizeSmall = 24.0;
  static const double iconSizeMedium = 32.0;
  static const double iconSizeLarge = 48.0;
  
  // Story Categories
  static const List<String> storyCategories = [
    'Adventure',
    'Love',
    'Folklore',
    'Moral Stories',
    'Fairy Tales',
    'Mystery',
    'Science Fiction',
    'Historical',
  ];
}
