import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_constants.dart';
import '../services/auth_service.dart';
import '../services/http_auth_service.dart';
import '../services/mock_auth_service.dart';

class AuthProvider extends ChangeNotifier {
  AuthProvider._(this._authService);

  static const String _pendingAuthorOnboardingKey = 'pending_author_onboarding';

  final AuthService _authService;
  String? _token;
  bool _isAuthor = false;
  String _role = 'user';
  String? _userEmail;
  String? _displayName;
  String? _avatarUrl;
  String _preferredLanguage = 'sw';
  String _preferredThemeMode = 'light';
  Map<String, dynamic>? _pendingAuthorOnboarding;
  String? get token => _token;
  bool get isAuthenticated => _token != null && _token!.isNotEmpty;
  bool get isAuthor => _isAuthor;
  String get role => _role;
  String? get userEmail => _userEmail;
  String get preferredLanguage => _preferredLanguage;
  String get preferredThemeMode => _preferredThemeMode;
  bool get hasPendingAuthorOnboarding => _pendingAuthorOnboarding != null;
  String get avatarUrl => (_avatarUrl ?? '').trim();
  String get displayName => (_displayName == null || _displayName!.trim().isEmpty)
      ? ((_userEmail ?? '').split('@').first)
      : _displayName!;

  static Future<AuthProvider> create() async {
    final baseUrl = '${AppConstants.apiBaseUrl}${AppConstants.apiVersion}';
    final authService = AppConstants.apiBaseUrl.isEmpty
        ? MockAuthService()
        : HttpAuthService(baseUrl: baseUrl);
    final provider = AuthProvider._(authService);
    await provider._restore();
    return provider;
  }

  Future<void> _restore() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('auth_token');
    _isAuthor = prefs.getBool('is_author') ?? false;
    _role = prefs.getString('role') ?? (_isAuthor ? 'author' : 'user');
    _userEmail = prefs.getString('user_email');
    _displayName = prefs.getString('display_name');
    _avatarUrl = prefs.getString('avatar_url');
    _preferredLanguage = (prefs.getString('preferred_language') ?? 'sw').toLowerCase();
    _preferredThemeMode = (prefs.getString('theme_mode') ?? 'light').toLowerCase();
    final pendingOnboardingRaw = prefs.getString(_pendingAuthorOnboardingKey);
    if (pendingOnboardingRaw != null && pendingOnboardingRaw.isNotEmpty) {
      try {
        _pendingAuthorOnboarding = jsonDecode(pendingOnboardingRaw) as Map<String, dynamic>;
      } catch (_) {
        _pendingAuthorOnboarding = null;
      }
    }

    // Keep local author state aligned with backend if we are authenticated.
    if (AppConstants.apiBaseUrl.isNotEmpty && isAuthenticated) {
      try {
        await refreshUserProfile();
        await refreshAuthorStatus();
      } catch (_) {
        // Use persisted value when network is unavailable.
      }
    }

    notifyListeners();
  }

  /// Requests an OTP code using the configured backend auth service.
  Future<void> requestOtp(String email) async {
    await _authService.requestOtp(email);
  }

  /// Verifies [email] and [otp], then stores a backend token.
  Future<void> verifyOtp(String email, String otp) async {
    final token = await _authService.verifyOtp(email, otp);
    _token = token;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
    await _submitPendingAuthorOnboardingIfAny();
    if (AppConstants.apiBaseUrl.isNotEmpty) {
      try {
        await refreshUserProfile();
        await refreshAuthorStatus();
      } catch (_) {
        // Keep user signed in even if author status fetch fails.
      }
    }
    notifyListeners();
  }

  Future<void> signInWithGoogle(String idToken) async {
    final token = await _authService.signInWithGoogle(idToken);
    _token = token;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
    await _submitPendingAuthorOnboardingIfAny();
    if (AppConstants.apiBaseUrl.isNotEmpty) {
      try {
        await refreshUserProfile();
        await refreshAuthorStatus();
      } catch (_) {
        // Keep user signed in even if author status fetch fails.
      }
    }
    notifyListeners();
  }

  Future<void> logout() async {
    final currentToken = _token;
    if (currentToken != null && currentToken.isNotEmpty) {
      await _authService.logout(currentToken);
    }
    await _clearLocalAuth();
    notifyListeners();
  }

  Future<void> _clearLocalAuth() async {
    _token = null;
    _isAuthor = false;
    _role = 'user';
    _userEmail = null;
    _displayName = null;
    _avatarUrl = null;
    _preferredLanguage = 'sw';
    _preferredThemeMode = 'light';
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('is_author');
    await prefs.remove('role');
    await prefs.remove('user_email');
    await prefs.remove('display_name');
    await prefs.remove('avatar_url');
    await prefs.remove('preferred_language');
    await prefs.remove('theme_mode');
  }

  Future<void> cachePendingAuthorOnboarding({
    required String fullName,
    required String bio,
    required String phone,
    required String payoutAccount,
  }) async {
    _pendingAuthorOnboarding = {
      'full_name': fullName.trim(),
      'bio': bio.trim(),
      'phone': phone.trim(),
      'payout_account': payoutAccount.trim(),
    };

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_pendingAuthorOnboardingKey, jsonEncode(_pendingAuthorOnboarding));
    notifyListeners();
  }

  Future<void> clearPendingAuthorOnboarding() async {
    _pendingAuthorOnboarding = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_pendingAuthorOnboardingKey);
    notifyListeners();
  }

  Future<void> _submitPendingAuthorOnboardingIfAny() async {
    if (_pendingAuthorOnboarding == null || _pendingAuthorOnboarding!.isEmpty) return;

    await completeAuthorOnboarding(
      fullName: (_pendingAuthorOnboarding!['full_name'] ?? '').toString(),
      bio: (_pendingAuthorOnboarding!['bio'] ?? '').toString(),
      phone: (_pendingAuthorOnboarding!['phone'] ?? '').toString(),
      payoutAccount: (_pendingAuthorOnboarding!['payout_account'] ?? '').toString(),
    );

    await clearPendingAuthorOnboarding();
  }

  Map<String, String> _authJsonHeaders() {
    final currentToken = _token;
    if (currentToken == null || currentToken.isEmpty) {
      throw Exception('Authentication required. Please sign in again.');
    }
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Token $currentToken',
    };
  }

  Future<void> completeAuthorOnboarding({
    required String fullName,
    required String bio,
    required String phone,
    required String payoutAccount,
  }) async {
    final trimmedPhone = phone.trim();

    if (AppConstants.apiBaseUrl.isNotEmpty) {
      final baseUrl = '${AppConstants.apiBaseUrl}${AppConstants.apiVersion}';
      final url = Uri.parse('$baseUrl/authors/onboard/');
      final response = await http.post(
        url,
        headers: _authJsonHeaders(),
        body: jsonEncode({
          'full_name': fullName.trim(),
          'bio': bio.trim(),
          'phone': trimmedPhone,
          'payout_account': payoutAccount.trim(),
        }),
      );

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw Exception('Author onboarding failed (${response.statusCode}): ${response.body}');
      }
    }

    _isAuthor = true;
    _role = 'author';
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_author', true);
    await prefs.setString('role', _role);
    notifyListeners();
  }

  Future<void> refreshAuthorStatus() async {
    if (AppConstants.apiBaseUrl.isEmpty || !isAuthenticated) return;

    final baseUrl = '${AppConstants.apiBaseUrl}${AppConstants.apiVersion}';
    final url = Uri.parse('$baseUrl/authors/status/');

    final response = await http.get(url, headers: _authJsonHeaders());
    if (response.statusCode == 401) {
      await _clearLocalAuth();
      return;
    }
    if (response.statusCode != 200) {
      throw Exception('Failed to fetch author status (${response.statusCode}).');
    }

    final body = jsonDecode(response.body);
    final backendIsAuthor = body is Map<String, dynamic> ? (body['is_author'] == true) : false;
    final backendRole = body is Map<String, dynamic>
      ? (body['role']?.toString().toLowerCase() ?? (backendIsAuthor ? 'author' : 'user'))
      : (backendIsAuthor ? 'author' : 'user');

    _isAuthor = backendIsAuthor;
    _role = backendRole;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_author', _isAuthor);
    await prefs.setString('role', _role);
    notifyListeners();
  }

  Future<void> refreshUserProfile() async {
    if (AppConstants.apiBaseUrl.isEmpty || !isAuthenticated) return;

    final baseUrl = '${AppConstants.apiBaseUrl}${AppConstants.apiVersion}';
    final url = Uri.parse('$baseUrl/me/profile/');

    final response = await http.get(url, headers: _authJsonHeaders());
    if (response.statusCode == 401) {
      await _clearLocalAuth();
      return;
    }
    if (response.statusCode != 200) {
      throw Exception('Failed to fetch user profile (${response.statusCode}).');
    }

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    _role = (body['role'] ?? (_isAuthor ? 'author' : 'user')).toString().toLowerCase();
    _isAuthor = _role == 'author';
    _userEmail = (body['email'] ?? '').toString();
    _displayName = (body['display_name'] ?? '').toString();
    _avatarUrl = (body['avatar_url'] ?? '').toString();
    _preferredLanguage = (body['preferred_language'] ?? _preferredLanguage).toString().toLowerCase();
    _preferredThemeMode = (body['theme_mode'] ?? _preferredThemeMode).toString().toLowerCase();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('role', _role);
    await prefs.setBool('is_author', _isAuthor);
    await prefs.setString('user_email', _userEmail ?? '');
    await prefs.setString('display_name', _displayName ?? '');
    await prefs.setString('avatar_url', _avatarUrl ?? '');
    await prefs.setString('preferred_language', _preferredLanguage);
    await prefs.setString('theme_mode', _preferredThemeMode);
    notifyListeners();
  }

  Future<void> updateUserProfile({
    String? displayName,
    String? avatarUrl,
    String? preferredLanguage,
    String? themeMode,
    XFile? avatarImage,
  }) async {
    if (AppConstants.apiBaseUrl.isEmpty || !isAuthenticated) {
      throw Exception('Backend API is not configured.');
    }

    final baseUrl = '${AppConstants.apiBaseUrl}${AppConstants.apiVersion}';
    final url = Uri.parse('$baseUrl/me/profile/');

    http.Response response;
    if (avatarImage != null) {
      final request = http.MultipartRequest('PATCH', url);
      request.headers['Authorization'] = 'Token ${_token!}';

      if (displayName != null) {
        request.fields['display_name'] = displayName.trim();
      }
      if (avatarUrl != null) {
        request.fields['avatar_url'] = avatarUrl.trim();
      }
      if (preferredLanguage != null && preferredLanguage.trim().isNotEmpty) {
        request.fields['preferred_language'] = preferredLanguage.trim().toLowerCase();
      }
      if (themeMode != null && themeMode.trim().isNotEmpty) {
        request.fields['theme_mode'] = themeMode.trim().toLowerCase();
      }

      final bytes = await avatarImage.readAsBytes();
      request.files.add(
        http.MultipartFile.fromBytes(
          'avatar_image',
          bytes,
          filename: avatarImage.name,
        ),
      );

      final streamed = await request.send();
      response = await http.Response.fromStream(streamed);
    } else {
      final payload = <String, dynamic>{};
      if (displayName != null) payload['display_name'] = displayName.trim();
      if (avatarUrl != null) payload['avatar_url'] = avatarUrl.trim();
      if (preferredLanguage != null && preferredLanguage.trim().isNotEmpty) {
        payload['preferred_language'] = preferredLanguage.trim().toLowerCase();
      }
      if (themeMode != null && themeMode.trim().isNotEmpty) {
        payload['theme_mode'] = themeMode.trim().toLowerCase();
      }
      if (payload.isEmpty) return;

      response = await http.patch(
        url,
        headers: _authJsonHeaders(),
        body: jsonEncode(payload),
      );
    }

    if (response.statusCode == 401) {
      await _clearLocalAuth();
      throw Exception('Unauthorized. Please sign in again.');
    }
    if (response.statusCode != 200) {
      throw Exception('Failed to update profile (${response.statusCode}).');
    }

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    _role = (body['role'] ?? (_isAuthor ? 'author' : 'user')).toString().toLowerCase();
    _isAuthor = _role == 'author';
    _userEmail = (body['email'] ?? _userEmail ?? '').toString();
    _displayName = (body['display_name'] ?? '').toString();
    _avatarUrl = (body['avatar_url'] ?? '').toString();
    // Use requested value as fallback if backend response is missing
    _preferredLanguage = (body['preferred_language'] ?? preferredLanguage ?? _preferredLanguage).toString().toLowerCase();
    _preferredThemeMode = (body['theme_mode'] ?? themeMode ?? _preferredThemeMode).toString().toLowerCase();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('role', _role);
    await prefs.setBool('is_author', _isAuthor);
    await prefs.setString('user_email', _userEmail ?? '');
    await prefs.setString('display_name', _displayName ?? '');
    await prefs.setString('avatar_url', _avatarUrl ?? '');
    await prefs.setString('preferred_language', _preferredLanguage);
    await prefs.setString('theme_mode', _preferredThemeMode);
    notifyListeners();
  }

  Future<void> updatePreferredLanguage(String languageCode) async {
    final normalized = languageCode.trim().toLowerCase();
    if (normalized.isEmpty) return;
    if (normalized == _preferredLanguage) return;

    // Immediately update local state for instant UI feedback
    _preferredLanguage = normalized;
    
    // Save to local SharedPreferences immediately
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('preferred_language', _preferredLanguage);
    
    notifyListeners();

    try {
      // Send to backend to persist
      await updateUserProfile(preferredLanguage: normalized);
    } catch (e) {
      // If backend update fails, at least we have the local change
      // The next restore() call will sync with server
      rethrow;
    }
  }

  Future<void> updatePreferredThemeMode(String themeMode) async {
    final normalized = themeMode.trim().toLowerCase();
    if (normalized.isEmpty) return;
    if (!{'light', 'dark', 'system'}.contains(normalized)) return;
    if (normalized == _preferredThemeMode) return;

    await updateUserProfile(themeMode: normalized);
  }
}
