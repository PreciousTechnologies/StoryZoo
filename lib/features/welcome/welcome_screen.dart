import 'package:flutter/material.dart';
import '../../shared/widgets/app_text.dart';
import 'package:go_router/go_router.dart';
import 'dart:math' as math;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/auth/auth_provider.dart';
import '../../core/utils/responsive_utils.dart';
import '../../shared/widgets/glassmorphic_container.dart';
import '../../shared/widgets/neumorphic_widgets.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.3, 1.0, curve: Curves.easeOut),
      ),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isAuthor = context.watch<AuthProvider>().isAuthor;

    return Scaffold(
      body: Container(
        width: size.width,
        height: size.height,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.sunsetOrange,
              AppColors.peachOrange,
              AppColors.warmBeige,
              AppColors.mintGreen,
            ],
            stops: [0.0, 0.3, 0.7, 1.0],
          ),
        ),
        child: Stack(
          children: [
            // Savannah background images
            Positioned.fill(
              child: Stack(
                children: [
                  // Main savannah landscape
                  Positioned.fill(
                    child: Opacity(
                      opacity: 0.3,
                      child: CachedNetworkImage(
                        imageUrl: 'https://images.unsplash.com/photo-1516426122078-c23e76319801?w=1200&q=80',
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(color: AppColors.warmBeige.withOpacity(0.1)),
                        errorWidget: (context, url, error) => Container(color: AppColors.warmBeige.withOpacity(0.1)),
                      ),
                    ),
                  ),
                  // Acacia tree silhouette overlay
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Opacity(
                      opacity: 0.25,
                      child: CachedNetworkImage(
                        imageUrl: 'https://images.unsplash.com/photo-1549366021-9f761d450615?w=1200&q=80',
                        fit: BoxFit.cover,
                        height: size.height * 0.5,
                        alignment: Alignment.bottomCenter,
                        placeholder: (context, url) => const SizedBox.shrink(),
                        errorWidget: (context, url, error) => const SizedBox.shrink(),
                      ),
                    ),
                  ),
                  // Animals silhouette for top-right
                  Positioned(
                    top: size.height * 0.1,
                    right: ResponsiveUtils.getSpacing(context),
                    child: Opacity(
                      opacity: 0.15,
                      child: CachedNetworkImage(
                        imageUrl: 'https://images.unsplash.com/photo-1535338454770-6f8c583cd0a4?w=800&q=80',
                        fit: BoxFit.contain,
                        height: ResponsiveUtils.isTablet(context) ? 150 : 120,
                        width: ResponsiveUtils.isTablet(context) ? 150 : 120,
                        placeholder: (context, url) => const SizedBox.shrink(),
                        errorWidget: (context, url, error) => const SizedBox.shrink(),
                      ),
                    ),
                  ),
                  // Color overlay for harmonious blending
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            AppColors.sunsetOrange.withOpacity(0.2),
                            AppColors.warmBeige.withOpacity(0.15),
                            AppColors.mintGreen.withOpacity(0.1),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // Animated savanna background patterns
            ...List.generate(5, (index) {
              return Positioned(
                top: math.Random(index).nextDouble() * size.height,
                left: math.Random(index * 2).nextDouble() * size.width,
                child: _FloatingCircle(
                  size: 100 + (index * 50),
                  color: AppColors.savannaGreen.withOpacity(0.1),
                  duration: Duration(seconds: 3 + index),
                ),
              );
            }),

            // Main content
            SafeArea(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: ResponsiveUtils.getPadding(context)),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Spacer(flex: 2),

                    // Logo container with glassmorphism
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: GlassmorphicContainer(
                        width: ResponsiveUtils.isTablet(context) ? 240 : 200,
                        height: ResponsiveUtils.isTablet(context) ? 240 : 200,
                        borderRadius: ResponsiveUtils.isTablet(context) ? 120 : 100,
                        blur: 15,
                        color: AppColors.glassWhite.withOpacity(0.3),
                        borderColor: AppColors.glassBorder,
                        borderWidth: 2,
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Placeholder for logo - replace with actual logo image
                              Icon(
                                Icons.auto_stories_rounded,
                                size: ResponsiveUtils.isTablet(context) ? 100 : 80,
                                color: AppColors.textLight,
                              ),
                              SizedBox(height: ResponsiveUtils.getSpacing(context) * 0.8),
                              AppText(
                                'Story Zoo',
                                style: (Theme.of(context).textTheme.headlineMedium ?? const TextStyle(fontSize: 24)).copyWith(
                                      color: AppColors.textLight,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 1.2,
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: ResponsiveUtils.getPadding(context) * 2),

                    // Welcome text
                    SlideTransition(
                      position: _slideAnimation,
                      child: FadeTransition(
                        opacity: _fadeAnimation,
                        child: Column(
                          children: [
                            AppText(
                              'Karibu Story Zoo! 🦁',
                              style: (Theme.of(context).textTheme.displaySmall ?? const TextStyle(fontSize: 32)).copyWith(
                                    color: AppColors.textLight,
                                    fontWeight: FontWeight.bold,
                                    fontSize: ResponsiveUtils.getHeadingSize(context, mobile: 28, tablet: 32, desktop: 40),
                                  ),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: ResponsiveUtils.getSpacing(context) * 0.8),
                            AppText(
                              'Soma na usikie hadithi za Kiswahili\nkwa njia ya kisasa',
                              style: (Theme.of(context).textTheme.bodyLarge ?? const TextStyle(fontSize: 16)).copyWith(
                                    color: AppColors.textLight.withOpacity(0.9),
                                  ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),

                    const Spacer(flex: 3),

                    // Buttons
                    SlideTransition(
                      position: _slideAnimation,
                      child: FadeTransition(
                        opacity: _fadeAnimation,
                        child: Column(
                          children: [
                            // Get Started Button - Neumorphic
                            NeumorphicButton(
                              onPressed: () {
                                // Start reading: go to login to enter phone number
                                context.go('/login');
                              },
                              color: AppColors.sunsetOrange,
                              height: ResponsiveUtils.getButtonHeight(context),
                              borderRadius: ResponsiveUtils.getBorderRadius(context),
                              child: AppText(
                                'Anza Kusoma',
                                style: (Theme.of(context).textTheme.titleLarge ?? const TextStyle(fontSize: 20)).copyWith(
                                      color: AppColors.textLight,
                                      fontWeight: FontWeight.w600,
                                    ),
                              ),
                            ),
                                const SizedBox(height: 14),
                                NeumorphicButton(
                                  onPressed: () {
                                    if (isAuthor) {
                                      context.go('/author-dashboard');
                                      return;
                                    }
                                    context.push('/author-onboarding');
                                  },
                                  color: AppColors.savannaGreen,
                                  height: ResponsiveUtils.getButtonHeight(context),
                                  borderRadius: ResponsiveUtils.getBorderRadius(context),
                                  child: AppText(
                                    isAuthor ? 'Nenda Dashboard ya Mwandishi' : 'Kuwa Mwandishi',
                                    style: (Theme.of(context).textTheme.titleLarge ?? const TextStyle(fontSize: 20)).copyWith(
                                          color: AppColors.textLight,
                                          fontWeight: FontWeight.w600,
                                        ),
                                  ),
                                ),
                          ],
                        ),
                      ),
                    ),

                    SizedBox(height: ResponsiveUtils.getPadding(context)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Floating animated circle for background decoration
class _FloatingCircle extends StatefulWidget {
  final double size;
  final Color color;
  final Duration duration;

  const _FloatingCircle({
    required this.size,
    required this.color,
    required this.duration,
  });

  @override
  State<_FloatingCircle> createState() => _FloatingCircleState();
}

class _FloatingCircleState extends State<_FloatingCircle> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(
            math.sin(_controller.value * 2 * math.pi) * 20,
            math.cos(_controller.value * 2 * math.pi) * 20,
          ),
          child: Container(
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: widget.color,
            ),
          ),
        );
      },
    );
  }
}

