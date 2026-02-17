import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/auth/auth_provider.dart';
import '../../core/constants/app_colors.dart';

class VerifyOtpScreen extends StatefulWidget {
  final String? phone;
  const VerifyOtpScreen({super.key, this.phone});

  @override
  State<VerifyOtpScreen> createState() => _VerifyOtpScreenState();
}

class _VerifyOtpScreenState extends State<VerifyOtpScreen> {
  final _controller = TextEditingController();
  bool _loading = false;
  String? _error;
  String? _phone;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _phone = widget.phone;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _verify() async {
    setState(() { _loading = true; _error = null; });
    try {
      final otp = _controller.text.trim();
      if (_phone == null) throw Exception('Missing phone');
      if (otp.isEmpty) throw Exception('Enter OTP');
      final auth = context.read<AuthProvider>();
      await auth.verifyOtp(_phone!, otp);
      if (!mounted) return;
      // Replace stack and go to home
      context.go('/home');
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
      appBar: AppBar(title: const Text('Enter OTP')),
      body: Stack(
        children: [
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
                      'Weka msimbo (OTP)',
                      style: (Theme.of(context).textTheme.titleLarge ?? const TextStyle(fontSize: 20)).copyWith(
                        color: AppColors.textLight,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    Text('An OTP was sent to ${_phone ?? '-'}', textAlign: TextAlign.center, style: TextStyle(color: AppColors.textLight.withOpacity(0.9))),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _controller,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'OTP',
                        hintText: '6-digit code',
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (_error != null) Text(_error!, style: const TextStyle(color: Colors.red)),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.sunsetOrange, padding: const EdgeInsets.symmetric(vertical: 14)),
                      onPressed: _loading ? null : _verify,
                      child: _loading ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('Thibitisha'),
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
