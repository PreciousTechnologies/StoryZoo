import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../shared/widgets/app_text.dart';
import 'package:go_router/go_router.dart';
import '../../core/auth/auth_provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../shared/widgets/micro_interactions.dart';
import '../../shared/widgets/neumorphic_widgets.dart';

class ThemeScreen extends StatefulWidget {
  const ThemeScreen({super.key});

  @override
  State<ThemeScreen> createState() => _ThemeScreenState();
}

class _ThemeScreenState extends State<ThemeScreen> {
  String _selectedTheme = 'Mwanga';

  @override
  void initState() {
    super.initState();
    final themeMode = context.read<AuthProvider>().preferredThemeMode;
    _selectedTheme = _labelFromThemeMode(themeMode);
  }

  String _labelFromThemeMode(String mode) {
    switch (mode.toLowerCase()) {
      case 'dark':
        return 'Giza';
      case 'light':
        return 'Mwanga';
      default:
        return 'Otomatiki';
    }
  }

  String _themeModeFromLabel(String label) {
    switch (label) {
      case 'Giza':
        return 'dark';
      case 'Mwanga':
        return 'light';
      default:
        return 'system';
    }
  }

  final List<Map<String, dynamic>> _themes = [
    {
      'name': 'Mwanga',
      'description': 'Mandhari ya mchana',
      'icon': Icons.light_mode,
      'color': AppColors.warning,
      'preview': [Colors.white, AppColors.backgroundLight],
    },
    {
      'name': 'Giza',
      'description': 'Mandhari ya usiku',
      'icon': Icons.dark_mode,
      'color': AppColors.clayPurple,
      'preview': [const Color(0xFF1A1A2E), const Color(0xFF16213E)],
    },
    {
      'name': 'Otomatiki',
      'description': 'Fuata mipangilio ya mfumo',
      'icon': Icons.brightness_auto,
      'color': AppColors.info,
      'preview': [Colors.white, const Color(0xFF1A1A2E)],
    },
  ];

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
                            'Mandhari',
                            style: (Theme.of(context).textTheme.headlineSmall ?? const TextStyle(fontSize: 24)).copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          AppText(
                            'Chagua mandhari',
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
                              color: AppColors.clayPurple.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.palette_rounded, color: AppColors.clayPurple),
                          ),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: AppText(
                              'Mandhari huathiri usomaji wa muda mrefu. Chagua inayokufaa mchana na usiku.',
                              style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                            ),
                          ),
                        ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 18),

                    // Theme options
                    ..._themes.map((theme) {
                      final index = _themes.indexOf(theme);
                      return StaggeredFadeSlide(order: index + 1, child: _buildThemeCard(theme));
                    }).toList(),

                    const SizedBox(height: 32),

                    // Additional settings
                    AppText(
                      'Mipangilio ya Ziada',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),

                    NeumorphicCard(
                      borderRadius: 20,
                      color: cardSurface,
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: AppColors.sunsetOrange.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: const Icon(Icons.invert_colors, color: AppColors.sunsetOrange, size: 24),
                          ),
                          const SizedBox(width: 16),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                AppText(
                                  'Mandhari ya AMOLED',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 4),
                                AppText(
                                  'Giza kamili kwa vifaa vya OLED',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Switch(
                            value: false,
                            onChanged: (value) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: AppText('Itakuwa inapatikana hivi karibuni')),
                              );
                            },
                            activeColor: AppColors.sunsetOrange,
                            activeTrackColor: AppColors.sunsetOrange.withOpacity(0.5),
                          ),
                        ],
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

  Widget _buildThemeCard(Map<String, dynamic> theme) {
    final isSelected = theme['name'] == _selectedTheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: GestureDetector(
        onTap: () async {
          final newTheme = theme['name'] as String;
          final previousTheme = _selectedTheme;
          if (newTheme == previousTheme) return;

          setState(() {
            _selectedTheme = newTheme;
          });

          try {
            await context.read<AuthProvider>().updatePreferredThemeMode(
              _themeModeFromLabel(newTheme),
            );

            if (!mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: AppText('Mandhari imebadilishwa kuwa $newTheme'),
                duration: const Duration(seconds: 2),
              ),
            );
          } catch (_) {
            if (!mounted) return;
            setState(() {
              _selectedTheme = previousTheme;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: AppText('Imeshindikana kubadilisha mandhari. Jaribu tena.'),
              ),
            );
          }
        },
        child: NeumorphicCard(
          borderRadius: 20,
          color: isSelected
              ? theme['color'].withOpacity(0.1)
              : (isDark ? const Color(0xFF2F2118) : AppColors.cardBackground),
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Theme icon & preview
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(
                    color: isSelected ? theme['color'] : AppColors.glassBorder,
                    width: 2,
                  ),
                ),
                child: Stack(
                  children: [
                    // Preview colors
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              color: theme['preview'][0],
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(13),
                                bottomLeft: Radius.circular(13),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              color: theme['preview'][1],
                              borderRadius: const BorderRadius.only(
                                topRight: Radius.circular(13),
                                bottomRight: Radius.circular(13),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    // Icon overlay
                    Center(
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: theme['color'].withOpacity(0.9),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          theme['icon'],
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),

              // Theme details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText(
                      theme['name'],
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isSelected ? theme['color'] : AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    AppText(
                      theme['description'],
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark ? Colors.white70 : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),

              // Selected indicator
              if (isSelected)
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: theme['color'],
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check,
                    color: Colors.white,
                    size: 20,
                  ),
                )
              else
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.glassBorder,
                      width: 2,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

