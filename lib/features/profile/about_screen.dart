import 'package:flutter/material.dart';
import '../../shared/widgets/app_text.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../shared/widgets/glassmorphic_container.dart';
import '../../shared/widgets/micro_interactions.dart';
import '../../shared/widgets/neumorphic_widgets.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundTop = isDark ? AppColors.backgroundDark : AppColors.backgroundLight;
    final backgroundBottom = isDark ? const Color(0xFF2A1B12) : AppColors.warmBeige;
    final cardSurface = isDark ? const Color(0xFF2F2118) : AppColors.cardBackground;
    final glassColor = isDark ? AppColors.glassDark : AppColors.glassWhite;
    final secondaryText = isDark ? Colors.white70 : AppColors.textSecondary;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              backgroundTop,
              backgroundBottom,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // App Bar
              Padding(
                padding: const EdgeInsets.all(AppConstants.paddingLarge),
                child: Row(
                  children: [
                    NeumorphicIconButton(
                      icon: Icons.arrow_back,
                      size: 50,
                      onPressed: () => context.pop(),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AppText(
                            'Kuhusu',
                            style: (Theme.of(context).textTheme.headlineSmall ?? const TextStyle(fontSize: 24)).copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          AppText(
                            'Kuhusu Story Zoo',
                            style: (Theme.of(context).textTheme.bodyMedium ?? const TextStyle(fontSize: 14)).copyWith(
                                  color: secondaryText,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: AppConstants.paddingLarge),
                  children: [
                    // App Logo
                    StaggeredFadeSlide(
                      order: 0,
                      child: Center(
                        child: Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [AppColors.sunsetOrange, AppColors.deepOrange],
                          ),
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.sunsetOrange.withOpacity(0.3),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.menu_book,
                          size: 60,
                          color: Colors.white,
                        ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // App name and version
                    const Center(
                      child: Column(
                        children: [
                          AppText(
                            'Story Zoo',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          SizedBox(height: 8),
                          AppText(
                            'Toleo 1.0.0',
                            style: TextStyle(
                              fontSize: 16,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),

                    NeumorphicCard(
                      borderRadius: 22,
                      color: cardSurface,
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Expanded(child: _miniInfo(context, 'Readers', '12K+')),
                          const SizedBox(width: 10),
                          Expanded(child: _miniInfo(context, 'Stories', '1.2K')),
                          const SizedBox(width: 10),
                          Expanded(child: _miniInfo(context, 'Rating', '4.8')),
                        ],
                      ),
                    ),

                    const SizedBox(height: 22),

                    // Description
                    StaggeredFadeSlide(
                      order: 1,
                      child: GlassmorphicContainer(
                        borderRadius: 20,
                        blur: 10,
                        color: glassColor,
                        borderColor: AppColors.glassBorder,
                        borderWidth: 1.5,
                        padding: const EdgeInsets.all(20),
                        child: AppText(
                        'Story Zoo ni jukwaa la kisasa la hadithi za Kiswahili ambapo wasomaji wanaweza kugundua, kununua na kusoma hadithi za kuvutia. Waandishi pia wanaweza kuandika na kuuza hadithi zao kwa umma mkubwa.',
                        style: TextStyle(
                          fontSize: 15,
                          color: AppColors.textPrimary,
                          height: 1.6,
                        ),
                        textAlign: TextAlign.center,
                        ),
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Info sections
                    _buildInfoCard(
                      context,
                      'Kampuni',
                      'Story Zoo Technologies Ltd.\nDar es Salaam, Tanzania',
                      Icons.business,
                      AppColors.sunsetOrange,
                    ),

                    const SizedBox(height: 16),

                    _buildInfoCard(
                      context,
                      'Barua Pepe',
                      'info@storyzoo.co.tz\nsupport@storyzoo.co.tz',
                      Icons.email,
                      AppColors.info,
                    ),

                    const SizedBox(height: 16),

                    _buildInfoCard(
                      context,
                      'Simu',
                      '+255 754 123 456\n+255 765 789 012',
                      Icons.phone,
                      AppColors.success,
                    ),

                    const SizedBox(height: 32),

                    // Links section
                    AppText(
                      'Viungo',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),

                    _buildLinkCard(
                      context,
                      'Sera ya Faragha',
                      'Soma sera yetu ya faragha',
                      Icons.privacy_tip,
                      AppColors.clayPurple,
                    ),

                    const SizedBox(height: 12),

                    _buildLinkCard(
                      context,
                      'Masharti ya Matumizi',
                      'Masharti ya kutumia huduma',
                      Icons.description,
                      AppColors.clayBlue,
                    ),

                    const SizedBox(height: 12),

                    _buildLinkCard(
                      context,
                      'Leseni',
                      'Leseni na haki za uandishi',
                      Icons.copyright,
                      AppColors.textMuted,
                    ),

                    const SizedBox(height: 32),

                    // Social media
                    AppText(
                      'Tufuate',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildSocialButton(Icons.facebook, AppColors.info),
                        const SizedBox(width: 16),
                        _buildSocialButton(Icons.telegram, AppColors.clayBlue),
                        const SizedBox(width: 16),
                        _buildSocialButton(Icons.tag, AppColors.clayPurple),
                        const SizedBox(width: 16),
                        _buildSocialButton(Icons.language, AppColors.success),
                      ],
                    ),

                    const SizedBox(height: 32),

                    // Copyright
                    Center(
                      child: AppText(
                        '© 2026 Story Zoo. Haki zote zimehifadhiwa.',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textMuted,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),

                    const SizedBox(height: 120),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context, String title, String content, IconData icon, Color color) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return NeumorphicCard(
      borderRadius: 20,
      color: isDark ? const Color(0xFF2F2118) : AppColors.cardBackground,
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white60 : AppColors.textMuted,
                  ),
                ),
                const SizedBox(height: 4),
                AppText(
                  content,
                  style: TextStyle(
                    fontSize: 15,
                    color: isDark ? Colors.white : AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLinkCard(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    Color color,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: AppText('Inafungua $title...')),
        );
      },
      child: NeumorphicCard(
        borderRadius: 20,
        color: isDark ? const Color(0xFF2F2118) : AppColors.cardBackground,
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 45,
              height: 45,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText(
                    title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  AppText(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? Colors.white70 : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: isDark ? Colors.white54 : AppColors.textMuted,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSocialButton(IconData icon, Color color) {
    return NeumorphicIconButton(
      icon: icon,
      size: 55,
      iconColor: color,
      onPressed: () {
        // Handle social media links
      },
    );
  }

  Widget _miniInfo(BuildContext context, String label, String value) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: isDark ? const Color(0x33FFFFFF) : AppColors.warmBeige.withOpacity(0.35),
        border: Border.all(color: AppColors.glassBorder),
      ),
      child: Column(
        children: [
          AppText(value, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
          const SizedBox(height: 2),
          AppText(
            label,
            style: TextStyle(fontSize: 10, color: isDark ? Colors.white60 : AppColors.textMuted),
          ),
        ],
      ),
    );
  }
}

