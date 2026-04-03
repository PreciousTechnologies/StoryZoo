import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_service.dart';

class HttpAuthService implements AuthService {
  final String baseUrl;

  HttpAuthService({required this.baseUrl});

  @override
  Future<void> requestOtp(String email) async {
    final url = Uri.parse('$baseUrl/auth/request-otp');
    final res = await http.post(url, body: {'email': email});
    if (res.statusCode != 200) {
      throw Exception('Failed to request OTP: ${res.body}');
    }
  }

  @override
  Future<String> verifyOtp(String email, String otp) async {
    final url = Uri.parse('$baseUrl/auth/verify-otp');
    final res = await http.post(url, body: {'email': email, 'otp': otp});
    if (res.statusCode != 200) {
      throw Exception('OTP verification failed: ${res.body}');
    }
    final body = jsonDecode(res.body);
    return body['token'] as String;
  }

  @override
  Future<String> signInWithGoogle(String idToken) async {
    final url = Uri.parse('$baseUrl/auth/google/');
    final res = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'id_token': idToken}),
    );

    if (res.statusCode != 200) {
      throw Exception('Google sign-in failed: ${res.body}');
    }

    final body = jsonDecode(res.body) as Map<String, dynamic>;
    final token = body['token'];
    if (token is! String || token.isEmpty) {
      throw Exception('Backend did not return a valid auth token.');
    }
    return token;
  }

  @override
  Future<void> logout(String token) async {
    final url = Uri.parse('$baseUrl/auth/logout');
    await http.post(url, headers: {'Authorization': 'Token $token'});
  }
}
