import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../shared/widgets/clay_widgets.dart';
import '../../models/story.dart';

class ChildUIScreen extends StatefulWidget {
  const ChildUIScreen({super.key});

  @override
  State<ChildUIScreen> createState() => _ChildUIScreenState();
}

class _ChildUIScreenState extends State<ChildUIScreen> {
  // Mock data for child-friendly stories
  final List<Story> _stories = [
    Story(
      id: '1',
      title: 'Simba na Sungura',
      description: 'Hadithi ya urafiki',
      author: 'Mama Sarah',
      authorId: 'author1',
      category: 'Wanyama',
      coverImage: 'https://images.unsplash.com/photo-1456926631375-92c8ce872def?w=800&q=80',
      price: 1000,
      rating: 5.0,
      hasAudio: true,
      publishedDate: DateTime.now(),
    ),
    Story(
      id: '2',
      title: 'Ndege wa Rangi',
      description: 'Safari ya ajabu',
      author: 'Baba John',
      authorId: 'author2',
      category: 'Safari',
      coverImage: 'https://images.unsplash.com/photo-1444464666168-49d633b86797?w=800&q=80',
      price: 1000,
      rating: 4.9,
      hasAudio: true,
      publishedDate: DateTime.now(),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.clayYellow.withOpacity(0.3),
              AppColors.clayPink.withOpacity(0.3),
              AppColors.clayBlue.withOpacity(0.3),
            ],
          ),
        ),
        child: SafeArea(
          child: CustomScrollView(
            // Bouncing physics for playful feel
            physics: const BouncingScrollPhysics(),
            slivers: [
              // App Bar with large, friendly text
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(AppConstants.paddingLarge),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '👋 Karibu!',
                            style: (Theme.of(context).textTheme.displaySmall ?? const TextStyle(fontSize: 32)).copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.childRed,
                                ),
                          ),
                          ClayIconButton(
                            icon: Icons.account_circle,
                            size: 60,
                            backgroundColor: AppColors.clayPink,
                            onPressed: () {
                              // Show profile
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Chagua hadithi ya kusoma! 📚',
                        style: (Theme.of(context).textTheme.headlineSmall ?? const TextStyle(fontSize: 20)).copyWith(
                              color: AppColors.textSecondary,
                            ),
                      ),
                    ],
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 20)),

              // Bright, colorful category buttons
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 100,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: AppConstants.paddingMedium),
                    physics: const BouncingScrollPhysics(),
                    children: [
                      _buildCategoryCard('🦁', 'Wanyama', AppColors.childYellow),
                      _buildCategoryCard('🚀', 'Safari', AppColors.childBlue),
                      _buildCategoryCard('👑', 'Wafalme', AppColors.childPurple),
                      _buildCategoryCard('🌟', 'Uchawi', AppColors.childGreen),
                      _buildCategoryCard('❤️', 'Upendo', AppColors.childRed),
                    ],
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 30)),

              // Stories grid with oversized clay components
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: AppConstants.paddingLarge),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 1,
                    childAspectRatio: 1.3,
                    mainAxisSpacing: 24,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      return _buildStoryCard(_stories[index % _stories.length], index);
                    },
                    childCount: 4,
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          ),
        ),
      ),

      // Bottom navigation with clay style
      bottomNavigationBar: Container(
        margin: const EdgeInsets.all(16),
        child: ClayContainer(
          height: 80,
          borderRadius: 40,
          color: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavButton(Icons.home_rounded, 'Nyumbani', AppColors.childBlue, true),
              _buildNavButton(Icons.favorite_rounded, 'Favorites', AppColors.childRed, false),
              _buildNavButton(Icons.face, 'Mimi', AppColors.childYellow, false),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryCard(String emoji, String label, Color color) {
    return Padding(
      padding: const EdgeInsets.only(right: 16),
      child: ClayContainer(
        width: 110,
        height: 100,
        color: color.withOpacity(0.3),
        borderRadius: 25,
        padding: const EdgeInsets.all(12),
        onTap: () {
          // Filter by category
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              emoji,
              style: const TextStyle(fontSize: 40),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: (Theme.of(context).textTheme.bodyMedium ?? const TextStyle(fontSize: 14)).copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStoryCard(Story story, int index) {
    // Alternate colors for variety
    final colors = [
      AppColors.clayPink,
      AppColors.clayBlue,
      AppColors.clayYellow,
      AppColors.clayMint,
    ];
    final color = colors[index % colors.length];

    return ClayContainer(
      color: color.withOpacity(0.4),
      borderRadius: 35,
      padding: const EdgeInsets.all(20),
      onTap: () {
        // Navigate to story
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Story cover
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(25),
              child: story.coverImage.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: story.coverImage,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                      placeholder: (context, url) => Container(
                        color: Colors.white.withOpacity(0.5),
                        child: const Center(
                          child: CircularProgressIndicator(),
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: Colors.white.withOpacity(0.5),
                        child: Center(
                          child: Text(
                            ['📖', '🎧', '🌟', '✨'][index % 4],
                            style: const TextStyle(fontSize: 80),
                          ),
                        ),
                      ),
                    )
                  : Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: Center(
                        child: Text(
                          ['📖', '🎧', '🌟', '✨'][index % 4],
                          style: const TextStyle(fontSize: 80),
                        ),
                      ),
                    ),
            ),
          ),

          const SizedBox(height: 16),

          // Title
          Text(
            story.title,
            style: (Theme.of(context).textTheme.headlineSmall ?? const TextStyle(fontSize: 20)).copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),

          const SizedBox(height: 8),

          // Author with emoji
          Text(
            '👤 ${story.author}',
            style: (Theme.of(context).textTheme.bodyLarge ?? const TextStyle(fontSize: 16)).copyWith(
                  color: AppColors.textSecondary,
                ),
          ),

          const SizedBox(height: 16),

          // Action buttons
          Row(
            children: [
              // Read button
              Expanded(
                child: ClayButton(
                  onPressed: () {
                    // Read story
                  },
                  color: AppColors.childBlue,
                  height: 60,
                  borderRadius: 30,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.menu_book_rounded, color: Colors.white, size: 24),
                      const SizedBox(width: 8),
                      Text(
                        'Soma',
                        style: (Theme.of(context).textTheme.titleMedium ?? const TextStyle(fontSize: 16)).copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(width: 12),

              // Listen button
              Expanded(
                child: ClayButton(
                  onPressed: story.hasAudio
                      ? () {
                          // Listen to story
                        }
                      : null,
                  color: story.hasAudio ? AppColors.childGreen : AppColors.textMuted.withOpacity(0.3),
                  height: 60,
                  borderRadius: 30,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.headphones_rounded,
                        color: story.hasAudio ? Colors.white : AppColors.textMuted,
                        size: 24,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Sikiliza',
                        style: (Theme.of(context).textTheme.titleMedium ?? const TextStyle(fontSize: 16)).copyWith(
                              color: story.hasAudio ? Colors.white : AppColors.textMuted,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Ask Parent button (soft neumorphic)
          if (!story.isPurchased)
            ClayButton(
              onPressed: () {
                _showAskParentDialog(context);
              },
              color: AppColors.clayYellow,
              height: 55,
              borderRadius: 28,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.family_restroom, color: AppColors.textPrimary, size: 24),
                  const SizedBox(width: 8),
                  Text(
                    'Omba Mzazi 🙏',
                    style: (Theme.of(context).textTheme.titleMedium ?? const TextStyle(fontSize: 16)).copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildNavButton(IconData icon, String label, Color color, bool isActive) {
    return GestureDetector(
      onTap: () {
        // Navigate
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isActive ? color.withOpacity(0.2) : Colors.transparent,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              icon,
              color: isActive ? color : AppColors.textMuted,
              size: 30,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              color: isActive ? color : AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }

  void _showAskParentDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: ClayContainer(
          width: double.infinity,
          height: 350,
          color: Colors.white,
          borderRadius: 40,
          padding: const EdgeInsets.all(30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '👨👩👧👦',
                style: const TextStyle(fontSize: 80),
              ),
              const SizedBox(height: 20),
              Text(
                'Omba Mzazi',
                style: (Theme.of(context).textTheme.headlineMedium ?? const TextStyle(fontSize: 24)).copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 16),
              Text(
                'Ujumbe umepelekwa kwa mzazi wako kumwomba ruhusa ya kununua hadithi hii! 🎉',
                style: Theme.of(context).textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ClayButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                color: AppColors.childGreen,
                height: 55,
                child: Text(
                  'Sawa! 👍',
                  style: (Theme.of(context).textTheme.titleLarge ?? const TextStyle(fontSize: 20)).copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
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
