import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../shared/widgets/glassmorphic_container.dart';
import '../../shared/widgets/neumorphic_widgets.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.backgroundLight,
              AppColors.warmBeige,
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
                          Text(
                            'Kuhusu',
                            style: (Theme.of(context).textTheme.headlineSmall ?? const TextStyle(fontSize: 24)).copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          Text(
                            'Kuhusu Story Zoo',
                            style: (Theme.of(context).textTheme.bodyMedium ?? const TextStyle(fontSize: 14)).copyWith(
                                  color: AppColors.textSecondary,
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
                    Center(
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

                    const SizedBox(height: 24),

                    // App name and version
                    const Center(
                      child: Column(
                        children: [
                          Text(
                            'Story Zoo',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
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

                    // Description
                    GlassmorphicContainer(
                      borderRadius: 20,
                      blur: 10,
                      color: AppColors.glassWhite,
                      borderColor: AppColors.glassBorder,
                      borderWidth: 1.5,
                      padding: const EdgeInsets.all(20),
                      child: const Text(
                        'Story Zoo ni jukwaa la kisasa la hadithi za Kiswahili ambapo wasomaji wanaweza kugundua, kununua na kusoma hadithi za kuvutia. Waandishi pia wanaweza kuandika na kuuza hadithi zao kwa umma mkubwa.',
                        style: TextStyle(
                          fontSize: 15,
                          color: AppColors.textPrimary,
                          height: 1.6,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Info sections
                    _buildInfoCard(
                      'Kampuni',
                      'Story Zoo Technologies Ltd.\nDar es Salaam, Tanzania',
                      Icons.business,
                      AppColors.sunsetOrange,
                    ),

                    const SizedBox(height: 16),

                    _buildInfoCard(
                      'Barua Pepe',
                      'info@storyzoo.co.tz\nsupport@storyzoo.co.tz',
                      Icons.email,
                      AppColors.info,
                    ),

                    const SizedBox(height: 16),

                    _buildInfoCard(
                      'Simu',
                      '+255 754 123 456\n+255 765 789 012',
                      Icons.phone,
                      AppColors.success,
                    ),

                    const SizedBox(height: 32),

                    // Links section
                    const Text(
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
                    const Text(
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
                      child: Text(
                        '© 2026 Story Zoo. Haki zote zimehifadhiwa.',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textMuted,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),

                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard(String title, String content, IconData icon, Color color) {
    return NeumorphicCard(
      borderRadius: 20,
      color: AppColors.cardBackground,
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
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textMuted,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  content,
                  style: const TextStyle(
                    fontSize: 15,
                    color: AppColors.textPrimary,
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
    return GestureDetector(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Inafungua $title...')),
        );
      },
      child: NeumorphicCard(
        borderRadius: 20,
        color: AppColors.cardBackground,
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
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, color: AppColors.textMuted, size: 16),
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
}
