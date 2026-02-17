import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../shared/widgets/neumorphic_widgets.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  bool _pushNotifications = true;
  bool _emailNotifications = false;
  bool _newStories = true;
  bool _promotions = true;
  bool _authorUpdates = false;
  bool _comments = true;
  bool _likes = false;
  bool _soundEffects = true;
  bool _vibration = true;

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
                            'Arifa',
                            style: (Theme.of(context).textTheme.headlineSmall ?? const TextStyle(fontSize: 24)).copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          Text(
                            'Mipangilio ya arifa',
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
                    // General Settings
                    const Text(
                      'Mipangilio ya Jumla',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),

                    _buildSwitchTile(
                      'Arifa za Kusukuma',
                      'Pokea arifa kwenye kifaa chako',
                      Icons.notifications_active,
                      AppColors.sunsetOrange,
                      _pushNotifications,
                      (value) => setState(() => _pushNotifications = value),
                    ),

                    const SizedBox(height: 12),

                    _buildSwitchTile(
                      'Arifa za Barua Pepe',
                      'Pokea arifa kupitia email',
                      Icons.email,
                      AppColors.info,
                      _emailNotifications,
                      (value) => setState(() => _emailNotifications = value),
                    ),

                    const SizedBox(height: 32),

                    // Content Notifications
                    const Text(
                      'Arifa za Maudhui',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),

                    _buildSwitchTile(
                      'Hadithi Mpya',
                      'Arifa za hadithi mpya',
                      Icons.auto_stories,
                      AppColors.savannaGreen,
                      _newStories,
                      (value) => setState(() => _newStories = value),
                    ),

                    const SizedBox(height: 12),

                    _buildSwitchTile(
                      'Matangazo',
                      'Punguzo na matoleo maalum',
                      Icons.local_offer,
                      AppColors.warning,
                      _promotions,
                      (value) => setState(() => _promotions = value),
                    ),

                    const SizedBox(height: 12),

                    _buildSwitchTile(
                      'Sasisho za Waandishi',
                      'Hadithi mpya kutoka waandishi unaofuata',
                      Icons.person_add,
                      AppColors.clayPurple,
                      _authorUpdates,
                      (value) => setState(() => _authorUpdates = value),
                    ),

                    const SizedBox(height: 32),

                    // Social Notifications
                    const Text(
                      'Arifa za Kijamii',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),

                    _buildSwitchTile(
                      'Maoni',
                      'Mtu anapotoa maoni kwenye hadithi yako',
                      Icons.comment,
                      AppColors.info,
                      _comments,
                      (value) => setState(() => _comments = value),
                    ),

                    const SizedBox(height: 12),

                    _buildSwitchTile(
                      'Mipendwa',
                      'Mtu anapopenda hadithi yako',
                      Icons.favorite,
                      AppColors.error,
                      _likes,
                      (value) => setState(() => _likes = value),
                    ),

                    const SizedBox(height: 32),

                    // Sound & Vibration
                    const Text(
                      'Sauti na Mtetemo',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),

                    _buildSwitchTile(
                      'Sauti',
                      'Cheza sauti kwa arifa',
                      Icons.volume_up,
                      AppColors.sunsetOrange,
                      _soundEffects,
                      (value) => setState(() => _soundEffects = value),
                    ),

                    const SizedBox(height: 12),

                    _buildSwitchTile(
                      'Mtetemo',
                      'Tetema wakati wa arifa',
                      Icons.vibration,
                      AppColors.clayBlue,
                      _vibration,
                      (value) => setState(() => _vibration = value),
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

  Widget _buildSwitchTile(
    String title,
    String subtitle,
    IconData icon,
    Color color,
    bool value,
    Function(bool) onChanged,
  ) {
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
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.sunsetOrange,
            activeTrackColor: AppColors.sunsetOrange.withOpacity(0.5),
          ),
        ],
      ),
    );
  }
}
