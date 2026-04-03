import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

import '../../../core/constants/app_constants.dart';

class ChapterDraft {
  const ChapterDraft({
    required this.title,
    required this.content,
    required this.order,
  });

  final String title;
  final String content;
  final int order;

  Map<String, dynamic> toJson() => {
        'title': title,
        'content': content,
        'order': order,
      };
}

class UploadBookRepository {
  Future<void> createBook({
    required String token,
    required String title,
    required String description,
    required String category,
    required String language,
    required bool isFree,
    required double price,
    required bool hasAudio,
    required bool publishNow,
    required List<ChapterDraft> chapters,
    XFile? coverImage,
  }) async {
    final url = Uri.parse('${AppConstants.apiBaseUrl}${AppConstants.apiVersion}/books/');

    final request = http.MultipartRequest('POST', url)
      ..headers['Authorization'] = 'Token $token'
      ..fields['title'] = title.trim()
      ..fields['description'] = description.trim()
      ..fields['category'] = category
      ..fields['language'] = language
      ..fields['is_free'] = isFree.toString()
      ..fields['has_audio'] = hasAudio.toString()
      ..fields['publish_now'] = publishNow.toString()
      ..fields['price'] = isFree ? '0' : price.toStringAsFixed(2)
      ..fields['chapters'] = jsonEncode(chapters.map((c) => c.toJson()).toList());

    if (coverImage != null) {
      final bytes = await coverImage.readAsBytes();
      request.files.add(
        http.MultipartFile.fromBytes(
          'cover_image',
          bytes,
          filename: coverImage.name,
        ),
      );
    }

    final streamed = await request.send();
    final response = await http.Response.fromStream(streamed);

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Failed to save book (${response.statusCode}): ${response.body}');
    }
  }
}
