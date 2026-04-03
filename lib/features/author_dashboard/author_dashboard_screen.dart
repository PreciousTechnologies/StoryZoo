import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import '../../shared/widgets/app_text.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import '../../core/auth/auth_provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/i18n/app_i18n.dart';
import '../../models/story.dart';
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
  Map<String, dynamic>? _dashboardData;
  bool _isLoading = true;
  String? _loadError;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadDashboard();
    });
  }

  Future<void> _loadDashboard() async {
    final auth = context.read<AuthProvider>();
    final token = auth.token;

    if (token == null || token.isEmpty) {
      setState(() {
        _isLoading = false;
        _loadError = 'Tafadhali ingia tena ili kuona dashibodi.';
      });
      return;
    }

    try {
      final url = Uri.parse('${AppConstants.apiBaseUrl}${AppConstants.apiVersion}/authors/dashboard/');
      final res = await http.get(
        url,
        headers: {'Authorization': 'Token $token'},
      );

      if (res.statusCode == 401) {
        await auth.logout();
        if (!mounted) return;
        setState(() {
          _isLoading = false;
          _loadError = 'Tafadhali ingia tena ili kuona dashibodi.';
        });
        return;
      }

      if (res.statusCode != 200) {
        throw Exception('Dashibodi haikupatikana (${res.statusCode}).');
      }

      final payload = jsonDecode(res.body) as Map<String, dynamic>;
      setState(() {
        _dashboardData = payload;
        _isLoading = false;
        _loadError = null;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _loadError = e.toString();
      });
    }
  }

  Future<void> _deleteBook(int bookId) async {
    final token = context.read<AuthProvider>().token;
    if (token == null || token.isEmpty) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: AppText('Futa Hadithi'),
        content: AppText('Una uhakika unataka kufuta hadithi hii? Haitaweza kurudishwa.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: AppText('Ghairi')),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: AppText('Futa'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    final url = Uri.parse('${AppConstants.apiBaseUrl}${AppConstants.apiVersion}/books/$bookId/manage/');
    final res = await http.delete(url, headers: {'Authorization': 'Token $token'});
    if (res.statusCode != 204) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: AppText('Imeshindikana kufuta hadithi (${res.statusCode}).')),
      );
      return;
    }

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: AppText('Hadithi imefutwa.')),
    );
    await _loadDashboard();
  }

  Future<void> _editBookDialog(Map<String, dynamic> story) async {
    final token = context.read<AuthProvider>().token;
    if (token == null || token.isEmpty) return;

    final titleController = TextEditingController(text: (story['title'] ?? '').toString());
    final descriptionController = TextEditingController(text: (story['description'] ?? '').toString());
    final priceController = TextEditingController(text: ((story['price'] ?? 0) as num).toStringAsFixed(0));
    String selectedCategory = (story['category'] ?? AppConstants.storyCategories.first).toString();
    String selectedLanguage = (story['language'] ?? 'Kiswahili').toString();
    bool isFree = story['is_free'] == true;
    bool hasAudio = story['has_audio'] == true;

    final saved = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: AppText('Hariri Hadithi'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: InputDecoration(labelText: context.tr('Kichwa')),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: descriptionController,
                  maxLines: 3,
                  decoration: InputDecoration(labelText: context.tr('Maelezo')),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: selectedCategory,
                  isExpanded: true,
                  items: AppConstants.storyCategories
                      .map((c) => DropdownMenuItem(value: c, child: AppText(c, overflow: TextOverflow.ellipsis)))
                      .toList(),
                  onChanged: (v) => setDialogState(() => selectedCategory = v ?? selectedCategory),
                  decoration: InputDecoration(labelText: context.tr('Kategoria')),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: selectedLanguage,
                  isExpanded: true,
                  items: const ['Kiswahili', 'English', 'Kiarabu']
                      .map((l) => DropdownMenuItem(value: l, child: AppText(l, overflow: TextOverflow.ellipsis)))
                      .toList(),
                  onChanged: (v) => setDialogState(() => selectedLanguage = v ?? selectedLanguage),
                  decoration: InputDecoration(labelText: context.tr('Lugha')),
                ),
                const SizedBox(height: 8),
                SwitchListTile(
                  value: isFree,
                  onChanged: (v) {
                    setDialogState(() {
                      isFree = v;
                      if (isFree) priceController.text = '0';
                    });
                  },
                  title: AppText('Bure'),
                  contentPadding: EdgeInsets.zero,
                ),
                SwitchListTile(
                  value: hasAudio,
                  onChanged: (v) => setDialogState(() => hasAudio = v),
                  title: AppText('Ina audiobook'),
                  contentPadding: EdgeInsets.zero,
                ),
                TextField(
                  controller: priceController,
                  enabled: !isFree,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(labelText: context.tr('Bei (TSh)')),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, false), child: AppText('Ghairi')),
            ElevatedButton(onPressed: () => Navigator.pop(context, true), child: AppText('Hifadhi')),
          ],
        ),
      ),
    );

    if (saved != true) return;

    final bookId = (story['id'] as num).toInt();
    final url = Uri.parse('${AppConstants.apiBaseUrl}${AppConstants.apiVersion}/books/$bookId/manage/');
    final payload = {
      'title': titleController.text.trim(),
      'description': descriptionController.text.trim(),
      'category': selectedCategory,
      'language': selectedLanguage,
      'is_free': isFree,
      'has_audio': hasAudio,
      'price': isFree ? 0 : (double.tryParse(priceController.text.trim()) ?? 0),
    };

    final res = await http.patch(
      url,
      headers: {'Authorization': 'Token $token', 'Content-Type': 'application/json'},
      body: jsonEncode(payload),
    );

    if (res.statusCode != 200) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: AppText('Imeshindikana kuhifadhi mabadiliko (${res.statusCode}).')),
      );
      return;
    }

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: AppText('Mabadiliko yamehifadhiwa.')));
    await _loadDashboard();
  }

  void _previewBook(Map<String, dynamic> story) {
    final bookId = (story['id'] as num).toInt();
    final previewStory = Story(
      id: '$bookId',
      title: (story['title'] ?? '').toString(),
      description: (story['description'] ?? '').toString(),
      author: ((_dashboardData?['author'] ?? const {})['full_name'] ?? 'Author').toString(),
      authorId: 'author',
      category: (story['category'] ?? '').toString(),
      language: (story['language'] ?? 'Kiswahili').toString(),
      coverImage: (story['cover_image_url'] ?? '').toString(),
      price: ((story['price'] ?? 0) as num).toDouble(),
      hasAudio: story['has_audio'] == true,
      publishedDate: DateTime.now(),
    );
    context.push('/ebook-reader/$bookId', extra: previewStory);
  }

  String _formatCurrency(num value) {
    return 'TSh ${value.toStringAsFixed(0)}';
  }

  Map<String, dynamic> _fallbackDashboard() {
    return {
      'author': {
        'full_name': 'Mwandishi',
        'bio': '',
        'phone': '',
        'payout_account': '',
      },
      'stats': {
        'total_earnings': 0,
        'total_readers': 0,
        'total_stories': 0,
        'approved_stories': 0,
        'pending_stories': 0,
        'average_rating': 0,
        'review_count': 0,
      },
      'weekly_sales': <Map<String, dynamic>>[],
      'payout': {
        'upcoming_amount': 0,
        'history': <Map<String, dynamic>>[],
      },
      'stories': <Map<String, dynamic>>[],
    };
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final isAuthor = auth.isAuthor;
    final roleLabel = auth.role.toLowerCase() == 'author' ? 'Author' : 'User';
    final dashboard = _dashboardData ?? _fallbackDashboard();
    final author = (dashboard['author'] as Map<String, dynamic>? ?? {});
    final stats = (dashboard['stats'] as Map<String, dynamic>? ?? {});
    final weeklySales = (dashboard['weekly_sales'] as List?)?.cast<Map<String, dynamic>>() ?? <Map<String, dynamic>>[];
    final payout = (dashboard['payout'] as Map<String, dynamic>? ?? {});
    final stories = (dashboard['stories'] as List?)?.cast<Map<String, dynamic>>() ?? <Map<String, dynamic>>[];
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundTop = isDark ? AppColors.backgroundDark : AppColors.backgroundLight;
    final backgroundBottom = isDark ? const Color(0xFF2A1B12) : AppColors.warmBeige;
    final glassColor = isDark ? AppColors.glassDark : AppColors.glassWhite;
    final secondaryText = isDark ? Colors.white70 : AppColors.textSecondary;

    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_loadError != null) {
      return Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline, size: 40, color: AppColors.error),
                const SizedBox(height: 10),
                AppText(
                  _loadError!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppColors.textPrimary),
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: _loadDashboard,
                  child: AppText('Jaribu tena'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              backgroundTop,
              backgroundBottom,
            ],
          ),
        ),
        child: SafeArea(
          child: RefreshIndicator(
            onRefresh: _loadDashboard,
            child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
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
                            AppText(
                              'Dashibodi',
                              style: (Theme.of(context).textTheme.headlineSmall ?? const TextStyle(fontSize: 20)).copyWith(
                                    color: secondaryText,
                                  ),
                            ),
                            AppText(
                              (author['full_name'] ?? 'Mwandishi').toString(),
                              style: (Theme.of(context).textTheme.displaySmall ?? const TextStyle(fontSize: 32)).copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            const SizedBox(height: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: (roleLabel == 'Author' ? AppColors.savannaGreen : AppColors.info).withOpacity(0.14),
                                borderRadius: BorderRadius.circular(999),
                                border: Border.all(
                                  color: (roleLabel == 'Author' ? AppColors.savannaGreen : AppColors.info).withOpacity(0.35),
                                ),
                              ),
                              child: AppText(
                                roleLabel,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: roleLabel == 'Author' ? AppColors.savannaGreen : AppColors.info,
                                ),
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
                                AppText('Mwanzo'),
                              ],
                            ),
                          ),
                          const PopupMenuItem(
                            value: 'explore',
                            child: Row(
                              children: [
                                Icon(Icons.explore, size: 20),
                                SizedBox(width: 12),
                                AppText('Gundua'),
                              ],
                            ),
                          ),
                          const PopupMenuItem(
                            value: 'profile',
                            child: Row(
                              children: [
                                Icon(Icons.person, size: 20),
                                SizedBox(width: 12),
                                AppText('Wasifu'),
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
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppConstants.paddingLarge),
                  child: GlassmorphicContainer(
                    borderRadius: 20,
                    blur: 10,
                    color: glassColor,
                    borderColor: AppColors.glassBorder,
                    borderWidth: 1.5,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AppText(
                            'Taarifa za Mwandishi',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 10),
                          AppText('Jina: ${(author['full_name'] ?? '-').toString()}'),
                          const SizedBox(height: 6),
                          AppText('Bio: ${(author['bio'] ?? '-').toString()}'),
                          const SizedBox(height: 6),
                          AppText('Simu: ${(author['phone'] ?? '-').toString()}'),
                          const SizedBox(height: 6),
                          AppText('Akaunti ya Malipo: ${(author['payout_account'] ?? '-').toString()}'),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 16)),

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
                      _formatCurrency((stats['total_earnings'] ?? 0) as num),
                      Icons.monetization_on_outlined,
                      AppColors.sunsetOrange,
                      'Mapato yote',
                    ),
                    _buildStatCard(
                      context,
                      'Wasomaji',
                      '${stats['total_readers'] ?? 0}',
                      Icons.people_outline,
                      AppColors.savannaGreen,
                      'Jumla ya usomaji',
                    ),
                    _buildStatCard(
                      context,
                      'Hadithi',
                      '${stats['total_stories'] ?? 0}',
                      Icons.auto_stories_outlined,
                      AppColors.clayBlue,
                      '${stats['approved_stories'] ?? 0} zimepitishwa',
                    ),
                    _buildStatCard(
                      context,
                      'Tathmini',
                      '${stats['average_rating'] ?? 0} ⭐',
                      Icons.star_outline,
                      AppColors.warning,
                      'kutoka kwa ${stats['review_count'] ?? 0}',
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
                      AppText(
                        'Takwimu za Mauzo',
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      const SizedBox(height: 16),
                      _buildSalesGraph(context, weeklySales),
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
                      AppText(
                        'Hali ya Malipo',
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      const SizedBox(height: 16),
                      _buildPayoutStatus(context, payout),
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
                      AppText(
                        'Hadithi Zangu',
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      TextButton(
                        onPressed: () {},
                        child: AppText(
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
                sliver: stories.isEmpty
                    ? SliverToBoxAdapter(
                        child: NeumorphicCard(
                          borderRadius: 16,
                          padding: const EdgeInsets.all(16),
                          child: AppText('Bado hujapakia hadithi yoyote.'),
                        ),
                      )
                    : SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) => _buildStoryItem(context, stories[index]),
                          childCount: stories.length,
                        ),
                      ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          ),
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
              child: AppText(
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final glassColor = isDark ? AppColors.glassDark.withOpacity(0.6) : AppColors.glassWhite.withOpacity(0.6);
    final primaryText = isDark ? Colors.white : AppColors.textPrimary;
    final mutedText = isDark ? Colors.white70 : AppColors.textMuted;

    return GlassmorphicContainer(
      borderRadius: 25,
      blur: 12,
      color: glassColor,
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
                AppText(
                  value,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: primaryText),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                AppText(
                  title,
                  style: TextStyle(fontSize: 12, color: mutedText),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                AppText(
                  subtitle,
                  style: TextStyle(fontSize: 10, color: mutedText),
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
  
  Widget _buildSalesGraph(BuildContext context, List<Map<String, dynamic>> salesData) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final glassColor = isDark ? AppColors.glassDark : AppColors.glassWhite;
    final mutedText = isDark ? Colors.white60 : AppColors.textMuted;

    if (salesData.isEmpty) {
      return NeumorphicCard(
        borderRadius: 18,
        padding: const EdgeInsets.all(16),
        child: AppText('Hakuna takwimu za mauzo kwa sasa.'),
      );
    }

    final maxAmount = salesData
      .map((e) => (e['amount'] as num?)?.toDouble() ?? 0.0)
      .fold<double>(0.0, (a, b) => a > b ? a : b);
    final safeMax = maxAmount <= 0 ? 1.0 : maxAmount;
    final totalWeek = salesData.fold<double>(0, (sum, item) => sum + ((item['amount'] as num?)?.toDouble() ?? 0));
    
    return GlassmorphicContainer(
      borderRadius: 20,
      blur: 10,
      color: glassColor,
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
                AppText('Wiki Hii', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [AppColors.sunsetOrange, AppColors.deepOrange]),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: AppText(
                    _formatCurrency(totalWeek),
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
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
                  final amount = (data['amount'] as num?)?.toDouble() ?? 0;
                  final height = (amount / safeMax) * 110;
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
                      AppText(data['day'] as String, style: TextStyle(fontSize: 10, color: mutedText)),
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
  
  Widget _buildPayoutStatus(BuildContext context, Map<String, dynamic> payout) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final glassColor = isDark ? AppColors.glassDark : AppColors.glassWhite;

    final history = (payout['history'] as List?)?.cast<Map<String, dynamic>>() ?? <Map<String, dynamic>>[];
    return GlassmorphicContainer(
      borderRadius: 20,
      blur: 10,
      color: glassColor,
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
                      AppText('Malipo Yanayokuja', style: TextStyle(fontSize: 13, color: AppColors.textMuted)),
                      SizedBox(height: 4),
                      AppText('', style: TextStyle(fontSize: 0)),
                    ],
                  ),
                ),
              ],
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: AppText(
                _formatCurrency((payout['upcoming_amount'] ?? 0) as num),
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.success),
              ),
            ),
            const SizedBox(height: 20),
            const Divider(),
            const SizedBox(height: 16),
            if (history.isEmpty)
              AppText('Hakuna historia ya malipo kwa sasa.')
            else
              ...history.take(5).map(
                (item) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _buildPayoutItem(
                    (item['title'] ?? '').toString(),
                    _formatCurrency((item['amount'] ?? 0) as num),
                    AppColors.success,
                    Icons.check_circle,
                  ),
                ),
              ),
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
        Expanded(child: AppText(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500))),
        AppText(amount, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildStoryItem(BuildContext context, Map<String, dynamic> story) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardSurface = isDark ? const Color(0xFF2F2118) : AppColors.cardBackground;
    final thumbColor = isDark ? const Color(0x33FFFFFF) : AppColors.warmBeige;
    final placeholderAccent = isDark ? AppColors.warmBeige : Colors.white;

    final statusText = (story['status'] ?? '').toString();
    final statusColor = statusText == 'Imechapishwa'
        ? AppColors.success
        : (statusText == 'Inasubiri' ? AppColors.warning : AppColors.error);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: NeumorphicCard(
        borderRadius: 20,
        padding: const EdgeInsets.all(12),
        color: cardSurface,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Story thumbnail
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: thumbColor,
              ),
              clipBehavior: Clip.antiAlias,
              child: (story['cover_image_url'] ?? '').toString().isNotEmpty
                  ? Image.network(
                      (story['cover_image_url'] ?? '').toString(),
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Icon(
                        Icons.auto_stories,
                        size: 32,
                        color: placeholderAccent,
                      ),
                    )
                  : Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.clayBlue.withOpacity(0.6),
                            AppColors.clayPink.withOpacity(0.6),
                          ],
                        ),
                      ),
                      child: Icon(Icons.auto_stories, size: 32, color: placeholderAccent),
                    ),
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
                        child: AppText(
                          story['title'],
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: statusColor.withOpacity(0.3)),
                        ),
                        child: AppText(
                          statusText,
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w600,
                            color: statusColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Flexible(child: _buildMiniStat(Icons.visibility_outlined, '${story['views'] ?? 0}')),
                      const SizedBox(width: 8),
                      Flexible(child: _buildMiniStat(Icons.star, '${story['rating'] ?? 0}')),
                      const SizedBox(width: 8),
                      Flexible(child: _buildMiniStat(Icons.monetization_on, _formatCurrency((story['earnings'] ?? 0) as num))),
                    ],
                  ),
                ],
              ),
            ),

            PopupMenuButton<String>(
              icon: Icon(Icons.more_vert, color: isDark ? Colors.white70 : AppColors.textPrimary),
              onSelected: (value) {
                switch (value) {
                  case 'preview':
                    _previewBook(story);
                    break;
                  case 'edit':
                    _editBookDialog(story);
                    break;
                  case 'delete':
                    _deleteBook((story['id'] as num).toInt());
                    break;
                }
              },
              itemBuilder: (context) => const [
                PopupMenuItem(value: 'preview', child: AppText('Preview')),
                PopupMenuItem(value: 'edit', child: AppText('Hariri')),
                PopupMenuItem(value: 'delete', child: AppText('Futa')),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMiniStat(IconData icon, String value) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final muted = isDark ? Colors.white60 : AppColors.textMuted;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: muted),
        const SizedBox(width: 3),
        Flexible(
          child: AppText(
            value,
            style: TextStyle(
              fontSize: 10,
              color: muted,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

