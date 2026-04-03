import 'dart:typed_data';

import 'package:flutter/material.dart';
import '../../shared/widgets/app_text.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../core/auth/auth_provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/i18n/app_i18n.dart';
import '../../core/services/tts_service.dart';
import '../../shared/widgets/glassmorphic_container.dart';
import '../../shared/widgets/neumorphic_widgets.dart';
import 'data/upload_book_repository.dart';

class UploadBookScreen extends StatefulWidget {
  const UploadBookScreen({super.key});

  @override
  State<UploadBookScreen> createState() => _UploadBookScreenState();
}

class _UploadBookScreenState extends State<UploadBookScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();

  final ImagePicker _picker = ImagePicker();
  final UploadBookRepository _repository = UploadBookRepository();

  String _selectedCategory = AppConstants.storyCategories.first;
  String _selectedLanguage = 'Kiswahili';
  bool _isFree = false;
  bool _hasAudio = false;
  bool _isSubmitting = false;

  XFile? _coverImage;
  Uint8List? _coverPreview;

  final List<_ChapterInput> _chapters = [_ChapterInput(index: 1)];

  final List<String> _languages = const ['Kiswahili', 'English'];

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    for (final chapter in _chapters) {
      chapter.dispose();
    }
    super.dispose();
  }

  Future<void> _pickCoverImage() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: AppText('Chagua kutoka Gallery'),
              onTap: () => Navigator.of(context).pop(ImageSource.gallery),
            ),
            ListTile(
              leading: const Icon(Icons.photo_camera_outlined),
              title: AppText('Piga picha kwa Camera'),
              onTap: () => Navigator.of(context).pop(ImageSource.camera),
            ),
          ],
        ),
      ),
    );
    if (source == null) return;

    final picked = await _picker.pickImage(source: source, imageQuality: 85);
    if (picked == null) return;

    final bytes = await picked.readAsBytes();
    if (!mounted) return;

    setState(() {
      _coverImage = picked;
      _coverPreview = bytes;
    });
  }

  void _addChapter() {
    setState(() {
      _chapters.add(_ChapterInput(index: _chapters.length + 1));
    });
  }

  void _removeChapter(int idx) {
    if (_chapters.length == 1) return;
    setState(() {
      final removed = _chapters.removeAt(idx);
      removed.dispose();
      for (var i = 0; i < _chapters.length; i++) {
        _chapters[i].index = i + 1;
      }
    });
  }

  Future<void> _submit({required bool publishNow}) async {
    if (_formKey.currentState?.validate() != true) return;

    final auth = context.read<AuthProvider>();
    final token = auth.token;
    if (token == null || token.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: AppText('Ingia kwanza ili kupakia hadithi.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final chapters = <ChapterDraft>[];
    for (final chapter in _chapters) {
      final title = chapter.titleController.text.trim();
      final content = chapter.contentController.text.trim();
      if (title.isEmpty || content.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: AppText('Kila sura lazima iwe na kichwa na maudhui.'),
            backgroundColor: AppColors.error,
          ),
        );
        return;
      }
      chapters.add(ChapterDraft(title: title, content: content, order: chapter.index));
    }

    if (publishNow && chapters.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: AppText('Ongeza angalau sura moja kabla ya kuchapisha.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final parsedPrice = _isFree ? 0.0 : (double.tryParse(_priceController.text.trim()) ?? -1);
    if (!_isFree && parsedPrice < 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: AppText('Bei sio sahihi.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      await _repository.createBook(
        token: token,
        title: _titleController.text,
        description: _descriptionController.text,
        category: _selectedCategory,
        language: _selectedLanguage,
        isFree: _isFree,
        price: parsedPrice,
        hasAudio: _hasAudio,
        publishNow: publishNow,
        chapters: chapters,
        coverImage: _coverImage,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: AppText(
            publishNow
                ? 'Hadithi imechapishwa. Itaonekana Home na Explore mara moja.'
                : 'Rasimu imehifadhiwa. Unaweza kuichapisha baadaye.',
          ),
          backgroundColor: AppColors.success,
        ),
      );
      context.go('/author-dashboard');
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: AppText('Imeshindikana kupakia hadithi: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundTop = isDark ? AppColors.backgroundDark : AppColors.backgroundLight;
    final backgroundBottom = isDark ? const Color(0xFF2A1B12) : AppColors.warmBeige;
    final primaryText = isDark ? Colors.white : AppColors.textPrimary;
    final mutedText = isDark ? Colors.white70 : AppColors.textMuted;

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
              Padding(
                padding: const EdgeInsets.all(AppConstants.paddingLarge),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: () => context.pop(),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AppText(
                            'Pakia Hadithi Mpya',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: primaryText,
                            ),
                          ),
                          SizedBox(height: 4),
                          AppText(
                            'Andika sura, chagua bei, lugha na uchapishe',
                            style: TextStyle(
                              fontSize: 13,
                              color: mutedText,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Form(
                  key: _formKey,
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: AppConstants.paddingLarge),
                    children: [
                      _buildSectionTitle('Picha ya Jalada (Hiari)'),
                      const SizedBox(height: 10),
                      GestureDetector(
                        onTap: _pickCoverImage,
                        child: Container(
                          height: 190,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            gradient: _coverPreview == null
                                ? LinearGradient(
                                    colors: [
                                      AppColors.clayBlue.withOpacity(0.3),
                                      AppColors.clayPink.withOpacity(0.3),
                                    ],
                                  )
                                : null,
                            border: Border.all(color: AppColors.glassBorder, width: 1.6),
                          ),
                          child: _coverPreview == null
                              ? const Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.add_photo_alternate, size: 52, color: AppColors.textMuted),
                                    SizedBox(height: 8),
                                    AppText('Bofya kuchagua picha ya jalada'),
                                  ],
                                )
                              : ClipRRect(
                                  borderRadius: BorderRadius.circular(18),
                                  child: Image.memory(
                                    _coverPreview!,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      _buildSectionTitle('Taarifa za Msingi'),
                      const SizedBox(height: 12),
                      _buildTextField(
                        controller: _titleController,
                        label: 'Kichwa cha Hadithi',
                        hint: 'Mfano: Safari ya Simba',
                        icon: Icons.title,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Weka kichwa cha hadithi.';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        controller: _descriptionController,
                        label: 'Maelezo',
                        hint: 'Eleza hadithi kwa ufupi...',
                        icon: Icons.description,
                        maxLines: 4,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Weka maelezo ya hadithi.';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final compact = constraints.maxWidth < 380;
                          if (compact) {
                            return Column(
                              children: [
                                _buildDropdown(
                                  label: 'Kategoria',
                                  value: _selectedCategory,
                                  items: AppConstants.storyCategories,
                                  onChanged: (value) {
                                    if (value == null) return;
                                    setState(() {
                                      _selectedCategory = value;
                                    });
                                  },
                                ),
                                const SizedBox(height: 12),
                                _buildDropdown(
                                  label: 'Lugha',
                                  value: _selectedLanguage,
                                  items: _languages,
                                  onChanged: (value) {
                                    if (value == null) return;
                                    setState(() {
                                      _selectedLanguage = value;
                                    });
                                  },
                                ),
                              ],
                            );
                          }

                          return Row(
                            children: [
                              Expanded(
                                child: _buildDropdown(
                                  label: 'Kategoria',
                                  value: _selectedCategory,
                                  items: AppConstants.storyCategories,
                                  onChanged: (value) {
                                    if (value == null) return;
                                    setState(() {
                                      _selectedCategory = value;
                                    });
                                  },
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: _buildDropdown(
                                  label: 'Lugha',
                                  value: _selectedLanguage,
                                  items: _languages,
                                  onChanged: (value) {
                                    if (value == null) return;
                                    setState(() {
                                      _selectedLanguage = value;
                                    });
                                  },
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                      const SizedBox(height: 14),
                      GlassmorphicContainer(
                        borderRadius: 14,
                        blur: 10,
                        color: isDark ? AppColors.glassDark : AppColors.glassWhite,
                        borderColor: AppColors.glassBorder,
                        borderWidth: 1.1,
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        child: Row(
                          children: [
                            const Icon(Icons.record_voice_over, color: AppColors.sunsetOrange, size: 18),
                            const SizedBox(width: 8),
                            Expanded(
                              child: AppText(
                                'Piper voice: ${TTSService.getVoiceDisplayName(_selectedLanguage)}',
                                style: TextStyle(fontSize: 12, color: mutedText),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),
                      GlassmorphicContainer(
                        borderRadius: 16,
                        blur: 10,
                        color: isDark ? AppColors.glassDark : AppColors.glassWhite,
                        borderColor: AppColors.glassBorder,
                        borderWidth: 1.2,
                        child: SwitchListTile(
                          value: _hasAudio,
                          onChanged: (value) {
                            setState(() {
                              _hasAudio = value;
                            });
                          },
                          title: AppText('Ina audiobook?'),
                          subtitle: AppText('Weka ON kama hadithi ina audio.'),
                          activeColor: AppColors.sunsetOrange,
                        ),
                      ),
                      const SizedBox(height: 24),
                      _buildSectionTitle('Bei na Upatikanaji'),
                      const SizedBox(height: 12),
                      GlassmorphicContainer(
                        borderRadius: 16,
                        blur: 10,
                        color: isDark ? AppColors.glassDark : AppColors.glassWhite,
                        borderColor: AppColors.glassBorder,
                        borderWidth: 1.2,
                        child: SwitchListTile(
                          value: _isFree,
                          onChanged: (value) {
                            setState(() {
                              _isFree = value;
                              if (_isFree) {
                                _priceController.text = '0';
                              }
                            });
                          },
                          title: AppText('Hadithi ni bure?'),
                          subtitle: AppText('Weka ON kufanya usomaji bure kwa wote.'),
                          activeColor: AppColors.success,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildTextField(
                        controller: _priceController,
                        label: 'Bei (TSh)',
                        hint: _isFree ? '0' : '500',
                        icon: Icons.attach_money,
                        keyboardType: TextInputType.number,
                        enabled: !_isFree,
                        validator: (value) {
                          if (_isFree) return null;
                          if (value == null || value.trim().isEmpty) {
                            return 'Weka bei ya hadithi.';
                          }
                          final parsed = double.tryParse(value.trim());
                          if (parsed == null || parsed < 0) {
                            return 'Weka namba sahihi ya bei.';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildSectionTitle('Sura za Hadithi'),
                          TextButton.icon(
                            onPressed: _addChapter,
                            icon: const Icon(Icons.add),
                            label: AppText('Ongeza Sura'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ...List.generate(_chapters.length, (index) {
                        final chapter = _chapters[index];
                        return _buildChapterCard(index, chapter);
                      }),
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: Container(
        width: MediaQuery.of(context).size.width - 32,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            Expanded(
              child: NeumorphicButton(
                onPressed: _isSubmitting ? null : () => _submit(publishNow: false),
                color: AppColors.clayBlue,
                height: 54,
                borderRadius: 26,
                child: _isSubmitting
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: Colors.white,
                        ),
                      )
                    : const FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.save_outlined, color: Colors.white, size: 18),
                            SizedBox(width: 6),
                            AppText(
                              'Hifadhi Rasimu',
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14),
                            ),
                          ],
                        ),
                      ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: NeumorphicButton(
                onPressed: _isSubmitting ? null : () => _submit(publishNow: true),
                color: AppColors.sunsetOrange,
                height: 54,
                borderRadius: 26,
                child: _isSubmitting
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: Colors.white,
                        ),
                      )
                    : const FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.publish, color: Colors.white, size: 20),
                            SizedBox(width: 8),
                            AppText(
                              'Chapisha',
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14),
                            ),
                          ],
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildChapterCard(int index, _ChapterInput chapter) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GlassmorphicContainer(
        borderRadius: 16,
        blur: 10,
        color: isDark ? AppColors.glassDark : AppColors.glassWhite,
        borderColor: AppColors.glassBorder,
        borderWidth: 1.2,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  AppText(
                    'Sura ${chapter.index}',
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  IconButton(
                    onPressed: () => _removeChapter(index),
                    icon: const Icon(Icons.delete_outline, color: AppColors.error),
                  ),
                ],
              ),
              _buildTextField(
                controller: chapter.titleController,
                label: 'Kichwa cha Sura',
                hint: 'Mfano: Mwanzo wa Safari',
                icon: Icons.bookmark_outline,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) return 'Weka kichwa cha sura.';
                  return null;
                },
              ),
              const SizedBox(height: 10),
              _buildTextField(
                controller: chapter.contentController,
                label: 'Maudhui ya Sura',
                hint: 'Andika maudhui ya sura hapa...',
                icon: Icons.notes,
                maxLines: 8,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) return 'Andika maudhui ya sura.';
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AppText(
      title,
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: isDark ? Colors.white : AppColors.textPrimary,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    int maxLines = 1,
    TextInputType? keyboardType,
    bool enabled = true,
    String? Function(String?)? validator,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white : AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        GlassmorphicContainer(
          borderRadius: 16,
          blur: 10,
          color: isDark ? AppColors.glassDark : AppColors.glassWhite,
          borderColor: AppColors.glassBorder,
          borderWidth: 1.5,
          child: TextFormField(
            controller: controller,
            maxLines: maxLines,
            keyboardType: keyboardType,
            validator: (value) {
              final message = validator?.call(value);
              if (message == null) return null;
              return context.tr(message);
            },
            enabled: enabled,
            decoration: InputDecoration(
              hintText: context.tr(hint),
              hintStyle: TextStyle(
                color: isDark ? Colors.white54 : AppColors.textMuted,
                fontSize: 13,
              ),
              prefixIcon: Icon(icon, color: AppColors.sunsetOrange, size: 20),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown({
    required String label,
    required String value,
    required List<String> items,
    required void Function(String?) onChanged,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white : AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        GlassmorphicContainer(
          borderRadius: 16,
          blur: 10,
          color: isDark ? AppColors.glassDark : AppColors.glassWhite,
          borderColor: AppColors.glassBorder,
          borderWidth: 1.5,
          child: DropdownButtonFormField<String>(
            value: value,
            isExpanded: true,
            items: items
                .map(
                  (item) => DropdownMenuItem<String>(
                    value: item,
                    child: AppText(
                      item,
                      style: const TextStyle(fontSize: 13),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                )
                .toList(),
            onChanged: onChanged,
            decoration: const InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
            icon: const Icon(Icons.arrow_drop_down, color: AppColors.sunsetOrange),
          ),
        ),
      ],
    );
  }
}

class _ChapterInput {
  _ChapterInput({required this.index});

  int index;
  final TextEditingController titleController = TextEditingController();
  final TextEditingController contentController = TextEditingController();

  void dispose() {
    titleController.dispose();
    contentController.dispose();
  }
}

