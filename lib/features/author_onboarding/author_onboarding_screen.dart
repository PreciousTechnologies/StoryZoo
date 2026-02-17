import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../shared/widgets/glassmorphic_container.dart';
import '../../shared/widgets/neumorphic_widgets.dart';

class AuthorOnboardingScreen extends StatefulWidget {
  const AuthorOnboardingScreen({super.key});

  @override
  State<AuthorOnboardingScreen> createState() => _AuthorOnboardingScreenState();
}

class _AuthorOnboardingScreenState extends State<AuthorOnboardingScreen> {
  int _currentStep = 0;
  final _formKey = GlobalKey<FormState>();
  
  // Form data
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _bankAccountController = TextEditingController();
  bool _agreedToTerms = false;
  
  final List<Map<String, dynamic>> _steps = [
    {
      'title': 'Karibu!',
      'subtitle': 'Anza safari yako ya kuandika na kuuza hadithi',
      'icon': Icons.waving_hand,
      'color': AppColors.sunsetOrange,
    },
    {
      'title': 'Taarifa Binafsi',
      'subtitle': 'Tuambie juu yako',
      'icon': Icons.person,
      'color': AppColors.info,
    },
    {
      'title': 'Malipo',
      'subtitle': 'Weka taarifa za kupokea mapato',
      'icon': Icons.account_balance,
      'color': AppColors.success,
    },
    {
      'title': 'Masharti',
      'subtitle': 'Kubali vigezo vya uandishi',
      'icon': Icons.check_circle,
      'color': AppColors.clayPurple,
    },
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    _phoneController.dispose();
    _bankAccountController.dispose();
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
                    if (_currentStep > 0)
                      IconButton(
                        icon: const Icon(Icons.arrow_back),
                        onPressed: () {
                          if (_currentStep > 0) {
                            setState(() {
                              _currentStep--;
                            });
                          }
                        },
                      ),
                    if (_currentStep == 0)
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => context.pop(),
                      ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            'Kuwa Mwandishi',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Hatua ${_currentStep + 1} ya ${_steps.length}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 48), // Balance the back button
                  ],
                ),
              ),
              
              // Progress indicator
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppConstants.paddingLarge),
                child: Row(
                  children: List.generate(_steps.length, (index) {
                    return Expanded(
                      child: Container(
                        height: 4,
                        margin: EdgeInsets.only(right: index < _steps.length - 1 ? 8 : 0),
                        decoration: BoxDecoration(
                          gradient: index <= _currentStep
                              ? const LinearGradient(
                                  colors: [AppColors.sunsetOrange, AppColors.deepOrange],
                                )
                              : null,
                          color: index > _currentStep ? AppColors.textMuted.withOpacity(0.2) : null,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    );
                  }),
                ),
              ),
              
              // Content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(AppConstants.paddingLarge),
                  child: _buildStepContent(),
                ),
              ),
              
              // Bottom button
              Padding(
                padding: const EdgeInsets.all(AppConstants.paddingLarge),
                child: NeumorphicButton(
                  onPressed: _handleNext,
                  color: _steps[_currentStep]['color'] as Color,
                  height: 56,
                  borderRadius: 28,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _currentStep == _steps.length - 1 ? 'Maliza na Anzisha' : 'Endelea',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.arrow_forward, color: Colors.white, size: 20),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildStepContent() {
    switch (_currentStep) {
      case 0:
        return _buildWelcomeStep();
      case 1:
        return _buildPersonalInfoStep();
      case 2:
        return _buildPaymentStep();
      case 3:
        return _buildTermsStep();
      default:
        return Container();
    }
  }
  
  Widget _buildWelcomeStep() {
    return Column(
      children: [
        const SizedBox(height: 20),
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              colors: [AppColors.sunsetOrange, AppColors.deepOrange],
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.sunsetOrange.withOpacity(0.3),
                blurRadius: 30,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: const Icon(Icons.edit_note, size: 50, color: Colors.white),
        ),
        const SizedBox(height: 20),
        Text(
          'Karibu kwenye jamii ya waandishi!',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 12),
        Text(
          'Pata fursa ya kushiriki hadithi zako na kupata mapato kutoka kwa wasomaji na wasikilizaji wengi.',
          style: TextStyle(
            fontSize: 13,
            color: AppColors.textSecondary,
            height: 1.4,
          ),
          textAlign: TextAlign.center,
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 24),
        _buildBenefitCard(
          icon: Icons.monetization_on,
          title: 'Pata Mapato',
          description: 'Uza hadithi zako na upokee 70% ya mapato',
          color: AppColors.success,
        ),
        const SizedBox(height: 12),
        _buildBenefitCard(
          icon: Icons.people,
          title: 'Wasikilizaji Wengi',
          description: 'Fikia wasomaji milioni Tanzania na nje',
          color: AppColors.info,
        ),
        const SizedBox(height: 12),
        _buildBenefitCard(
          icon: Icons.trending_up,
          title: 'Ukuaji wa Ufundi',
          description: 'Pata takwimu na maoni kutoka kwa wasomaji',
          color: AppColors.clayPurple,
        ),
      ],
    );
  }
  
  Widget _buildPersonalInfoStep() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          const Icon(Icons.person, size: 60, color: AppColors.info),
          const SizedBox(height: 20),
          const Text(
            'Taarifa Binafsi',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Tuambie juu yako ili wasomaji wakujue zaidi',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textMuted,
            ),
          ),
          const SizedBox(height: 30),
          _buildTextField(
            controller: _nameController,
            label: 'Jina Kamili la Mwandishi',
            hint: 'Mfano: Juma Bakari',
            icon: Icons.person_outline,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Tafadhali ingiza jina lako';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),
          _buildTextField(
            controller: _bioController,
            label: 'Wasifu Mfupi',
            hint: 'Eleza juu yako na aina ya hadithi unazopenda...',
            icon: Icons.description_outlined,
            maxLines: 4,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Tafadhali andika wasifu wako';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),
          _buildTextField(
            controller: _phoneController,
            label: 'Namba ya Simu',
            hint: '+255 XXX XXX XXX',
            icon: Icons.phone_outlined,
            keyboardType: TextInputType.phone,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Tafadhali ingiza namba ya simu';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }
  
  Widget _buildPaymentStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        const Icon(Icons.account_balance, size: 60, color: AppColors.success),
        const SizedBox(height: 20),
        const Text(
          'Taarifa za Malipo',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Weka taarifa za kupokea mapato yako',
          style: TextStyle(
            fontSize: 14,
            color: AppColors.textMuted,
          ),
        ),
        const SizedBox(height: 30),
        GlassmorphicContainer(
          borderRadius: 16,
          blur: 10,
          color: AppColors.glassWhite,
          borderColor: AppColors.glassBorder,
          borderWidth: 1.5,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: const BoxDecoration(
                        color: AppColors.success,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.info_outline, color: Colors.white, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Malipo yanafanywa mwishoni mwa kila mwezi kupitia M-PESA au benki',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        _buildTextField(
          controller: _bankAccountController,
          label: 'Namba ya M-PESA au Akaunti ya Benki',
          hint: '0XXX XXX XXX au Namba ya Akaunti',
          icon: Icons.payment,
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.warning.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.warning.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              Icon(Icons.percent, color: AppColors.warning, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Unapata 70% ya kila mauzo. StoryZoo inachukua 30% kwa huduma za app.',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
  
  Widget _buildTermsStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        const Icon(Icons.check_circle, size: 60, color: AppColors.clayPurple),
        const SizedBox(height: 20),
        const Text(
          'Masharti ya Huduma',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Tafadhali soma na ukubali masharti',
          style: TextStyle(
            fontSize: 14,
            color: AppColors.textMuted,
          ),
        ),
        const SizedBox(height: 30),
        GlassmorphicContainer(
          borderRadius: 16,
          blur: 10,
          color: AppColors.glassWhite,
          borderColor: AppColors.glassBorder,
          borderWidth: 1.5,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTermItem('Maudhui yako ni mali yako na haki zako zimehifadhiwa'),
                _buildTermItem('Hadithi zinapaswa kuwa za asili na kuridhisha vigezo vya jamii'),
                _buildTermItem('Malipo yanafanywa kila mwezi baada ya kufikia TSh 50,000'),
                _buildTermItem('Bei za hadithi zinaweza kubadilishwa wakati wowote'),
                _buildTermItem('StoryZoo inaweza kusimamisha akaunti inayokiuka vigezo'),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        GestureDetector(
          onTap: () {
            setState(() {
              _agreedToTerms = !_agreedToTerms;
            });
          },
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: _agreedToTerms
                  ? const LinearGradient(
                      colors: [AppColors.sunsetOrange, AppColors.deepOrange],
                    )
                  : null,
              color: _agreedToTerms ? null : AppColors.warmBeige.withOpacity(0.3),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: _agreedToTerms ? AppColors.sunsetOrange : AppColors.glassBorder,
                width: 2,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  _agreedToTerms ? Icons.check_circle : Icons.circle_outlined,
                  color: _agreedToTerms ? Colors.white : AppColors.textMuted,
                  size: 28,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Ninakubali masharti na vigezo vya StoryZoo',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: _agreedToTerms ? Colors.white : AppColors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
  
  Widget _buildBenefitCard({
    required IconData icon,
    required String title,
    required String description,
    required Color color,
  }) {
    return GlassmorphicContainer(
      borderRadius: 16,
      blur: 10,
      color: AppColors.glassWhite,
      borderColor: AppColors.glassBorder,
      borderWidth: 1.5,
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textMuted,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
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
            fontSize: 14,
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
              hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 14),
              prefixIcon: Icon(icon, color: AppColors.sunsetOrange),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            ),
          ),
        ),
      ],
    );
  }
  
  Widget _buildTermItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.check, size: 18, color: AppColors.success),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textPrimary,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  void _handleNext() {
    if (_currentStep == 1) {
      // Validate personal info form
      if (_formKey.currentState?.validate() != true) {
        return;
      }
    }
    
    if (_currentStep == 3) {
      // Final step - check terms agreement
      if (!_agreedToTerms) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Tafadhali kubali masharti ili uendelee'),
            backgroundColor: AppColors.error,
          ),
        );
        return;
      }
      
      // Complete onboarding
      _completeOnboarding();
      return;
    }
    
    // Go to next step
    setState(() {
      _currentStep++;
    });
  }
  
  void _completeOnboarding() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Hongera! Sasa wewe ni mwandishi wa StoryZoo!'),
        backgroundColor: AppColors.success,
        duration: Duration(seconds: 3),
      ),
    );
    
    // Navigate to author dashboard
    context.go('/author-dashboard');
  }
}
