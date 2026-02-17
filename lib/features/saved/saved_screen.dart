import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../shared/widgets/glassmorphic_container.dart';
import '../../shared/widgets/neumorphic_widgets.dart';
import '../../shared/widgets/enhanced_bottom_nav.dart';
import '../../models/story.dart';

class SavedScreen extends StatefulWidget {
  const SavedScreen({super.key});

  @override
  State<SavedScreen> createState() => _SavedScreenState();
}

class _SavedScreenState extends State<SavedScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Mock saved and purchased stories
  final List<Story> _purchasedStories = [
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
      isPurchased: true,
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
      isPurchased: true,
      publishedDate: DateTime.now().subtract(const Duration(days: 14)),
    ),
  ];

  final List<Story> _savedStories = [
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
      isPurchased: false,
      publishedDate: DateTime.now().subtract(const Duration(days: 21)),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
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
              AppColors.mintGreen,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(AppConstants.paddingLarge),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Maktaba Yangu',
                          style: (Theme.of(context).textTheme.headlineMedium ?? const TextStyle(fontSize: 28)).copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${_purchasedStories.length + _savedStories.length} hadithi jumla',
                          style: (Theme.of(context).textTheme.bodyLarge ?? const TextStyle(fontSize: 16)).copyWith(
                                color: AppColors.textSecondary,
                              ),
                        ),
                      ],
                    ),
                    GlassmorphicContainer(
                      width: 50,
                      height: 50,
                      borderRadius: 25,
                      blur: 10,
                      color: AppColors.glassWhite,
                      borderColor: AppColors.glassBorder,
                      borderWidth: 1.5,
                      child: IconButton(
                        icon: const Icon(Icons.search, color: AppColors.sunsetOrange),
                        onPressed: () {
                          // Search functionality
                        },
                      ),
                    ),
                  ],
                ),
              ),

              // Tab Bar
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
                    indicator: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppColors.success, AppColors.savannaGreen],
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    labelColor: Colors.white,
                    unselectedLabelColor: AppColors.textMuted,
                    labelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                    tabs: [
                      Tab(text: 'Nilinunua (${_purchasedStories.length})'),
                      Tab(text: 'Zilizohifadhiwa (${_savedStories.length})'),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Tab Views
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    // Purchased tab
                    _purchasedStories.isEmpty
                        ? _buildEmptyState('Hakuna Hadithi Ulizozinunua', 'Nenda kwenye duka ukaanze kuchagua hadithi')
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppConstants.paddingLarge,
                              vertical: 8,
                            ).copyWith(bottom: 100),
                            itemCount: _purchasedStories.length,
                            itemBuilder: (context, index) {
                              return _buildStoryCard(_purchasedStories[index], isPurchased: true);
                            },
                          ),
                    // Saved tab
                    _savedStories.isEmpty
                        ? _buildEmptyState('Hakuna Hadithi Zilizohifadhiwa', 'Bonyeza ikoni ya moyo kuhifadhi hadithi')
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppConstants.paddingLarge,
                              vertical: 8,
                            ).copyWith(bottom: 100),
                            itemCount: _savedStories.length,
                            itemBuilder: (context, index) {
                              return _buildStoryCard(_savedStories[index], isPurchased: false);
                            },
                          ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: EnhancedBottomNav(
        currentIndex: 2,
        isAuthor: true,
        onTap: (index) {
          switch (index) {
            case 0:
              context.go('/home');
              break;
            case 1:
              context.go('/explore');
              break;
            case 2:
              // Already on saved
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

  Widget _buildEmptyState(String title, String subtitle) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          GlassmorphicContainer(
            width: 150,
            height: 150,
            borderRadius: 75,
            blur: 15,
            color: AppColors.glassWhite,
            borderColor: AppColors.glassBorder,
            borderWidth: 2,
            child: const Icon(
              Icons.library_books,
              size: 80,
              color: AppColors.textMuted,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            title,
            style: (Theme.of(context).textTheme.titleLarge ?? const TextStyle(fontSize: 20)).copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: (Theme.of(context).textTheme.bodyLarge ?? const TextStyle(fontSize: 16)).copyWith(
                  color: AppColors.textSecondary,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildStoryCard(Story story, {required bool isPurchased}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: GestureDetector(
        onTap: () {
          context.push('/story/${story.id}', extra: story);
        },
        child: NeumorphicCard(
          borderRadius: 20,
          padding: EdgeInsets.zero,
          color: AppColors.cardBackground,
          child: Row(
            children: [
              // Cover image
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  bottomLeft: Radius.circular(20),
                ),
                child: SizedBox(
                  width: 120,
                  height: 160,
                  child: story.coverImage.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: story.coverImage,
                          fit: BoxFit.cover,
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

              // Story details
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Category badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.sunsetOrange.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          story.category,
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.sunsetOrange,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Title
                      Text(
                        story.title,
                        style: (Theme.of(context).textTheme.titleMedium ?? const TextStyle(fontSize: 16)).copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),

                      // Author
                      Text(
                        story.author,
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.textMuted,
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Rating and audio indicator
                      Row(
                        children: [
                          const Icon(Icons.star, color: AppColors.warning, size: 14),
                          const SizedBox(width: 4),
                          Text(
                            '${story.rating}',
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(width: 8),
                          if (story.hasAudio) ...[
                            Flexible(
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                                decoration: BoxDecoration(
                                  color: AppColors.info.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.headphones, size: 11, color: AppColors.info),
                                    SizedBox(width: 3),
                                    Text(
                                      'Audio',
                                      style: TextStyle(
                                        fontSize: 9,
                                        color: AppColors.info,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // Remove/Action button
              Padding(
                padding: const EdgeInsets.only(right: 12),
                child: IconButton(
                  icon: Icon(
                    isPurchased ? Icons.download : Icons.favorite,
                    color: isPurchased ? AppColors.info : AppColors.error,
                    size: 24,
                  ),
                  onPressed: () {
                    if (isPurchased) {
                      // Download functionality
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Inapakuliwa...'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    } else {
                      setState(() {
                        _savedStories.remove(story);
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Imeondolewa kutoka kwenye zilizohifadhiwa'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
