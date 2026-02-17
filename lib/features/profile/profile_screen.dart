import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../shared/widgets/glassmorphic_container.dart';
import '../../shared/widgets/neumorphic_widgets.dart';
import '../../shared/widgets/enhanced_bottom_nav.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

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
              AppColors.clayPurple,
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppConstants.paddingLarge).copyWith(bottom: 100),
            child: Column(
              children: [
                // Profile header
                GlassmorphicContainer(
                  borderRadius: 30,
                  blur: 15,
                  color: AppColors.glassWhite,
                  borderColor: AppColors.glassBorder,
                  borderWidth: 2,
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      // Avatar
                      Stack(
                        children: [
                          Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: const LinearGradient(
                                colors: [
                                  AppColors.sunsetOrange,
                                  AppColors.deepOrange,
                                ],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.sunsetOrange.withOpacity(0.3),
                                  blurRadius: 20,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: ClipOval(
                              child: CachedNetworkImage(
                                imageUrl: 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=400&q=80',
                                fit: BoxFit.cover,
                                placeholder: (context, url) => const Center(
                                  child: Icon(Icons.person, size: 60, color: Colors.white),
                                ),
                                errorWidget: (context, url, error) => const Center(
                                  child: Icon(Icons.person, size: 60, color: Colors.white),
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: const BoxDecoration(
                                color: AppColors.success,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.edit,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Name
                      Text(
                        'Juma Mwinyi',
                        style: (Theme.of(context).textTheme.headlineSmall ?? const TextStyle(fontSize: 24)).copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                      ),
                      const SizedBox(height: 4),

                      // Email
                      Text(
                        'juma.mwinyi@storyzoo.co.tz',
                        style: (Theme.of(context).textTheme.bodyMedium ?? const TextStyle(fontSize: 14)).copyWith(
                              color: AppColors.textSecondary,
                            ),
                      ),
                      const SizedBox(height: 20),

                      // Stats
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildStatItem(context, '24', 'Hadithi'),
                          Container(width: 1, height: 40, color: AppColors.glassBorder),
                          _buildStatItem(context, '8', 'Zilizohifadhiwa'),
                          Container(width: 1, height: 40, color: AppColors.glassBorder),
                          _buildStatItem(context, '156', 'Masaa'),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),
                
                // Become an Author CTA
                NeumorphicButton(
                  onPressed: () {
                    context.push('/author-onboarding');
                  },
                  color: AppColors.sunsetOrange,
                  height: 64,
                  borderRadius: 32,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: const BoxDecoration(
                            color: Colors.white24,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.edit_note, color: Colors.white, size: 20),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text(
                                'Kuwa Mwandishi',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2),
                              const Text(
                                'Andika na uuze hadithi zako',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 11,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.arrow_forward, color: Colors.white, size: 18),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Menu items
                _buildMenuItem(
                  context,
                  icon: Icons.shopping_bag_rounded,
                  title: 'Manunuzi Yangu',
                  subtitle: 'Hadithi nilizoinunua',
                  color: AppColors.sunsetOrange,
                  onTap: () {
                    context.push('/my-purchases');
                  },
                ),
                const SizedBox(height: 12),

                _buildMenuItem(
                  context,
                  icon: Icons.history_rounded,
                  title: 'Historia',
                  subtitle: 'Hadithi nilizosoma',
                  color: AppColors.info,
                  onTap: () {
                    context.push('/history');
                  },
                ),
                const SizedBox(height: 12),

                _buildMenuItem(
                  context,
                  icon: Icons.payment_rounded,
                  title: 'Malipo',
                  subtitle: 'Njia za malipo',
                  color: AppColors.success,
                  onTap: () {
                    context.push('/payments');
                  },
                ),
                const SizedBox(height: 12),

                _buildMenuItem(
                  context,
                  icon: Icons.notifications_rounded,
                  title: 'Arifa',
                  subtitle: 'Mipangilio ya arifa',
                  color: AppColors.warning,
                  onTap: () {
                    context.push('/notifications');
                  },
                ),
                const SizedBox(height: 12),

                _buildMenuItem(
                  context,
                  icon: Icons.language_rounded,
                  title: 'Lugha',
                  subtitle: 'Kiswahili',
                  color: AppColors.savannaGreen,
                  onTap: () {
                    context.push('/language');
                  },
                ),
                const SizedBox(height: 12),

                _buildMenuItem(
                  context,
                  icon: Icons.dark_mode_rounded,
                  title: 'Mandhari',
                  subtitle: 'Hali ya giza/Mwanga',
                  color: AppColors.clayPurple,
                  onTap: () {
                    context.push('/theme');
                  },
                ),
                const SizedBox(height: 12),

                _buildMenuItem(
                  context,
                  icon: Icons.help_rounded,
                  title: 'Msaada',
                  subtitle: 'Maswali yanayoulizwa',
                  color: AppColors.info,
                  onTap: () {
                    context.push('/help');
                  },
                ),
                const SizedBox(height: 12),

                _buildMenuItem(
                  context,
                  icon: Icons.info_rounded,
                  title: 'Kuhusu',
                  subtitle: 'Toleo 1.0.0',
                  color: AppColors.textMuted,
                  onTap: () {
                    context.push('/about');
                  },
                ),
                const SizedBox(height: 24),

                // Logout button
                NeumorphicCard(
                  borderRadius: 20,
                  color: AppColors.error.withOpacity(0.1),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  onTap: () {
                    _showLogoutDialog(context);
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.logout_rounded, color: AppColors.error, size: 24),
                      const SizedBox(width: 12),
                      Text(
                        'Toka',
                        style: (Theme.of(context).textTheme.titleMedium ?? const TextStyle(fontSize: 16)).copyWith(
                              color: AppColors.error,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: EnhancedBottomNav(
        currentIndex: 3,
        isAuthor: true,
        onTap: (index) {
          switch (index) {
            case 0:
              context.go('/home');
              break;
            case 1:
              context.go('/explore');
              break;
            case 2:
              context.go('/saved');
              break;
            case 3:
              // Already on profile
              break;
            case 4:
              context.go('/author-dashboard');
              break;
          }
        },
      ),
    );
  }

  Widget _buildStatItem(BuildContext context, String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: (Theme.of(context).textTheme.headlineSmall ?? const TextStyle(fontSize: 24)).copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.sunsetOrange,
              ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: (Theme.of(context).textTheme.bodySmall ?? const TextStyle(fontSize: 12)).copyWith(
                color: AppColors.textSecondary,
              ),
        ),
      ],
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: NeumorphicCard(
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
                    style: (Theme.of(context).textTheme.titleMedium ?? const TextStyle(fontSize: 16)).copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: (Theme.of(context).textTheme.bodySmall ?? const TextStyle(fontSize: 12)).copyWith(
                          color: AppColors.textMuted,
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

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Toka'),
        content: const Text('Je, una uhakika unataka kutoka?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Ghairi'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              context.go('/');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Toka'),
          ),
        ],
      ),
    );
  }
}
