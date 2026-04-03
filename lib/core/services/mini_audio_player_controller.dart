import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

import '../../models/story.dart';
import 'global_audio_player_service.dart';

class MiniAudioPlayerController extends ChangeNotifier {
  final GlobalAudioPlayerService _audio = GlobalAudioPlayerService.instance;
  StreamSubscription<PlayerState>? _playerStateSub;

  MiniAudioPlayerController() {
    _playerStateSub = _audio.player.onPlayerStateChanged.listen((_) {
      notifyListeners();
    });
  }

  bool _visible = false;
  Story? _story;
  Offset _position = const Offset(16, 120);
  Future<void> Function()? _onPreviousChapter;
  Future<void> Function()? _onNextChapter;
  VoidCallback? _onOpenFullPlayer;

  bool get visible => _visible;
  Story? get story => _story;
  Offset get position => _position;
  bool get isPlaying => _audio.player.state == PlayerState.playing;
  bool get canGoPrevious => _onPreviousChapter != null;
  bool get canGoNext => _onNextChapter != null;

  void showForStory(Story story) {
    _story = story;
    _visible = true;
    notifyListeners();
  }

  void bindChapterControls({
    Future<void> Function()? onPreviousChapter,
    Future<void> Function()? onNextChapter,
    VoidCallback? onOpenFullPlayer,
  }) {
    _onPreviousChapter = onPreviousChapter;
    _onNextChapter = onNextChapter;
    _onOpenFullPlayer = onOpenFullPlayer;
    notifyListeners();
  }

  void hideOverlay() {
    if (!_visible) return;
    _visible = false;
    notifyListeners();
  }

  Future<void> stopAndHide() async {
    await _audio.stop();
    _visible = false;
    _story = null;
    notifyListeners();
  }

  Future<void> togglePlayPause() async {
    await _audio.togglePlayPause();
    notifyListeners();
  }

  Future<void> previousChapter() async {
    final handler = _onPreviousChapter;
    if (handler == null) return;
    await handler();
  }

  Future<void> nextChapter() async {
    final handler = _onNextChapter;
    if (handler == null) return;
    await handler();
  }

  void openFullPlayer() {
    final handler = _onOpenFullPlayer;
    if (handler == null) return;
    handler();
  }

  void updatePosition(Offset next) {
    _position = next;
    notifyListeners();
  }

  @override
  void dispose() {
    _playerStateSub?.cancel();
    super.dispose();
  }
}
