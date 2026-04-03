import 'package:flutter/material.dart';
import '../../shared/widgets/app_text.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import '../../core/auth/auth_provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../shared/widgets/micro_interactions.dart';
import '../../shared/widgets/neumorphic_widgets.dart';
import '../../models/story.dart';
import 'data/profile_repository.dart';

class MyPurchasesScreen extends StatefulWidget {
  const MyPurchasesScreen({super.key});

  @override
  State<MyPurchasesScreen> createState() => _MyPurchasesScreenState();
}

class _MyPurchasesScreenState extends State<MyPurchasesScreen> {
  String _selectedFilter = 'Zote';

  final List<String> _filters = ['Zote', 'Hadithi', 'Sauti', 'Vitabu'];

  final ProfileRepository _repository = ProfileRepository();
  bool _isLoading = true;
  String? _error;
  PurchasesData _data = const PurchasesData(total: 0, audio: 0, budget: 0, items: []);

  List<Story> get _filteredStories {
    final all = _data.items;
    switch (_selectedFilter) {
      case 'Sauti':
        return all.where((story) => story.hasAudio).toList();
      case 'Vitabu':
        return all.where((story) => !story.hasAudio).toList();
      case 'Hadithi':
        return all.where((story) {
          final haystack = '${story.title} ${story.description} ${story.category}'.toLowerCase();
          return haystack.contains('hadithi');
        }).toList();
      case 'Zote':
      default:
        return all;
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadPurchases());
  }

  @override
  void dispose() {
    _repository.dispose();
    super.dispose();
  }

  Future<void> _loadPurchases() async {
    final token = context.read<AuthProvider>().token;
    if (token == null || token.isEmpty) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _error = 'Tafadhali ingia tena ili kuona manunuzi yako.';
      });
      return;
    }

    try {
      final payload = await _repository.fetchPurchases(token);
      if (!mounted) return;
      setState(() {
        _data = payload;
        _isLoading = false;
        _error = null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _error = e.toString();
      });
    }
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
                            'Manunuzi Yangu',
                            style: (Theme.of(context).textTheme.headlineSmall ?? const TextStyle(fontSize: 24)).copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          AppText(
                            '${_data.total} hadithi',
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
                            color: isSelected ? null : cardSurface,
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
                          child: AppText(
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

              StaggeredFadeSlide(
                order: 0,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppConstants.paddingLarge),
                  child: NeumorphicCard(
                    borderRadius: 20,
                    color: cardSurface,
                    padding: const EdgeInsets.all(14),
                    child: Row(
                      children: [
                        Expanded(child: _buildStatPill('Jumla', '${_data.total}', Icons.menu_book_outlined)),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _buildStatPill(
                            'Audio',
                            '${_data.audio}',
                            Icons.headphones_rounded,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _buildStatPill(
                            'Bajeti',
                            'TSh ${_data.budget.toStringAsFixed(0)}',
                            Icons.account_balance_wallet_outlined,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 14),

              // Purchased stories list
              Expanded(
                child: _buildListContent(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildListContent() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.paddingLarge),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppText(_error!, textAlign: TextAlign.center),
              const SizedBox(height: 12),
              ElevatedButton(onPressed: _loadPurchases, child: AppText('Jaribu tena')),
            ],
          ),
        ),
      );
    }

    final stories = _filteredStories;
    if (stories.isEmpty) {
      return const Center(
        child: AppText(
          'Hakuna hadithi za kuonyesha kwenye kichujio hiki.',
          style: TextStyle(color: Colors.white70),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadPurchases,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: AppConstants.paddingLarge).copyWith(bottom: 40),
        itemCount: stories.length,
        itemBuilder: (context, index) {
          return StaggeredFadeSlide(
            order: index + 1,
            child: _buildPurchaseCard(stories[index]),
          );
        },
      ),
    );
  }

  Widget _buildPurchaseCard(Story story) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardSurface = isDark ? const Color(0xFF2F2118) : AppColors.cardBackground;
    final placeholderSurface = isDark ? const Color(0xFF3A2A20) : AppColors.backgroundLight;
    final mutedText = isDark ? Colors.white70 : AppColors.textSecondary;

    return GestureDetector(
      onTap: () {
        context.push('/story/${story.id}', extra: story);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        child: NeumorphicCard(
          borderRadius: 20,
          color: cardSurface,
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
                    color: placeholderSurface,
                    child: const Center(child: CircularProgressIndicator()),
                  ),
                  errorWidget: (context, url, error) => Container(
                    color: placeholderSurface,
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
                    AppText(
                      story.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    AppText(
                      story.author,
                      style: TextStyle(
                        fontSize: 13,
                        color: mutedText,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.star, size: 16, color: AppColors.warning),
                        const SizedBox(width: 4),
                        AppText(
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
                                AppText(
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
                    AppText(
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
                    icon: Icons.chrome_reader_mode,
                    size: 40,
                    iconColor: AppColors.sunsetOrange,
                    onPressed: () {
                      context.push('/ebook-reader/${story.id}', extra: story);
                    },
                  ),
                  const SizedBox(height: 8),
                  NeumorphicIconButton(
                    icon: Icons.download,
                    size: 40,
                    onPressed: () {
                      // Handle download
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: AppText('Inapakua...')),
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

  Widget _buildStatPill(String label, String value, IconData icon) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: isDark ? const Color(0x33FFFFFF) : AppColors.warmBeige.withOpacity(0.35),
        border: Border.all(color: AppColors.glassBorder),
      ),
      child: Column(
        children: [
          Icon(icon, size: 16, color: AppColors.sunsetOrange),
          const SizedBox(height: 4),
          AppText(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
          const SizedBox(height: 2),
          AppText(
            label,
            style: TextStyle(fontSize: 10, color: isDark ? Colors.white60 : AppColors.textMuted),
          ),
        ],
      ),
    );
  }
}

