import 'dart:convert';
import 'dart:async';

import 'package:flutter/material.dart';
import '../../shared/widgets/app_text.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/auth/auth_provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/services/user_data_service.dart';
import '../payments/payment_service.dart';
import '../../models/story.dart';

class EbookReaderScreen extends StatefulWidget {
  final Story story;
  final int bookId;

  const EbookReaderScreen({
    super.key,
    required this.story,
    required this.bookId,
  });

  @override
  State<EbookReaderScreen> createState() => _EbookReaderScreenState();
}

class _EbookReaderScreenState extends State<EbookReaderScreen> {
  late Future<BookChapterPayload> _future;
  BookChapterPayload? _lastPayload;
  String? _authToken;
  Timer? _progressSaveTimer;
  bool _isSavingProgress = false;
  double _fontSize = 18;
  bool _isNightMode = false;
  bool _themeSynced = false;
  int _currentChapterIndex = 0;
  bool _localPurchaseUnlocked = false;
  final PaymentService _paymentService = PaymentService();

  @override
  void initState() {
    super.initState();
    _authToken = context.read<AuthProvider>().token;
    _future = _fetchChapters();
  }

  Future<BookChapterPayload> _fetchChapters() async {
    final uri = Uri.parse('${AppConstants.apiBaseUrl}${AppConstants.apiVersion}/books/${widget.bookId}/chapters/');
    final response = await http.get(uri);
    if (response.statusCode != 200) {
      throw Exception('Failed to load chapters (${response.statusCode}).');
    }

    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    final chapterData = decoded['chapters'] as List<dynamic>? ?? [];
    final chapters = chapterData
        .whereType<Map<String, dynamic>>()
        .map(BookChapter.fromJson)
        .toList()
      ..sort((a, b) => a.order.compareTo(b.order));

    final payload = BookChapterPayload(
      bookTitle: (decoded['book_title'] ?? widget.story.title).toString(),
      message: (decoded['message'] ?? '').toString(),
      previewOnly: decoded['preview_only'] == true,
      purchased: decoded['purchased'] == true,
      chapters: chapters,
    );

    await _restoreReadingProgress(payload);
    // Persist an initial touchpoint so chapter opening is reflected in history.
    await _saveReadingProgress(payload);
    _startPeriodicProgressSave(payload);
    return payload;
  }

  Future<bool> _confirmPurchaseAccess(String token) async {
    final uri = Uri.parse('${AppConstants.apiBaseUrl}${AppConstants.apiVersion}/books/${widget.bookId}/chapters/');
    final response = await http.get(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Token $token',
      },
    );

    if (response.statusCode != 200) {
      return false;
    }

    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    return decoded['purchased'] == true;
  }

  Future<void> _restoreReadingProgress(BookChapterPayload payload) async {
    final token = _authToken;
    if (token == null || token.isEmpty || payload.chapters.isEmpty) return;

    final progress = await UserDataService.fetchReadingProgress(
      token: token,
      bookId: widget.bookId,
    );
    if (progress == null) return;

    final chapterOrder = (progress['current_chapter_order'] as num?)?.toInt() ?? 1;
    final index = payload.chapters.indexWhere((c) => c.order == chapterOrder);
    if (index >= 0 && mounted) {
      setState(() {
        _currentChapterIndex = index;
      });
    }
  }

  Future<void> _saveReadingProgress(BookChapterPayload payload) async {
    if (_isSavingProgress) return;

    final token = _authToken;
    if (token == null || token.isEmpty || payload.chapters.isEmpty) return;

    final chapter = payload.chapters[_currentChapterIndex];
    _isSavingProgress = true;
    try {
      await UserDataService.saveReadingProgress(
        token: token,
        bookId: widget.bookId,
        chapterOrder: chapter.order,
        chapterProgress: 1.0,
      );
    } finally {
      _isSavingProgress = false;
    }
  }

  void _startPeriodicProgressSave(BookChapterPayload payload) {
    _progressSaveTimer?.cancel();
    _progressSaveTimer = Timer.periodic(const Duration(seconds: 20), (_) {
      _saveReadingProgress(payload);
    });
  }

  Future<void> _saveReadingProgressIfAvailable() async {
    final payload = _lastPayload;
    if (payload == null) return;
    await _saveReadingProgress(payload);
  }

  Future<void> _handleBack() async {
    final router = GoRouter.of(context);
    await _saveReadingProgressIfAvailable();
    if (!mounted) return;
    router.pop();
  }

  bool _isPurchased(BookChapterPayload payload) {
    return payload.purchased || _localPurchaseUnlocked;
  }

  bool _isChapterLocked(BookChapter chapter, BookChapterPayload payload) {
    return !_isPurchased(payload) && chapter.isLocked;
  }

  Future<void> _handleNext(BookChapterPayload payload) async {
    if (_currentChapterIndex >= payload.chapters.length - 1) return;

    final nextChapter = payload.chapters[_currentChapterIndex + 1];
    if (_isChapterLocked(nextChapter, payload)) {
      final shouldPay = await _showPurchasePrompt();
      if (!shouldPay || !mounted) return;

      final paid = await _showPaymentPopup();
      if (!paid || !mounted) return;

      setState(() {
        _localPurchaseUnlocked = true;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: AppText('Malipo yamekamilika. Unaweza kuendelea kusoma.')),
      );
    }

    if (!mounted) return;
    setState(() {
      _currentChapterIndex += 1;
    });
      await _saveReadingProgress(payload);
  }


  @override
  void dispose() {
    _progressSaveTimer?.cancel();
    _paymentService.dispose();
    super.dispose();
  }
  Future<bool> _showPurchasePrompt() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: AppText('Endelea Kusoma'),
        content: AppText(
          'Umesoma sura ya kwanza bure. Ili kuendelea na sura zinazofuata, nunua kitabu hiki sasa.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: AppText('Baadaye'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.sunsetOrange),
            child: AppText('Nunua Sasa'),
          ),
        ],
      ),
    );
    return result == true;
  }

  Future<bool> _showPaymentPopup() async {
    final token = _authToken ?? context.read<AuthProvider>().token;
    if (token == null || token.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: AppText('Ingia kwanza ili kulipa kitabu hiki.')),
        );
      }
      return false;
    }

    final email = (context.read<AuthProvider>().userEmail ?? '').trim();
    if (email.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: AppText('Akaunti yako haina email ya malipo.')),
        );
      }
      return false;
    }

    try {
      final initiated = await _paymentService.initiateBookPayment(
        token: token,
        bookId: widget.bookId,
        email: email,
      );

      if (initiated.alreadyPurchased) {
        final confirmed = await _confirmPurchaseAccess(token);
        if (confirmed) {
          return true;
        }
        throw Exception('Malipo hayajathibitishwa bado. Tafadhali jaribu tena ili kufungua ukurasa wa Pesapal.');
      }

      final checkoutUrl = initiated.redirectUri;
      if (checkoutUrl == null) return false;

      var opened = await launchUrl(checkoutUrl, mode: LaunchMode.platformDefault);
      if (!opened) {
        opened = await launchUrl(checkoutUrl, mode: LaunchMode.inAppBrowserView);
      }
      if (!opened) {
        opened = await launchUrl(checkoutUrl, mode: LaunchMode.externalApplication);
      }
      if (!opened) {
        throw Exception('Imeshindikana kufungua ukurasa wa malipo ya Pesapal.');
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: AppText('Ukurasa wa Pesapal umefunguliwa. Kamilisha malipo, kisha subiri uthibitisho.')),
        );
      }

      for (var i = 0; i < 24; i++) {
        await Future.delayed(const Duration(seconds: 5));
        final status = await _paymentService.fetchPaymentStatus(
          token: token,
          merchantReference: initiated.merchantReference,
        );
        if (status == 'completed') {
          return true;
        }
        if (status == 'failed') {
          return false;
        }
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: AppText('Malipo bado hayajathibitishwa. Jaribu tena muda mfupi ujao.')),
        );
      }
      return false;
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: AppText('Malipo yameshindwa: ${e.toString()}')),
        );
      }
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_themeSynced) {
      _isNightMode = Theme.of(context).brightness == Brightness.dark;
      _themeSynced = true;
    }

    final background = _isNightMode ? AppColors.backgroundDark : AppColors.backgroundLight;
    final card = _isNightMode ? const Color(0xFF2F2118) : Colors.white;
    final text = _isNightMode ? const Color(0xFFE8EDF3) : AppColors.textPrimary;
    final iconColor = _isNightMode ? Colors.white70 : AppColors.textPrimary;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final router = GoRouter.of(context);
        await _saveReadingProgressIfAvailable();
        if (!mounted) return;
        router.pop();
      },
      child: Scaffold(
        backgroundColor: background,
        body: SafeArea(
          child: FutureBuilder<BookChapterPayload>(
          future: _future,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: AppText(
                    'Imeshindikana kupakia sura. ${snapshot.error}',
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            }

            final payload = snapshot.data!;
            _lastPayload = payload;
            if (payload.chapters.isEmpty) {
              return Center(
                child: AppText(
                  payload.message.isEmpty ? 'Hakuna sura zilizopatikana.' : payload.message,
                  style: TextStyle(color: text),
                ),
              );
            }

            if (_currentChapterIndex >= payload.chapters.length) {
              _currentChapterIndex = 0;
            }

            final chapter = payload.chapters[_currentChapterIndex];
            final chapterLocked = _isChapterLocked(chapter, payload);

            return Column(
              children: [
                Container(
                  margin: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: card,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(_isNightMode ? 0.28 : 0.06),
                        blurRadius: 18,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: _handleBack,
                        icon: Icon(Icons.arrow_back, color: text),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AppText(
                              payload.bookTitle,
                              style: TextStyle(color: text, fontWeight: FontWeight.w700),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            AppText(
                              'Sura ${_currentChapterIndex + 1} ya ${payload.chapters.length}',
                              style: TextStyle(color: text.withOpacity(0.65), fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => setState(() => _isNightMode = !_isNightMode),
                        icon: Icon(_isNightMode ? Icons.light_mode : Icons.dark_mode, color: text),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(
                      color: card,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: chapterLocked
                        ? _LockedChapterView(message: payload.message)
                        : SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                AppText(
                                  chapter.title,
                                  style: TextStyle(
                                    color: text,
                                    fontSize: _fontSize + 6,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                AppText(
                                  chapter.content.isEmpty
                                      ? 'Sura hii imefunguliwa. Maudhui kamili yanaendelea kusawazishwa.'
                                      : chapter.content,
                                  style: TextStyle(
                                    color: text,
                                    fontSize: _fontSize,
                                    height: 1.8,
                                  ),
                                ),
                              ],
                            ),
                          ),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: card,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Icon(Icons.text_decrease, size: 18, color: iconColor),
                          Expanded(
                            child: Slider(
                              value: _fontSize,
                              min: 14,
                              max: 28,
                              divisions: 14,
                              activeColor: AppColors.sunsetOrange,
                              onChanged: (v) => setState(() => _fontSize = v),
                            ),
                          ),
                          Icon(Icons.text_increase, size: 18, color: iconColor),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          ElevatedButton.icon(
                            onPressed: _currentChapterIndex > 0
                                ? () {
                                    setState(() => _currentChapterIndex -= 1);
                                    _saveReadingProgress(payload);
                                  }
                                : null,
                            icon: const Icon(Icons.chevron_left),
                            label: AppText('Previous'),
                          ),
                          ElevatedButton.icon(
                            onPressed: _currentChapterIndex < payload.chapters.length - 1
                                ? () => _handleNext(payload)
                                : null,
                            icon: const Icon(Icons.chevron_right),
                            label: AppText('Next'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
          ),
        ),
      ),
    );
  }
}

class _LockedChapterView extends StatelessWidget {
  final String message;

  const _LockedChapterView({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.lock_outline, size: 56, color: AppColors.sunsetOrange),
          const SizedBox(height: 12),
          AppText(
            message.isEmpty ? 'Buy this book to continue reading' : message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class BookChapterPayload {
  final String bookTitle;
  final bool previewOnly;
  final bool purchased;
  final String message;
  final List<BookChapter> chapters;

  BookChapterPayload({
    required this.bookTitle,
    required this.previewOnly,
    required this.purchased,
    required this.message,
    required this.chapters,
  });
}

class BookChapter {
  final int id;
  final String title;
  final String content;
  final int order;
  final bool isLocked;

  BookChapter({
    required this.id,
    required this.title,
    required this.content,
    required this.order,
    required this.isLocked,
  });

  factory BookChapter.fromJson(Map<String, dynamic> json) {
    return BookChapter(
      id: (json['id'] as num?)?.toInt() ?? 0,
      title: (json['title'] ?? '').toString(),
      content: (json['content'] ?? '').toString(),
      order: (json['order'] as num?)?.toInt() ?? 0,
      isLocked: json['is_locked'] == true,
    );
  }
}

