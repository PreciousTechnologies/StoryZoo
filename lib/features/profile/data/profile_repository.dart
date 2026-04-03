import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../core/constants/app_constants.dart';
import '../../../models/story.dart';

class ProfileStatsData {
  const ProfileStatsData({
    required this.storiesCount,
    required this.savedCount,
    required this.listeningHours,
  });

  final int storiesCount;
  final int savedCount;
  final double listeningHours;

  factory ProfileStatsData.fromJson(Map<String, dynamic> json) {
    return ProfileStatsData(
      storiesCount: _asInt(json['stories_count']),
      savedCount: _asInt(json['saved_count']),
      listeningHours: _asDouble(json['listening_hours']),
    );
  }
}

class PurchasesData {
  const PurchasesData({
    required this.total,
    required this.audio,
    required this.budget,
    required this.items,
  });

  final int total;
  final int audio;
  final double budget;
  final List<Story> items;

  factory PurchasesData.fromJson(Map<String, dynamic> json) {
    final stats = (json['stats'] as Map<String, dynamic>?) ?? const {};
    final itemsRaw = (json['items'] as List?)?.whereType<Map<String, dynamic>>().toList() ?? const [];

    return PurchasesData(
      total: _asInt(stats['jumla']),
      audio: _asInt(stats['audio']),
      budget: _asDouble(stats['bajeti']),
      items: itemsRaw.map(Story.fromJson).toList(),
    );
  }
}

class HistoryEntry {
  const HistoryEntry({
    required this.story,
    required this.progress,
    required this.timeLabel,
    required this.updatedAt,
  });

  final Story story;
  final double progress;
  final String timeLabel;
  final DateTime updatedAt;

  factory HistoryEntry.fromJson(Map<String, dynamic> json) {
    final source = Map<String, dynamic>.from(json);
    source['author_id'] = source['author_id'] ?? 'unknown';
    source['description'] = source['description'] ?? '';
    source['category'] = source['category'] ?? 'General';
    source['cover_image'] = source['cover_image'] ?? '';
    source['price'] = source['price'] ?? 0;
    source['rating'] = source['rating'] ?? 0;
    source['total_reviews'] = source['total_reviews'] ?? 0;
    source['is_purchased'] = source['is_purchased'] ?? true;
    source['published_date'] = source['updated_at'] ?? DateTime.now().toIso8601String();

    return HistoryEntry(
      story: Story.fromJson(source),
      progress: _asDouble(json['progress']),
      timeLabel: (json['time'] ?? '').toString(),
      updatedAt: _asDateTime(json['updated_at']),
    );
  }
}

class HistoryData {
  const HistoryData({
    required this.mudaHours,
    required this.vitabu,
    required this.kumalizaPercent,
    required this.groups,
  });

  final double mudaHours;
  final int vitabu;
  final double kumalizaPercent;
  final Map<String, List<HistoryEntry>> groups;

  factory HistoryData.fromJson(Map<String, dynamic> json) {
    final stats = (json['stats'] as Map<String, dynamic>?) ?? const {};
    final groupsRaw = (json['groups'] as Map<String, dynamic>?) ?? const {};

    final parsedGroups = <String, List<HistoryEntry>>{};
    for (final entry in groupsRaw.entries) {
      final rows = (entry.value as List?)?.whereType<Map<String, dynamic>>().toList() ?? const [];
      parsedGroups[entry.key] = rows.map(HistoryEntry.fromJson).toList();
    }

    return HistoryData(
      mudaHours: _asDouble(stats['muda_hours']),
      vitabu: _asInt(stats['vitabu']),
      kumalizaPercent: _asDouble(stats['kumaliza_percent']),
      groups: parsedGroups,
    );
  }
}

class NotificationSettingsData {
  const NotificationSettingsData({
    required this.pushNotifications,
    required this.emailNotifications,
    required this.newStories,
    required this.promotions,
    required this.authorUpdates,
    required this.comments,
    required this.likes,
    required this.soundEffects,
    required this.vibration,
  });

  final bool pushNotifications;
  final bool emailNotifications;
  final bool newStories;
  final bool promotions;
  final bool authorUpdates;
  final bool comments;
  final bool likes;
  final bool soundEffects;
  final bool vibration;

  factory NotificationSettingsData.fromJson(Map<String, dynamic> json) {
    return NotificationSettingsData(
      pushNotifications: _asBool(json['push_notifications'], fallback: true),
      emailNotifications: _asBool(json['email_notifications']),
      newStories: _asBool(json['new_stories'], fallback: true),
      promotions: _asBool(json['promotions'], fallback: true),
      authorUpdates: _asBool(json['author_updates']),
      comments: _asBool(json['comments'], fallback: true),
      likes: _asBool(json['likes']),
      soundEffects: _asBool(json['sound_effects'], fallback: true),
      vibration: _asBool(json['vibration'], fallback: true),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'push_notifications': pushNotifications,
      'email_notifications': emailNotifications,
      'new_stories': newStories,
      'promotions': promotions,
      'author_updates': authorUpdates,
      'comments': comments,
      'likes': likes,
      'sound_effects': soundEffects,
      'vibration': vibration,
    };
  }
}

class ProfileRepository {
  ProfileRepository({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  String get _base => '${AppConstants.apiBaseUrl}${AppConstants.apiVersion}';

  Map<String, String> _headers(String token) => {
        'Authorization': 'Token $token',
        'Content-Type': 'application/json',
      };

  Future<ProfileStatsData> fetchProfileStats(String token) async {
    final res = await _client.get(Uri.parse('$_base/me/profile/stats/'), headers: _headers(token));
    if (res.statusCode != 200) {
      throw Exception('Failed to load profile stats (${res.statusCode}).');
    }
    return ProfileStatsData.fromJson(jsonDecode(res.body) as Map<String, dynamic>);
  }

  Future<PurchasesData> fetchPurchases(String token) async {
    final res = await _client.get(Uri.parse('$_base/me/purchases/'), headers: _headers(token));
    if (res.statusCode != 200) {
      throw Exception('Failed to load purchases (${res.statusCode}).');
    }
    return PurchasesData.fromJson(jsonDecode(res.body) as Map<String, dynamic>);
  }

  Future<HistoryData> fetchHistory(String token) async {
    final res = await _client.get(Uri.parse('$_base/me/history/'), headers: _headers(token));
    if (res.statusCode != 200) {
      throw Exception('Failed to load history (${res.statusCode}).');
    }
    return HistoryData.fromJson(jsonDecode(res.body) as Map<String, dynamic>);
  }

  Future<NotificationSettingsData> fetchNotificationSettings(String token) async {
    final res = await _client.get(Uri.parse('$_base/me/notifications/preferences/'), headers: _headers(token));
    if (res.statusCode != 200) {
      throw Exception('Failed to load notification preferences (${res.statusCode}).');
    }
    return NotificationSettingsData.fromJson(jsonDecode(res.body) as Map<String, dynamic>);
  }

  Future<NotificationSettingsData> updateNotificationSettings(
    String token,
    Map<String, dynamic> payload,
  ) async {
    final res = await _client.patch(
      Uri.parse('$_base/me/notifications/preferences/'),
      headers: _headers(token),
      body: jsonEncode(payload),
    );
    if (res.statusCode != 200) {
      throw Exception('Failed to update notification preferences (${res.statusCode}).');
    }
    return NotificationSettingsData.fromJson(jsonDecode(res.body) as Map<String, dynamic>);
  }

  void dispose() {
    _client.close();
  }
}

int _asInt(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '') ?? 0;
}

double _asDouble(dynamic value) {
  if (value is num) return value.toDouble();
  return double.tryParse(value?.toString() ?? '') ?? 0.0;
}

DateTime _asDateTime(dynamic value) {
  if (value is DateTime) return value;
  if (value is String) return DateTime.tryParse(value) ?? DateTime.now();
  return DateTime.now();
}

bool _asBool(dynamic value, {bool fallback = false}) {
  if (value is bool) return value;
  if (value is num) return value != 0;
  final raw = (value ?? '').toString().trim().toLowerCase();
  if (raw == 'true' || raw == '1' || raw == 'yes') return true;
  if (raw == 'false' || raw == '0' || raw == 'no') return false;
  return fallback;
}
