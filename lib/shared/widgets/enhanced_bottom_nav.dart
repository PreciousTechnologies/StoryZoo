import 'dart:ui';
import 'package:flutter/material.dart';
import 'app_text.dart';
import '../../core/constants/app_colors.dart';

class EnhancedBottomNav extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;
  final bool isAuthor;

  const EnhancedBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.isAuthor = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final navShadowColor = isDark ? Colors.black.withOpacity(0.35) : Colors.black.withOpacity(0.1);
    final navSurfaceColor = isDark ? const Color(0xCC2F2118) : Colors.white.withOpacity(0.85);
    final navBorderColor = isDark ? const Color(0x66FFFFFF) : Colors.white.withOpacity(0.3);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      height: 60,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: navShadowColor,
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: Container(
            decoration: BoxDecoration(
              color: navSurfaceColor,
              borderRadius: BorderRadius.circular(30),
              border: Border.all(
                color: navBorderColor,
                width: 1.5,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(
                  icon: Icons.home_rounded,
                  label: 'Mwanzo',
                  index: 0,
                  isActive: currentIndex == 0,
                  isDark: isDark,
                ),
                _buildNavItem(
                  icon: Icons.explore_rounded,
                  label: 'Gundua',
                  index: 1,
                  isActive: currentIndex == 1,
                  isDark: isDark,
                ),
                _buildNavItem(
                  icon: Icons.favorite_rounded,
                  label: 'Maktaba',
                  index: 2,
                  isActive: currentIndex == 2,
                  isDark: isDark,
                ),
                if (isAuthor)
                  _buildNavItem(
                    icon: Icons.dashboard_rounded,
                    label: 'Dashibodi',
                    index: 4,
                    isActive: currentIndex == 4,
                    isDark: isDark,
                  ),
                _buildNavItem(
                  icon: Icons.person_rounded,
                  label: 'Wasifu',
                  index: 3,
                  isActive: currentIndex == 3,
                  isDark: isDark,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required int index,
    required bool isActive,
    required bool isDark,
  }) {
    return GestureDetector(
      onTap: () => onTap(index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        padding: EdgeInsets.symmetric(
          horizontal: isActive ? 16 : 10,
          vertical: 6,
        ),
        decoration: BoxDecoration(
          gradient: isActive
              ? LinearGradient(
                  colors: [
                    AppColors.sunsetOrange,
                    AppColors.deepOrange,
                  ],
                )
              : null,
          borderRadius: BorderRadius.circular(20),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: AppColors.sunsetOrange.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isActive ? Colors.white : (isDark ? Colors.white70 : AppColors.textMuted),
              size: isActive ? 22 : 20,
            ),
            if (isActive) ...[
              const SizedBox(width: 6),
              AppText(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

