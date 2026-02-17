class AppConstants {
  AppConstants._();

  // API Configuration (backend removed)
  // Backend services were removed; keep empty base for offline/local usage.
  static const String apiBaseUrl = '';
  static const String apiVersion = '';
  
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
