import 'dart:ui';
import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

/// Glassmorphism Container Widget
/// Creates a frosted glass effect with blur and semi-transparent background
class GlassmorphicContainer extends StatelessWidget {
  final Widget child;
  final double? width;
  final double? height;
  final double borderRadius;
  final double blur;
  final Color color;
  final Color borderColor;
  final double borderWidth;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;

  const GlassmorphicContainer({
    super.key,
    required this.child,
    this.width,
    this.height,
    this.borderRadius = 20,
    this.blur = 10,
    this.color = AppColors.glassWhite,
    this.borderColor = AppColors.glassBorder,
    this.borderWidth = 1.5,
    this.padding,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      margin: margin,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(borderRadius),
              border: Border.all(
                color: borderColor,
                width: borderWidth,
              ),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}

/// Glassmorphic Card - Preset glass card for common use
class GlassCard extends StatelessWidget {
  final Widget child;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;

  const GlassCard({
    super.key,
    required this.child,
    this.width,
    this.height,
    this.padding,
    this.margin,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cardContent = GlassmorphicContainer(
      width: width,
      height: height,
      borderRadius: 24,
      blur: 12,
      color: AppColors.glassWhite,
      borderColor: AppColors.glassBorder,
      padding: padding ?? const EdgeInsets.all(16),
      margin: margin,
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

/// Glassmorphic Bottom Sheet
class GlassBottomSheet extends StatelessWidget {
  final Widget child;
  final double height;

  const GlassBottomSheet({
    super.key,
    required this.child,
    this.height = 300,
  });

  @override
  Widget build(BuildContext context) {
    return GlassmorphicContainer(
      height: height,
      borderRadius: 30,
      blur: 15,
      color: AppColors.glassWhite.withOpacity(0.5),
      borderColor: AppColors.glassBorder,
      padding: const EdgeInsets.all(24),
      child: child,
    );
  }
}
