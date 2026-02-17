import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../shared/widgets/glassmorphic_container.dart';
import '../../shared/widgets/neumorphic_widgets.dart';

class LanguageScreen extends StatefulWidget {
  const LanguageScreen({super.key});

  @override
  State<LanguageScreen> createState() => _LanguageScreenState();
}

class _LanguageScreenState extends State<LanguageScreen> {
  String _selectedLanguage = 'Kiswahili';

  final List<Map<String, dynamic>> _languages = [
    {
      'name': 'Kiswahili',
      'nativeName': 'Kiswahili',
      'code': 'sw',
      'flag': '🇹🇿',
    },
    {
      'name': 'English',
      'nativeName': 'English',
      'code': 'en',
      'flag': '🇬🇧',
    },
    {
      'name': 'Kifaransa',
      'nativeName': 'Français',
      'code': 'fr',
      'flag': '🇫🇷',
    },
    {
      'name': 'Kiarabu',
      'nativeName': 'العربية',
      'code': 'ar',
      'flag': '🇸🇦',
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
                            'Lugha',
                            style: (Theme.of(context).textTheme.headlineSmall ?? const TextStyle(fontSize: 24)).copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          Text(
                            'Chagua lugha',
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
                    // Info card
                    GlassmorphicContainer(
                      borderRadius: 20,
                      blur: 10,
                      color: AppColors.info.withOpacity(0.1),
                      borderColor: AppColors.info.withOpacity(0.3),
                      borderWidth: 1.5,
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.info.withOpacity(0.2),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.info_outline, color: AppColors.info, size: 24),
                          ),
                          const SizedBox(width: 16),
                          const Expanded(
                            child: Text(
                              'Badilisha lugha itabadilisha lugha ya programu na maudhui',
                              style: TextStyle(
                                fontSize: 13,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Language list
                    ..._languages.map((language) => _buildLanguageCard(language)).toList(),

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

  Widget _buildLanguageCard(Map<String, dynamic> language) {
    final isSelected = language['name'] == _selectedLanguage;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedLanguage = language['name'];
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Lugha imebadilishwa kuwa ${language['name']}'),
              duration: const Duration(seconds: 2),
            ),
          );
        },
        child: NeumorphicCard(
          borderRadius: 20,
          color: isSelected ? AppColors.sunsetOrange.withOpacity(0.1) : AppColors.cardBackground,
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Flag
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(
                    color: isSelected ? AppColors.sunsetOrange : AppColors.glassBorder,
                    width: 2,
                  ),
                ),
                child: Center(
                  child: Text(
                    language['flag'],
                    style: const TextStyle(fontSize: 32),
                  ),
                ),
              ),
              const SizedBox(width: 16),

              // Language name
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      language['name'],
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isSelected ? AppColors.sunsetOrange : AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      language['nativeName'],
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
                  decoration: const BoxDecoration(
                    color: AppColors.sunsetOrange,
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
