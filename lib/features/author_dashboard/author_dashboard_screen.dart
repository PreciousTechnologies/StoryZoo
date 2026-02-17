import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../shared/widgets/glassmorphic_container.dart';
import '../../shared/widgets/neumorphic_widgets.dart';
import '../../shared/widgets/clay_widgets.dart';
import '../../shared/widgets/enhanced_bottom_nav.dart';

class AuthorDashboardScreen extends StatefulWidget {
  const AuthorDashboardScreen({super.key});

  @override
  State<AuthorDashboardScreen> createState() => _AuthorDashboardScreenState();
}

class _AuthorDashboardScreenState extends State<AuthorDashboardScreen> {
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
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Dashibodi',
                              style: (Theme.of(context).textTheme.headlineSmall ?? const TextStyle(fontSize: 20)).copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                            ),
                            Text(
                              'Mwandishi',
                              style: (Theme.of(context).textTheme.displaySmall ?? const TextStyle(fontSize: 32)).copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                          ],
                        ),
                      ),
                      PopupMenuButton<String>(
                        icon: const Icon(Icons.menu, size: 28),
                        onSelected: (value) {
                          switch (value) {
                            case 'home':
                              context.go('/');
                              break;
                            case 'explore':
                              context.go('/explore');
                              break;
                            case 'profile':
                              context.go('/profile');
                              break;
                          }
                        },
                        itemBuilder: (context) => [
                          const PopupMenuItem(
                            value: 'home',
                            child: Row(
                              children: [
                                Icon(Icons.home, size: 20),
                                SizedBox(width: 12),
                                Text('Mwanzo'),
                              ],
                            ),
                          ),
                          const PopupMenuItem(
                            value: 'explore',
                            child: Row(
                              children: [
                                Icon(Icons.explore, size: 20),
                                SizedBox(width: 12),
                                Text('Gundua'),
                              ],
                            ),
                          ),
                          const PopupMenuItem(
                            value: 'profile',
                            child: Row(
                              children: [
                                Icon(Icons.person, size: 20),
                                SizedBox(width: 12),
                                Text('Wasifu'),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // Statistics Cards
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: AppConstants.paddingLarge),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 1.1,
                  ),
                  delegate: SliverChildListDelegate([
                    _buildStatCard(
                      context,
                      'Mapato',
                      'TSh 1,250,000',
                      Icons.monetization_on_outlined,
                      AppColors.sunsetOrange,
                      '+15% mwezi huu',
                    ),
                    _buildStatCard(
                      context,
                      'Wasomaji',
                      '3,482',
                      Icons.people_outline,
                      AppColors.savannaGreen,
                      '+8% mwezi huu',
                    ),
                    _buildStatCard(
                      context,
                      'Hadithi',
                      '24',
                      Icons.auto_stories_outlined,
                      AppColors.clayBlue,
                      '12 zimepitishwa',
                    ),
                    _buildStatCard(
                      context,
                      'Tathmini',
                      '4.8 ⭐',
                      Icons.star_outline,
                      AppColors.warning,
                      'kutoka kwa 186',
                    ),
                  ]),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 30)),

              // Sales Graph Section
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppConstants.paddingLarge),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Takwimu za Mauzo',
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      const SizedBox(height: 16),
                      _buildSalesGraph(context),
                    ],
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 30)),

              // Payout Status Section
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppConstants.paddingLarge),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Hali ya Malipo',
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      const SizedBox(height: 16),
                      _buildPayoutStatus(context),
                    ],
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 30)),

              // My Stories Section
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppConstants.paddingLarge),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Hadithi Zangu',
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      TextButton(
                        onPressed: () {},
                        child: Text(
                          'Tazama Zote',
                          style: TextStyle(
                            color: AppColors.sunsetOrange,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Stories List
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: AppConstants.paddingLarge),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => _buildStoryItem(context, index),
                    childCount: 3,
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          ),
        ),
      ),

      // Claymorphism FAB for upload
      floatingActionButton: ClayButton(
        onPressed: () {
          context.push('/upload-book');
        },
        color: AppColors.sunsetOrange,
        width: 170,
        height: 60,
        borderRadius: 30,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.add_circle_outline, color: Colors.white, size: 24),
            const SizedBox(width: 10),
            const Flexible(
              child: Text(
                'Pakia Hadithi',
                style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      bottomNavigationBar: EnhancedBottomNav(
        currentIndex: 4,
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
              context.go('/saved');
              break;
            case 3:
              context.go('/profile');
              break;
            case 4:
              // Already on dashboard
              break;
          }
        },
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
    String subtitle,
  ) {
    return GlassmorphicContainer(
      borderRadius: 25,
      blur: 12,
      color: AppColors.glassWhite.withOpacity(0.6),
      borderColor: color.withOpacity(0.3),
      borderWidth: 2,
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.trending_up, color: color, size: 16),
              ),
            ],
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  value,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  title,
                  style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(fontSize: 10, color: AppColors.textMuted),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildSalesGraph(BuildContext context) {
    final List<Map<String, dynamic>> salesData = [
      {'day': 'Jum', 'amount': 45000},
      {'day': 'Jmt', 'amount': 52000},
      {'day': 'Jpl', 'amount': 38000},
      {'day': 'Alh', 'amount': 68000},
      {'day': 'Iju', 'amount': 75000},
      {'day': 'Jma', 'amount': 82000},
      {'day': 'Jpi', 'amount': 91000},
    ];
    
    final maxAmount = salesData.map((e) => e['amount'] as int).reduce((a, b) => a > b ? a : b);
    
    return GlassmorphicContainer(
      borderRadius: 20,
      blur: 10,
      color: AppColors.glassWhite,
      borderColor: AppColors.glassBorder,
      borderWidth: 1.5,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Wiki Hii', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [AppColors.sunsetOrange, AppColors.deepOrange]),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text('+18.5%', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white)),
                ),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 140,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: salesData.map((data) {
                  final height = (data['amount'] as int) / maxAmount * 110;
                  return Flexible(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 28,
                          height: height,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: [AppColors.sunsetOrange, AppColors.deepOrange],
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(data['day'] as String, style: const TextStyle(fontSize: 10, color: AppColors.textMuted)),
                    ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildPayoutStatus(BuildContext context) {
    return GlassmorphicContainer(
      borderRadius: 20,
      blur: 10,
      color: AppColors.glassWhite,
      borderColor: AppColors.glassBorder,
      borderWidth: 1.5,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [AppColors.success, AppColors.savannaGreen]),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(Icons.account_balance_wallet, color: Colors.white, size: 28),
                ),
                const SizedBox(width: 16),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Malipo Yanayokuja', style: TextStyle(fontSize: 13, color: AppColors.textMuted)),
                      SizedBox(height: 4),
                      Text('TSh 875,000', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.success)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Divider(),
            const SizedBox(height: 16),
            _buildPayoutItem('Malipo ya Januari 2026', 'TSh 825,000', AppColors.success, Icons.check_circle),
            const SizedBox(height: 12),
            _buildPayoutItem('Malipo ya Disemba 2025', 'TSh 765,000', AppColors.success, Icons.check_circle),
          ],
        ),
      ),
    );
  }
  
  Widget _buildPayoutItem(String title, String amount, Color color, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 12),
        Expanded(child: Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500))),
        Text(amount, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildStoryItem(BuildContext context, int index) {
    final List<Map<String, dynamic>> stories = [
      {
        'title': 'Simba Mjanja',
        'status': 'Imepitishwa',
        'views': '1,245',
        'earnings': 'TSh 250,000',
        'rating': '4.8',
        'color': AppColors.success,
      },
      {
        'title': 'Pembe ya Ndovu',
        'status': 'Inasubiri',
        'views': '890',
        'earnings': 'TSh 180,000',
        'rating': '4.6',
        'color': AppColors.warning,
      },
      {
        'title': 'Twiga na Sungura',
        'status': 'Imepitishwa',
        'views': '2,100',
        'earnings': 'TSh 420,000',
        'rating': '4.9',
        'color': AppColors.success,
      },
    ];

    final story = stories[index];

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: NeumorphicCard(
        borderRadius: 20,
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Story thumbnail
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(
                  colors: [
                    AppColors.clayBlue.withOpacity(0.6),
                    AppColors.clayPink.withOpacity(0.6),
                  ],
                ),
              ),
              child: const Icon(Icons.auto_stories, size: 32, color: Colors.white),
            ),

            const SizedBox(width: 12),

            // Story info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          story['title'],
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: story['color'].withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: story['color'].withOpacity(0.3)),
                        ),
                        child: Text(
                          story['status'],
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w600,
                            color: story['color'],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Flexible(child: _buildMiniStat(Icons.visibility_outlined, story['views'])),
                      const SizedBox(width: 8),
                      Flexible(child: _buildMiniStat(Icons.star, story['rating'])),
                      const SizedBox(width: 8),
                      Flexible(child: _buildMiniStat(Icons.monetization_on, story['earnings'])),
                    ],
                  ),
                ],
              ),
            ),

            // More button
            NeumorphicIconButton(
              icon: Icons.more_vert,
              size: 36,
              onPressed: () {
                // Show options
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMiniStat(IconData icon, String value) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: AppColors.textMuted),
        const SizedBox(width: 3),
        Flexible(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 10,
              color: AppColors.textMuted,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
