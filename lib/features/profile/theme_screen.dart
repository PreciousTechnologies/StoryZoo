import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../shared/widgets/neumorphic_widgets.dart';

class ThemeScreen extends StatefulWidget {
  const ThemeScreen({super.key});

  @override
  State<ThemeScreen> createState() => _ThemeScreenState();
}

class _ThemeScreenState extends State<ThemeScreen> {
  String _selectedTheme = 'Mwanga';

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
                            'Mandhari',
                            style: (Theme.of(context).textTheme.headlineSmall ?? const TextStyle(fontSize: 24)).copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          Text(
                            'Chagua mandhari',
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
                    // Theme options
                    ..._themes.map((theme) => _buildThemeCard(theme)).toList(),

                    const SizedBox(height: 32),

                    // Additional settings
                    const Text(
                      'Mipangilio ya Ziada',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),

                    NeumorphicCard(
                      borderRadius: 20,
                      color: AppColors.cardBackground,
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
                                Text(
                                  'Mandhari ya AMOLED',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
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
                                const SnackBar(content: Text('Itakuwa inapatikana hivi karibuni')),
                              );
                            },
                            activeColor: AppColors.sunsetOrange,
                            activeTrackColor: AppColors.sunsetOrange.withOpacity(0.5),
                          ),
                        ],
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

  Widget _buildThemeCard(Map<String, dynamic> theme) {
    final isSelected = theme['name'] == _selectedTheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedTheme = theme['name'];
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Mandhari imebadilishwa kuwa ${theme['name']}'),
              duration: const Duration(seconds: 2),
            ),
          );
        },
        child: NeumorphicCard(
          borderRadius: 20,
          color: isSelected ? theme['color'].withOpacity(0.1) : AppColors.cardBackground,
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
                    Text(
                      theme['name'],
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isSelected ? theme['color'] : AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      theme['description'],
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
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
