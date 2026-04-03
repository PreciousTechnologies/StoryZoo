import 'package:flutter/material.dart';
import '../../shared/widgets/app_text.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/auth/auth_provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../shared/widgets/micro_interactions.dart';
import '../../shared/widgets/neumorphic_widgets.dart';
import 'data/profile_repository.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final ProfileRepository _repository = ProfileRepository();

  bool _pushNotifications = true;
  bool _emailNotifications = false;
  bool _newStories = true;
  bool _promotions = true;
  bool _authorUpdates = false;
  bool _comments = true;
  bool _likes = false;
  bool _soundEffects = true;
  bool _vibration = true;
  bool _isLoadingPreferences = true;
  bool _isSavingPreference = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadPreferences());
  }

  @override
  void dispose() {
    _repository.dispose();
    super.dispose();
  }

  Future<void> _loadPreferences() async {
    final token = context.read<AuthProvider>().token;
    if (token == null || token.isEmpty) {
      if (!mounted) return;
      setState(() {
        _isLoadingPreferences = false;
      });
      return;
    }

    try {
      final prefs = await _repository.fetchNotificationSettings(token);
      if (!mounted) return;
      setState(() {
        _applyPreferences(prefs);
        _isLoadingPreferences = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isLoadingPreferences = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: AppText('Imeshindikana kupakia mipangilio ya arifa.')),
      );
    }
  }

  void _applyPreferences(NotificationSettingsData prefs) {
    _pushNotifications = prefs.pushNotifications;
    _emailNotifications = prefs.emailNotifications;
    _newStories = prefs.newStories;
    _promotions = prefs.promotions;
    _authorUpdates = prefs.authorUpdates;
    _comments = prefs.comments;
    _likes = prefs.likes;
    _soundEffects = prefs.soundEffects;
    _vibration = prefs.vibration;
  }

  Future<void> _updatePreference(String key, bool value) async {
    if (_isSavingPreference) return;

    final token = context.read<AuthProvider>().token;
    if (token == null || token.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: AppText('Ingia tena ili kubadilisha mipangilio ya arifa.')),
      );
      return;
    }

    final previousValue = _getPreferenceValue(key);
    setState(() {
      _isSavingPreference = true;
      _setPreferenceValue(key, value);
    });

    try {
      final updated = await _repository.updateNotificationSettings(token, {key: value});
      if (!mounted) return;
      setState(() {
        _applyPreferences(updated);
        _isSavingPreference = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _setPreferenceValue(key, previousValue);
        _isSavingPreference = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: AppText('Imeshindikana kuhifadhi mabadiliko. Jaribu tena.')),
      );
    }
  }

  bool _getPreferenceValue(String key) {
    switch (key) {
      case 'push_notifications':
        return _pushNotifications;
      case 'email_notifications':
        return _emailNotifications;
      case 'new_stories':
        return _newStories;
      case 'promotions':
        return _promotions;
      case 'author_updates':
        return _authorUpdates;
      case 'comments':
        return _comments;
      case 'likes':
        return _likes;
      case 'sound_effects':
        return _soundEffects;
      case 'vibration':
        return _vibration;
      default:
        return false;
    }
  }

  void _setPreferenceValue(String key, bool value) {
    switch (key) {
      case 'push_notifications':
        _pushNotifications = value;
        break;
      case 'email_notifications':
        _emailNotifications = value;
        break;
      case 'new_stories':
        _newStories = value;
        break;
      case 'promotions':
        _promotions = value;
        break;
      case 'author_updates':
        _authorUpdates = value;
        break;
      case 'comments':
        _comments = value;
        break;
      case 'likes':
        _likes = value;
        break;
      case 'sound_effects':
        _soundEffects = value;
        break;
      case 'vibration':
        _vibration = value;
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundTop = isDark ? AppColors.backgroundDark : AppColors.backgroundLight;
    final backgroundBottom = isDark ? const Color(0xFF2A1B12) : AppColors.warmBeige;
    final cardSurface = isDark ? const Color(0xFF2F2118) : AppColors.cardBackground;
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
                            'Arifa',
                            style: (Theme.of(context).textTheme.headlineSmall ?? const TextStyle(fontSize: 24)).copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          AppText(
                            'Mipangilio ya arifa',
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
                child: _isLoadingPreferences
                    ? const Center(child: CircularProgressIndicator())
                    : ListView(
                        padding: const EdgeInsets.symmetric(horizontal: AppConstants.paddingLarge),
                        children: [
                          StaggeredFadeSlide(
                            order: 0,
                            child: NeumorphicCard(
                              borderRadius: 20,
                              color: cardSurface,
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                children: [
                                  Container(
                                    width: 44,
                                    height: 44,
                                    decoration: BoxDecoration(
                                      color: AppColors.sunsetOrange.withOpacity(0.12),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Icon(Icons.tune_rounded, color: AppColors.sunsetOrange),
                                  ),
                                  const SizedBox(width: 12),
                                  const Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        AppText('Notification Center', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                                        SizedBox(height: 2),
                                        AppText(
                                          'Chagua arifa muhimu tu ili usipate usumbufu.',
                                          style: TextStyle(fontSize: 12, color: AppColors.textMuted),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(height: 20),

                          // General Settings
                          AppText(
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
                            (value) => _updatePreference('push_notifications', value),
                          ),

                          const SizedBox(height: 12),

                          _buildSwitchTile(
                            'Arifa za Barua Pepe',
                            'Pokea arifa kupitia email',
                            Icons.email,
                            AppColors.info,
                            _emailNotifications,
                            (value) => _updatePreference('email_notifications', value),
                          ),

                          const SizedBox(height: 32),

                          // Content Notifications
                          AppText(
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
                            (value) => _updatePreference('new_stories', value),
                          ),

                          const SizedBox(height: 12),

                          _buildSwitchTile(
                            'Matangazo',
                            'Punguzo na matoleo maalum',
                            Icons.local_offer,
                            AppColors.warning,
                            _promotions,
                            (value) => _updatePreference('promotions', value),
                          ),

                          const SizedBox(height: 12),

                          _buildSwitchTile(
                            'Sasisho za Waandishi',
                            'Hadithi mpya kutoka waandishi unaofuata',
                            Icons.person_add,
                            AppColors.clayPurple,
                            _authorUpdates,
                            (value) => _updatePreference('author_updates', value),
                          ),

                          const SizedBox(height: 32),

                          // Social Notifications
                          AppText(
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
                            (value) => _updatePreference('comments', value),
                          ),

                          const SizedBox(height: 12),

                          _buildSwitchTile(
                            'Mipendwa',
                            'Mtu anapopenda hadithi yako',
                            Icons.favorite,
                            AppColors.error,
                            _likes,
                            (value) => _updatePreference('likes', value),
                          ),

                          const SizedBox(height: 32),

                          // Sound & Vibration
                          AppText(
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
                            (value) => _updatePreference('sound_effects', value),
                          ),

                          const SizedBox(height: 12),

                          _buildSwitchTile(
                            'Mtetemo',
                            'Tetema wakati wa arifa',
                            Icons.vibration,
                            AppColors.clayBlue,
                            _vibration,
                            (value) => _updatePreference('vibration', value),
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

  Widget _buildSwitchTile(
    String title,
    String subtitle,
    IconData icon,
    Color color,
    bool value,
    Function(bool) onChanged,
  ) {
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
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                AppText(
                  subtitle,
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark ? Colors.white70 : AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: _isSavingPreference ? null : onChanged,
            activeColor: AppColors.sunsetOrange,
            activeTrackColor: AppColors.sunsetOrange.withOpacity(0.5),
          ),
        ],
      ),
    );
  }
}

