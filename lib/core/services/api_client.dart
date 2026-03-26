import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_constants.dart';

/// Lightweight HTTP client that:
///  - Prefixes every request with [AppConstants.apiBaseUrl]/api/[AppConstants.apiVersion]/
///  - Attaches the stored JWT access token (if available)
///  - Throws [ApiException] on non-2xx responses
class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;
  ApiClient._internal();

  String get _base =>
      '${AppConstants.apiBaseUrl}/api/${AppConstants.apiVersion}';

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  Map<String, String> _headers({String? token}) {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  Future<dynamic> get(String path, {Map<String, String>? queryParams}) async {
    final token = await _getToken();
    var uri = Uri.parse('$_base$path');
    if (queryParams != null && queryParams.isNotEmpty) {
      uri = uri.replace(queryParameters: queryParams);
    }
    final response = await http.get(uri, headers: _headers(token: token));
    return _handleResponse(response);
  }

  Future<dynamic> post(String path, {Map<String, dynamic>? body}) async {
    final token = await _getToken();
    final uri = Uri.parse('$_base$path');
    final response = await http.post(
      uri,
      headers: _headers(token: token),
      body: body != null ? jsonEncode(body) : null,
    );
    return _handleResponse(response);
  }

  Future<dynamic> patch(String path, {Map<String, dynamic>? body}) async {
    final token = await _getToken();
    final uri = Uri.parse('$_base$path');
    final response = await http.patch(
      uri,
      headers: _headers(token: token),
      body: body != null ? jsonEncode(body) : null,
    );
    return _handleResponse(response);
  }

  dynamic _handleResponse(http.Response response) {
    final statusCode = response.statusCode;
    if (statusCode >= 200 && statusCode < 300) {
      if (response.body.isEmpty) return null;
      return jsonDecode(response.body);
    }
    String message;
    try {
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      message = (json['detail'] ?? json['message'] ?? response.body).toString();
    } catch (_) {
      message = response.body;
    }
    throw ApiException(statusCode: statusCode, message: message);
  }
}

class ApiException implements Exception {
  final int statusCode;
  final String message;
  const ApiException({required this.statusCode, required this.message});

  @override
  String toString() => 'ApiException($statusCode): $message';
}
