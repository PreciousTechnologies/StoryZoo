import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_service.dart';

/// HTTP auth service that communicates with the Django JWT endpoints.
///
/// Endpoints used:
///   POST /api/v1/auth/login/   – obtain access + refresh tokens
///   POST /api/v1/auth/register/ – register a new account
///
/// The [requestOtp] method is retained for interface compatibility; when a
/// Django backend is present the UI should use username/password login instead.
class HttpAuthService implements AuthService {
  final String baseUrl;

  HttpAuthService({required this.baseUrl});

  String get _apiBase => '$baseUrl/api/v1';

  /// Logs in with [email] (used as the username) and [otp] (used as the
  /// password). Returns the JWT access token on success.
  @override
  Future<String> verifyOtp(String email, String otp) async {
    final url = Uri.parse('$_apiBase/auth/login/');
    final res = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'username': email, 'password': otp}),
    );
    if (res.statusCode != 200) {
      throw Exception('Login failed: ${res.body}');
    }
    final body = jsonDecode(res.body) as Map<String, dynamic>;
    return body['access'] as String;
  }

  /// Not applicable for JWT login – kept for interface compatibility.
  @override
  Future<void> requestOtp(String email) async {
    // No-op: JWT flow does not require a separate OTP request step.
  }

  @override
  Future<void> logout(String token) async {
    // JWT logout is client-side (discard the token).
    // Optionally call a revoke endpoint here if implemented in Django.
  }
}
