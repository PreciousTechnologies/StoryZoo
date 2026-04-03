import 'package:flutter/material.dart';

/// Staggered fade + slide entrance used for premium section reveals.
class StaggeredFadeSlide extends StatefulWidget {
  final Widget child;
  final int order;
  final Offset beginOffset;

  const StaggeredFadeSlide({
    super.key,
    required this.child,
    this.order = 0,
    this.beginOffset = const Offset(0, 0.04),
  });

  @override
  State<StaggeredFadeSlide> createState() => _StaggeredFadeSlideState();
}

class _StaggeredFadeSlideState extends State<StaggeredFadeSlide>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _curve;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 420),
    );
    _curve = CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic);

    final delay = Duration(milliseconds: 60 * widget.order);
    Future.delayed(delay, () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _curve,
      builder: (context, child) {
        final t = _curve.value;
        return Opacity(
          opacity: t,
          child: Transform.translate(
            offset: Offset(
              widget.beginOffset.dx * (1 - t) * 100,
              widget.beginOffset.dy * (1 - t) * 100,
            ),
            child: child,
          ),
        );
      },
      child: widget.child,
    );
  }
}
