import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
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
  bool _isPlaying = false;
  double _currentPosition = 0.0;
  final double _totalDuration = 100.0;
  double _playbackSpeed = 1.0;
  bool _isDownloaded = false;

  @override
  void initState() {
    super.initState();
    
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
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _playPauseController.dispose();
    super.dispose();
  }

  void _togglePlayPause() {
    setState(() {
      _isPlaying = !_isPlaying;
      if (_isPlaying) {
        _rotationController.repeat();
        _playPauseController.forward();
      } else {
        _rotationController.stop();
        _playPauseController.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        width: size.width,
        height: size.height,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.sunsetOrange.withOpacity(0.3),
              AppColors.savannaGreen.withOpacity(0.3),
              AppColors.clayPurple.withOpacity(0.2),
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
                  color: AppColors.backgroundLight.withOpacity(0.7),
                ),
              ),
            ),

            // Main content
            SafeArea(
              child: Column(
                children: [
                  // App bar
                  Padding(
                    padding: const EdgeInsets.all(AppConstants.paddingMedium),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        NeumorphicIconButton(
                          icon: Icons.keyboard_arrow_down,
                          size: 50,
                          onPressed: () => context.pop(),
                        ),
                        Text(
                          'Sikiliza Hadithi',
                          style: (Theme.of(context).textTheme.titleLarge ?? const TextStyle(fontSize: 20)).copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                        NeumorphicIconButton(
                          icon: Icons.more_vert,
                          size: 50,
                          onPressed: () {
                            // Show options
                          },
                        ),
                      ],
                    ),
                  ),

                  const Spacer(),

                  // Rotating book cover (Hero animation)
                  Hero(
                    tag: 'story_cover_${widget.story.id}',
                    child: RotationTransition(
                      turns: _rotationController,
                      child: Container(
                        width: 280,
                        height: 280,
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
                              width: 240,
                              height: 240,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppColors.cardBackground,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
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

                  const Spacer(),

                  // Story info
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppConstants.paddingLarge),
                    child: Column(
                      children: [
                        Text(
                          widget.story.title,
                          style: (Theme.of(context).textTheme.headlineMedium ?? const TextStyle(fontSize: 24)).copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          widget.story.author,
                          style: (Theme.of(context).textTheme.bodyLarge ?? const TextStyle(fontSize: 16)).copyWith(
                                color: AppColors.textSecondary,
                              ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 40),

                  // Progress slider with glassmorphism
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppConstants.paddingLarge),
                    child: Column(
                      children: [
                        GlassmorphicContainer(
                          height: 8,
                          borderRadius: 4,
                          blur: 8,
                          color: AppColors.glassWhite.withOpacity(0.3),
                          borderColor: AppColors.glassBorder.withOpacity(0.5),
                          borderWidth: 1,
                          padding: EdgeInsets.zero,
                          child: Stack(
                            children: [
                              FractionallySizedBox(
                                widthFactor: _currentPosition / _totalDuration,
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
                            Text(
                              _formatDuration(_currentPosition),
                              style: (Theme.of(context).textTheme.bodySmall ?? const TextStyle(fontSize: 12)).copyWith(
                                    color: AppColors.textMuted,
                                  ),
                            ),
                            Text(
                              _formatDuration(_totalDuration),
                              style: (Theme.of(context).textTheme.bodySmall ?? const TextStyle(fontSize: 12)).copyWith(
                                    color: AppColors.textMuted,
                                  ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 40),

                  // Neumorphic control bar
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppConstants.paddingMedium),
                    child: NeumorphicCard(
                      borderRadius: 40,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          // Previous button
                          _buildControlButton(
                            Icons.skip_previous_rounded,
                            50,
                            () {
                              // Previous track
                            },
                          ),

                          // Rewind button
                          _buildControlButton(
                            Icons.replay_10_rounded,
                            45,
                            () {
                              // Rewind 10 seconds
                            },
                          ),

                          // Play/Pause button (larger)
                          GestureDetector(
                            onTap: _togglePlayPause,
                            child: Container(
                              width: 70,
                              height: 70,
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
                                size: 36,
                                color: Colors.white,
                              ),
                            ),
                          ),

                          // Forward button
                          _buildControlButton(
                            Icons.forward_10_rounded,
                            45,
                            () {
                              // Forward 10 seconds
                            },
                          ),

                          // Next button
                          _buildControlButton(
                            Icons.skip_next_rounded,
                            50,
                            () {
                              // Next track
                            },
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),

                  // Additional controls
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppConstants.paddingLarge),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildSecondaryControl(Icons.playlist_play, 'Playlist', () {}),
                        _buildSecondaryControl(Icons.speed, '${_playbackSpeed}x', _showSpeedDialog),
                        _buildSecondaryControl(
                          _isDownloaded ? Icons.download_done : Icons.download_outlined,
                          _isDownloaded ? 'Imehifadhiwa' : 'Pakua',
                          _toggleDownload,
                        ),
                        _buildSecondaryControl(Icons.share_outlined, 'Shiriki', () {}),
                      ],
                    ),
                  ),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  void _showSpeedDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Chagua Kasi ya Usikilizaji', style: TextStyle(fontSize: 16)),
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
              title: Text(
                '${speed}x',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  color: isSelected ? AppColors.sunsetOrange : AppColors.textPrimary,
                ),
              ),
              onTap: () {
                setState(() {
                  _playbackSpeed = speed;
                });
                Navigator.pop(context);
              },
            );
          }).toList(),
        ),
      ),
    );
  }
  
  void _toggleDownload() {
    setState(() {
      _isDownloaded = !_isDownloaded;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_isDownloaded ? 'Hadithi imehifadhiwa kwa usikilizaji nje ya mtandao' : 'Upakuaji umeghairiwa'),
        backgroundColor: _isDownloaded ? AppColors.success : AppColors.textMuted,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Widget _buildControlButton(IconData icon, double size, VoidCallback onPressed) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.cardBackground,
          boxShadow: [
            const BoxShadow(
              color: AppColors.neuShadowLight,
              offset: Offset(-3, -3),
              blurRadius: 6,
            ),
            BoxShadow(
              color: AppColors.neuShadowDark.withOpacity(0.3),
              offset: const Offset(3, 3),
              blurRadius: 6,
            ),
          ],
        ),
        child: Icon(
          icon,
          size: size * 0.5,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }

  Widget _buildSecondaryControl(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Icon(icon, size: 24, color: AppColors.textSecondary),
          const SizedBox(height: 4),
          Text(
            label,
            style: (Theme.of(context).textTheme.bodySmall ?? const TextStyle(fontSize: 12)).copyWith(
                  color: AppColors.textMuted,
                ),
          ),
        ],
      ),
    );
  }

  String _formatDuration(double seconds) {
    final minutes = (seconds / 60).floor();
    final secs = (seconds % 60).floor();
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }
}
