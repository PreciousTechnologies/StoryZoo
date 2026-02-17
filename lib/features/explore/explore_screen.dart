import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
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
  final TextEditingController _searchController = TextEditingController();
  
  // Filter state
  RangeValues _priceRange = const RangeValues(0, 5000);
  String _selectedLanguage = 'Yote';
  bool _showFilters = false;
  final List<String> _languages = ['Yote', 'Kiswahili', 'English', 'Kiarabu'];

  // Mock categories with stories
  final Map<String, List<Story>> _categorizedStories = {
    'Adventure': [
      Story(
        id: 'adv1',
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
        id: 'adv2',
        title: 'Safari ya Mto',
        description: 'Wanyama wa porini wanaenda safarini',
        author: 'Fatuma Said',
        authorId: 'author4',
        category: 'Adventure',
        coverImage: 'https://images.unsplash.com/photo-1535338454770-6f8c583cd0a4?w=800&q=80',
        price: 1800,
        rating: 4.7,
        totalReviews: 95,
        hasAudio: true,
        publishedDate: DateTime.now().subtract(const Duration(days: 3)),
      ),
    ],
    'Folklore': [
      Story(
        id: 'folk1',
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
        id: 'folk2',
        title: 'Hadithi za Bibi',
        description: 'Hadithi za kale kutoka kwa mababu',
        author: 'Hassan Mwinyi',
        authorId: 'author5',
        category: 'Folklore',
        coverImage: 'https://images.unsplash.com/photo-1481627834876-b7833e8f5570?w=800&q=80',
        price: 1200,
        rating: 4.6,
        totalReviews: 72,
        hasAudio: false,
        publishedDate: DateTime.now().subtract(const Duration(days: 20)),
      ),
    ],
    'Moral Stories': [
      Story(
        id: 'moral1',
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
    ],
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _categorizedStories.keys.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

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
              // Header
              Padding(
                padding: const EdgeInsets.all(AppConstants.paddingLarge),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Gundua Hadithi',
                      style: (Theme.of(context).textTheme.headlineMedium ?? const TextStyle(fontSize: 28)).copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Pata hadithi mpya za kusisimua',
                      style: (Theme.of(context).textTheme.bodyLarge ?? const TextStyle(fontSize: 16)).copyWith(
                            color: AppColors.textSecondary,
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
                            color: AppColors.glassWhite,
                            borderColor: AppColors.glassBorder,
                            borderWidth: 1.5,
                            child: TextField(
                              controller: _searchController,
                              decoration: InputDecoration(
                                hintText: 'Tafuta hadithi...',
                                hintStyle: TextStyle(color: AppColors.textMuted),
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
                            color: _showFilters ? AppColors.sunsetOrange : AppColors.cardBackground,
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
                        color: AppColors.glassWhite,
                        borderColor: AppColors.glassBorder,
                        borderWidth: 1.5,
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Price Range
                              const Text(
                                'Bei (TSh)',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
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
                                  Text(
                                    'TSh ${_priceRange.start.round()}',
                                    style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                                  ),
                                  Text(
                                    'TSh ${_priceRange.end.round()}',
                                    style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              
                              // Language Filter
                              const Text(
                                'Lugha',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
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
                                        color: isSelected ? null : AppColors.warmBeige.withOpacity(0.3),
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(
                                          color: isSelected ? AppColors.sunsetOrange : AppColors.glassBorder,
                                          width: 1,
                                        ),
                                      ),
                                      child: Text(
                                        lang,
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                                          color: isSelected ? Colors.white : AppColors.textPrimary,
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
                                  label: const Text('Futa Chujio', style: TextStyle(fontSize: 12)),
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

              // Category tabs
              Container(
                margin: const EdgeInsets.symmetric(horizontal: AppConstants.paddingLarge),
                child: GlassmorphicContainer(
                  height: 50,
                  borderRadius: 25,
                  blur: 8,
                  color: AppColors.glassWhite,
                  borderColor: AppColors.glassBorder,
                  borderWidth: 1.5,
                  child: TabBar(
                    controller: _tabController,
                    isScrollable: true,
                    indicator: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppColors.sunsetOrange, AppColors.deepOrange],
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    labelColor: Colors.white,
                    unselectedLabelColor: AppColors.textMuted,
                    labelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                    unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal, fontSize: 14),
                    tabs: _categorizedStories.keys.map((category) => Tab(text: category)).toList(),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Stories grid
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: _categorizedStories.entries.map((entry) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: AppConstants.paddingLarge),
                      child: GridView.builder(
                        padding: const EdgeInsets.only(bottom: 100),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.65,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                        ),
                        itemCount: entry.value.length,
                        itemBuilder: (context, index) {
                          return _buildExploreCard(entry.value[index]);
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
        isAuthor: true,
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
                  ],
                ),
              ),
            ),
            // Info
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      story.title,
                      style: (Theme.of(context).textTheme.bodyMedium ?? const TextStyle(fontSize: 14)).copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      story.author,
                      style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Spacer(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.star, color: AppColors.warning, size: 12),
                            const SizedBox(width: 4),
                            Text(
                              '${story.rating}',
                              style: const TextStyle(fontSize: 11),
                            ),
                          ],
                        ),
                        Text(
                          'TSh ${story.price}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.sunsetOrange,
                            fontWeight: FontWeight.bold,
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
