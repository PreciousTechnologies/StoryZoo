import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
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
  final PageController _pageController = PageController(viewportFraction: 0.85);
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

  // Mock data - Replace with actual API calls
  final List<Story> _featuredStories = [
    Story(
      id: '1',
      title: 'Simba Mjanja',
      description: 'Hadithi ya simba aliyejifunza kuwa na hekima',
      author: 'Juma Bakari',
      authorId: 'author1',
      category: 'Adventure',
      coverImage: 'https://images.unsplash.com/photo-1614027164847-1b28cfe1df60?w=800&q=80',
      price: 2000,
      rating: 4.5,
      totalReviews: 120,
      hasAudio: true,
      publishedDate: DateTime.now().subtract(const Duration(days: 7)),
    ),
    Story(
      id: '2',
      title: 'Pembe ya Ndovu',
      description: 'Safari ya kutafuta pembe iliyopotea',
      author: 'Amina Hassan',
      authorId: 'author2',
      category: 'Folklore',
      coverImage: 'https://images.unsplash.com/photo-1564760055775-d63b17a55c44?w=800&q=80',
      price: 1500,
      rating: 4.8,
      totalReviews: 85,
      hasAudio: true,
      publishedDate: DateTime.now().subtract(const Duration(days: 14)),
    ),
    Story(
      id: '3',
      title: 'Twiga na Sungura',
      description: 'Hadithi ya urafiki na ushirikiano',
      author: 'Mohamed Ali',
      authorId: 'author3',
      category: 'Moral Stories',
      coverImage: 'https://images.unsplash.com/photo-1551316679-9c6ae9dec224?w=800&q=80',
      price: 1000,
      rating: 4.3,
      totalReviews: 65,
      hasAudio: false,
      publishedDate: DateTime.now().subtract(const Duration(days: 21)),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _pageController.addListener(() {
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
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.backgroundLight,
              AppColors.warmBeige,
            ],
          ),
        ),
        child: SafeArea(
          child: CustomScrollView(
            slivers: [
              // App Bar
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(AppConstants.paddingLarge),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Karibu! 👋',
                            style: (Theme.of(context).textTheme.headlineSmall ?? const TextStyle(fontSize: 20)).copyWith(
                                  color: AppColors.textSecondary,
                                ),
                          ),
                          Text(
                            'Story Zoo',
                            style: (Theme.of(context).textTheme.displaySmall ?? const TextStyle(fontSize: 32)).copyWith(
                                  color: AppColors.textPrimary,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          NeumorphicIconButton(
                            icon: Icons.search,
                            size: 50,
                            onPressed: () {
                              // Navigate to search
                            },
                          ),
                          const SizedBox(width: 12),
                          NeumorphicIconButton(
                            icon: Icons.notifications_outlined,
                            size: 50,
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
                      padding: const EdgeInsets.symmetric(horizontal: AppConstants.paddingLarge),
                      child: Text(
                        'Hadithi Maarufu',
                        style: (Theme.of(context).textTheme.headlineMedium ?? const TextStyle(fontSize: 24)).copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ),
                    const SizedBox(height: AppConstants.paddingMedium),
                    SizedBox(
                      height: 320,
                      child: PageView.builder(
                        controller: _pageController,
                        itemCount: _featuredStories.length,
                        itemBuilder: (context, index) {
                          return _buildFeaturedCard(_featuredStories[index], index);
                        },
                      ),
                    ),
                    const SizedBox(height: AppConstants.paddingMedium),
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

              const SliverToBoxAdapter(child: SizedBox(height: AppConstants.paddingLarge)),

              // Category Cards Section
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: AppConstants.paddingLarge),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Kategoria za Hadithi',
                            style: (Theme.of(context).textTheme.titleLarge ?? const TextStyle(fontSize: 20)).copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          TextButton(
                            onPressed: () {
                              context.go('/explore');
                            },
                            child: const Text('Angalia Zote'),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 110,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: AppConstants.paddingLarge),
                        itemCount: _categories.length,
                        itemBuilder: (context, index) {
                          return _buildCategoryCard(_categories[index], _categoryIcons[_categories[index]]!);
                        },
                      ),
                    ),
                  ],
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: AppConstants.paddingLarge)),

              // Quick Filter Chips
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: AppConstants.paddingLarge),
                      child: Text(
                        'Chagua Hadithi',
                        style: (Theme.of(context).textTheme.titleMedium ?? const TextStyle(fontSize: 16)).copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ),
                    const SizedBox(height: AppConstants.paddingMedium),
                    SizedBox(
                      height: 45,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: AppConstants.paddingMedium),
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
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: AppConstants.paddingLarge),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.7,
                    crossAxisSpacing: AppConstants.paddingMedium,
                    mainAxisSpacing: AppConstants.paddingMedium,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      return _buildStoryCard(_featuredStories[index % _featuredStories.length]);
                    },
                    childCount: 6,
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: AppConstants.paddingLarge)),
            ],
          ),
        ),
      ),
      bottomNavigationBar: EnhancedBottomNav(
        currentIndex: _selectedNavIndex,
        isAuthor: true, // Set to true to show author dashboard button
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
    
    return TweenAnimationBuilder<double>(
      duration: AppConstants.mediumAnimation,
      tween: Tween(begin: scale, end: scale),
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: GestureDetector(
            onTap: () {
              context.push('/story/${story.id}', extra: story);
            },
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 8),
              child: NeumorphicCard(
                borderRadius: 30,
                color: AppColors.cardBackground,
                padding: EdgeInsets.zero,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Cover image
                    SizedBox(
                      height: 200,
                      child: Stack(
                        children: [
                          ClipRRect(
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
                            child: story.coverImage.isNotEmpty
                                ? CachedNetworkImage(
                                    imageUrl: story.coverImage,
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                    height: 200,
                                    placeholder: (context, url) => Container(
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            AppColors.sunsetOrange.withOpacity(0.6),
                                            AppColors.savannaGreen.withOpacity(0.6),
                                          ],
                                        ),
                                      ),
                                      child: const Center(
                                        child: CircularProgressIndicator(color: Colors.white),
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
                                      child: const Center(
                                        child: Icon(
                                          Icons.menu_book_rounded,
                                          size: 80,
                                          color: Colors.white,
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
                                    child: const Center(
                                      child: Icon(
                                        Icons.menu_book_rounded,
                                        size: 80,
                                        color: Colors.white,
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
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            story.title,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            story.author,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textMuted,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              const Icon(Icons.star, color: AppColors.warning, size: 14),
                              const SizedBox(width: 4),
                              Flexible(
                                child: Text(
                                  '${story.rating} (${story.totalReviews})',
                                  style: const TextStyle(fontSize: 11),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'TSh ${story.price}',
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: AppColors.sunsetOrange,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
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
              : AppColors.glassWhite,
          borderColor: isSelected ? AppColors.sunsetOrange : AppColors.glassBorder,
          borderWidth: isSelected ? 2 : 1.5,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Center(
            child: Text(
              category,
              style: (Theme.of(context).textTheme.bodyMedium ?? const TextStyle(fontSize: 14)).copyWith(
                    color: isSelected ? AppColors.sunsetOrange : AppColors.textPrimary,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStoryCard(Story story) {
    return GestureDetector(
      onTap: () {
        context.push('/story/${story.id}', extra: story);
      },
      child: NeumorphicCard(
        borderRadius: 24,
        padding: EdgeInsets.zero,
        color: AppColors.cardBackground,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cover
            Expanded(
              flex: 3,
              child: ClipRRect(
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
                          child: const Center(
                            child: CircularProgressIndicator(color: Colors.white),
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
                          child: const Center(
                            child: Icon(
                              Icons.auto_stories,
                              size: 50,
                              color: Colors.white,
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
                        child: const Center(
                          child: Icon(
                            Icons.auto_stories,
                            size: 50,
                            color: Colors.white,
                          ),
                        ),
                      ),
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
                      child: Text(
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
                              Text(
                                '${story.rating}',
                                style: const TextStyle(fontSize: 11),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
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
    final colors = [
      [AppColors.clayPink, AppColors.peachOrange],
      [AppColors.clayBlue, AppColors.info],
      [AppColors.clayYellow, AppColors.warning],
      [AppColors.clayMint, AppColors.savannaGreen],
      [AppColors.clayPurple, AppColors.sunsetOrange],
    ];
    final colorIndex = _categories.indexOf(category) % colors.length;

    return Container(
      width: 100,
      margin: const EdgeInsets.only(right: 12),
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedCategory = category;
          });
        },
        child: NeumorphicCard(
          borderRadius: 20,
          padding: const EdgeInsets.all(12),
          color: AppColors.cardBackground,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: colors[colorIndex],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: Colors.white, size: 24),
              ),
              const SizedBox(height: 8),
              Text(
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
