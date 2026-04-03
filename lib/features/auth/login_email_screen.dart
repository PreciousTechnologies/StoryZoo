import 'package:flutter/material.dart';
import '../../shared/widgets/app_text.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/auth/auth_provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/i18n/app_i18n.dart';

class LoginEmailScreen extends StatefulWidget {
  const LoginEmailScreen({super.key});

  @override
  State<LoginEmailScreen> createState() => _LoginEmailScreenState();
}

class _LoginEmailScreenState extends State<LoginEmailScreen> {
  final _controller = TextEditingController();
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _sendOtp() async {
    setState(() { _loading = true; _error = null; });
    try {
      final email = _controller.text.trim().toLowerCase();
      if (email.isEmpty) throw Exception('Ingiza barua pepe yako');
      if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email)) {
        throw Exception('Tafadhali ingiza barua pepe sahihi');
      }
      final auth = context.read<AuthProvider>();
      await auth.requestOtp(email);
      if (!mounted) return;
      context.push('/verify-otp', extra: email);
    } catch (e) {
      setState(() { _error = e.toString(); });
    } finally {
      if (mounted) setState(() { _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final hasPendingAuthorOnboarding = context.watch<AuthProvider>().hasPendingAuthorOnboarding;

    return Scaffold(
      appBar: AppBar(title: AppText('Login')),
      body: Stack(
        children: [
          // Background images + color overlay (from welcome screen)
          Positioned.fill(
            child: Opacity(
              opacity: 0.3,
              child: CachedNetworkImage(
                imageUrl: 'https://images.unsplash.com/photo-1516426122078-c23e76319801?w=1200&q=80',
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(color: AppColors.warmBeige.withOpacity(0.1)),
                errorWidget: (context, url, error) => Container(color: AppColors.warmBeige.withOpacity(0.1)),
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Opacity(
              opacity: 0.25,
              child: CachedNetworkImage(
                imageUrl: 'https://images.unsplash.com/photo-1549366021-9f761d450615?w=1200&q=80',
                fit: BoxFit.cover,
                height: size.height * 0.45,
                alignment: Alignment.bottomCenter,
                placeholder: (context, url) => const SizedBox.shrink(),
                errorWidget: (context, url, error) => const SizedBox.shrink(),
              ),
            ),
          ),
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColors.sunsetOrange.withOpacity(0.12),
                    AppColors.warmBeige.withOpacity(0.08),
                    AppColors.mintGreen.withOpacity(0.06),
                  ],
                ),
              ),
            ),
          ),

          // Content
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.06),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.glassBorder.withOpacity(0.6)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 4),
                    AppText(
                      'Ingia kwa barua pepe',
                      style: (Theme.of(context).textTheme.titleLarge ?? const TextStyle(fontSize: 20)).copyWith(
                        color: AppColors.textLight,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 18),
                    TextField(
                      controller: _controller,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        labelText: context.tr('Barua Pepe'),
                        hintText: context.tr('you@example.com'),
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (hasPendingAuthorOnboarding)
                      Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.info.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppColors.info.withOpacity(0.4)),
                        ),
                        child: AppText(
                          'Maliza kuingia ili taarifa za onboarding ya mwandishi zihifadhiwe kwenye akaunti yako.',
                          style: TextStyle(color: AppColors.textLight, fontSize: 12),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    if (_error != null) AppText(_error!, style: const TextStyle(color: Colors.red)),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.sunsetOrange, padding: const EdgeInsets.symmetric(vertical: 14)),
                      onPressed: _loading ? null : _sendOtp,
                      child: _loading ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)) : AppText('Tuma OTP'),
                    ),
                    const SizedBox(height: 6),
                    AppText(
                      'Tutakutumia msimbo wa tarakimu 4 kwenye barua pepe hiyo.',
                      style: (Theme.of(context).textTheme.bodySmall ?? const TextStyle(fontSize: 12)).copyWith(color: AppColors.textLight.withOpacity(0.85)),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

