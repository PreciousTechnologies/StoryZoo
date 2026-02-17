# Story Zoo - Design Components Quick Reference

## 🎨 Color Usage Guide

### When to Use Each Color

**Primary Actions** → `AppColors.sunsetOrange`
- Call-to-action buttons
- Active states
- Important highlights

**Secondary Actions** → `AppColors.savannaGreen`
- Secondary buttons
- Success states
- Nature/story themes

**Backgrounds** → `AppColors.backgroundLight`, `AppColors.warmBeige`
- Screen backgrounds
- Gradient combinations

**Cards/Containers** → `AppColors.cardBackground`
- Story cards
- Content containers
- Neumorphic surfaces

**Text**
- Primary: `AppColors.textPrimary`
- Secondary: `AppColors.textSecondary`
- Light: `AppColors.textLight` (on dark backgrounds)
- Muted: `AppColors.textMuted` (hints, captions)

## 🔘 Widget Selection Guide

### Glassmorphism - Use When:
- Modern, elegant look needed
- Overlaying content (modals, bottom sheets)
- Navigation bars
- Category chips
- Floating panels

```dart
GlassmorphicContainer(
  blur: 10,
  color: AppColors.glassWhite,
  borderRadius: 20,
  child: // your content
)

// Or use presets
GlassCard(child: //...)
GlassBottomSheet(child: //...)
```

### Neumorphism - Use When:
- Interactive elements (buttons, cards)
- Need tactile 3D feel
- Main action buttons
- Story cards
- Icon buttons

```dart
NeumorphicButton(
  onPressed: () {},
  child: Text('Click Me'),
)

NeumorphicCard(
  child: // your content
)

NeumorphicIconButton(
  icon: Icons.play_arrow,
  onPressed: () {},
)
```

### Claymorphism - Use When:
- Child UI mode
- Playful, friendly interfaces
- Large touch targets for kids
- Bright, colorful sections

```dart
ClayButton(
  color: AppColors.clayYellow,
  onPressed: () {},
  child: Text('Fun Button!'),
)

ClayCard(
  color: AppColors.clayBlue,
  child: // colorful content
)

ClayIconButton(
  icon: Icons.favorite,
  backgroundColor: AppColors.clayPink,
)
```

## 📐 Layout Guidelines

### Spacing
```dart
// Use constants for consistency
AppConstants.paddingSmall    // 8.0
AppConstants.paddingMedium   // 16.0
AppConstants.paddingLarge    // 24.0
AppConstants.paddingXLarge   // 32.0
```

### Border Radius
```dart
AppConstants.radiusSmall     // 12.0
AppConstants.radiusMedium    // 20.0
AppConstants.radiusLarge     // 30.0
AppConstants.radiusXLarge    // 40.0
```

### Animation Durations
```dart
AppConstants.shortAnimation   // 200ms - micro interactions
AppConstants.mediumAnimation  // 300ms - standard transitions
AppConstants.longAnimation    // 500ms - complex animations
```

## 🎭 Animation Patterns

### Fade In
```dart
FadeTransition(
  opacity: _fadeAnimation,
  child: YourWidget(),
)
```

### Slide In
```dart
SlideTransition(
  position: _slideAnimation,
  child: YourWidget(),
)
```

### Scale (Press Effect)
```dart
ScaleTransition(
  scale: _scaleAnimation,
  child: YourWidget(),
)
```

### Animated Container
```dart
AnimatedContainer(
  duration: AppConstants.mediumAnimation,
  // changing properties
)
```

## 🏗️ Screen Structure Template

```dart
class YourScreen extends StatefulWidget {
  const YourScreen({super.key});

  @override
  State<YourScreen> createState() => _YourScreenState();
}

class _YourScreenState extends State<YourScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.backgroundLight,
              AppColors.warmBeige,
            ],
          ),
        ),
        child: SafeArea(
          child: // Your content
        ),
      ),
    );
  }
}
```

## 📱 Common UI Patterns

### Story Card
```dart
NeumorphicCard(
  borderRadius: 24,
  child: Column(
    children: [
      // Cover image container
      Container(
        height: 200,
        decoration: BoxDecoration(
          gradient: LinearGradient(...),
        ),
      ),
      // Story info
      Padding(
        padding: EdgeInsets.all(16),
        child: // title, author, price
      ),
    ],
  ),
)
```

### Action Button
```dart
NeumorphicButton(
  onPressed: () {},
  color: AppColors.sunsetOrange,
  height: 60,
  borderRadius: 30,
  child: Text(
    'Button Text',
    style: TextStyle(
      color: AppColors.textLight,
      fontWeight: FontWeight.w600,
    ),
  ),
)
```

### Category Chip
```dart
GlassmorphicContainer(
  height: 50,
  borderRadius: 25,
  blur: 8,
  color: isSelected 
    ? AppColors.sunsetOrange.withOpacity(0.3)
    : AppColors.glassWhite,
  borderColor: isSelected 
    ? AppColors.sunsetOrange 
    : AppColors.glassBorder,
  child: Center(child: Text(category)),
)
```

### Bottom Navigation
```dart
Container(
  child: ClipRRect(
    borderRadius: BorderRadius.circular(30),
    child: BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.glassWhite.withOpacity(0.8),
          border: Border.all(color: AppColors.glassBorder),
        ),
        child: Row(
          // navigation items
        ),
      ),
    ),
  ),
)
```

## 🎯 Typography Scale

```dart
// Display (Large titles)
Theme.of(context).textTheme.displayLarge   // 32px, bold
Theme.of(context).textTheme.displayMedium  // 28px, bold
Theme.of(context).textTheme.displaySmall   // 24px, semibold

// Headlines
Theme.of(context).textTheme.headlineMedium // 20px, semibold
Theme.of(context).textTheme.headlineSmall  // 18px, semibold

// Body
Theme.of(context).textTheme.bodyLarge      // 16px, normal
Theme.of(context).textTheme.bodyMedium     // 14px, normal
Theme.of(context).textTheme.bodySmall      // 12px, normal

// Title
Theme.of(context).textTheme.titleLarge     // 16px, medium
```

## 🌈 Gradient Combinations

### Sunset Gradient
```dart
LinearGradient(
  colors: [
    AppColors.sunsetOrange,
    AppColors.peachOrange,
    AppColors.warmBeige,
  ],
)
```

### Savanna Gradient
```dart
LinearGradient(
  colors: [
    AppColors.savannaGreen,
    AppColors.mintGreen,
  ],
)
```

### Clay Gradient (for child UI)
```dart
LinearGradient(
  colors: [
    AppColors.clayPink,
    AppColors.clayBlue,
  ],
)
```

## 🔧 Best Practices

1. **Always use const constructors** when possible
2. **Extract repeated widgets** into separate methods or files
3. **Use AppColors constants** instead of hardcoded colors
4. **Apply consistent spacing** using AppConstants
5. **Add animations** to state changes for smooth UX
6. **Test on different screen sizes** using responsive units
7. **Use meaningful widget names** for readability
8. **Keep widget trees shallow** for better performance

## 📚 Import Template

```dart
// Always include these in new screens
import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../shared/widgets/glassmorphic_container.dart';
import '../../shared/widgets/neumorphic_widgets.dart';
import '../../shared/widgets/clay_widgets.dart';
```

---

**Quick Tip**: When in doubt, check the existing `welcome_screen.dart` or `home_screen.dart` for implementation examples!
