import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/auth/auth_provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../shared/widgets/app_text.dart';
import '../../shared/widgets/neumorphic_widgets.dart';
import 'payment_service.dart';

class SubscribeScreen extends StatefulWidget {
  const SubscribeScreen({super.key, this.bookId = 0});

  final int bookId;

  @override
  State<SubscribeScreen> createState() => _SubscribeScreenState();
}

class _SubscribeScreenState extends State<SubscribeScreen> {
  final PaymentService _service = PaymentService();
  final TextEditingController _emailController = TextEditingController();
  bool _isLoading = false;
  String? _error;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final authEmail = context.read<AuthProvider>().userEmail;
    if (authEmail != null && authEmail.isNotEmpty && _emailController.text.isEmpty) {
      _emailController.text = authEmail;
    }
  }

  @override
  void dispose() {
    _service.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _startPayment() async {
    final email = _emailController.text.trim();
    final token = context.read<AuthProvider>().token ?? '';

    if (widget.bookId <= 0) {
      setState(() {
        _error = 'Book context is required. Open payment from a specific locked book.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final initiated = await _service.initiateBookPayment(
        token: token,
        bookId: widget.bookId,
        email: email,
      );

      if (initiated.alreadyPurchased) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: AppText('Book already purchased.')),
          );
        }
        return;
      }

      final redirectUri = initiated.redirectUri;
      if (redirectUri == null) {
        throw Exception('Payment page URL is missing.');
      }

      final launched = await launchUrl(redirectUri, mode: LaunchMode.externalApplication);
      if (!launched) {
        throw Exception('Unable to open payment page.');
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
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
              Padding(
                padding: const EdgeInsets.all(AppConstants.paddingLarge),
                child: Row(
                  children: [
                    NeumorphicIconButton(
                      icon: Icons.arrow_back,
                      size: 50,
                      onPressed: () => Navigator.pop(context),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AppText(
                            'Premium Subscription',
                            style: (Theme.of(context).textTheme.headlineSmall ?? const TextStyle(fontSize: 24)).copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          AppText(
                            'Lipa kupitia Pesapal',
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
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: AppConstants.paddingLarge),
                  children: [
                    NeumorphicCard(
                      borderRadius: 22,
                      color: cardSurface,
                      padding: const EdgeInsets.all(18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AppText(
                            'Maelezo ya Malipo',
                            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            decoration: InputDecoration(
                              labelText: 'Email',
                              hintText: 'user@example.com',
                            ),
                          ),
                          const SizedBox(height: 16),
                          if (_error != null)
                            AppText(
                              _error!,
                              style: const TextStyle(color: AppColors.error, fontSize: 12),
                            ),
                          const SizedBox(height: 10),
                          NeumorphicButton(
                            onPressed: _isLoading ? null : _startPayment,
                            color: AppColors.sunsetOrange,
                            height: 56,
                            borderRadius: 18,
                            child: _isLoading
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                    ),
                                  )
                                : const Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.lock_outline, color: Colors.white),
                                      SizedBox(width: 10),
                                      AppText(
                                        'Endelea Kulipa',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
