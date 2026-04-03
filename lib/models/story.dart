class Story {
  final String id;
  final String title;
  final String description;
  final String author;
  final String authorId;
  final String category;
  final String language;
  final String coverImage;
  final double price;
  final double rating;
  final int totalReviews;
  final bool isPurchased;
  final bool hasAudio;
  final Duration? audioDuration;
  final DateTime publishedDate;

  Story({
    required this.id,
    required this.title,
    required this.description,
    required this.author,
    required this.authorId,
    required this.category,
    this.language = 'Kiswahili',
    required this.coverImage,
    required this.price,
    this.rating = 0.0,
    this.totalReviews = 0,
    this.isPurchased = false,
    this.hasAudio = false,
    this.audioDuration,
    required this.publishedDate,
  });

  factory Story.fromJson(Map<String, dynamic> json) {
    return Story(
      id: (json['id'] ?? '').toString(),
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      author: json['author'] ?? '',
      authorId: json['author_id'] ?? '',
      category: json['category'] ?? '',
      language: json['language'] ?? 'Kiswahili',
      coverImage: json['cover_image'] ?? '',
      price: _asDouble(json['price']),
      rating: _asDouble(json['rating']),
      totalReviews: _asInt(json['total_reviews']),
      isPurchased: json['is_purchased'] ?? false,
      hasAudio: json['has_audio'] ?? false,
      audioDuration: json['audio_duration'] != null
          ? Duration(seconds: _asInt(json['audio_duration']))
          : null,
      publishedDate: json['published_date'] != null
          ? DateTime.parse(json['published_date'])
          : DateTime.now(),
    );
  }

  factory Story.fromMap(Map<String, dynamic> data, {String? id}) {
    return Story(
      id: id ?? (data['id'] ?? ''),
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      author: data['author'] ?? '',
      authorId: data['authorId'] ?? data['author_id'] ?? '',
      category: data['category'] ?? '',
      language: data['language'] ?? 'Kiswahili',
      coverImage: data['coverImage'] ?? data['cover_image'] ?? '',
      price: _asDouble(data['price']),
      rating: _asDouble(data['rating']),
      totalReviews: (data['totalReviews'] ?? data['total_reviews'] ?? 0) as int,
      isPurchased: (data['isPurchased'] ?? data['is_purchased'] ?? false) as bool,
      hasAudio: (data['hasAudio'] ?? data['has_audio'] ?? false) as bool,
      audioDuration: data['audioDuration'] != null
          ? Duration(seconds: (data['audioDuration'] as num).toInt())
          : data['audio_duration'] != null
              ? Duration(seconds: (data['audio_duration'] as num).toInt())
              : null,
      publishedDate: _parseDate(data['publishedAt'] ?? data['published_date']),
    );
  }

  static double _asDouble(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }

  static int _asInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static DateTime _parseDate(dynamic value) {
    if (value == null) return DateTime.now();
    if (value is DateTime) return value;
    if (value is String) {
      return DateTime.tryParse(value) ?? DateTime.now();
    }
    // Keeps compatibility with backend libraries exposing a toDate() method.
    if (value.toDate is Function) {
      try {
        return value.toDate() as DateTime;
      } catch (_) {
        return DateTime.now();
      }
    }
    return DateTime.now();
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'author': author,
      'author_id': authorId,
      'category': category,
      'language': language,
      'cover_image': coverImage,
      'price': price,
      'rating': rating,
      'total_reviews': totalReviews,
      'is_purchased': isPurchased,
      'has_audio': hasAudio,
      'audio_duration': audioDuration?.inSeconds,
      'published_date': publishedDate.toIso8601String(),
    };
  }
}
