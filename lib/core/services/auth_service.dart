import 'package:flutter/foundation.dart';

abstract class AuthService {
  /// Request an OTP to be sent to [email].
  Future<void> requestOtp(String email);

  /// Verify [email] with [otp] and return a token string on success.
  Future<String> verifyOtp(String email, String otp);

  /// Optional: invalidate a token / logout.
  Future<void> logout(String token);
}
