import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:ui';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import '../../shared/widgets/app_text.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/auth/auth_provider.dart';
import '../../core/constants/app_constants.dart';
import '../../core/constants/app_colors.dart';
import '../../core/services/global_audio_player_service.dart';
import '../../core/services/mini_audio_player_controller.dart';
import '../../core/services/tts_service.dart';
import '../../core/services/user_data_service.dart';
import '../payments/payment_service.dart';
import '../../shared/widgets/glassmorphic_container.dart';
import '../../shared/widgets/neumorphic_widgets.dart';
import '../../models/story.dart';

class AudioPlayerScreen extends StatefulWidget {
  final Story story;

  const AudioPlayerScreen({
    super.key,
    required this.story,
  });

  @override
  State<AudioPlayerScreen> createState() => _AudioPlayerScreenState();
}

class _AudioPlayerScreenState extends State<AudioPlayerScreen> with TickerProviderStateMixin {
  late AnimationController _rotationController;
  late AnimationController _playPauseController;
  final AudioPlayer _audioPlayer = GlobalAudioPlayerService.instance.player;
  StreamSubscription<Duration>? _positionSub;
  StreamSubscription<Duration>? _durationSub;
  StreamSubscription<PlayerState>? _playerStateSub;
  StreamSubscription<void>? _playerCompleteSub;

  bool _isPlaying = false;
  bool _isLoadingAudio = true;
  String? _audioError;
  double _currentPosition = 0.0;
  double _totalDuration = 1.0;
  double _playbackSpeed = 1.0;
  int? _storyId;
  final List<_AudioChapter> _chapters = [];
  int _currentChapterIndex = 0;
  bool _bookPurchased = false;
  bool _previewOnly = false;
  bool _localPurchaseUnlocked = false;
  String? _authToken;
  String? _audioFilePath;
  final PaymentService _paymentService = PaymentService();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final mini = context.read<MiniAudioPlayerController>();
      mini.hideOverlay();
      mini.bindChapterControls(
        onPreviousChapter: _handlePreviousChapterFromMini,
        onNextChapter: _handleAutoNextChapter,
        onOpenFullPlayer: _reopenFromMini,
      );
    });
    
    // Rotation animation for book cover
    _rotationController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    );

    // Play/Pause icon animation
    _playPauseController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _setupAudio();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _authToken = context.read<AuthProvider>().token;
  }

  @override
  void dispose() {
    if (mounted) {
      context.read<MiniAudioPlayerController>().bindChapterControls();
    }
    _saveAudioProgress();
    _positionSub?.cancel();
    _durationSub?.cancel();
    _playerStateSub?.cancel();
    _playerCompleteSub?.cancel();
    _paymentService.dispose();
    _rotationController.dispose();
    _playPauseController.dispose();
    super.dispose();
  }

  void _minimizePlayer() {
    if (!mounted) return;
    final mini = context.read<MiniAudioPlayerController>();
    mini.showForStory(widget.story);
    mini.bindChapterControls(
      onPreviousChapter: _handlePreviousChapterFromMini,
      onNextChapter: _handleAutoNextChapter,
      onOpenFullPlayer: _reopenFromMini,
    );
    context.push('/home');
  }

  void _reopenFromMini() {
    if (!mounted) return;
    final mini = context.read<MiniAudioPlayerController>();
    mini.hideOverlay();

    // Prefer returning to the existing audio route instance so playback
    // continues from current position without regenerating/restarting audio.
    if (Navigator.of(context).canPop()) {
      context.pop();
      return;
    }

    // Fallback for edge cases where this route is no longer in stack.
    context.push('/audio-player/${widget.story.id}', extra: widget.story);
  }

  Future<void> _handlePreviousChapterFromMini() async {
    if (_currentChapterIndex > 0) {
      if (!mounted) return;
      setState(() {
        _currentChapterIndex -= 1;
      });
      await _loadCurrentChapterAudio(autoPlay: true);
      return;
    }
    await _audioPlayer.seek(Duration.zero);
  }

  Future<void> _setupAudio() async {
    try {
      _authToken = context.read<AuthProvider>().token;
      // Always bind audio voice to the book/story language selected by author.
      final storyLanguage = widget.story.language;
      final voiceModel = TTSService.getVoiceModel(storyLanguage);
      
      print('🎵 Audio Setup: StoryLanguage=$storyLanguage, Voice=${voiceModel.voiceModel}');
      
      final storyId = int.tryParse(widget.story.id);
      _storyId = storyId;

      if (storyId != null) {
        await _loadBookChapters(storyId);
      }
      if (_chapters.isEmpty) {
        _chapters.add(
          _AudioChapter(
            id: storyId ?? 0,
            title: widget.story.title,
            content: widget.story.description,
            order: 1,
            isLocked: false,
          ),
        );
      }

      _durationSub = _audioPlayer.onDurationChanged.listen((duration) {
        if (!mounted) return;
        setState(() {
          _totalDuration = duration.inMilliseconds <= 0 ? 1 : duration.inSeconds.toDouble();
        });
      });

      _positionSub = _audioPlayer.onPositionChanged.listen((position) {
        if (!mounted) return;
        setState(() {
          _currentPosition = position.inSeconds.toDouble();
        });
      });

      _playerStateSub = _audioPlayer.onPlayerStateChanged.listen((state) {
        if (!mounted) return;
        setState(() {
          _isPlaying = state == PlayerState.playing;
        });

        if (_isPlaying) {
          _rotationController.repeat();
          _playPauseController.forward();
        } else {
          _rotationController.stop();
          _playPauseController.reverse();
        }
      });

      _playerCompleteSub = _audioPlayer.onPlayerComplete.listen((_) {
        _handleAutoNextChapter();
      });

      await _restoreAudioProgress();
      await _loadCurrentChapterAudio(autoPlay: true);

      if (!mounted) return;
      setState(() {
        _isLoadingAudio = false;
      });
    } catch (e) {
      if (!mounted) return;
      final voiceModel = TTSService.getVoiceModel(widget.story.language);
      print('🎵 ERROR: $e, Language=${widget.story.language}, Voice=${voiceModel.voiceModel}');
      setState(() {
        _audioError = 'Imeshindikana kupakia sauti. Hakikisha Piper TTS imewashwa kwenye server.\nLugha: ${widget.story.language}\nSauti: ${voiceModel.voiceModel}';
        _isLoadingAudio = false;
      });
    }
  }

  Future<void> _loadBookChapters(int bookId) async {
    final uri = Uri.parse('${AppConstants.apiBaseUrl}${AppConstants.apiVersion}/books/$bookId/chapters/');
    final headers = <String, String>{};
    if (_authToken != null && _authToken!.isNotEmpty) {
      headers['Authorization'] = 'Token ${_authToken!}';
    }

    final response = await http.get(uri, headers: headers);
    if (response.statusCode != 200) {
      return;
    }

    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    final chapterData = decoded['chapters'] as List<dynamic>? ?? [];
    final chapters = chapterData
        .whereType<Map<String, dynamic>>()
        .map(_AudioChapter.fromJson)
        .toList()
      ..sort((a, b) => a.order.compareTo(b.order));

    _bookPurchased = decoded['purchased'] == true;
    _previewOnly = decoded['preview_only'] == true;
    _chapters
      ..clear()
      ..addAll(chapters);
  }

  bool _isChapterLocked(_AudioChapter chapter, int chapterIndex) {
    final hasPaidAccess = _bookPurchased || _localPurchaseUnlocked;

    // Canonical gate from backend: preview_only means only chapter 1 is free.
    if (_previewOnly && !hasPaidAccess && chapterIndex > 0) {
      return true;
    }

    // Extra safety fallback if backend lock metadata is inconsistent.
    final isPaidBook = widget.story.price > 0;
    if (isPaidBook && !hasPaidAccess && chapterIndex > 0) {
      return true;
    }

    return chapter.isLocked && !hasPaidAccess;
  }

  Future<void> _loadCurrentChapterAudio({required bool autoPlay}) async {
    if (_chapters.isEmpty) return;
    final chapter = _chapters[_currentChapterIndex];
    final text = chapter.content.trim().isEmpty
        ? '${widget.story.title}. ${widget.story.description}'
        : chapter.content.trim();

    if (mounted) {
      setState(() {
        _isLoadingAudio = true;
        _audioError = null;
        _currentPosition = 0;
      });
    }

    final audioUrl = TTSService.buildTextTtsUrl(
      text: text,
      languageCode: widget.story.language,
    );
    final localAudioPath = await _downloadTtsToTempFile(audioUrl, storyId: _storyId, chapterOrder: chapter.order);
    _audioFilePath = localAudioPath;
    await _audioPlayer.stop();
    await _audioPlayer.setSource(DeviceFileSource(localAudioPath));
    await _audioPlayer.setPlaybackRate(_playbackSpeed);

    if (autoPlay) {
      await _audioPlayer.resume();
    }

    if (mounted) {
      setState(() {
        _isLoadingAudio = false;
      });
    }
  }

  Future<void> _handleAutoNextChapter() async {
    if (_currentChapterIndex >= _chapters.length - 1) {
      return;
    }

    final nextIndex = _currentChapterIndex + 1;
    final nextChapter = _chapters[nextIndex];
    if (_isChapterLocked(nextChapter, nextIndex)) {
      final shouldPay = await _showPurchasePrompt();
      if (!shouldPay || !mounted) return;

      final paid = await _showPaymentPopup();
      if (!paid || !mounted) return;

      setState(() {
        _localPurchaseUnlocked = true;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: AppText('Malipo yamekamilika. Sasa unaweza kusikiliza sura zote.')),
      );
    }

    if (!mounted) return;
    setState(() {
      _currentChapterIndex = nextIndex;
    });
    await _loadCurrentChapterAudio(autoPlay: true);
  }

  Future<String> _downloadTtsToTempFile(String audioUrl, {int? storyId, int? chapterOrder}) async {
    final uri = Uri.parse(audioUrl);
    final response = await http.get(uri);
    if (response.statusCode != 200) {
      throw Exception('TTS endpoint failed with status ${response.statusCode}');
    }

    final tempDir = await getTemporaryDirectory();
    final suffix = chapterOrder != null ? '_chapter_$chapterOrder' : '';
    final filename = storyId != null ? 'tts_story_$storyId$suffix.wav' : 'tts_preview$suffix.wav';
    final file = File('${tempDir.path}${Platform.pathSeparator}$filename');
    await file.writeAsBytes(response.bodyBytes, flush: true);
    return file.path;
  }

  Future<bool> _confirmPurchaseAccess(String token) async {
    final sid = _storyId;
    if (sid == null) return false;
    final uri = Uri.parse('${AppConstants.apiBaseUrl}${AppConstants.apiVersion}/books/$sid/chapters/');
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

  Future<bool> _showPurchasePrompt() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const AppText('Endelea Kusikiliza'),
        content: const AppText(
          'Sura inayofuata imefungwa. Nunua kitabu hiki ili kuendelea kusikiliza sura zilizobaki.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const AppText('Baadaye'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.sunsetOrange),
            child: const AppText('Nunua Sasa'),
          ),
        ],
      ),
    );
    return result == true;
  }

  Future<bool> _showPaymentPopup() async {
    final token = _authToken ?? context.read<AuthProvider>().token;
    final sid = _storyId;
    if (token == null || token.isEmpty || sid == null) {
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
        bookId: sid,
        email: email,
      );

      if (initiated.alreadyPurchased) {
        final confirmed = await _confirmPurchaseAccess(token);
        if (confirmed) return true;
        throw Exception('Malipo hayajathibitishwa bado. Jaribu tena.');
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

  Future<void> _togglePlayPause() async {
    if (_audioError != null) return;
    if (_isPlaying) {
      await _audioPlayer.pause();
      await _saveAudioProgress();
    } else {
      await _audioPlayer.resume();
    }
  }

  Future<void> _restoreAudioProgress() async {
    final sid = _storyId;
    if (sid == null) return;

    final token = _authToken ?? context.read<AuthProvider>().token;
    if (token == null || token.isEmpty) return;

    final progress = await UserDataService.fetchAudioProgress(token: token, storyId: sid);
    if (progress == null) return;

    final playbackSpeed = (progress['playback_speed'] as num?)?.toDouble() ?? 1.0;
    final positionSeconds = (progress['position_seconds'] as num?)?.toInt() ?? 0;

    await _audioPlayer.setPlaybackRate(playbackSpeed);
    if (positionSeconds > 0) {
      await _audioPlayer.seek(Duration(seconds: positionSeconds));
    }

    if (!mounted) return;
    setState(() {
      _playbackSpeed = playbackSpeed;
      _currentPosition = positionSeconds.toDouble();
    });
  }

  Future<void> _saveAudioProgress() async {
    final sid = _storyId;
    if (sid == null) return;

    final token = _authToken ?? context.read<AuthProvider>().token;
    if (token == null || token.isEmpty) return;

    await UserDataService.saveAudioProgress(
      token: token,
      storyId: sid,
      positionSeconds: _currentPosition.round(),
      totalSeconds: _totalDuration.round(),
      playbackSpeed: _playbackSpeed,
    );
  }

  Future<void> _seekBySeconds(int deltaSeconds) async {
    final target = (_currentPosition + deltaSeconds).clamp(0, _totalDuration).toDouble();
    await _audioPlayer.seek(Duration(seconds: target.round()));
  }

  Future<void> _restartPlayback() async {
    if (_audioError != null) return;
    await _audioPlayer.stop();
    final sourcePath = _audioFilePath;
    if (sourcePath != null) {
      await _audioPlayer.setSource(DeviceFileSource(sourcePath));
      await _audioPlayer.setPlaybackRate(_playbackSpeed);
    }
    await _audioPlayer.seek(Duration.zero);
    if (mounted) {
      setState(() {
        _currentPosition = 0;
      });
    }
    await _audioPlayer.resume();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final overlayColor = isDark
        ? AppColors.backgroundDark.withOpacity(0.72)
        : AppColors.backgroundLight.withOpacity(0.7);
    final titleColor = isDark ? Colors.white : AppColors.textPrimary;
    final secondaryColor = isDark ? Colors.white70 : AppColors.textSecondary;
    final mutedColor = isDark ? Colors.white60 : AppColors.textMuted;
    final progressGlass = isDark
        ? AppColors.glassDark.withOpacity(0.45)
        : AppColors.glassWhite.withOpacity(0.3);

    return Scaffold(
      body: Container(
        width: size.width,
        height: size.height,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.sunsetOrange.withOpacity(isDark ? 0.2 : 0.3),
              AppColors.savannaGreen.withOpacity(isDark ? 0.18 : 0.3),
              AppColors.clayPurple.withOpacity(isDark ? 0.12 : 0.2),
            ],
          ),
        ),
        child: Stack(
          children: [
            // Blurred background effect
            Positioned.fill(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
                child: Container(
                  color: overlayColor,
                ),
              ),
            ),

            // Main content
            SafeArea(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final coverSize = (constraints.maxHeight * 0.34).clamp(180.0, 280.0).toDouble();
                  final innerCoverSize = (coverSize - 40).clamp(140.0, 240.0).toDouble();
                  final playButtonSize = (constraints.maxHeight * 0.09).clamp(60.0, 70.0).toDouble();

                  return SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(minHeight: constraints.maxHeight),
                      child: Column(
                        children: [
                  // App bar
                  Padding(
                    padding: const EdgeInsets.all(AppConstants.paddingMedium),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const SizedBox(width: 50),
                        AppText(
                          'Sikiliza Hadithi',
                          style: (Theme.of(context).textTheme.titleLarge ?? const TextStyle(fontSize: 20)).copyWith(
                                fontWeight: FontWeight.w600,
                                color: titleColor,
                              ),
                        ),
                        NeumorphicIconButton(
                          icon: Icons.open_in_new,
                          size: 50,
                          onPressed: _minimizePlayer,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Rotating book cover (Hero animation)
                  Hero(
                    tag: 'story_cover_${widget.story.id}',
                    child: RotationTransition(
                      turns: _rotationController,
                      child: Container(
                        width: coverSize,
                        height: coverSize,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.sunsetOrange.withOpacity(0.3),
                              blurRadius: 40,
                              spreadRadius: 10,
                            ),
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                AppColors.sunsetOrange,
                                AppColors.savannaGreen,
                              ],
                            ),
                          ),
                          child: Center(
                            child: Container(
                              width: innerCoverSize,
                              height: innerCoverSize,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isDark ? const Color(0xFF2F2118) : AppColors.cardBackground,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(isDark ? 0.28 : 0.1),
                                    blurRadius: 10,
                                    spreadRadius: -5,
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.auto_stories_rounded,
                                size: 100,
                                color: AppColors.sunsetOrange,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 18),

                  // Story info
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppConstants.paddingLarge),
                    child: Column(
                      children: [
                        AppText(
                          widget.story.title,
                          style: (Theme.of(context).textTheme.headlineMedium ?? const TextStyle(fontSize: 24)).copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        AppText(
                          widget.story.author,
                          style: (Theme.of(context).textTheme.bodyLarge ?? const TextStyle(fontSize: 16)).copyWith(
                                color: secondaryColor,
                              ),
                        ),
                        if (_chapters.isNotEmpty) ...[
                          const SizedBox(height: 6),
                          AppText(
                            'Sura ${_currentChapterIndex + 1} ya ${_chapters.length}: ${_chapters[_currentChapterIndex].title}',
                            style: TextStyle(fontSize: 12, color: mutedColor),
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                        const SizedBox(height: 8),
                        if (_isLoadingAudio)
                          AppText('Inatengeneza sauti kupitia Piper TTS...', style: TextStyle(fontSize: 12))
                        else if (_audioError != null)
                          AppText(
                            _audioError!,
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 12, color: AppColors.error),
                          )
                        else
                          AppText(
                            'Free audio narration via Piper TTS',
                            style: TextStyle(fontSize: 12, color: mutedColor),
                          ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Progress slider with glassmorphism
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppConstants.paddingLarge),
                    child: Column(
                      children: [
                        GlassmorphicContainer(
                          height: 8,
                          borderRadius: 4,
                          blur: 8,
                          color: progressGlass,
                          borderColor: AppColors.glassBorder.withOpacity(0.5),
                          borderWidth: 1,
                          padding: EdgeInsets.zero,
                          child: Stack(
                            children: [
                              FractionallySizedBox(
                                widthFactor: (_totalDuration <= 0 ? 0.0 : _currentPosition / _totalDuration)
                                    .clamp(0.0, 1.0)
                                    .toDouble(),
                                child: Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        AppColors.sunsetOrange,
                                        AppColors.deepOrange,
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            AppText(
                              _formatDuration(_currentPosition),
                              style: (Theme.of(context).textTheme.bodySmall ?? const TextStyle(fontSize: 12)).copyWith(
                                    color: mutedColor,
                                  ),
                            ),
                            AppText(
                              _formatDuration(_totalDuration),
                              style: (Theme.of(context).textTheme.bodySmall ?? const TextStyle(fontSize: 12)).copyWith(
                                    color: mutedColor,
                                  ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 18),

                  // Neumorphic control bar
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppConstants.paddingMedium),
                    child: NeumorphicCard(
                      borderRadius: 40,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                          // Previous button
                          _buildControlButton(
                            Icons.skip_previous_rounded,
                            50,
                            _handlePreviousChapterFromMini,
                          ),

                          // Rewind button
                          _buildControlButton(
                            Icons.replay_10_rounded,
                            45,
                            () {
                              _seekBySeconds(-10);
                            },
                          ),

                          // Play/Pause button (larger)
                          GestureDetector(
                            onTap: _togglePlayPause,
                            child: Container(
                              width: playButtonSize,
                              height: playButtonSize,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    AppColors.sunsetOrange,
                                    AppColors.deepOrange,
                                  ],
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.sunsetOrange.withOpacity(0.4),
                                    blurRadius: 20,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: Icon(
                                _isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                                size: playButtonSize * 0.5,
                                color: Colors.white,
                              ),
                            ),
                          ),

                          // Forward button
                          _buildControlButton(
                            Icons.forward_10_rounded,
                            45,
                            () {
                              _seekBySeconds(10);
                            },
                          ),

                          // Next button
                          _buildControlButton(
                            Icons.skip_next_rounded,
                            50,
                            _handleAutoNextChapter,
                          ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 18),

                  // Additional controls
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppConstants.paddingLarge),
                    child: Wrap(
                      alignment: WrapAlignment.spaceAround,
                      runSpacing: 12,
                      spacing: 12,
                      children: [
                        _buildSecondaryControl(Icons.replay_rounded, 'Rudia', _restartPlayback),
                        _buildSecondaryControl(Icons.speed, '${_playbackSpeed}x', _showSpeedDialog),
                        _buildSecondaryControl(Icons.share_outlined, 'Shiriki', () {}),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  void _showSpeedDialog() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final dialogBg = isDark ? const Color(0xFF2F2118) : AppColors.cardBackground;
    final itemText = isDark ? Colors.white : AppColors.textPrimary;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: dialogBg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: AppText('Chagua Kasi ya Usikilizaji', style: TextStyle(fontSize: 16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [0.5, 0.75, 1.0, 1.25, 1.5, 1.75, 2.0].map((speed) {
            final isSelected = _playbackSpeed == speed;
            return ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(
                isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                color: isSelected ? AppColors.sunsetOrange : AppColors.textMuted,
                size: 20,
              ),
              title: AppText(
                '${speed}x',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  color: isSelected ? AppColors.sunsetOrange : itemText,
                ),
              ),
              onTap: () {
                setState(() {
                  _playbackSpeed = speed;
                });
                _audioPlayer.setPlaybackRate(speed);
                Navigator.pop(context);
              },
            );
          }).toList(),
        ),
      ),
    );
  }
  
  Widget _buildControlButton(IconData icon, double size, FutureOr<void> Function() onPressed) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final buttonColor = isDark ? const Color(0xFF3A2A20) : AppColors.cardBackground;
    final lightShadow = isDark ? AppColors.sandBrown.withOpacity(0.12) : AppColors.neuShadowLight;
    final darkShadow = isDark
        ? Colors.black.withOpacity(0.45)
        : AppColors.neuShadowDark.withOpacity(0.3);
    final iconColor = isDark ? Colors.white70 : AppColors.textPrimary;

    return GestureDetector(
      onTap: () {
        onPressed();
      },
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: buttonColor,
          boxShadow: [
            BoxShadow(
              color: lightShadow,
              offset: const Offset(-3, -3),
              blurRadius: 6,
            ),
            BoxShadow(
              color: darkShadow,
              offset: const Offset(3, 3),
              blurRadius: 6,
            ),
          ],
        ),
        child: Icon(
          icon,
          size: size * 0.5,
          color: iconColor,
        ),
      ),
    );
  }

  Widget _buildSecondaryControl(IconData icon, String label, VoidCallback onTap) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final iconColor = isDark ? Colors.white70 : AppColors.textSecondary;
    final textColor = isDark ? Colors.white60 : AppColors.textMuted;

    return SizedBox(
      width: 76,
      height: 64,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 24, color: iconColor),
              const SizedBox(height: 4),
              AppText(
                label,
                style: (Theme.of(context).textTheme.bodySmall ?? const TextStyle(fontSize: 12)).copyWith(
                      color: textColor,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDuration(double seconds) {
    final minutes = (seconds / 60).floor();
    final secs = (seconds % 60).floor();
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }
}

class _AudioChapter {
  final int id;
  final String title;
  final String content;
  final int order;
  final bool isLocked;

  const _AudioChapter({
    required this.id,
    required this.title,
    required this.content,
    required this.order,
    required this.isLocked,
  });

  factory _AudioChapter.fromJson(Map<String, dynamic> json) {
    return _AudioChapter(
      id: (json['id'] as num?)?.toInt() ?? 0,
      title: (json['title'] ?? '').toString(),
      content: (json['content'] ?? '').toString(),
      order: (json['order'] as num?)?.toInt() ?? 0,
      isLocked: json['is_locked'] == true,
    );
  }
}

