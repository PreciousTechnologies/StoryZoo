import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/auth/auth_provider.dart';
import '../../shared/widgets/app_text.dart';
import '../../shared/widgets/glassmorphic_container.dart';
import '../../shared/widgets/micro_interactions.dart';
import '../../shared/widgets/neumorphic_widgets.dart';

class LanguageScreen extends StatefulWidget {
  const LanguageScreen({super.key});

  @override
  State<LanguageScreen> createState() => _LanguageScreenState();
}

class _LanguageScreenState extends State<LanguageScreen> {
  String _selectedLanguageCode = 'sw';
  bool _isSaving = false;

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
  ];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final providerCode = context.read<AuthProvider>().preferredLanguage;
    if (!_isSaving) {
      _selectedLanguageCode = providerCode == 'en' ? 'en' : 'sw';
    }
  }

  String _languageName(String code) {
    final language = _languages.firstWhere(
      (item) => item['code'] == code,
      orElse: () => _languages.first,
    );
    return (language['name'] ?? 'Kiswahili').toString();
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
                            'Lugha',
                            style: (Theme.of(context).textTheme.headlineSmall ?? const TextStyle(fontSize: 24)).copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          AppText(
                            'Chagua lugha',
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
                              color: AppColors.savannaGreen.withOpacity(0.14),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.translate_rounded, color: AppColors.savannaGreen),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const AppText('Lugha inayotumika', style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
                                const SizedBox(height: 2),
                                AppText(_languageName(_selectedLanguageCode), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                              ],
                            ),
                          ),
                        ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 18),

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
                            child: AppText(
                              'Badilisha lugha itabadilisha lugha ya programu, maudhui, na sauti za lugha',
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

                    // Voice model info card
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
                            child: const Icon(Icons.volume_up, color: AppColors.info, size: 24),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const AppText(
                                  'Audio Voice Model',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                AppText(
                                  _selectedLanguageCode == 'en'
                                      ? 'English (en_US-lessac-medium)'
                                      : 'Kiswahili (sw_CD-lanfrica-medium)',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Language list
                    ..._languages.map((language) {
                      final index = _languages.indexOf(language);
                      return StaggeredFadeSlide(
                        order: index + 1,
                        child: _buildLanguageCard(language),
                      );
                    }).toList(),

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

  Widget _buildLanguageCard(Map<String, dynamic> language) {
    final languageCode = (language['code'] ?? 'sw').toString();
    final languageName = (language['name'] ?? '').toString();
    final isSelected = languageCode == _selectedLanguageCode;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: GestureDetector(
        onTap: _isSaving
            ? null
            : () async {
                final provider = context.read<AuthProvider>();
                final newCode = languageCode == 'en' ? 'en' : 'sw';
                if (newCode == _selectedLanguageCode) return;

                setState(() {
                  _selectedLanguageCode = newCode;
                  _isSaving = true;
                });

                try {
                  await provider.updatePreferredLanguage(newCode);
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: AppText('Lugha imebadilishwa kuwa $languageName'),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                } catch (_) {
                  if (!mounted) return;
                  setState(() {
                    _selectedLanguageCode = provider.preferredLanguage == 'en' ? 'en' : 'sw';
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: AppText('Imeshindikana kubadilisha lugha. Jaribu tena.'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                } finally {
                  if (mounted) {
                    setState(() {
                      _isSaving = false;
                    });
                  }
                }
              },
        child: NeumorphicCard(
          borderRadius: 20,
          color: isSelected
              ? AppColors.sunsetOrange.withOpacity(0.1)
              : (isDark ? const Color(0xFF2F2118) : AppColors.cardBackground),
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Flag
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF3A2A20) : Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(
                    color: isSelected ? AppColors.sunsetOrange : AppColors.glassBorder,
                    width: 2,
                  ),
                ),
                child: Center(
                  child: AppText(
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
                    AppText(
                      languageName,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isSelected ? AppColors.sunsetOrange : AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    AppText(
                      (language['nativeName'] ?? '').toString(),
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

