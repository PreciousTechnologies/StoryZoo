import 'dart:async';
import 'dart:math';

import 'auth_service.dart';

/// A mock auth service used when no backend is configured. It "sends" OTPs
/// locally and returns a dummy token on verification. OTPs are logged to
/// console (debug) so they can be used during local development.
class MockAuthService implements AuthService {
  final Map<String, String> _store = {}; // email -> otp

  @override
  Future<void> requestOtp(String email) async {
    final otp = _generateOtp();
    _store[email] = otp;
    // For local development we print the OTP. In real app this must be
    // delivered by email from a backend.
    // ignore: avoid_print
    print('MockAuthService: OTP for $email is $otp');
    await Future.delayed(const Duration(milliseconds: 300));
  }

  @override
  Future<String> verifyOtp(String email, String otp) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final expected = _store[email];
    if (expected == null) throw Exception('No OTP requested for $email');
    if (expected != otp) throw Exception('Invalid OTP');
    // return a dummy token
    final token = 'mock_token_${Random().nextInt(999999)}';
    _store.remove(email);
    return token;
  }

  @override
  Future<void> logout(String token) async {
    await Future.delayed(const Duration(milliseconds: 100));
  }

  String _generateOtp() {
    final rand = Random();
    final n = rand.nextInt(900000) + 100000; // 6-digit
    return n.toString();
  }
}
