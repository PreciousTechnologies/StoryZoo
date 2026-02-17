class Story {
  final String id;
  final String title;
  final String description;
  final String author;
  final String authorId;
  final String category;
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
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      author: json['author'] ?? '',
      authorId: json['author_id'] ?? '',
      category: json['category'] ?? '',
      coverImage: json['cover_image'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      rating: (json['rating'] ?? 0).toDouble(),
      totalReviews: json['total_reviews'] ?? 0,
      isPurchased: json['is_purchased'] ?? false,
      hasAudio: json['has_audio'] ?? false,
      audioDuration: json['audio_duration'] != null
          ? Duration(seconds: json['audio_duration'])
          : null,
      publishedDate: json['published_date'] != null
          ? DateTime.parse(json['published_date'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'author': author,
      'author_id': authorId,
      'category': category,
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
