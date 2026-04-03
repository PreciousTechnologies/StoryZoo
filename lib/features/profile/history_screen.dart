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
import 'data/profile_repository.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final ProfileRepository _repository = ProfileRepository();
  bool _isLoading = true;
  String? _error;
  HistoryData _history = const HistoryData(
    mudaHours: 0,
    vitabu: 0,
    kumalizaPercent: 0,
    groups: {'Leo': [], 'Jana': [], 'Wiki iliyopita': []},
  );

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadHistory());
  }

  @override
  void dispose() {
    _repository.dispose();
    super.dispose();
  }

  Future<void> _loadHistory() async {
    final token = context.read<AuthProvider>().token;
    if (token == null || token.isEmpty) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _error = 'Tafadhali ingia tena ili kuona historia.';
      });
      return;
    }

    try {
      final payload = await _repository.fetchHistory(token);
      if (!mounted) return;
      setState(() {
        _history = payload;
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
                            'Historia',
                            style: (Theme.of(context).textTheme.headlineSmall ?? const TextStyle(fontSize: 24)).copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          AppText(
                            'Hadithi nilizosoma',
                            style: (Theme.of(context).textTheme.bodyMedium ?? const TextStyle(fontSize: 14)).copyWith(
                                  color: secondaryText,
                                ),
                          ),
                        ],
                      ),
                    ),
                    NeumorphicIconButton(
                      icon: Icons.delete_outline,
                      size: 50,
                      onPressed: () {
                        _showClearHistoryDialog(context);
                      },
                    ),
                  ],
                ),
              ),

              // History list
              Expanded(
                child: _buildBody(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardSurface = isDark ? const Color(0xFF2F2118) : AppColors.cardBackground;

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
              ElevatedButton(onPressed: _loadHistory, child: AppText('Jaribu tena')),
            ],
          ),
        ),
      );
    }

    final groups = {
      'Leo': _history.groups['Leo'] ?? const <HistoryEntry>[],
      'Jana': _history.groups['Jana'] ?? const <HistoryEntry>[],
      'Wiki iliyopita': _history.groups['Wiki iliyopita'] ?? const <HistoryEntry>[],
    };

    final hasAnyItems = groups.values.any((items) => items.isNotEmpty);

    return RefreshIndicator(
      onRefresh: _loadHistory,
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: AppConstants.paddingLarge).copyWith(bottom: 40),
        children: [
          StaggeredFadeSlide(
            order: 0,
            child: NeumorphicCard(
              borderRadius: 20,
              color: cardSurface,
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  Expanded(child: _buildMetric('Muda', '${_history.mudaHours.toStringAsFixed(1)}h', Icons.timer_outlined)),
                  const SizedBox(width: 10),
                  Expanded(child: _buildMetric('Vitabu', '${_history.vitabu}', Icons.library_books_outlined)),
                  const SizedBox(width: 10),
                  Expanded(child: _buildMetric('Kumaliza', '${_history.kumalizaPercent.toStringAsFixed(0)}%', Icons.trending_up_rounded)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),
          if (!hasAnyItems)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 48),
              child: Center(
                child: AppText(
                  'Hakuna historia ya usomaji kwa sasa.',
                  style: TextStyle(color: Colors.white70),
                ),
              ),
            ),
          ...groups.entries.map((entry) {
            if (entry.value.isEmpty) return const SizedBox.shrink();
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 12, top: 8),
                  child: AppText(
                    entry.key,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : AppColors.textPrimary,
                    ),
                  ),
                ),
                ...entry.value.asMap().entries.map((row) {
                  return StaggeredFadeSlide(
                    order: row.key + 1,
                    child: _buildHistoryCard(context, row.value),
                  );
                }),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildMetric(String title, String value, IconData icon) {
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
          AppText(value, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
          const SizedBox(height: 2),
          AppText(
            title,
            style: TextStyle(fontSize: 10, color: isDark ? Colors.white60 : AppColors.textMuted),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryCard(BuildContext context, HistoryEntry item) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardSurface = isDark ? const Color(0xFF2F2118) : AppColors.cardBackground;
    final placeholderSurface = isDark ? const Color(0xFF3A2A20) : AppColors.backgroundLight;
    final mutedText = isDark ? Colors.white70 : AppColors.textMuted;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: NeumorphicCard(
        borderRadius: 20,
        color: cardSurface,
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Cover image with progress indicator
            Stack(
              alignment: Alignment.center,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: CachedNetworkImage(
                    imageUrl: item.story.coverImage,
                    width: 70,
                    height: 90,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      color: placeholderSurface,
                      child: const Center(child: CircularProgressIndicator()),
                    ),
                    errorWidget: (context, url, error) => Container(
                      color: placeholderSurface,
                      child: const Icon(Icons.book, size: 30, color: AppColors.textMuted),
                    ),
                  ),
                ),
                if (item.progress >= 1.0)
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppColors.success,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.success.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 16),

            // Story details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText(
                    item.story.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  AppText(
                    item.story.author,
                    style: TextStyle(
                      fontSize: 13,
                        color: isDark ? Colors.white70 : AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.access_time, size: 14, color: AppColors.textMuted),
                      const SizedBox(width: 4),
                      AppText(
                        item.timeLabel,
                        style: TextStyle(
                          fontSize: 12,
                          color: mutedText,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Progress bar
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: item.progress,
                          backgroundColor: isDark ? const Color(0x44FFFFFF) : AppColors.backgroundLight,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            item.progress >= 1.0 ? AppColors.success : AppColors.sunsetOrange,
                          ),
                          minHeight: 6,
                        ),
                      ),
                      const SizedBox(height: 4),
                      AppText(
                        '${(item.progress * 100).toInt()}% iliyomaliza',
                        style: TextStyle(
                          fontSize: 11,
                          color: mutedText,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(width: 12),
            NeumorphicIconButton(
              icon: Icons.play_circle_filled,
              size: 40,
              iconColor: AppColors.sunsetOrange,
              onPressed: () {
                context.push('/story/${item.story.id}', extra: item.story);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showClearHistoryDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: AppText('Futa Historia'),
        content: AppText('Je, una uhakika unataka kufuta historia yako yote?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: AppText('Ghairi'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: AppText('Historia imefutwa')),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: AppText('Futa'),
          ),
        ],
      ),
    );
  }
}

