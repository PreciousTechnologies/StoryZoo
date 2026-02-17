import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../shared/widgets/glassmorphic_container.dart';
import '../../shared/widgets/neumorphic_widgets.dart';

class UploadBookScreen extends StatefulWidget {
  const UploadBookScreen({super.key});

  @override
  State<UploadBookScreen> createState() => _UploadBookScreenState();
}

class _UploadBookScreenState extends State<UploadBookScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Form controllers
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  
  // Form state
  String _selectedCategory = 'Watoto';
  String _selectedLanguage = 'Kiswahili';
  bool _hasAudiobook = false;
  bool _hasEbook = true;
  String? _ebookPath;
  String? _audiobookPath;
  String? _coverImagePath;
  
  final List<String> _categories = ['Watoto', 'Elimu', 'Imani', 'Hadithi', 'Biashara'];
  final List<String> _languages = ['Kiswahili', 'English', 'Kiarabu'];

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    super.dispose();
  }

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
              // Header
              Padding(
                padding: const EdgeInsets.all(AppConstants.paddingLarge),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: () => context.pop(),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Pakia Hadithi Mpya',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Shiriki hadithi yako na ulimwengu',
                            style: TextStyle(
                              fontSize: 13,
                              color: AppColors.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              
              // Form content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: AppConstants.paddingLarge),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Cover Image
                        _buildSectionTitle('Picha ya Jalada'),
                        const SizedBox(height: 12),
                        GestureDetector(
                          onTap: _pickCoverImage,
                          child: Container(
                            height: 200,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              gradient: _coverImagePath != null
                                  ? null
                                  : LinearGradient(
                                      colors: [
                                        AppColors.clayBlue.withOpacity(0.3),
                                        AppColors.clayPink.withOpacity(0.3),
                                      ],
                                    ),
                              border: Border.all(
                                color: AppColors.glassBorder,
                                width: 2,
                                style: BorderStyle.solid,
                              ),
                            ),
                            child: _coverImagePath != null
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(18),
                                    child: Image.asset(
                                      _coverImagePath!,
                                      fit: BoxFit.cover,
                                    ),
                                  )
                                : const Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.add_photo_alternate, size: 60, color: AppColors.textMuted),
                                      SizedBox(height: 12),
                                      Text(
                                        'Bofya kuchagua picha ya jalada',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: AppColors.textMuted,
                                        ),
                                      ),
                                    ],
                                  ),
                          ),
                        ),
                        
                        const SizedBox(height: 24),
                        
                        // Basic Info
                        _buildSectionTitle('Taarifa za Msingi'),
                        const SizedBox(height: 12),
                        _buildTextField(
                          controller: _titleController,
                          label: 'Kichwa cha Hadithi',
                          hint: 'Mfano: Simba Mjanja',
                          icon: Icons.title,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Tafadhali ingiza kichwa';
                            }
                            return null;
                          },
                        ),
                        
                        const SizedBox(height: 16),
                        
                        _buildTextField(
                          controller: _descriptionController,
                          label: 'Maelezo',
                          hint: 'Eleza hadithi yako kwa ufupi...',
                          icon: Icons.description,
                          maxLines: 4,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Tafadhali andika maelezo';
                            }
                            return null;
                          },
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // Category & Language
                        Row(
                          children: [
                            Expanded(
                              child: _buildDropdown(
                                label: 'Aina',
                                value: _selectedCategory,
                                items: _categories,
                                onChanged: (value) {
                                  setState(() {
                                    _selectedCategory = value!;
                                  });
                                },
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _buildDropdown(
                                label: 'Lugha',
                                value: _selectedLanguage,
                                items: _languages,
                                onChanged: (value) {
                                  setState(() {
                                    _selectedLanguage = value!;
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 24),
                        
                        // Content Type
                        _buildSectionTitle('Aina ya Maudhui'),
                        const SizedBox(height: 12),
                        
                        GlassmorphicContainer(
                          borderRadius: 16,
                          blur: 10,
                          color: AppColors.glassWhite,
                          borderColor: AppColors.glassBorder,
                          borderWidth: 1.5,
                          child: Column(
                            children: [
                              CheckboxListTile(
                                value: _hasEbook,
                                onChanged: (value) {
                                  setState(() {
                                    _hasEbook = value ?? true;
                                  });
                                },
                                title: const Text('eBook (PDF/EPUB)', style: TextStyle(fontSize: 14)),
                                subtitle: Text(
                                  _ebookPath ?? 'Chagua faili',
                                  style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                                ),
                                secondary: const Icon(Icons.menu_book, color: AppColors.success),
                                activeColor: AppColors.success,
                                controlAffinity: ListTileControlAffinity.leading,
                              ),
                              if (_hasEbook)
                                Padding(
                                  padding: const EdgeInsets.only(left: 72, right: 16, bottom: 12),
                                  child: ElevatedButton.icon(
                                    onPressed: _pickEbookFile,
                                    icon: const Icon(Icons.upload_file, size: 18),
                                    label: const Text('Pakia eBook', style: TextStyle(fontSize: 13)),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.success,
                                      foregroundColor: Colors.white,
                                      minimumSize: const Size(double.infinity, 40),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                  ),
                                ),
                              const Divider(height: 1),
                              CheckboxListTile(
                                value: _hasAudiobook,
                                onChanged: (value) {
                                  setState(() {
                                    _hasAudiobook = value ?? false;
                                  });
                                },
                                title: const Text('Audiobook (MP3/M4A)', style: TextStyle(fontSize: 14)),
                                subtitle: Text(
                                  _audiobookPath ?? 'Chagua faili',
                                  style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                                ),
                                secondary: const Icon(Icons.headphones, color: AppColors.info),
                                activeColor: AppColors.info,
                                controlAffinity: ListTileControlAffinity.leading,
                              ),
                              if (_hasAudiobook)
                                Padding(
                                  padding: const EdgeInsets.only(left: 72, right: 16, bottom: 12),
                                  child: ElevatedButton.icon(
                                    onPressed: _pickAudiobookFile,
                                    icon: const Icon(Icons.upload_file, size: 18),
                                    label: const Text('Pakia Audiobook', style: TextStyle(fontSize: 13)),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.info,
                                      foregroundColor: Colors.white,
                                      minimumSize: const Size(double.infinity, 40),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        
                        const SizedBox(height: 24),
                        
                        // Pricing
                        _buildSectionTitle('Bei'),
                        const SizedBox(height: 12),
                        _buildTextField(
                          controller: _priceController,
                          label: 'Bei (TSh)',
                          hint: '5000',
                          icon: Icons.attach_money,
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Tafadhali ingiza bei';
                            }
                            final price = double.tryParse(value);
                            if (price == null || price < 500) {
                              return 'Bei lazima iwe angalau TSh 500';
                            }
                            return null;
                          },
                        ),
                        
                        const SizedBox(height: 12),
                        
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.info.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.info.withOpacity(0.3)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.info_outline, color: AppColors.info, size: 20),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'Utapata 70% ya bei. Mfano: Bei TSh ${_calculateEarnings()}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                        const SizedBox(height: 100),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      
      // Floating action button
      floatingActionButton: Container(
        width: MediaQuery.of(context).size.width - 32,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: NeumorphicButton(
          onPressed: _publishBook,
          color: AppColors.sunsetOrange,
          height: 56,
          borderRadius: 28,
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.publish, color: Colors.white, size: 24),
              SizedBox(width: 12),
              Text(
                'Chapisha Hadithi',
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
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
  
  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
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
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        GlassmorphicContainer(
          borderRadius: 16,
          blur: 10,
          color: AppColors.glassWhite,
          borderColor: AppColors.glassBorder,
          borderWidth: 1.5,
          child: TextFormField(
            controller: controller,
            maxLines: maxLines,
            keyboardType: keyboardType,
            validator: validator,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 13),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        GlassmorphicContainer(
          borderRadius: 16,
          blur: 10,
          color: AppColors.glassWhite,
          borderColor: AppColors.glassBorder,
          borderWidth: 1.5,
          child: DropdownButtonFormField<String>(
            value: value,
            items: items.map((item) {
              return DropdownMenuItem(
                value: item,
                child: Text(item, style: const TextStyle(fontSize: 13)),
              );
            }).toList(),
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
  
  String _calculateEarnings() {
    final price = double.tryParse(_priceController.text) ?? 0;
    final earnings = price * 0.7;
    return '${earnings.toStringAsFixed(0)} ni yako';
  }
  
  void _pickCoverImage() {
    // Simulate file picker
    setState(() {
      _coverImagePath = 'cover_image.jpg';
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Picha ya jalada imechaguliwa'),
        duration: Duration(seconds: 2),
      ),
    );
  }
  
  void _pickEbookFile() {
    // Simulate file picker
    setState(() {
      _ebookPath = 'hadithi_yangu.pdf';
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Faili la eBook limechaguliwa'),
        duration: Duration(seconds: 2),
      ),
    );
  }
  
  void _pickAudiobookFile() {
    // Simulate file picker
    setState(() {
      _audiobookPath = 'hadithi_yangu.mp3';
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Faili la audiobook limechaguliwa'),
        duration: Duration(seconds: 2),
      ),
    );
  }
  
  void _publishBook() {
    if (_formKey.currentState?.validate() != true) {
      return;
    }
    
    if (!_hasEbook && !_hasAudiobook) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tafadhali chagua angalau eBook au Audiobook'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }
    
    if (_coverImagePath == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tafadhali chagua picha ya jalada'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }
    
    // Show success and navigate back
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Hongera! Hadithi yako imechapishwa!'),
        backgroundColor: AppColors.success,
        duration: Duration(seconds: 3),
      ),
    );
    
    // Navigate to author dashboard
    context.go('/author-dashboard');
  }
}
