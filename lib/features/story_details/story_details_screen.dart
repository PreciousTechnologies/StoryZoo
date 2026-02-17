import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../shared/widgets/glassmorphic_container.dart';
import '../../shared/widgets/neumorphic_widgets.dart';
import '../../models/story.dart';

class StoryDetailsScreen extends StatefulWidget {
  final Story story;

  const StoryDetailsScreen({
    super.key,
    required this.story,
  });

  @override
  State<StoryDetailsScreen> createState() => _StoryDetailsScreenState();
}

class _StoryDetailsScreenState extends State<StoryDetailsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // SliverAppBar with story cover
          SliverAppBar(
            expandedHeight: 400,
            pinned: true,
            backgroundColor: AppColors.backgroundLight,
            leading: Padding(
              padding: const EdgeInsets.all(8.0),
              child: NeumorphicIconButton(
                icon: Icons.arrow_back,
                size: 45,
                onPressed: () => context.pop(),
              ),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: NeumorphicIconButton(
                  icon: widget.story.isPurchased ? Icons.favorite : Icons.favorite_border,
                  size: 45,
                  iconColor: widget.story.isPurchased ? AppColors.error : AppColors.textPrimary,
                  onPressed: () {
                    // Toggle favorite
                  },
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // Story cover image
                  widget.story.coverImage.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: widget.story.coverImage,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  AppColors.sunsetOrange.withOpacity(0.7),
                                  AppColors.savannaGreen.withOpacity(0.7),
                                  AppColors.clayPurple.withOpacity(0.5),
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
                                  AppColors.sunsetOrange.withOpacity(0.7),
                                  AppColors.savannaGreen.withOpacity(0.7),
                                  AppColors.clayPurple.withOpacity(0.5),
                                ],
                              ),
                            ),
                            child: const Center(
                              child: Icon(
                                Icons.auto_stories_rounded,
                                size: 120,
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
                                AppColors.sunsetOrange.withOpacity(0.7),
                                AppColors.savannaGreen.withOpacity(0.7),
                                AppColors.clayPurple.withOpacity(0.5),
                              ],
                            ),
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.auto_stories_rounded,
                              size: 120,
                              color: Colors.white,
                            ),
                          ),
                        ),
                  // Gradient overlay for text readability
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    height: 200,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            AppColors.backgroundLight.withOpacity(0.9),
                          ],
                        ),
                      ),
                    ),
                  ),
                  // Audio badge
                  if (widget.story.hasAudio)
                    Positioned(
                      top: 100,
                      right: 20,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppColors.sunsetOrange,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.headphones, color: Colors.white, size: 18),
                            const SizedBox(width: 6),
                            Text(
                              'Audio Available',
                              style: (Theme.of(context).textTheme.bodySmall ?? const TextStyle(fontSize: 12)).copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),

          // Story content
          SliverToBoxAdapter(
            child: Column(
              children: [
                // Glassmorphic info panel
                Padding(
                  padding: const EdgeInsets.all(AppConstants.paddingLarge),
                  child: GlassmorphicContainer(
                    borderRadius: 30,
                    blur: 15,
                    color: AppColors.glassWhite.withOpacity(0.6),
                    borderColor: AppColors.glassBorder,
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title
                        Text(
                          widget.story.title,
                          style: (Theme.of(context).textTheme.displaySmall ?? const TextStyle(fontSize: 32)).copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                        ),
                        const SizedBox(height: 8),
                        
                        // Author
                        Row(
                          children: [
                            const Icon(Icons.person, size: 20, color: AppColors.textSecondary),
                            const SizedBox(width: 8),
                            Text(
                              'na ${widget.story.author}',
                              style: (Theme.of(context).textTheme.bodyLarge ?? const TextStyle(fontSize: 16)).copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // Stats row
                        Row(
                          children: [
                            _buildStatChip(
                              Icons.star,
                              '${widget.story.rating}',
                              AppColors.warning,
                            ),
                            const SizedBox(width: 8),
                            _buildStatChip(
                              Icons.reviews_outlined,
                              '${widget.story.totalReviews}',
                              AppColors.info,
                            ),
                            const SizedBox(width: 8),
                            _buildStatChip(
                              Icons.category_outlined,
                              widget.story.category,
                              AppColors.savannaGreen,
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 20),
                        const Divider(),
                        const SizedBox(height: 20),

                        // Price and Preview Section
                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      AppColors.sunsetOrange.withOpacity(0.1),
                                      AppColors.peachOrange.withOpacity(0.1),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: AppColors.sunsetOrange.withOpacity(0.3),
                                    width: 2,
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Bei',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: AppColors.textMuted,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'TSh ${widget.story.price.toStringAsFixed(0)}',
                                      style: const TextStyle(
                                        fontSize: 28,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.sunsetOrange,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        const Icon(Icons.check_circle, size: 14, color: AppColors.success),
                                        const SizedBox(width: 4),
                                        Text(
                                          widget.story.hasAudio ? 'Audiobook + eBook' : 'eBook',
                                          style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            GestureDetector(
                              onTap: () {
                                _showPreview();
                              },
                              child: Container(
                                width: 70,
                                height: 100,
                                decoration: BoxDecoration(
                                  color: AppColors.info.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: AppColors.info.withOpacity(0.3),
                                    width: 2,
                                  ),
                                ),
                                child: const Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.play_circle_outline, size: 32, color: AppColors.info),
                                    SizedBox(height: 4),
                                    Text(
                                      'Preview',
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.info,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 20),
                        const Divider(),
                        const SizedBox(height: 20),
                        
                        // Description
                        Text(
                          'Kuhusu Hadithi',
                          style: (Theme.of(context).textTheme.titleLarge ?? const TextStyle(fontSize: 20)).copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          widget.story.description,
                          style: (Theme.of(context).textTheme.bodyLarge ?? const TextStyle(fontSize: 16)).copyWith(
                                height: 1.6,
                                color: AppColors.textSecondary,
                              ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Action buttons - Buy, Read, and Listen
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppConstants.paddingLarge,
                    vertical: AppConstants.paddingMedium,
                  ),
                  child: Column(
                    children: [
                      // Buy button (primary action)
                      if (!widget.story.isPurchased)
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: NeumorphicButton(
                            onPressed: () {
                              _showBuyDialog();
                            },
                            color: AppColors.sunsetOrange,
                            height: 56,
                            borderRadius: 28,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.shopping_cart, color: Colors.white, size: 24),
                                const SizedBox(width: 12),
                                Text(
                                  'Nunua Sasa - TSh ${widget.story.price.toStringAsFixed(0)}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      
                      if (widget.story.isPurchased)
                        Row(
                          children: [
                            // Read button
                            Expanded(
                              child: NeumorphicButton(
                                onPressed: () {
                                  context.push('/ebook-reader/${widget.story.id}', extra: widget.story);
                                },
                                color: AppColors.success,
                                height: 56,
                                borderRadius: 28,
                                child: const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.menu_book, color: Colors.white, size: 22),
                                    SizedBox(width: 8),
                                    Text(
                                      'Soma',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            // Listen button
                            if (widget.story.hasAudio)
                              Expanded(
                                child: NeumorphicButton(
                                  onPressed: () {
                                    context.push('/audio-player/${widget.story.id}', extra: widget.story);
                                  },
                                  color: AppColors.info,
                                  height: 56,
                                  borderRadius: 28,
                                  child: const Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.headphones, color: Colors.white, size: 22),
                                      SizedBox(width: 8),
                                      Text(
                                        'Sikiliza',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                          ],
                        ),
                    ],
                  ),
                ),

                // Secondary actions row
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppConstants.paddingLarge),
                  child: Row(
                    children: [
                      // Read button (if not purchased, show as secondary)
                      if (!widget.story.isPurchased)
                        Expanded(
                          child: NeumorphicButton(
                            onPressed: () {
                              // Navigate to reader
                          },
                          color: AppColors.sunsetOrange,
                          height: 65,
                          borderRadius: 35,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.menu_book, color: Colors.white, size: 22),
                              const SizedBox(width: 8),
                              Flexible(
                                child: Text(
                                  'Soma',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      
                      const SizedBox(width: 16),
                      
                      // Listen button
                      Expanded(
                        child: NeumorphicButton(
                          onPressed: widget.story.hasAudio
                              ? () {
                                  context.push('/audio-player/${widget.story.id}', extra: widget.story);
                                }
                              : null,
                          color: widget.story.hasAudio
                              ? AppColors.savannaGreen
                              : AppColors.textMuted.withOpacity(0.3),
                          height: 65,
                          borderRadius: 35,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.headphones_rounded,
                                color: widget.story.hasAudio ? Colors.white : AppColors.textMuted,
                                size: 22,
                              ),
                              const SizedBox(width: 8),
                              Flexible(
                                child: Text(
                                  'Sikiliza',
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: widget.story.hasAudio ? Colors.white : AppColors.textMuted,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Price card if not purchased
                if (!widget.story.isPurchased)
                  Padding(
                    padding: const EdgeInsets.all(AppConstants.paddingLarge),
                    child: GlassCard(
                      padding: const EdgeInsets.all(20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Bei',
                                style: (Theme.of(context).textTheme.bodyMedium ?? const TextStyle(fontSize: 14)).copyWith(
                                      color: AppColors.textMuted,
                                    ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'TSh ${widget.story.price}',
                                style: (Theme.of(context).textTheme.headlineMedium ?? const TextStyle(fontSize: 24)).copyWith(
                                      color: AppColors.sunsetOrange,
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                            ],
                          ),
                          NeumorphicButton(
                            onPressed: () {
                              // Handle purchase
                            },
                            color: AppColors.sunsetOrange,
                            width: 140,
                            height: 50,
                            borderRadius: 25,
                            child: Text(
                              'Nunua Sasa',
                              style: (Theme.of(context).textTheme.bodyLarge ?? const TextStyle(fontSize: 16)).copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                // Reviews section
                Padding(
                  padding: const EdgeInsets.all(AppConstants.paddingLarge),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Maoni ya Wasomaji',
                        style: (Theme.of(context).textTheme.headlineMedium ?? const TextStyle(fontSize: 24)).copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 16),
                      
                      // Sample reviews
                      ...List.generate(3, (index) => _buildReviewCard(context, index)),
                    ],
                  ),
                ),

                const SizedBox(height: 100),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatChip(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: color),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewCard(BuildContext context, int index) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: NeumorphicCard(
        borderRadius: 20,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: AppColors.clayBlue,
                  child: Text(
                    'M${index + 1}',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Msomaji ${index + 1}',
                        style: (Theme.of(context).textTheme.bodyLarge ?? const TextStyle(fontSize: 16)).copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      Row(
                        children: List.generate(
                          5,
                          (i) => Icon(
                            i < 4 ? Icons.star : Icons.star_border,
                            size: 14,
                            color: AppColors.warning,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Hadithi nzuri sana! Nimependa jinsi mwandishi alivyoelezea matukio. Inanishika toka mwanzo hadi mwisho.',
              style: (Theme.of(context).textTheme.bodyMedium ?? const TextStyle(fontSize: 14)).copyWith(
                    color: AppColors.textSecondary,
                    height: 1.5,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  void _showPreview() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.play_circle, color: AppColors.info),
            SizedBox(width: 12),
            Text('Preview', style: TextStyle(fontSize: 18)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.info.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Column(
                children: [
                  Icon(Icons.headphones, size: 48, color: AppColors.info),
                  SizedBox(height: 12),
                  Text(
                    'Sikiliza dondoo la kwanza la hadithi hii',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Preview hii inakuruhusu kusikiliza dakika 2 za kwanza za audiobook.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: AppColors.textMuted),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Funga'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              // Play preview
            },
            icon: const Icon(Icons.play_arrow),
            label: const Text('Cheza Preview'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.info,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ],
      ),
    );
  }

  void _showBuyDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.shopping_cart, color: AppColors.sunsetOrange),
            SizedBox(width: 12),
            Text('Thibitisha Ununuzi', style: TextStyle(fontSize: 18)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.story.title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'na ${widget.story.author}',
              style: const TextStyle(fontSize: 14, color: AppColors.textMuted),
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Bei:', style: TextStyle(fontSize: 14)),
                Text(
                  'TSh ${widget.story.price.toStringAsFixed(0)}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.sunsetOrange,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.success.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.check_circle, size: 14, color: AppColors.success),
                      const SizedBox(width: 6),
                      Flexible(
                        child: const Text('Unachopata:', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  _buildBenefitItem('eBook kamili'),
                  if (widget.story.hasAudio) _buildBenefitItem('Audiobook kamili'),
                  _buildBenefitItem('Usomaji wa mtandaoni na nje ya mtandao'),
                  _buildBenefitItem('Milele - hakuna ada za kila mwezi'),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Ghairi'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Ununuzi umekamilika! Karibu katika maktaba yako.'),
                  backgroundColor: AppColors.success,
                  duration: Duration(seconds: 3),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.sunsetOrange,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Nunua Sasa', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildBenefitItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 20, top: 4),
      child: Row(
        children: [
          const Icon(Icons.check, size: 12, color: AppColors.success),
          const SizedBox(width: 6),
          Expanded(
            child: Text(text, style: const TextStyle(fontSize: 11)),
          ),
        ],
      ),
    );
  }
}
