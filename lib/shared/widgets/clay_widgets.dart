import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

/// Claymorphism Container Widget
/// Creates a soft, clay-like 3D effect with large border radius and inner shadows
class ClayContainer extends StatelessWidget {
  final Widget child;
  final double? width;
  final double? height;
  final double borderRadius;
  final Color color;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;
  final bool spread;

  const ClayContainer({
    super.key,
    required this.child,
    this.width,
    this.height,
    this.borderRadius = 35,
    this.color = AppColors.clayPink,
    this.padding,
    this.margin,
    this.onTap,
    this.spread = true,
  });

  @override
  Widget build(BuildContext context) {
    final container = Container(
      width: width,
      height: height,
      margin: margin,
      padding: padding ?? const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: [
          // Soft outer shadow for depth
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            offset: const Offset(0, 10),
            blurRadius: 20,
            spreadRadius: spread ? 2 : 0,
          ),
          // Inner highlight
          BoxShadow(
            color: Colors.white.withOpacity(0.5),
            offset: const Offset(-2, -2),
            blurRadius: 6,
            spreadRadius: -2,
          ),
        ],
      ),
      child: child,
    );

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        child: container,
      );
    }

    return container;
  }
}

/// Clay Button Widget
/// Soft, squishy button with clay-like appearance
class ClayButton extends StatefulWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final double? width;
  final double height;
  final double borderRadius;
  final Color color;
  final EdgeInsetsGeometry? padding;

  const ClayButton({
    super.key,
    required this.child,
    this.onPressed,
    this.width,
    this.height = 60,
    this.borderRadius = 35,
    this.color = AppColors.clayYellow,
    this.padding,
  });

  @override
  State<ClayButton> createState() => _ClayButtonState();
}

class _ClayButtonState extends State<ClayButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        widget.onPressed?.call();
      },
      onTapCancel: () => _controller.reverse(),
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          width: widget.width,
          height: widget.height,
          padding: widget.padding ?? const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          decoration: BoxDecoration(
            color: widget.color,
            borderRadius: BorderRadius.circular(widget.borderRadius),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                offset: const Offset(0, 8),
                blurRadius: 16,
                spreadRadius: 1,
              ),
              BoxShadow(
                color: Colors.white.withOpacity(0.6),
                offset: const Offset(-3, -3),
                blurRadius: 8,
                spreadRadius: -1,
              ),
            ],
          ),
          child: Center(child: widget.child),
        ),
      ),
    );
  }
}

/// Clay Card for Child UI
/// Bright, playful card with rounded edges
class ClayCard extends StatelessWidget {
  final Widget child;
  final double? width;
  final double? height;
  final Color color;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;

  const ClayCard({
    super.key,
    required this.child,
    this.width,
    this.height,
    this.color = AppColors.clayBlue,
    this.padding,
    this.margin,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ClayContainer(
      width: width,
      height: height,
      color: color,
      borderRadius: 30,
      padding: padding ?? const EdgeInsets.all(16),
      margin: margin,
      onTap: onTap,
      child: child,
    );
  }
}

/// Clay Icon Button for Child UI
class ClayIconButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final double size;
  final Color backgroundColor;
  final Color iconColor;

  const ClayIconButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.size = 60,
    this.backgroundColor = AppColors.clayPink,
    this.iconColor = Colors.white,
  });

  @override
  State<ClayIconButton> createState() => _ClayIconButtonState();
}

class _ClayIconButtonState extends State<ClayIconButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.9).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        widget.onPressed?.call();
      },
      onTapCancel: () => _controller.reverse(),
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(
            color: widget.backgroundColor,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                offset: const Offset(0, 6),
                blurRadius: 12,
              ),
              BoxShadow(
                color: Colors.white.withOpacity(0.6),
                offset: const Offset(-2, -2),
                blurRadius: 6,
              ),
            ],
          ),
          child: Icon(
            widget.icon,
            color: widget.iconColor,
            size: widget.size * 0.5,
          ),
        ),
      ),
    );
  }
}
