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
                    color: AppColors.neuShadowDark.withOpacity(0.2),
                    offset: const Offset(2, 2),
                    blurRadius: 4,
                  ),
                ]
              : [
                  // Light shadow (top-left)
                  const BoxShadow(
                    color: AppColors.neuShadowLight,
                    offset: Offset(-6, -6),
                    blurRadius: 12,
                    spreadRadius: 1,
                  ),
                  // Dark shadow (bottom-right)
                  BoxShadow(
                    color: AppColors.neuShadowDark.withOpacity(0.3),
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
class NeumorphicCard extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final cardContent = Container(
      width: width,
      height: height,
      margin: margin,
      padding: padding ?? const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: [
          // Light shadow (top-left)
          const BoxShadow(
            color: AppColors.neuShadowLight,
            offset: Offset(-5, -5),
            blurRadius: 10,
            spreadRadius: 1,
          ),
          // Dark shadow (bottom-right)
          BoxShadow(
            color: AppColors.neuShadowDark.withOpacity(0.3),
            offset: const Offset(5, 5),
            blurRadius: 10,
            spreadRadius: 1,
          ),
        ],
      ),
      child: child,
    );

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        child: cardContent,
      );
    }

    return cardContent;
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
                    color: AppColors.neuShadowDark.withOpacity(0.2),
                    offset: const Offset(2, 2),
                    blurRadius: 4,
                  ),
                ]
              : [
                  const BoxShadow(
                    color: AppColors.neuShadowLight,
                    offset: Offset(-4, -4),
                    blurRadius: 8,
                  ),
                  BoxShadow(
                    color: AppColors.neuShadowDark.withOpacity(0.3),
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
