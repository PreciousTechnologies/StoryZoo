import '../../models/story.dart';
import 'api_client.dart';

/// Fetches story data from the Django REST API.
class StoryService {
  final ApiClient _client;

  StoryService({ApiClient? client}) : _client = client ?? ApiClient();

  /// Returns a paginated list of stories.
  /// Optional [category], [search], and [featured] filters are forwarded
  /// to the Django backend as query parameters.
  Future<List<Story>> fetchStories({
    String? category,
    String? search,
    bool featured = false,
    int page = 1,
  }) async {
    final params = <String, String>{
      'page': page.toString(),
    };
    if (category != null && category.isNotEmpty) params['category'] = category;
    if (search != null && search.isNotEmpty) params['search'] = search;
    if (featured) params['featured'] = 'true';

    final data = await _client.get('/stories/', queryParams: params);
    final results = data['results'] as List<dynamic>;
    return results
        .map((e) => Story.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Returns a single story by [id].
  Future<Story> fetchStory(String id) async {
    final data = await _client.get('/stories/$id/');
    return Story.fromJson(data as Map<String, dynamic>);
  }

  /// Returns the list of stories the authenticated user has purchased.
  Future<List<Story>> fetchMyPurchases() async {
    final data = await _client.get('/my-purchases/');
    return (data as List<dynamic>)
        .map((e) => Story.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Registers a purchase for story [id].
  Future<void> purchaseStory(String id) async {
    await _client.post('/stories/$id/purchase/');
  }

  /// Returns the list of available categories.
  Future<List<String>> fetchCategories() async {
    final data = await _client.get('/categories/');
    final results = data['results'] as List<dynamic>? ?? data as List<dynamic>;
    return results
        .map((e) => (e as Map<String, dynamic>)['name'] as String)
        .toList();
  }
}
