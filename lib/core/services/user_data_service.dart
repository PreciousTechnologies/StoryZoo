import 'dart:convert';

import 'package:http/http.dart' as http;

import '../constants/app_constants.dart';

class UserDataService {
  UserDataService._();

  static Map<String, String> _headers(String token) => {
        'Content-Type': 'application/json',
        'Authorization': 'Token $token',
      };

  static String get _base => '${AppConstants.apiBaseUrl}${AppConstants.apiVersion}';

  static Future<Map<String, dynamic>?> fetchReadingProgress({
    required String token,
    required int bookId,
  }) async {
    if (token.trim().isEmpty) return null;
    final url = Uri.parse('$_base/me/progress/reading/').replace(queryParameters: {
      'book_id': '$bookId',
    });
    final res = await http.get(url, headers: _headers(token));
    if (res.statusCode != 200) return null;
    return jsonDecode(res.body) as Map<String, dynamic>;
  }

  static Future<void> saveReadingProgress({
    required String token,
    required int bookId,
    required int chapterOrder,
    required double chapterProgress,
  }) async {
    if (token.trim().isEmpty) return;
    final url = Uri.parse('$_base/me/progress/reading/');
    final res = await http.post(
      url,
      headers: _headers(token),
      body: jsonEncode({
        'book_id': bookId,
        'current_chapter_order': chapterOrder,
        'chapter_progress': chapterProgress,
      }),
    );
    if (res.statusCode == 401) return;
  }

  static Future<Map<String, dynamic>?> fetchAudioProgress({
    required String token,
    required int storyId,
  }) async {
    if (token.trim().isEmpty) return null;
    final url = Uri.parse('$_base/me/progress/audio/').replace(queryParameters: {
      'story_id': '$storyId',
    });
    final res = await http.get(url, headers: _headers(token));
    if (res.statusCode != 200) return null;
    return jsonDecode(res.body) as Map<String, dynamic>;
  }

  static Future<void> saveAudioProgress({
    required String token,
    required int storyId,
    required int positionSeconds,
    required int totalSeconds,
    required double playbackSpeed,
  }) async {
    if (token.trim().isEmpty) return;
    final url = Uri.parse('$_base/me/progress/audio/');
    final res = await http.post(
      url,
      headers: _headers(token),
      body: jsonEncode({
        'story_id': storyId,
        'position_seconds': positionSeconds,
        'total_seconds': totalSeconds,
        'playback_speed': playbackSpeed,
      }),
    );
    if (res.statusCode == 401) return;
  }
}
