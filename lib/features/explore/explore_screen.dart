import 'dart:async';
import 'package:flutter/material.dart';
import '../../shared/widgets/app_text.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import '../../core/auth/auth_provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/i18n/app_i18n.dart';
import '../../core/services/tts_service.dart';
import '../stories/data/story_repository.dart';
import '../../shared/widgets/glassmorphic_container.dart';
import '../../shared/widgets/neumorphic_widgets.dart';
import '../../shared/widgets/enhanced_bottom_nav.dart';
import '../../models/story.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final StoryRepository _storyRepository = StoryRepository();
  final TextEditingController _searchController = TextEditingController();
  StreamSubscription<List<Story>>? _storiesSubscription;
  
  // Filter state
  RangeValues _priceRange = const RangeValues(0, 5000);
  String _selectedLanguage = 'Yote';
  bool _showFilters = false;
  final List<String> _languages = ['Yote', 'Kiswahili', 'English', 'Kiarabu'];
  final List<String> _tabs = ['All', ...AppConstants.storyCategories];
  int _selectedTabIndex = 0;

  List<Story> _stories = const [];

  void _openReader(Story story) {
    context.push('/ebook-reader/${story.id}', extra: story);
  }

  void _openAudio(Story story) {
    context.push('/audio-player/${story.id}', extra: story);
  }

  String _languageTagText(Story story) {
    return TTSService.languageTagLabel(story.language);
  }

  Color _languageTagColor(Story story) {
    return TTSService.normalizeLanguageCode(story.language) == 'en'
        ? AppColors.clayBlue
        : AppColors.savannaGreen;
  }

  List<Story> _storiesForTab(String category) {
    final query = _searchController.text.trim().toLowerCase();

    return _stories.where((story) {
      if (category != 'All' && story.category != category) return false;

      final inRange = story.price >= _priceRange.start && story.price <= _priceRange.end;
      if (!inRange) return false;

      if (_selectedLanguage != 'Yote' && story.language != _selectedLanguage) return false;

      if (query.isEmpty) return true;
      final title = story.title.toLowerCase();
      final author = story.author.toLowerCase();
      final desc = story.description.toLowerCase();
      return title.contains(query) || author.contains(query) || desc.contains(query);
    }).toList();
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    _tabController.addListener(() {
      if (!mounted) return;
      if (_selectedTabIndex != _tabController.index) {
        setState(() {
          _selectedTabIndex = _tabController.index;
        });
      }
    });
    _storiesSubscription = _storyRepository.streamPublishedStories(limit: 80).listen((stories) {
      if (!mounted) return;
      setState(() {
        _stories = stories;
      });
    });
  }

  @override
  void dispose() {
    _storiesSubscription?.cancel();
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isAuthor = context.watch<AuthProvider>().isAuthor;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundTop = isDark ? AppColors.backgroundDark : AppColors.backgroundLight;
    final backgroundBottom = isDark ? const Color(0xFF2A1B12) : AppColors.warmBeige;
    final primaryText = isDark ? Colors.white : AppColors.textPrimary;
    final secondaryText = isDark ? Colors.white70 : AppColors.textSecondary;
    final glassColor = isDark ? AppColors.glassDark : AppColors.glassWhite;
    final inputHint = isDark ? Colors.white60 : AppColors.textMuted;
    final filterSurface = isDark ? const Color(0xFF3A2A20) : AppColors.cardBackground;

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
              // Header
              Padding(
                padding: const EdgeInsets.all(AppConstants.paddingLarge),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText(
                      'Gundua Hadithi',
                      style: (Theme.of(context).textTheme.headlineMedium ?? const TextStyle(fontSize: 28)).copyWith(
                            fontWeight: FontWeight.bold,
                            color: primaryText,
                          ),
                    ),
                    const SizedBox(height: 8),
                    AppText(
                      'Pata hadithi mpya za kusisimua',
                      style: (Theme.of(context).textTheme.bodyLarge ?? const TextStyle(fontSize: 16)).copyWith(
                            color: secondaryText,
                          ),
                    ),
                    const SizedBox(height: 20),
                    
                    // Search bar with filter button
                    Row(
                      children: [
                        Expanded(
                          child: GlassmorphicContainer(
                            height: 55,
                            borderRadius: 28,
                            blur: 10,
                            color: glassColor,
                            borderColor: AppColors.glassBorder,
                            borderWidth: 1.5,
                            child: TextField(
                              controller: _searchController,
                              decoration: InputDecoration(
                                hintText: context.tr('Tafuta hadithi...'),
                                hintStyle: TextStyle(color: inputHint),
                                prefixIcon: const Icon(Icons.search, color: AppColors.sunsetOrange),
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                              ),
                              onChanged: (value) {
                                setState(() {});
                              },
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _showFilters = !_showFilters;
                            });
                          },
                          child: NeumorphicCard(
                            padding: const EdgeInsets.all(16),
                            borderRadius: 28,
                            color: _showFilters ? AppColors.sunsetOrange : filterSurface,
                            child: Icon(
                              Icons.tune,
                              color: _showFilters ? Colors.white : AppColors.sunsetOrange,
                              size: 22,
                            ),
                          ),
                        ),
                      ],
                    ),
                    
                    // Filters section
                    if (_showFilters) ...[
                      const SizedBox(height: 16),
                      GlassmorphicContainer(
                        borderRadius: 20,
                        blur: 10,
                        color: glassColor,
                        borderColor: AppColors.glassBorder,
                        borderWidth: 1.5,
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Price Range
                              AppText(
                                'Bei (TSh)',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: primaryText,
                                ),
                              ),
                              const SizedBox(height: 8),
                              RangeSlider(
                                values: _priceRange,
                                min: 0,
                                max: 5000,
                                divisions: 50,
                                activeColor: AppColors.sunsetOrange,
                                inactiveColor: AppColors.textMuted.withOpacity(0.2),
                                labels: RangeLabels(
                                  '${_priceRange.start.round()}',
                                  '${_priceRange.end.round()}',
                                ),
                                onChanged: (values) {
                                  setState(() {
                                    _priceRange = values;
                                  });
                                },
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  AppText(
                                    'TSh ${_priceRange.start.round()}',
                                    style: TextStyle(fontSize: 11, color: inputHint),
                                  ),
                                  AppText(
                                    'TSh ${_priceRange.end.round()}',
                                    style: TextStyle(fontSize: 11, color: inputHint),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              
                              // Language Filter
                              AppText(
                                'Lugha',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: primaryText,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: _languages.map((lang) {
                                  final isSelected = _selectedLanguage == lang;
                                  return GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _selectedLanguage = lang;
                                      });
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                      decoration: BoxDecoration(
                                        gradient: isSelected
                                            ? const LinearGradient(
                                                colors: [AppColors.sunsetOrange, AppColors.deepOrange],
                                              )
                                            : null,
                                        color: isSelected
                                            ? null
                                            : (isDark
                                                ? const Color(0x33FFFFFF)
                                                : AppColors.warmBeige.withOpacity(0.3)),
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(
                                          color: isSelected ? AppColors.sunsetOrange : AppColors.glassBorder,
                                          width: 1,
                                        ),
                                      ),
                                      child: AppText(
                                        lang,
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                                          color: isSelected ? Colors.white : primaryText,
                                        ),
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                              
                              const SizedBox(height: 12),
                              
                              // Clear filters button
                              Center(
                                child: TextButton.icon(
                                  onPressed: () {
                                    setState(() {
                                      _priceRange = const RangeValues(0, 5000);
                                      _selectedLanguage = 'Yote';
                                    });
                                  },
                                  icon: const Icon(Icons.clear_all, size: 16),
                                  label: AppText('Futa Chujio', style: TextStyle(fontSize: 12)),
                                  style: TextButton.styleFrom(
                                    foregroundColor: AppColors.sunsetOrange,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              // Category tabs (neumorphic chips)
              Container(
                margin: const EdgeInsets.symmetric(horizontal: AppConstants.paddingLarge),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  child: Row(
                    children: List.generate(_tabs.length, (index) {
                      final isSelected = _selectedTabIndex == index;
                      return Padding(
                        padding: EdgeInsets.only(right: index == _tabs.length - 1 ? 0 : 10),
                        child: GestureDetector(
                          onTap: () {
                            _tabController.animateTo(index);
                            setState(() {
                              _selectedTabIndex = index;
                            });
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 220),
                            curve: Curves.easeOutCubic,
                            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(22),
                              gradient: isSelected
                                  ? const LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [AppColors.sunsetOrange, AppColors.deepOrange],
                                    )
                                  : LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: isDark
                                          ? const [Color(0xFF3A2A20), Color(0xFF2D211A)]
                                          : const [Color(0xFFFFF6E8), Color(0xFFF8ECDC)],
                                    ),
                              boxShadow: isSelected
                                  ? [
                                      BoxShadow(
                                        color: AppColors.sunsetOrange.withOpacity(0.3),
                                        blurRadius: 16,
                                        offset: const Offset(0, 8),
                                      ),
                                    ]
                                  : [
                                      BoxShadow(
                                        color: isDark
                                            ? AppColors.sandBrown.withOpacity(0.12)
                                            : Colors.white,
                                        offset: const Offset(-4, -4),
                                        blurRadius: 8,
                                      ),
                                      BoxShadow(
                                        color: isDark
                                            ? Colors.black.withOpacity(0.35)
                                            : Colors.brown.withOpacity(0.15),
                                        offset: const Offset(4, 4),
                                        blurRadius: 8,
                                      ),
                                    ],
                            ),
                            child: AppText(
                              _tabs[index],
                              style: TextStyle(
                                color: isSelected ? Colors.white : secondaryText,
                                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Stories grid
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: _tabs.map((category) {
                    final stories = _storiesForTab(category);
                    if (stories.isEmpty) {
                      return const Center(
                        child: AppText('Hakuna hadithi zilizopatikana.'),
                      );
                    }

                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: AppConstants.paddingLarge),
                      child: GridView.builder(
                        padding: const EdgeInsets.only(bottom: 100),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.56,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                        ),
                        itemCount: stories.length,
                        itemBuilder: (context, index) {
                          return _buildExploreCard(stories[index]);
                        },
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: EnhancedBottomNav(
        currentIndex: 1,
        isAuthor: isAuthor,
        onTap: (index) {
          switch (index) {
            case 0:
              context.go('/home');
              break;
            case 1:
              // Already on explore
              break;
            case 2:
              context.go('/saved');
              break;
            case 3:
              context.go('/profile');
              break;
            case 4:
              context.go('/author-dashboard');
              break;
          }
        },
      ),
    );
  }

  Widget _buildExploreCard(Story story) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor = isDark ? const Color(0xFF2F2118) : AppColors.cardBackground;
    final mutedColor = isDark ? Colors.white70 : AppColors.textMuted;
    final placeholderAccent = isDark ? AppColors.warmBeige : Colors.white;

    return GestureDetector(
      onTap: () {
        _openReader(story);
      },
      child: NeumorphicCard(
        borderRadius: 24,
        padding: EdgeInsets.zero,
        color: surfaceColor,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cover
            Expanded(
              flex: 3,
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                child: Stack(
                  children: [
                    story.coverImage.isNotEmpty
                        ? CachedNetworkImage(
                            imageUrl: story.coverImage,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: double.infinity,
                            placeholder: (context, url) => Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    AppColors.clayBlue.withOpacity(0.7),
                                    AppColors.clayPink.withOpacity(0.7),
                                  ],
                                ),
                              ),
                              child: Center(
                                child: CircularProgressIndicator(color: placeholderAccent),
                              ),
                            ),
                            errorWidget: (context, url, error) => Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    AppColors.clayBlue.withOpacity(0.7),
                                    AppColors.clayPink.withOpacity(0.7),
                                  ],
                                ),
                              ),
                              child: Center(
                                child: Icon(
                                  Icons.auto_stories,
                                  size: 50,
                                  color: placeholderAccent,
                                ),
                              ),
                            ),
                          )
                        : Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  AppColors.clayBlue.withOpacity(0.7),
                                  AppColors.clayPink.withOpacity(0.7),
                                ],
                              ),
                            ),
                            child: Center(
                              child: Icon(
                                Icons.auto_stories,
                                size: 50,
                                color: placeholderAccent,
                              ),
                            ),
                          ),
                    if (story.hasAudio)
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: const BoxDecoration(
                            color: AppColors.sunsetOrange,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.headphones,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                      ),
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: _languageTagColor(story),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.18),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: AppText(
                          _languageTagText(story),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.4,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Info
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText(
                      story.title,
                      style: (Theme.of(context).textTheme.bodyMedium ?? const TextStyle(fontSize: 14)).copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    AppText(
                      story.author,
                      style: TextStyle(fontSize: 10, color: mutedColor),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.star, color: AppColors.warning, size: 12),
                            const SizedBox(width: 2),
                            AppText(
                              '${story.rating}',
                              style: TextStyle(fontSize: 10, color: mutedColor),
                            ),
                          ],
                        ),
                        Flexible(
                          child: AppText(
                            'TSh ${story.price.toStringAsFixed(0)}',
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.sunsetOrange,
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () => _openReader(story),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 5),
                              decoration: BoxDecoration(
                                color: AppColors.savannaGreen,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.menu_book_rounded, size: 12, color: Colors.white),
                                    SizedBox(width: 2),
                                    AppText(
                                      'Read',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 9.5,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: GestureDetector(
                            onTap: () => _openAudio(story),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 5),
                              decoration: BoxDecoration(
                                color: AppColors.sunsetOrange,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.headphones, size: 12, color: Colors.white),
                                    const SizedBox(width: 2),
                                    AppText(
                                      'Listen',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 9.5,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
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

