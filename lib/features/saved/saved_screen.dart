import 'package:flutter/material.dart';
import '../../shared/widgets/app_text.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import '../../core/auth/auth_provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/responsive_utils.dart';
import '../../shared/widgets/glassmorphic_container.dart';
import '../../shared/widgets/micro_interactions.dart';
import '../../shared/widgets/neumorphic_widgets.dart';
import '../../shared/widgets/enhanced_bottom_nav.dart';
import '../../models/story.dart';

class SavedScreen extends StatefulWidget {
  const SavedScreen({super.key});

  @override
  State<SavedScreen> createState() => _SavedScreenState();
}

class _SavedScreenState extends State<SavedScreen> {
  int _activeTab = 0;

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
  Widget build(BuildContext context) {
    final isAuthor = context.watch<AuthProvider>().isAuthor;
    final visibleStories = _activeTab == 0 ? _purchasedStories : _savedStories;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundTop = isDark ? AppColors.backgroundDark : AppColors.backgroundLight;
    final backgroundBottom = isDark ? const Color(0xFF26443A) : AppColors.mintGreen;
    final primaryText = isDark ? Colors.white : AppColors.textPrimary;
    final secondaryText = isDark ? Colors.white70 : AppColors.textSecondary;
    final glassColor = isDark ? AppColors.glassDark : AppColors.glassWhite;
    final cardSurface = isDark ? const Color(0xFF2F2118) : AppColors.cardBackground;

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
              StaggeredFadeSlide(
                order: 0,
                child: Padding(
                  padding: EdgeInsets.all(ResponsiveUtils.getPadding(context)),
                  child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AppText(
                              'Maktaba Yangu',
                              style: (Theme.of(context).textTheme.headlineMedium ?? const TextStyle(fontSize: 28)).copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: primaryText,
                                  ),
                            ),
                            const SizedBox(height: 4),
                            AppText(
                              '${_purchasedStories.length + _savedStories.length} hadithi jumla',
                              style: (Theme.of(context).textTheme.bodyLarge ?? const TextStyle(fontSize: 16)).copyWith(
                                    color: secondaryText,
                                  ),
                            ),
                          ],
                        ),
                        GlassmorphicContainer(
                          width: ResponsiveUtils.getIconButtonSize(context),
                          height: ResponsiveUtils.getIconButtonSize(context),
                          borderRadius: ResponsiveUtils.getIconButtonSize(context) / 2,
                          blur: 10,
                          color: glassColor,
                          borderColor: AppColors.glassBorder,
                          borderWidth: 1.5,
                          child: IconButton(
                            icon: const Icon(Icons.search, color: AppColors.sunsetOrange),
                            onPressed: () {},
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    NeumorphicCard(
                      borderRadius: ResponsiveUtils.getBorderRadius(context),
                      padding: EdgeInsets.all(ResponsiveUtils.getSpacing(context)),
                      color: cardSurface,
                      child: Row(
                        children: [
                          _buildKpi('Zimesomwa', '${_purchasedStories.length}', Icons.menu_book),
                          SizedBox(width: ResponsiveUtils.getSpacing(context) * 0.7),
                          _buildKpi('Wish List', '${_savedStories.length}', Icons.favorite),
                          SizedBox(width: ResponsiveUtils.getSpacing(context) * 0.7),
                          _buildKpi('Audio', '${_purchasedStories.where((s) => s.hasAudio).length}', Icons.headphones),
                        ],
                      ),
                    ),
                  ],
                  ),
                ),
              ),

              // Neumorphic segmented tabs
              StaggeredFadeSlide(
                order: 1,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: ResponsiveUtils.getPadding(context)),
                  child: Row(
                  children: [
                    Expanded(
                      child: _buildSegment(
                        title: 'Nilinunua',
                        count: _purchasedStories.length,
                        active: _activeTab == 0,
                        onTap: () => setState(() => _activeTab = 0),
                      ),
                    ),
                    SizedBox(width: ResponsiveUtils.getSpacing(context)),
                    Expanded(
                      child: _buildSegment(
                        title: 'Zilizohifadhiwa',
                        count: _savedStories.length,
                        active: _activeTab == 1,
                        onTap: () => setState(() => _activeTab = 1),
                      ),
                    ),
                  ],
                  ),
                ),
              ),

              SizedBox(height: ResponsiveUtils.getSpacing(context) * 1.5),

              // Story list
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 280),
                  switchInCurve: Curves.easeOutCubic,
                  switchOutCurve: Curves.easeInCubic,
                  child: visibleStories.isEmpty
                      ? _buildEmptyState(
                          _activeTab == 0 ? 'Hakuna Hadithi Ulizozinunua' : 'Hakuna Hadithi Zilizohifadhiwa',
                          _activeTab == 0
                              ? 'Nenda Explore uchague hadithi za kusoma.'
                              : 'Bonyeza ikoni ya moyo kuhifadhi hadithi unazopenda.',
                        )
                      : ListView.builder(
                          key: ValueKey<int>(_activeTab),
                          padding: EdgeInsets.symmetric(
                            horizontal: ResponsiveUtils.getPadding(context),
                            vertical: ResponsiveUtils.getSpacing(context) * 0.5,
                          ).copyWith(bottom: 100),
                          itemCount: visibleStories.length,
                          itemBuilder: (context, index) {
                            return StaggeredFadeSlide(
                              order: index,
                              child: _buildStoryCard(visibleStories[index], isPurchased: _activeTab == 0),
                            );
                          },
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: EnhancedBottomNav(
        currentIndex: 2,
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final glassColor = isDark ? AppColors.glassDark : AppColors.glassWhite;
    final primaryText = isDark ? Colors.white : AppColors.textPrimary;
    final secondaryText = isDark ? Colors.white70 : AppColors.textSecondary;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          GlassmorphicContainer(
            width: ResponsiveUtils.getIconButtonSize(context) * 1.8,
            height: ResponsiveUtils.getIconButtonSize(context) * 1.8,
            borderRadius: ResponsiveUtils.getIconButtonSize(context) * 0.9,
            blur: 15,
            color: glassColor,
            borderColor: AppColors.glassBorder,
            borderWidth: 2,
            child: Icon(
              Icons.library_books,
              size: ResponsiveUtils.getIconButtonSize(context) * 0.9,
              color: AppColors.textMuted,
            ),
          ),
          SizedBox(height: ResponsiveUtils.getSpacing(context) * 1.5),
          AppText(
            title,
            style: (Theme.of(context).textTheme.titleLarge ?? const TextStyle(fontSize: 20)).copyWith(
                  fontWeight: FontWeight.bold,
                  color: primaryText,
                ),
          ),
          const SizedBox(height: 8),
          AppText(
            subtitle,
            style: (Theme.of(context).textTheme.bodyLarge ?? const TextStyle(fontSize: 16)).copyWith(
                  color: secondaryText,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildStoryCard(Story story, {required bool isPurchased}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardSurface = isDark ? const Color(0xFF2F2118) : AppColors.cardBackground;
    final mutedText = isDark ? Colors.white70 : AppColors.textMuted;
    final placeholderAccent = isDark ? AppColors.warmBeige : Colors.white;

    final imageWidth = ResponsiveUtils.isMobile(context) ? 120.0 : 160.0;
    final imageHeight = ResponsiveUtils.isMobile(context) ? 160.0 : 220.0;
    
    return Container(
      margin: EdgeInsets.only(bottom: ResponsiveUtils.getSpacing(context)),
      child: GestureDetector(
        onTap: () {
          context.push('/story/${story.id}', extra: story);
        },
        child: NeumorphicCard(
          borderRadius: ResponsiveUtils.getBorderRadius(context),
          padding: EdgeInsets.zero,
          color: cardSurface,
          child: Row(
            children: [
              // Cover image
              ClipRRect(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(ResponsiveUtils.getBorderRadius(context)),
                  bottomLeft: Radius.circular(ResponsiveUtils.getBorderRadius(context)),
                ),
                child: SizedBox(
                  width: imageWidth,
                  height: imageHeight,
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
                                  AppColors.clayBlue.withValues(alpha: 0.7),
                                  AppColors.clayPink.withValues(alpha: 0.7),
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
                                  AppColors.clayBlue.withValues(alpha: 0.7),
                                  AppColors.clayPink.withValues(alpha: 0.7),
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
                                AppColors.clayBlue.withValues(alpha: 0.7),
                                AppColors.clayPink.withValues(alpha: 0.7),
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
              ),

              // Story details
              Expanded(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    ResponsiveUtils.getSpacing(context),
                    ResponsiveUtils.getSpacing(context) * 0.8,
                    ResponsiveUtils.getSpacing(context) * 0.7,
                    ResponsiveUtils.getSpacing(context) * 0.8,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Category badge
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: ResponsiveUtils.getSpacing(context) * 0.6,
                          vertical: ResponsiveUtils.getSpacing(context) * 0.25,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.sunsetOrange.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(ResponsiveUtils.getBorderRadius(context) * 0.5),
                        ),
                        child: AppText(
                          story.category,
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.sunsetOrange,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      SizedBox(height: ResponsiveUtils.getSpacing(context) * 0.5),

                      // Title
                      AppText(
                        story.title,
                        style: (Theme.of(context).textTheme.titleMedium ?? const TextStyle(fontSize: 16)).copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: ResponsiveUtils.getSpacing(context) * 0.25),

                      // Author
                      AppText(
                        story.author,
                          style: TextStyle(
                          fontSize: 13,
                          color: mutedText,
                        ),
                      ),
                      SizedBox(height: ResponsiveUtils.getSpacing(context) * 0.7),

                      // Reading progress
                      ClipRRect(
                        borderRadius: BorderRadius.circular(ResponsiveUtils.getBorderRadius(context) * 0.4),
                        child: LinearProgressIndicator(
                          value: isPurchased ? 0.65 : 0.0,
                          minHeight: ResponsiveUtils.getSpacing(context) * 0.35,
                          backgroundColor: AppColors.warmBeige.withValues(alpha: 0.6),
                          valueColor: AlwaysStoppedAnimation<Color>(
                            isPurchased ? AppColors.success : AppColors.sunsetOrange.withValues(alpha: 0.45),
                          ),
                        ),
                      ),
                      SizedBox(height: ResponsiveUtils.getSpacing(context) * 0.5),

                      // Rating and audio indicator
                      Row(
                        children: [
                          const Icon(Icons.star, color: AppColors.warning, size: 14),
                          SizedBox(width: ResponsiveUtils.getSpacing(context) * 0.25),
                          AppText(
                            '${story.rating}',
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                          ),
                          SizedBox(width: ResponsiveUtils.getSpacing(context) * 0.5),
                          if (story.hasAudio) ...[
                            Flexible(
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: ResponsiveUtils.getSpacing(context) * 0.35,
                                  vertical: ResponsiveUtils.getSpacing(context) * 0.15,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.info.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(ResponsiveUtils.getBorderRadius(context) * 0.5),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.headphones, size: ResponsiveUtils.getSpacing(context) * 0.65, color: AppColors.info),
                                    SizedBox(width: ResponsiveUtils.getSpacing(context) * 0.15),
                                    AppText(
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
                      SizedBox(height: ResponsiveUtils.getSpacing(context) * 0.5),
                      Row(
                        children: [
                          Expanded(
                            child: AppText(
                              isPurchased ? 'Mwisho kusoma: Jana, 21:00' : 'Imehifadhiwa kwa baadaye',
                              style: TextStyle(fontSize: 11, color: mutedText),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
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
                          content: AppText('Inapakuliwa...'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    } else {
                      setState(() {
                        _savedStories.remove(story);
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: AppText('Imeondolewa kutoka kwenye zilizohifadhiwa'),
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

  Widget _buildKpi(String title, String value, IconData icon) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: isDark
              ? const Color(0x33FFFFFF)
              : AppColors.warmBeige.withValues(alpha: 0.35),
          border: Border.all(color: AppColors.glassBorder),
        ),
        child: Column(
          children: [
            Icon(icon, color: AppColors.sunsetOrange, size: 18),
            const SizedBox(height: 6),
            AppText(
              value,
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
            ),
            const SizedBox(height: 2),
            AppText(
              title,
              style: TextStyle(
                fontSize: 11,
                color: isDark ? Colors.white60 : AppColors.textMuted,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSegment({
    required String title,
    required int count,
    required bool active,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          gradient: active
              ? const LinearGradient(colors: [AppColors.success, AppColors.savannaGreen])
                : LinearGradient(
                  colors: isDark
                    ? const [Color(0xFF3A2A20), Color(0xFF2D211A)]
                    : const [Color(0xFFFFF6E8), Color(0xFFF8ECDC)],
                ),
          boxShadow: active
              ? [
                  BoxShadow(
                    color: AppColors.success.withValues(alpha: 0.28),
                    blurRadius: 14,
                    offset: const Offset(0, 8),
                  ),
                ]
              : [
                  BoxShadow(
                    color: isDark ? AppColors.sandBrown.withValues(alpha: 0.16) : Colors.white,
                    offset: const Offset(-4, -4),
                    blurRadius: 8,
                  ),
                  BoxShadow(
                    color: isDark
                        ? Colors.black.withValues(alpha: 0.4)
                        : Colors.brown.withValues(alpha: 0.12),
                    offset: const Offset(4, 4),
                    blurRadius: 8,
                  ),
                ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Flexible(
              child: AppText(
                title,
                style: TextStyle(
                  color: active ? Colors.white : (isDark ? Colors.white70 : AppColors.textPrimary),
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
              decoration: BoxDecoration(
                color: active ? Colors.white24 : AppColors.sunsetOrange.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(99),
              ),
              child: AppText(
                '$count',
                style: TextStyle(
                  color: active ? Colors.white : AppColors.sunsetOrange,
                  fontWeight: FontWeight.w700,
                  fontSize: 11,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

