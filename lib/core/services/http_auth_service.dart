import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_service.dart';
import '../constants/app_constants.dart';

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
  Future<void> logout(String token) async {
    final url = Uri.parse('$baseUrl/auth/logout');
    await http.post(url, headers: {'Authorization': 'Bearer $token'});
  }
}
