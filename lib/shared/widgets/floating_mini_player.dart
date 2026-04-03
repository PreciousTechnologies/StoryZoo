import 'package:flutter/material.dart';
import '../../shared/widgets/app_text.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/services/mini_audio_player_controller.dart';

class FloatingMiniPlayer extends StatelessWidget {
  const FloatingMiniPlayer({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<MiniAudioPlayerController>(
      builder: (context, mini, _) {
        if (!mini.visible || mini.story == null) {
          return const SizedBox.shrink();
        }

        final size = MediaQuery.of(context).size;
        final isTablet = size.shortestSide >= 600;
        final width = isTablet ? 380.0 : (size.width - 28).clamp(280.0, 420.0);

        final maxX = (size.width - width).clamp(0.0, double.infinity);
        final maxY = (size.height - (isTablet ? 96.0 : 88.0)).clamp(80.0, double.infinity);
        final current = mini.position;
        final clamped = Offset(
          current.dx.clamp(0.0, maxX),
          current.dy.clamp(80.0, maxY),
        );

        if (clamped != current) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            mini.updatePosition(clamped);
          });
        }

        return Positioned(
          left: clamped.dx,
          top: clamped.dy,
          child: GestureDetector(
            onPanUpdate: (details) {
              final next = Offset(clamped.dx + details.delta.dx, clamped.dy + details.delta.dy);
              mini.updatePosition(
                Offset(
                  next.dx.clamp(0.0, maxX),
                  next.dy.clamp(80.0, maxY),
                ),
              );
            },
            onTap: () {
              mini.openFullPlayer();
            },
            child: Material(
              color: Colors.transparent,
              child: Container(
                width: width,
                padding: EdgeInsets.symmetric(horizontal: isTablet ? 14 : 12, vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xEE2F2118),
                  borderRadius: BorderRadius.circular(isTablet ? 20 : 18),
                  border: Border.all(color: AppColors.sunsetOrange.withOpacity(0.35)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.28),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: isTablet ? 44 : 40,
                      height: isTablet ? 44 : 40,
                      decoration: const BoxDecoration(
                        color: AppColors.sunsetOrange,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.headphones, color: Colors.white, size: 20),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          AppText(
                            mini.story!.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: isTablet ? 14 : 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          AppText(
                            mini.story!.author,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: isTablet ? 12 : 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: mini.canGoPrevious ? mini.previousChapter : null,
                      icon: Icon(
                        Icons.skip_previous_rounded,
                        color: mini.canGoPrevious ? Colors.white : Colors.white30,
                        size: isTablet ? 26 : 24,
                      ),
                    ),
                    IconButton(
                      onPressed: mini.togglePlayPause,
                      icon: Icon(
                        mini.isPlaying ? Icons.pause_circle_filled : Icons.play_circle_fill,
                        color: Colors.white,
                        size: isTablet ? 30 : 28,
                      ),
                    ),
                    IconButton(
                      onPressed: mini.canGoNext ? mini.nextChapter : null,
                      icon: Icon(
                        Icons.skip_next_rounded,
                        color: mini.canGoNext ? Colors.white : Colors.white30,
                        size: isTablet ? 26 : 24,
                      ),
                    ),
                    IconButton(
                      onPressed: mini.stopAndHide,
                      icon: Icon(Icons.close, color: Colors.white70, size: isTablet ? 24 : 22),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
