import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../shared/widgets/neumorphic_widgets.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Mock history data grouped by date
    final historyData = {
      'Leo': [
        {
          'title': 'Simba Mjanja',
          'author': 'Juma Bakari',
          'coverImage': 'https://images.unsplash.com/photo-1614027164847-1b28cfe1df60?w=800&q=80',
          'progress': 0.75,
          'time': '2 masaa',
        },
        {
          'title': 'Pembe ya Ndovu',
          'author': 'Amina Hassan',
          'coverImage': 'https://images.unsplash.com/photo-1564760055775-d63b17a55c44?w=800&q=80',
          'progress': 0.45,
          'time': '1 saa',
        },
      ],
      'Jana': [
        {
          'title': 'Twiga na Sungura',
          'author': 'Mohamed Ali',
          'coverImage': 'https://images.unsplash.com/photo-1551316679-9c6ae9dec224?w=800&q=80',
          'progress': 1.0,
          'time': '3 masaa',
        },
      ],
      'Wiki iliyopita': [
        {
          'title': 'Fisi Mjanja',
          'author': 'Fatuma Rashid',
          'coverImage': 'https://images.unsplash.com/photo-1589883661923-6476cb0ae9f2?w=800&q=80',
          'progress': 0.6,
          'time': '5 masaa',
        },
      ],
    };

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
                            'Historia',
                            style: (Theme.of(context).textTheme.headlineSmall ?? const TextStyle(fontSize: 24)).copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          Text(
                            'Hadithi nilizosoma',
                            style: (Theme.of(context).textTheme.bodyMedium ?? const TextStyle(fontSize: 14)).copyWith(
                                  color: AppColors.textSecondary,
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
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: AppConstants.paddingLarge),
                  children: historyData.entries.map((entry) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12, top: 8),
                          child: Text(
                            entry.key,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                        ...entry.value.map((item) => _buildHistoryCard(context, item)).toList(),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHistoryCard(BuildContext context, Map<String, dynamic> item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: NeumorphicCard(
        borderRadius: 20,
        color: AppColors.cardBackground,
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
                    imageUrl: item['coverImage'],
                    width: 70,
                    height: 90,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      color: AppColors.backgroundLight,
                      child: const Center(child: CircularProgressIndicator()),
                    ),
                    errorWidget: (context, url, error) => Container(
                      color: AppColors.backgroundLight,
                      child: const Icon(Icons.book, size: 30, color: AppColors.textMuted),
                    ),
                  ),
                ),
                if (item['progress'] == 1.0)
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
                  Text(
                    item['title'],
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item['author'],
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.access_time, size: 14, color: AppColors.textMuted),
                      const SizedBox(width: 4),
                      Text(
                        item['time'],
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textMuted,
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
                          value: item['progress'],
                          backgroundColor: AppColors.backgroundLight,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            item['progress'] == 1.0 ? AppColors.success : AppColors.sunsetOrange,
                          ),
                          minHeight: 6,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${(item['progress'] * 100).toInt()}% iliyomaliza',
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.textMuted,
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
                // Navigate to story
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
        title: const Text('Futa Historia'),
        content: const Text('Je, una uhakika unataka kufuta historia yako yote?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Ghairi'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Historia imefutwa')),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Futa'),
          ),
        ],
      ),
    );
  }
}
