import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../shared/widgets/neumorphic_widgets.dart';
import '../../models/story.dart';

class MyPurchasesScreen extends StatefulWidget {
  const MyPurchasesScreen({super.key});

  @override
  State<MyPurchasesScreen> createState() => _MyPurchasesScreenState();
}

class _MyPurchasesScreenState extends State<MyPurchasesScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedFilter = 'Zote';
  
  final List<String> _filters = ['Zote', 'Hadithi', 'Sauti', 'Vitabu'];

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

  // Mock data
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
      isPurchased: true,
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
      isPurchased: true,
      hasAudio: false,
      publishedDate: DateTime.now().subtract(const Duration(days: 14)),
    ),
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
                            'Manunuzi Yangu',
                            style: (Theme.of(context).textTheme.headlineSmall ?? const TextStyle(fontSize: 24)).copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          Text(
                            '${_purchasedStories.length} hadithi',
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

              // Filter chips
              SizedBox(
                height: 50,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: AppConstants.paddingLarge),
                  itemCount: _filters.length,
                  itemBuilder: (context, index) {
                    final filter = _filters[index];
                    final isSelected = filter == _selectedFilter;
                    return Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedFilter = filter;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          decoration: BoxDecoration(
                            gradient: isSelected
                                ? const LinearGradient(
                                    colors: [AppColors.sunsetOrange, AppColors.deepOrange],
                                  )
                                : null,
                            color: isSelected ? null : AppColors.cardBackground,
                            borderRadius: BorderRadius.circular(25),
                            boxShadow: isSelected
                                ? [
                                    BoxShadow(
                                      color: AppColors.sunsetOrange.withOpacity(0.3),
                                      blurRadius: 8,
                                      offset: const Offset(0, 4),
                                    ),
                                  ]
                                : null,
                          ),
                          child: Text(
                            filter,
                            style: TextStyle(
                              color: isSelected ? Colors.white : AppColors.textPrimary,
                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 20),

              // Purchased stories list
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: AppConstants.paddingLarge),
                  itemCount: _purchasedStories.length,
                  itemBuilder: (context, index) {
                    return _buildPurchaseCard(_purchasedStories[index]);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPurchaseCard(Story story) {
    return GestureDetector(
      onTap: () {
        context.push('/story/${story.id}', extra: story);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        child: NeumorphicCard(
          borderRadius: 20,
          color: AppColors.cardBackground,
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Cover image
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: CachedNetworkImage(
                  imageUrl: story.coverImage,
                  width: 80,
                  height: 100,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    color: AppColors.backgroundLight,
                    child: const Center(child: CircularProgressIndicator()),
                  ),
                  errorWidget: (context, url, error) => Container(
                    color: AppColors.backgroundLight,
                    child: const Icon(Icons.book, size: 40, color: AppColors.textMuted),
                  ),
                ),
              ),
              const SizedBox(width: 16),

              // Story details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      story.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      story.author,
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.star, size: 16, color: AppColors.warning),
                        const SizedBox(width: 4),
                        Text(
                          story.rating.toString(),
                          style: const TextStyle(fontSize: 13),
                        ),
                        const SizedBox(width: 12),
                        if (story.hasAudio)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.info.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: const [
                                Icon(Icons.headphones, size: 12, color: AppColors.info),
                                SizedBox(width: 4),
                                Text(
                                  'Audio',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: AppColors.info,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'TSh ${story.price.toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: AppColors.sunsetOrange,
                      ),
                    ),
                  ],
                ),
              ),

              // Actions
              Column(
                children: [
                  NeumorphicIconButton(
                    icon: Icons.play_circle_filled,
                    size: 40,
                    iconColor: AppColors.sunsetOrange,
                    onPressed: () {
                      if (story.hasAudio) {
                        context.push('/audio-player/${story.id}', extra: story);
                      } else {
                        context.push('/ebook-reader/${story.id}', extra: story);
                      }
                    },
                  ),
                  const SizedBox(height: 8),
                  NeumorphicIconButton(
                    icon: Icons.download,
                    size: 40,
                    onPressed: () {
                      // Handle download
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Inapakua...')),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
