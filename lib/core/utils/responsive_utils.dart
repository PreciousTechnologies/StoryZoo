import 'package:flutter/material.dart';

/// Screen type enumeration (moved outside class per Dart requirements)
enum ScreenType { mobile, tablet, desktop }

/// Utility class for responsive design calculations
/// Provides breakpoints and responsive values based on screen size
class ResponsiveUtils {
  static const double _mobileMaxWidth = 600;
  static const double _tabletMaxWidth = 1200;

  /// Get current screen type
  static ScreenType getScreenType(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < _mobileMaxWidth) {
      return ScreenType.mobile;
    } else if (width < _tabletMaxWidth) {
      return ScreenType.tablet;
    } else {
      return ScreenType.desktop;
    }
  }

  /// Check if device is mobile
  static bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < _mobileMaxWidth;
  }

  /// Check if device is tablet
  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= _mobileMaxWidth && width < _tabletMaxWidth;
  }

  /// Check if device is desktop
  static bool isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= _tabletMaxWidth;
  }

  /// Get responsive padding based on screen size
  static double getPadding(BuildContext context) {
    final screenType = getScreenType(context);
    switch (screenType) {
      case ScreenType.mobile:
        return 16;
      case ScreenType.tablet:
        return 24;
      case ScreenType.desktop:
        return 32;
    }
  }

  /// Get responsive font size
  static double getFontSize(BuildContext context,
      {double mobile = 14, double tablet = 16, double desktop = 18}) {
    final screenType = getScreenType(context);
    switch (screenType) {
      case ScreenType.mobile:
        return mobile;
      case ScreenType.tablet:
        return tablet;
      case ScreenType.desktop:
        return desktop;
    }
  }

  /// Get responsive heading size
  static double getHeadingSize(BuildContext context,
      {double mobile = 24, double tablet = 32, double desktop = 40}) {
    final screenType = getScreenType(context);
    switch (screenType) {
      case ScreenType.mobile:
        return mobile;
      case ScreenType.tablet:
        return tablet;
      case ScreenType.desktop:
        return desktop;
    }
  }

  /// Get responsive spacing
  static double getSpacing(BuildContext context,
      {double mobile = 12, double tablet = 16, double desktop = 20}) {
    final screenType = getScreenType(context);
    switch (screenType) {
      case ScreenType.mobile:
        return mobile;
      case ScreenType.tablet:
        return tablet;
      case ScreenType.desktop:
        return desktop;
    }
  }

  /// Get grid column count based on screen size
  static int getGridColumnCount(BuildContext context) {
    final screenType = getScreenType(context);
    switch (screenType) {
      case ScreenType.mobile:
        return 2;
      case ScreenType.tablet:
        return 3;
      case ScreenType.desktop:
        return 4;
    }
  }

  /// Get aspect ratio for grid items
  static double getGridAspectRatio(BuildContext context) {
    final screenType = getScreenType(context);
    switch (screenType) {
      case ScreenType.mobile:
        return 0.7;
      case ScreenType.tablet:
        return 0.75;
      case ScreenType.desktop:
        return 0.8;
    }
  }

  /// Get carousel height based on screen size
  static double getCarouselHeight(BuildContext context) {
    final screenType = getScreenType(context);
    switch (screenType) {
      case ScreenType.mobile:
        return 320;
      case ScreenType.tablet:
        return 380;
      case ScreenType.desktop:
        return 450;
    }
  }

  /// Get page view viewport fraction for carousel
  static double getCarouselViewportFraction(BuildContext context) {
    final screenType = getScreenType(context);
    switch (screenType) {
      case ScreenType.mobile:
        return 0.85;
      case ScreenType.tablet:
        return 0.6;
      case ScreenType.desktop:
        return 0.5;
    }
  }

  /// Get max width constraint for content
  static double getMaxContentWidth(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final screenType = getScreenType(context);
    switch (screenType) {
      case ScreenType.mobile:
        return width - 32; // 16px padding on each side
      case ScreenType.tablet:
        return 1000;
      case ScreenType.desktop:
        return 1400;
    }
  }

  /// Get featured card cover image height
  static double getFeaturedCardImageHeight(BuildContext context) {
    final screenType = getScreenType(context);
    switch (screenType) {
      case ScreenType.mobile:
        return 185;
      case ScreenType.tablet:
        return 220;
      case ScreenType.desktop:
        return 280;
    }
  }

  /// Get horizontal scrollable item height
  static double getHorizontalItemHeight(BuildContext context) {
    final screenType = getScreenType(context);
    switch (screenType) {
      case ScreenType.mobile:
        return 110;
      case ScreenType.tablet:
        return 130;
      case ScreenType.desktop:
        return 150;
    }
  }

  /// Get icon button size
  static double getIconButtonSize(BuildContext context) {
    final screenType = getScreenType(context);
    switch (screenType) {
      case ScreenType.mobile:
        return 50;
      case ScreenType.tablet:
        return 56;
      case ScreenType.desktop:
        return 64;
    }
  }

  /// Get button height
  static double getButtonHeight(BuildContext context) {
    final screenType = getScreenType(context);
    switch (screenType) {
      case ScreenType.mobile:
        return 48;
      case ScreenType.tablet:
        return 56;
      case ScreenType.desktop:
        return 64;
    }
  }

  /// Get border radius for rounded elements
  static double getBorderRadius(BuildContext context) {
    final screenType = getScreenType(context);
    switch (screenType) {
      case ScreenType.mobile:
        return 20;
      case ScreenType.tablet:
        return 24;
      case ScreenType.desktop:
        return 28;
    }
  }

  /// Apply responsive constraints to builder
  static Widget withConstraints(
    BuildContext context,
    Widget child, {
    double? maxWidth,
  }) {
    final actualMaxWidth = maxWidth ?? getMaxContentWidth(context);
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: actualMaxWidth),
        child: child,
      ),
    );
  }
}

/// Extension for easier access to responsive utilities
extension ResponsiveExtension on BuildContext {
  ScreenType get screenType => ResponsiveUtils.getScreenType(this);
  bool get isMobile => ResponsiveUtils.isMobile(this);
  bool get isTablet => ResponsiveUtils.isTablet(this);
  bool get isDesktop => ResponsiveUtils.isDesktop(this);
  double get responsivePadding => ResponsiveUtils.getPadding(this);
  double get responsiveSpacing => ResponsiveUtils.getSpacing(this);
  int get gridColumnCount => ResponsiveUtils.getGridColumnCount(this);
  double get gridAspectRatio => ResponsiveUtils.getGridAspectRatio(this);
  double get carouselHeight => ResponsiveUtils.getCarouselHeight(this);
  double get carouselViewportFraction =>
      ResponsiveUtils.getCarouselViewportFraction(this);
  double get maxContentWidth => ResponsiveUtils.getMaxContentWidth(this);
  double get iconButtonSize => ResponsiveUtils.getIconButtonSize(this);
  double get buttonHeight => ResponsiveUtils.getButtonHeight(this);
  double get borderRadius => ResponsiveUtils.getBorderRadius(this);
}
