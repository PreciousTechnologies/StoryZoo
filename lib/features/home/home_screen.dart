import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import '../../shared/widgets/app_text.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import '../../core/auth/auth_provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/services/tts_service.dart';
import '../../core/utils/responsive_utils.dart';
import '../stories/data/story_repository.dart';
import '../../shared/widgets/glassmorphic_container.dart';
import '../../shared/widgets/neumorphic_widgets.dart';
import '../../shared/widgets/enhanced_bottom_nav.dart';
import '../../models/story.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late PageController _pageController;
  final StoryRepository _storyRepository = StoryRepository();

  StreamSubscription<List<Story>>? _storiesSubscription;
  int _currentPage = 0;
  int _selectedNavIndex = 0;
  String _selectedCategory = 'All';

  final List<String> _categories = ['Watoto', 'Elimu', 'Imani', 'Hadithi', 'Biashara'];
  final Map<String, IconData> _categoryIcons = {
    'Watoto': Icons.child_care,
    'Elimu': Icons.school,
    'Imani': Icons.mosque,
    'Hadithi': Icons.auto_stories,
    'Biashara': Icons.business_center,
  };

  List<Story> _allStories = const [];

  List<Story> get _featuredStories {
    if (_allStories.length <= 5) return _allStories;
    return _allStories.take(5).toList();
  }

  List<Story> get _gridStories {
    if (_selectedCategory == 'All') return _allStories;
    return _allStories.where((story) => story.category == _selectedCategory).toList();
  }

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

  @override
  void initState() {
    super.initState();
    // Initialize PageController with a default value - will be recreated in build() with responsive value
    _pageController = PageController(viewportFraction: 0.85);
    
    _storiesSubscription = _storyRepository.streamPublishedStories(limit: 30).listen((stories) {
      if (!mounted) return;
      setState(() {
        _allStories = stories;
        if (_currentPage >= _featuredStories.length) {
          _currentPage = _featuredStories.isEmpty ? 0 : _featuredStories.length - 1;
        }
      });
    });

    _pageController.addListener(() {
      if (_featuredStories.isEmpty) return;
      final page = _pageController.page;
      if (page == null || !mounted) return;
      final next = page.round().clamp(0, _featuredStories.length - 1);
      if (_currentPage == next) return;
      setState(() {
        _currentPage = next;
      });
    });
  }

  @override
  void dispose() {
    _storiesSubscription?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isAuthor = context.watch<AuthProvider>().isAuthor;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundTop = isDark ? AppColors.backgroundDark : AppColors.backgroundLight;
    final backgroundBottom = isDark ? const Color(0xFF2A1B12) : AppColors.warmBeige;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              backgroundTop,
              backgroundBottom,
            ],
          ),
        ),
        child: SafeArea(
          child: CustomScrollView(
            slivers: [
              // App Bar
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.all(ResponsiveUtils.getPadding(context)),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AppText(
                            'Karibu! 👋',
                            style: (Theme.of(context).textTheme.headlineSmall ?? const TextStyle(fontSize: 20)).copyWith(
                                  color: isDark ? Colors.white70 : AppColors.textSecondary,
                                ),
                          ),
                          AppText(
                            'Story Zoo',
                            style: (Theme.of(context).textTheme.displaySmall ?? const TextStyle(fontSize: 32)).copyWith(
                                  color: isDark ? Colors.white : AppColors.textPrimary,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          NeumorphicIconButton(
                            icon: Icons.search,
                            size: ResponsiveUtils.getIconButtonSize(context),
                            onPressed: () {
                              // Navigate to search
                            },
                          ),
                          SizedBox(width: ResponsiveUtils.getSpacing(context)),
                          NeumorphicIconButton(
                            icon: Icons.notifications_outlined,
                            size: ResponsiveUtils.getIconButtonSize(context),
                            onPressed: () {
                              // Show notifications
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // Featured Stories Carousel
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: ResponsiveUtils.getPadding(context)),
                      child: AppText(
                        'Hadithi Maarufu',
                        style: (Theme.of(context).textTheme.headlineMedium ?? const TextStyle(fontSize: 24)).copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ),
                    SizedBox(height: ResponsiveUtils.getSpacing(context)),
                    if (_featuredStories.isEmpty)
                      SizedBox(
                        height: ResponsiveUtils.getFeaturedCardImageHeight(context) * 0.7,
                        child: const Center(
                          child: AppText('Hakuna hadithi zilizochapishwa kwa sasa.'),
                        ),
                      )
                    else
                      SizedBox(
                        height: ResponsiveUtils.getCarouselHeight(context),
                        child: PageView.builder(
                          controller: _pageController,
                          itemCount: _featuredStories.length,
                          itemBuilder: (context, index) {
                            return _buildFeaturedCard(_featuredStories[index], index);
                          },
                        ),
                      ),
                    SizedBox(height: ResponsiveUtils.getSpacing(context)),
                    // Page indicators
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        _featuredStories.length,
                        (index) => _buildPageIndicator(index),
                      ),
                    ),
                  ],
                ),
              ),

              SliverToBoxAdapter(child: SizedBox(height: ResponsiveUtils.getPadding(context))),

              // Category Cards Section
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: ResponsiveUtils.getPadding(context)),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          AppText(
                            'Kategoria za Hadithi',
                            style: (Theme.of(context).textTheme.titleLarge ?? const TextStyle(fontSize: 20)).copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          TextButton(
                            onPressed: () {
                              context.go('/explore');
                            },
                            child: AppText('Angalia Zote'),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: ResponsiveUtils.getSpacing(context)),
                    SizedBox(
                      height: ResponsiveUtils.getHorizontalItemHeight(context),
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: EdgeInsets.symmetric(horizontal: ResponsiveUtils.getPadding(context)),
                        itemCount: _categories.length,
                        itemBuilder: (context, index) {
                          return _buildCategoryCard(_categories[index], _categoryIcons[_categories[index]]!);
                        },
                      ),
                    ),
                  ],
                ),
              ),

              SliverToBoxAdapter(child: SizedBox(height: ResponsiveUtils.getPadding(context))),

              // Quick Filter Chips
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: ResponsiveUtils.getPadding(context)),
                      child: AppText(
                        'Chagua Hadithi',
                        style: (Theme.of(context).textTheme.titleMedium ?? const TextStyle(fontSize: 16)).copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ),
                    SizedBox(height: ResponsiveUtils.getSpacing(context)),
                    SizedBox(
                      height: ResponsiveUtils.getButtonHeight(context) * 0.8,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: EdgeInsets.symmetric(horizontal: ResponsiveUtils.getSpacing(context)),
                        itemCount: AppConstants.storyCategories.length + 1,
                        itemBuilder: (context, index) {
                          if (index == 0) {
                            return _buildCategoryChip('All');
                          }
                          return _buildCategoryChip(AppConstants.storyCategories[index - 1]);
                        },
                      ),
                    ),
                  ],
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: AppConstants.paddingLarge)),

              // Story Grid
              if (_gridStories.isEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: ResponsiveUtils.getPadding(context)),
                    child: AppText('Hakuna hadithi kwenye kategoria hii.'),
                  ),
                )
              else
                SliverPadding(
                  padding: EdgeInsets.symmetric(horizontal: ResponsiveUtils.getPadding(context)),
                  sliver: SliverGrid(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: ResponsiveUtils.getGridColumnCount(context),
                      childAspectRatio: ResponsiveUtils.getGridAspectRatio(context),
                      crossAxisSpacing: ResponsiveUtils.getSpacing(context),
                      mainAxisSpacing: ResponsiveUtils.getSpacing(context),
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        return _buildStoryCard(_gridStories[index]);
                      },
                      childCount: _gridStories.length,
                    ),
                  ),
                ),

              SliverToBoxAdapter(child: SizedBox(height: ResponsiveUtils.getPadding(context))),
            ],
          ),
        ),
      ),
      bottomNavigationBar: EnhancedBottomNav(
        currentIndex: _selectedNavIndex,
        isAuthor: isAuthor,
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

  Widget _buildFeaturedCard(Story story, int index) {
    final scale = _currentPage == index ? 1.0 : 0.9;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor = isDark ? const Color(0xFF2F2118) : AppColors.cardBackground;
    final mutedColor = isDark ? Colors.white70 : AppColors.textMuted;
    final placeholderAccent = isDark ? AppColors.warmBeige : Colors.white;
    
    return TweenAnimationBuilder<double>(
      duration: AppConstants.mediumAnimation,
      tween: Tween(begin: scale, end: scale),
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: GestureDetector(
            onTap: () {
              _openReader(story);
            },
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 8),
              child: NeumorphicCard(
                borderRadius: 30,
                color: surfaceColor,
                padding: EdgeInsets.zero,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Cover image
                    SizedBox(
                      height: ResponsiveUtils.getFeaturedCardImageHeight(context),
                      child: Stack(
                        children: [
                          ClipRRect(
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
                            child: story.coverImage.isNotEmpty
                                ? CachedNetworkImage(
                                    imageUrl: story.coverImage,
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                    height: ResponsiveUtils.getFeaturedCardImageHeight(context),
                                    placeholder: (context, url) => Container(
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            AppColors.sunsetOrange.withOpacity(0.6),
                                            AppColors.savannaGreen.withOpacity(0.6),
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
                                          colors: [
                                            AppColors.sunsetOrange.withOpacity(0.6),
                                            AppColors.savannaGreen.withOpacity(0.6),
                                          ],
                                        ),
                                      ),
                                      child: Center(
                                        child: Icon(
                                          Icons.menu_book_rounded,
                                          size: 80,
                                          color: placeholderAccent,
                                        ),
                                      ),
                                    ),
                                  )
                                : Container(
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          AppColors.sunsetOrange.withOpacity(0.6),
                                          AppColors.savannaGreen.withOpacity(0.6),
                                        ],
                                      ),
                                    ),
                                    child: Center(
                                      child: Icon(
                                        Icons.menu_book_rounded,
                                        size: 80,
                                        color: placeholderAccent,
                                      ),
                                    ),
                                  ),
                          ),
                          if (story.hasAudio)
                            Positioned(
                              top: 12,
                              right: 12,
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: const BoxDecoration(
                                  color: AppColors.sunsetOrange,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.headphones,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                            ),
                          Positioned(
                            top: 12,
                            left: 12,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: _languageTagColor(story),
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.18),
                                    blurRadius: 6,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: AppText(
                                _languageTagText(story),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.6,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.all(ResponsiveUtils.getSpacing(context) * 0.5),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            AppText(
                              story.title,
                              style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            AppText(
                              story.author,
                              style: TextStyle(
                                fontSize: 12,
                                color: mutedColor,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                const Icon(Icons.star, color: AppColors.warning, size: 14),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: AppText(
                                    '${story.rating} (${story.totalReviews})',
                                    style: const TextStyle(fontSize: 11),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Flexible(
                                  child: AppText(
                                    'TSh ${story.price.toStringAsFixed(0)}',
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: AppColors.sunsetOrange,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Expanded(
                                  child: NeumorphicButton(
                                    onPressed: () => _openReader(story),
                                    height: 32,
                                    borderRadius: 14,
                                    color: AppColors.savannaGreen,
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                                    child: const FittedBox(
                                      fit: BoxFit.scaleDown,
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(Icons.menu_book_rounded, color: Colors.white, size: 14),
                                          SizedBox(width: 4),
                                          AppText(
                                            'Read',
                                            style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: NeumorphicButton(
                                    onPressed: () => _openAudio(story),
                                    height: 32,
                                    borderRadius: 14,
                                    color: story.hasAudio ? AppColors.sunsetOrange : mutedColor,
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                                    child: FittedBox(
                                      fit: BoxFit.scaleDown,
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          const Icon(Icons.headphones, color: Colors.white, size: 14),
                                          const SizedBox(width: 4),
                                          AppText(
                                            'Listen',
                                            style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700),
                                          ),
                                        ],
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
            ),
          ),
        );
      },
    );
  }

  Widget _buildPageIndicator(int index) {
    return AnimatedContainer(
      duration: AppConstants.mediumAnimation,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      height: 8,
      width: _currentPage == index ? 24 : 8,
      decoration: BoxDecoration(
        color: _currentPage == index ? AppColors.sunsetOrange : AppColors.textMuted.withOpacity(0.3),
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }

  Widget _buildCategoryChip(String category) {
    final isSelected = _selectedCategory == category;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final chipBackground = isDark ? const Color(0x55FFFFFF) : AppColors.glassWhite;
    final chipTextColor = isDark ? Colors.white : AppColors.textPrimary;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedCategory = category;
        });
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 6),
        child: GlassmorphicContainer(
          height: 50,
          borderRadius: 25,
          blur: 8,
          color: isSelected
              ? AppColors.sunsetOrange.withOpacity(0.3)
              : chipBackground,
          borderColor: isSelected ? AppColors.sunsetOrange : AppColors.glassBorder,
          borderWidth: isSelected ? 2 : 1.5,
          padding: EdgeInsets.symmetric(
            horizontal: ResponsiveUtils.getSpacing(context) * 1.2,
            vertical: ResponsiveUtils.getSpacing(context) * 0.7,
          ),
          child: Center(
            child: AppText(
              category,
              style: (Theme.of(context).textTheme.bodyMedium ?? const TextStyle(fontSize: 14)).copyWith(
                  color: isSelected ? AppColors.sunsetOrange : chipTextColor,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStoryCard(Story story) {
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
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                    child: story.coverImage.isNotEmpty
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
                  ),
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _languageTagColor(story),
                        borderRadius: BorderRadius.circular(12),
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
            // Info
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: AppText(
                        story.title,
                        style: (Theme.of(context).textTheme.bodyMedium ?? const TextStyle(fontSize: 14)).copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.star, color: AppColors.warning, size: 12),
                              const SizedBox(width: 2),
                              AppText(
                                '${story.rating}',
                                style: TextStyle(fontSize: 11, color: mutedColor),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 4),
                        Flexible(
                          child: AppText(
                            'TSh ${story.price}',
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
                              padding: const EdgeInsets.symmetric(vertical: 6),
                              decoration: BoxDecoration(
                                color: AppColors.savannaGreen,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.chrome_reader_mode, color: Colors.white, size: 12),
                                    SizedBox(width: 3),
                                    AppText(
                                      'Read',
                                      style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w700),
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
                              padding: const EdgeInsets.symmetric(vertical: 6),
                              decoration: BoxDecoration(
                                color: story.hasAudio ? AppColors.sunsetOrange : mutedColor,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.headphones, color: Colors.white, size: 12),
                                    const SizedBox(width: 3),
                                    AppText(
                                      'Listen',
                                      style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w700),
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

  Widget _buildCategoryCard(String category, IconData icon) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor = isDark ? const Color(0xFF2F2118) : AppColors.cardBackground;

    final colors = [
      [AppColors.clayPink, AppColors.peachOrange],
      [AppColors.clayBlue, AppColors.info],
      [AppColors.clayYellow, AppColors.warning],
      [AppColors.clayMint, AppColors.savannaGreen],
      [AppColors.clayPurple, AppColors.sunsetOrange],
    ];
    final colorIndex = _categories.indexOf(category) % colors.length;
    final categoryWidth = ResponsiveUtils.getHorizontalItemHeight(context) * 0.9;
    final categoryMargin = ResponsiveUtils.getSpacing(context) * 0.5;

    return Container(
      width: categoryWidth,
      margin: EdgeInsets.only(right: categoryMargin),
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedCategory = category;
          });
        },
        child: NeumorphicCard(
          borderRadius: ResponsiveUtils.getBorderRadius(context),
          padding: EdgeInsets.all(ResponsiveUtils.getSpacing(context) * 0.5),
          color: surfaceColor,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(ResponsiveUtils.getSpacing(context) * 0.5),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: colors[colorIndex],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(ResponsiveUtils.getBorderRadius(context) * 0.6),
                ),
                child: Icon(icon, color: Colors.white, size: ResponsiveUtils.getIconButtonSize(context) * 0.5),
              ),
              SizedBox(height: ResponsiveUtils.getSpacing(context) * 0.3),
              AppText(
                category,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

