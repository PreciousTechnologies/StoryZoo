import 'package:flutter/material.dart';
import '../../shared/widgets/app_text.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../core/auth/auth_provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/i18n/app_i18n.dart';
import 'data/profile_repository.dart';
import '../../shared/widgets/glassmorphic_container.dart';
import '../../shared/widgets/micro_interactions.dart';
import '../../shared/widgets/neumorphic_widgets.dart';
import '../../shared/widgets/enhanced_bottom_nav.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final isAuthor = auth.isAuthor;
    final roleLabel = auth.role.toLowerCase() == 'author' ? 'Author' : 'User';
    final displayName = auth.displayName.isEmpty ? 'StoryZoo Reader' : auth.displayName;
    final email = auth.userEmail ?? 'No email';
    final avatarUrl = auth.avatarUrl;
    final currentLanguageLabel = auth.preferredLanguage == 'en' ? 'English' : 'Kiswahili';
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundTop = isDark ? AppColors.backgroundDark : AppColors.backgroundLight;
    final backgroundBottom = isDark ? const Color(0xFF33283A) : AppColors.clayPurple;
    final glassColor = isDark ? AppColors.glassDark : AppColors.glassWhite;
    final cardSurface = isDark ? const Color(0xFF2F2118) : AppColors.cardBackground;
    final primaryText = isDark ? Colors.white : AppColors.textPrimary;
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
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppConstants.paddingLarge).copyWith(bottom: 100),
            child: Column(
              children: [
                // Profile header
                StaggeredFadeSlide(
                  order: 0,
                  child: GlassmorphicContainer(
                    borderRadius: 30,
                    blur: 15,
                    color: glassColor,
                    borderColor: AppColors.glassBorder,
                    borderWidth: 2,
                    padding: const EdgeInsets.all(24),
                    child: Column(
                    children: [
                      // Avatar
                      SizedBox(
                        width: 120,
                        height: 120,
                        child: Stack(
                          children: [
                            Container(
                              width: 120,
                              height: 120,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: const LinearGradient(
                                  colors: [
                                    AppColors.sunsetOrange,
                                    AppColors.deepOrange,
                                  ],
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.sunsetOrange.withOpacity(0.3),
                                    blurRadius: 20,
                                    offset: const Offset(0, 10),
                                  ),
                                ],
                              ),
                              child: ClipOval(
                                child: CachedNetworkImage(
                                  imageUrl: avatarUrl.isEmpty
                                      ? 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=400&q=80'
                                      : avatarUrl,
                                  fit: BoxFit.cover,
                                  placeholder: (context, url) => const Center(
                                    child: Icon(Icons.person, size: 60, color: Colors.white),
                                  ),
                                  errorWidget: (context, url, error) => const Center(
                                    child: Icon(Icons.person, size: 60, color: Colors.white),
                                  ),
                                ),
                              ),
                            ),
                            Positioned.fill(
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(999),
                                  onTap: () => _showEditProfileDialog(context),
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: const BoxDecoration(
                                  color: AppColors.success,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.edit,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Name
                      AppText(
                        displayName,
                        style: (Theme.of(context).textTheme.headlineSmall ?? const TextStyle(fontSize: 24)).copyWith(
                              fontWeight: FontWeight.bold,
                              color: primaryText,
                            ),
                      ),
                      const SizedBox(height: 4),

                      // Email
                      AppText(
                        email,
                        style: (Theme.of(context).textTheme.bodyMedium ?? const TextStyle(fontSize: 14)).copyWith(
                              color: secondaryText,
                            ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 10),
                      _buildRoleBadge(roleLabel),
                      const SizedBox(height: 20),

                      // Stats
                      Row(
                        children: [
                          Expanded(child: _LiveProfileStatsCell(token: auth.token, field: _ProfileStatField.hadithi)),
                          Container(width: 1, height: 40, color: AppColors.glassBorder),
                          Expanded(child: _LiveProfileStatsCell(token: auth.token, field: _ProfileStatField.zilizohifadhiwa)),
                          Container(width: 1, height: 40, color: AppColors.glassBorder),
                          Expanded(child: _LiveProfileStatsCell(token: auth.token, field: _ProfileStatField.masaa)),
                        ],
                      ),
                    ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Premium membership card
                StaggeredFadeSlide(
                  order: 1,
                  child: NeumorphicCard(
                    borderRadius: 24,
                    color: cardSurface,
                    padding: const EdgeInsets.all(18),
                    child: Column(
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [AppColors.sunsetOrange, AppColors.deepOrange],
                              ),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: const Icon(Icons.workspace_premium, color: Colors.white),
                          ),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                AppText(
                                  'Story Zoo Plus',
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                                ),
                                SizedBox(height: 4),
                                AppText(
                                  'Soma bila matangazo, pata mapendekezo maalum na ufikie releases mapema.',
                                  style: TextStyle(fontSize: 12, color: AppColors.textMuted),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Align(
                        alignment: Alignment.centerRight,
                        child: NeumorphicButton(
                          onPressed: () {},
                          width: 108,
                          height: 38,
                          borderRadius: 18,
                          color: AppColors.savannaGreen,
                          child: AppText(
                            'Boresha',
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 12),
                          ),
                        ),
                      ),
                    ],
                    ),
                  ),
                ),

                const SizedBox(height: 18),

                // Quick actions
                StaggeredFadeSlide(
                  order: 2,
                  child: NeumorphicCard(
                    borderRadius: 22,
                    color: cardSurface,
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                    child: Wrap(
                    alignment: WrapAlignment.spaceAround,
                    runSpacing: 12,
                    children: [
                      _buildQuickAction(
                        context,
                        icon: Icons.shopping_bag_rounded,
                        label: 'Manunuzi',
                        color: AppColors.sunsetOrange,
                        onTap: () => context.push('/my-purchases'),
                      ),
                      _buildQuickAction(
                        context,
                        icon: Icons.history_rounded,
                        label: 'Historia',
                        color: AppColors.info,
                        onTap: () => context.push('/history'),
                      ),
                      _buildQuickAction(
                        context,
                        icon: Icons.favorite_rounded,
                        label: 'Saved',
                        color: AppColors.error,
                        onTap: () => context.go('/saved'),
                      ),
                      _buildQuickAction(
                        context,
                        icon: Icons.headphones_rounded,
                        label: 'Audio',
                        color: AppColors.savannaGreen,
                        onTap: () {},
                      ),
                    ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 24),

                Align(
                  alignment: Alignment.centerLeft,
                  child: AppText(
                    'Akaunti na Mipangilio',
                    style: (Theme.of(context).textTheme.titleMedium ?? const TextStyle(fontSize: 16)).copyWith(
                          fontWeight: FontWeight.w700,
                          color: secondaryText,
                        ),
                  ),
                ),

                const SizedBox(height: 12),

                // Menu items
                _buildMenuItem(
                  context,
                  icon: Icons.shopping_bag_rounded,
                  title: 'Manunuzi Yangu',
                  subtitle: 'Hadithi nilizoinunua',
                  color: AppColors.sunsetOrange,
                  onTap: () {
                    context.push('/my-purchases');
                  },
                ),
                const SizedBox(height: 12),

                _buildMenuItem(
                  context,
                  icon: Icons.history_rounded,
                  title: 'Historia',
                  subtitle: 'Hadithi nilizosoma',
                  color: AppColors.info,
                  onTap: () {
                    context.push('/history');
                  },
                ),
                const SizedBox(height: 12),

                _buildMenuItem(
                  context,
                  icon: Icons.payment_rounded,
                  title: 'Malipo',
                  subtitle: 'Njia za malipo',
                  color: AppColors.success,
                  onTap: () {
                    context.push('/payments');
                  },
                ),
                const SizedBox(height: 12),

                _buildMenuItem(
                  context,
                  icon: Icons.notifications_rounded,
                  title: 'Arifa',
                  subtitle: 'Mipangilio ya arifa',
                  color: AppColors.warning,
                  onTap: () {
                    context.push('/notifications');
                  },
                ),
                const SizedBox(height: 12),

                _buildMenuItem(
                  context,
                  icon: Icons.language_rounded,
                  title: 'Lugha',
                  subtitle: currentLanguageLabel,
                  color: AppColors.savannaGreen,
                  onTap: () {
                    context.push('/language');
                  },
                ),
                const SizedBox(height: 12),

                _buildMenuItem(
                  context,
                  icon: Icons.dark_mode_rounded,
                  title: 'Mandhari',
                  subtitle: 'Hali ya giza/Mwanga',
                  color: AppColors.clayPurple,
                  onTap: () {
                    context.push('/theme');
                  },
                ),
                const SizedBox(height: 12),

                _buildMenuItem(
                  context,
                  icon: Icons.help_rounded,
                  title: 'Msaada',
                  subtitle: 'Maswali yanayoulizwa',
                  color: AppColors.info,
                  onTap: () {
                    context.push('/help');
                  },
                ),
                const SizedBox(height: 12),

                _buildMenuItem(
                  context,
                  icon: Icons.info_rounded,
                  title: 'Kuhusu',
                  subtitle: 'Toleo 1.0.0',
                  color: AppColors.textMuted,
                  onTap: () {
                    context.push('/about');
                  },
                ),
                const SizedBox(height: 24),

                // Logout button
                NeumorphicCard(
                  borderRadius: 20,
                  color: AppColors.error.withOpacity(0.1),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  onTap: () {
                    _showLogoutDialog(context);
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.logout_rounded, color: AppColors.error, size: 24),
                      const SizedBox(width: 12),
                      AppText(
                        'Toka',
                        style: (Theme.of(context).textTheme.titleMedium ?? const TextStyle(fontSize: 16)).copyWith(
                              color: AppColors.error,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: EnhancedBottomNav(
        currentIndex: 3,
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
              // Already on profile
              break;
            case 4:
              context.go('/author-dashboard');
              break;
          }
        },
      ),
    );
  }

  Widget _buildQuickAction(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 68,
        child: Column(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: color.withOpacity(0.2)),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(height: 6),
            AppText(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white70 : AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoleBadge(String roleLabel) {
    final isAuthorRole = roleLabel == 'Author';
    final color = isAuthorRole ? AppColors.savannaGreen : AppColors.info;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.14),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withOpacity(0.35)),
      ),
      child: AppText(
        roleLabel,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: NeumorphicCard(
        borderRadius: 20,
        color: isDark ? const Color(0xFF2F2118) : AppColors.cardBackground,
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText(
                    title,
                    style: (Theme.of(context).textTheme.titleMedium ?? const TextStyle(fontSize: 16)).copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: 2),
                  AppText(
                    subtitle,
                    style: (Theme.of(context).textTheme.bodySmall ?? const TextStyle(fontSize: 12)).copyWith(
                          color: isDark ? Colors.white60 : AppColors.textMuted,
                        ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: isDark ? Colors.white54 : AppColors.textMuted,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: AppText('Toka'),
        content: AppText('Je, una uhakika unataka kutoka?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: AppText('Ghairi'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await context.read<AuthProvider>().logout();
              if (!context.mounted) return;
              context.go('/');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: AppText('Toka'),
          ),
        ],
      ),
    );
  }

  void _showEditProfileDialog(BuildContext context) {
    final auth = context.read<AuthProvider>();
    final nameController = TextEditingController(text: auth.displayName);
    final picker = ImagePicker();
    XFile? selectedImage;

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: AppText('Sasisha wasifu'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(
                  labelText: context.tr('Jina (hiari)'),
                  hintText: context.tr('Andika jina lako'),
                ),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        final image = await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
                        if (image == null) return;
                        setDialogState(() => selectedImage = image);
                      },
                      icon: const Icon(Icons.photo_library_outlined),
                      label: AppText('Gallery'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        final image = await picker.pickImage(source: ImageSource.camera, imageQuality: 80);
                        if (image == null) return;
                        setDialogState(() => selectedImage = image);
                      },
                      icon: const Icon(Icons.photo_camera_outlined),
                      label: AppText('Camera'),
                    ),
                  ),
                ],
              ),
              if (selectedImage != null) ...[
                const SizedBox(height: 8),
                AppText(
                  'Picha mpya: ${selectedImage!.name}',
                  style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                ),
              ] else ...[
                const SizedBox(height: 8),
                AppText(
                  'Hakuna picha mpya iliyochaguliwa',
                  style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                ),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: AppText('Ghairi'),
            ),
            ElevatedButton(
              onPressed: () async {
                try {
                  await auth.updateUserProfile(
                    displayName: nameController.text,
                    avatarImage: selectedImage,
                  );
                  if (!dialogContext.mounted) return;
                  Navigator.pop(dialogContext);
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: AppText('Wasifu umesasishwa.')),
                  );
                } catch (e) {
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: AppText('Imeshindikana kusasisha wasifu: $e')),
                  );
                }
              },
              child: AppText('Hifadhi'),
            ),
          ],
        ),
      ),
    );
  }
}

enum _ProfileStatField { hadithi, zilizohifadhiwa, masaa }

class _LiveProfileStatsCell extends StatefulWidget {
  const _LiveProfileStatsCell({
    required this.token,
    required this.field,
  });

  final String? token;
  final _ProfileStatField field;

  @override
  State<_LiveProfileStatsCell> createState() => _LiveProfileStatsCellState();
}

class _LiveProfileStatsCellState extends State<_LiveProfileStatsCell> {
  final ProfileRepository _repository = ProfileRepository();
  ProfileStatsData? _stats;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didUpdateWidget(covariant _LiveProfileStatsCell oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.token != widget.token) {
      _load();
    }
  }

  @override
  void dispose() {
    _repository.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final token = widget.token;
    if (token == null || token.isEmpty) return;
    try {
      final stats = await _repository.fetchProfileStats(token);
      if (!mounted) return;
      setState(() => _stats = stats);
    } catch (_) {
      if (!mounted) return;
      setState(() => _stats = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    String label;
    String value;
    final stats = _stats;

    switch (widget.field) {
      case _ProfileStatField.hadithi:
        label = 'Hadithi';
        value = '${stats?.storiesCount ?? 0}';
        break;
      case _ProfileStatField.zilizohifadhiwa:
        label = 'Zilizohifadhiwa';
        value = '${stats?.savedCount ?? 0}';
        break;
      case _ProfileStatField.masaa:
        label = 'Masaa';
        value = (stats?.listeningHours ?? 0).toStringAsFixed(1);
        break;
    }

    return Column(
      children: [
        AppText(
          value,
          style: (Theme.of(context).textTheme.headlineSmall ?? const TextStyle(fontSize: 24)).copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.sunsetOrange,
              ),
        ),
        const SizedBox(height: 4),
        AppText(
          label,
          style: (Theme.of(context).textTheme.bodySmall ?? const TextStyle(fontSize: 12)).copyWith(
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white70
                    : AppColors.textSecondary,
              ),
        ),
      ],
    );
  }
}

