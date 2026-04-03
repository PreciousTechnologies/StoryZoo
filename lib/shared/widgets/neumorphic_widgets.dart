import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

/// Neumorphic Button Widget
/// Creates a 3D extruded button effect with dual shadows
class NeumorphicButton extends StatefulWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final double width;
  final double height;
  final double borderRadius;
  final Color color;
  final EdgeInsetsGeometry? padding;
  final bool isPressed;

  const NeumorphicButton({
    super.key,
    required this.child,
    this.onPressed,
    this.width = double.infinity,
    this.height = 56,
    this.borderRadius = 30,
    this.color = AppColors.cardBackground,
    this.padding,
    this.isPressed = false,
  });

  @override
  State<NeumorphicButton> createState() => _NeumorphicButtonState();
}

class _NeumorphicButtonState extends State<NeumorphicButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final isPressed = _isPressed || widget.isPressed;
  final isDark = Theme.of(context).brightness == Brightness.dark;
  final lightShadowColor = isDark
    ? AppColors.sandBrown.withOpacity(0.14)
    : AppColors.neuShadowLight;
  final darkShadowColor = isDark
    ? Colors.black.withOpacity(0.45)
    : AppColors.neuShadowDark.withOpacity(0.3);
  final pressedShadowColor = isDark
    ? Colors.black.withOpacity(0.5)
    : AppColors.neuShadowDark.withOpacity(0.2);

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onPressed?.call();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: widget.width,
        height: widget.height,
        padding: widget.padding ?? const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: widget.color,
          borderRadius: BorderRadius.circular(widget.borderRadius),
          boxShadow: isPressed
              ? [
                  // Pressed state - subtle inner shadow effect
                  BoxShadow(
                    color: pressedShadowColor,
                    offset: const Offset(2, 2),
                    blurRadius: 4,
                  ),
                ]
              : [
                  // Light shadow (top-left)
                  BoxShadow(
                    color: lightShadowColor,
                    offset: const Offset(-6, -6),
                    blurRadius: 12,
                    spreadRadius: 1,
                  ),
                  // Dark shadow (bottom-right)
                  BoxShadow(
                    color: darkShadowColor,
                    offset: const Offset(6, 6),
                    blurRadius: 12,
                    spreadRadius: 1,
                  ),
                ],
        ),
        child: Center(child: widget.child),
      ),
    );
  }
}

/// Neumorphic Card Widget
/// Creates a 3D card with subtle depth
class NeumorphicCard extends StatefulWidget {
  final Widget child;
  final double? width;
  final double? height;
  final double borderRadius;
  final Color color;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;

  const NeumorphicCard({
    super.key,
    required this.child,
    this.width,
    this.height,
    this.borderRadius = 20,
    this.color = AppColors.cardBackground,
    this.padding,
    this.margin,
    this.onTap,
  });

  @override
  State<NeumorphicCard> createState() => _NeumorphicCardState();
}

class _NeumorphicCardState extends State<NeumorphicCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final hasTap = widget.onTap != null;
    final isPressed = hasTap && _isPressed;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final lightShadowColor = isDark
      ? AppColors.sandBrown.withOpacity(0.14)
      : AppColors.neuShadowLight;
    final darkShadowColor = isDark
      ? Colors.black.withOpacity(0.45)
      : AppColors.neuShadowDark.withOpacity(0.3);
    final pressedShadowColor = isDark
      ? Colors.black.withOpacity(0.5)
      : AppColors.neuShadowDark.withOpacity(0.2);

    final cardContent = AnimatedScale(
      duration: const Duration(milliseconds: 120),
      curve: Curves.easeOut,
      scale: isPressed ? 0.985 : 1,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        width: widget.width,
        height: widget.height,
        margin: widget.margin,
        padding: widget.padding ?? const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: widget.color,
          borderRadius: BorderRadius.circular(widget.borderRadius),
          boxShadow: isPressed
              ? [
                  BoxShadow(
                    color: pressedShadowColor,
                    offset: const Offset(2, 2),
                    blurRadius: 5,
                  ),
                ]
              : [
                  BoxShadow(
                    color: lightShadowColor,
                    offset: const Offset(-5, -5),
                    blurRadius: 10,
                    spreadRadius: 1,
                  ),
                  BoxShadow(
                    color: darkShadowColor,
                    offset: const Offset(5, 5),
                    blurRadius: 10,
                    spreadRadius: 1,
                  ),
                ],
        ),
        child: widget.child,
      ),
    );

    if (!hasTap) return cardContent;

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onTap?.call();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: cardContent,
    );
  }
}

/// Neumorphic Icon Button
class NeumorphicIconButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final double size;
  final Color iconColor;
  final Color backgroundColor;

  const NeumorphicIconButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.size = 50,
    this.iconColor = AppColors.textPrimary,
    this.backgroundColor = AppColors.cardBackground,
  });

  @override
  State<NeumorphicIconButton> createState() => _NeumorphicIconButtonState();
}

class _NeumorphicIconButtonState extends State<NeumorphicIconButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final lightShadowColor = isDark
        ? AppColors.sandBrown.withOpacity(0.14)
        : AppColors.neuShadowLight;
    final darkShadowColor = isDark
        ? Colors.black.withOpacity(0.45)
        : AppColors.neuShadowDark.withOpacity(0.3);
    final pressedShadowColor = isDark
        ? Colors.black.withOpacity(0.5)
        : AppColors.neuShadowDark.withOpacity(0.2);

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onPressed?.call();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: widget.size,
        height: widget.size,
        decoration: BoxDecoration(
          color: widget.backgroundColor,
          shape: BoxShape.circle,
          boxShadow: _isPressed
              ? [
                  BoxShadow(
                    color: pressedShadowColor,
                    offset: const Offset(2, 2),
                    blurRadius: 4,
                  ),
                ]
              : [
                  BoxShadow(
                    color: lightShadowColor,
                    offset: const Offset(-4, -4),
                    blurRadius: 8,
                  ),
                  BoxShadow(
                    color: darkShadowColor,
                    offset: const Offset(4, 4),
                    blurRadius: 8,
                  ),
                ],
        ),
        child: Icon(
          widget.icon,
          color: widget.iconColor,
          size: widget.size * 0.5,
        ),
      ),
    );
  }
}
