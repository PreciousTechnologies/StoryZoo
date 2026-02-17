import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/auth/auth_provider.dart';
import '../../core/constants/app_colors.dart';

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
      final phone = _controller.text.trim();
      if (phone.isEmpty) throw Exception('Ingiza nambari ya simu');
      // basic Tanzanian phone validation
      // Normalize common inputs: accept starting with 0 or 7 or +255
      String normalized = phone.replaceAll(RegExp(r'\s+'), '');
      if (normalized.startsWith('0')) normalized = '+255' + normalized.substring(1);
      if (!(normalized.startsWith('+2557') && normalized.length == 13)) {
        throw Exception('Tafadhali ingiza nambari halali ya Tanzania (e.g. +255712345678)');
      }
      final auth = context.read<AuthProvider>();
      await auth.requestOtp(normalized);
      if (!mounted) return;
      // Navigate to OTP verify screen (pass phone as extra)
      context.push('/verify-otp', extra: normalized);
    } catch (e) {
      setState(() { _error = e.toString(); });
    } finally {
      if (mounted) setState(() { _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
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
                    Text(
                      'Ingia kwa nambari ya simu',
                      style: (Theme.of(context).textTheme.titleLarge ?? const TextStyle(fontSize: 20)).copyWith(
                        color: AppColors.textLight,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 18),
                    TextField(
                      controller: _controller,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                        labelText: 'Nambari ya Simu',
                        hintText: '+255712345678',
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (_error != null) Text(_error!, style: const TextStyle(color: Colors.red)),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.sunsetOrange, padding: const EdgeInsets.symmetric(vertical: 14)),
                      onPressed: _loading ? null : _sendOtp,
                      child: _loading ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('Tuma OTP'),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Tutakutumia msimbo wa kuthibitisha kwenye nambari hiyo.',
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
