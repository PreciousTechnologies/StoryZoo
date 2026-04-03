import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../core/constants/app_constants.dart';
import '../../../models/story.dart';

class StoryRepository {
  StoryRepository({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  Uri _publishedStoriesUri({int limit = 50}) {
    final base = '${AppConstants.apiBaseUrl}${AppConstants.apiVersion}/stories/';
    return Uri.parse(base).replace(queryParameters: {
      'published': 'true',
      'limit': '$limit',
    });
  }

  Future<List<Story>> fetchPublishedStories({int limit = 50}) async {
    final response = await _client.get(_publishedStoriesUri(limit: limit));
    if (response.statusCode != 200) {
      throw Exception('Failed to load stories (${response.statusCode}).');
    }

    final decoded = jsonDecode(response.body);
    final items = decoded is List
        ? decoded
        : (decoded is Map<String, dynamic> && decoded['results'] is List
            ? decoded['results'] as List
            : <dynamic>[]);

    return items
        .whereType<Map<String, dynamic>>()
        .map((item) => Story.fromJson(item))
        .toList();
  }

  Stream<List<Story>> streamPublishedStories({int limit = 50}) {
    return _pollPublishedStories(limit: limit);
  }

  Stream<List<Story>> _pollPublishedStories({required int limit}) async* {
    yield await fetchPublishedStories(limit: limit);
    while (true) {
      await Future<void>.delayed(const Duration(seconds: 8));
      yield await fetchPublishedStories(limit: limit);
    }
  }

  Stream<List<String>> streamCategories() {
    return streamPublishedStories().map((stories) {
      final categories = stories
          .map((story) => story.category)
          .where((category) => category.trim().isNotEmpty)
          .toSet()
          .toList();
      categories.sort();
      return categories;
    });
  }

  Future<void> dispose() async {
    _client.close();
  }
}
