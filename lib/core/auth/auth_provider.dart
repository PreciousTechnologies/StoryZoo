import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../constants/app_constants.dart';

class AuthProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String? _token;
  String? get token => _token;
  bool get isAuthenticated => _token != null && _token!.isNotEmpty;

  String? _verificationId;

  AuthProvider._();

  static Future<AuthProvider> create() async {
    final provider = AuthProvider._();
    await provider._restore();
    return provider;
  }

  Future<void> _restore() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('auth_token');
    notifyListeners();
  }

  /// Requests an SMS code to be sent to [phone] using Firebase Phone Auth.
  Future<void> requestOtp(String phone) async {
    final completer = Completer<void>();

    await _auth.verifyPhoneNumber(
      phoneNumber: phone,
      timeout: const Duration(seconds: 60),
      verificationCompleted: (PhoneAuthCredential credential) async {
        // Auto-retrieval or instant verification. Sign in directly.
        final userCred = await _auth.signInWithCredential(credential);
        final id = await userCred.user?.getIdToken();
        if (id != null) {
          _token = id;
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('auth_token', id);
          notifyListeners();
        }
        completer.complete();
      },
      verificationFailed: (FirebaseAuthException e) {
        completer.completeError(e);
      },
      codeSent: (String verificationId, int? resendToken) {
        _verificationId = verificationId;
        completer.complete();
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        _verificationId = verificationId;
      },
    );

    return completer.future;
  }

  /// Verifies the [otp] using the previously saved verification id.
  Future<void> verifyOtp(String phone, String otp) async {
    if (_verificationId == null) {
      throw Exception('No verification id available. Call requestOtp first.');
    }

    final credential = PhoneAuthProvider.credential(
      verificationId: _verificationId!,
      smsCode: otp,
    );

    final userCred = await _auth.signInWithCredential(credential);
    final id = await userCred.user?.getIdToken();
    if (id == null) throw Exception('Failed to obtain ID token from Firebase user.');

    _token = id;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', id);
    notifyListeners();
  }

  Future<void> logout() async {
    await _auth.signOut();
    _token = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    notifyListeners();
  }
}
