import 'package:flutter/material.dart';
import '../models/streak_data.dart';
import '../constants/colors.dart';

class StreakDisplayWidget extends StatelessWidget {
  final StreakData streakData;
  final VoidCallback? onTap;

  const StreakDisplayWidget({
    super.key,
    required this.streakData,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.accentPurple.withOpacity(0.2),
              AppColors.accentBlue.withOpacity(0.2),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.accentPurple.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _getStreakColor().withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.local_fire_department,
                color: _getStreakColor(),
                size: 32,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        '${streakData.currentStreak} Gün',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : AppColors.textDark,
                        ),
                      ),
                      if (streakData.protectionActive) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.gold.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: AppColors.gold,
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.shield,
                                size: 14,
                                color: AppColors.gold,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Korumalı',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.gold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Üst üste giriş',
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark
                          ? Colors.white.withOpacity(0.7)
                          : AppColors.textDark.withOpacity(0.7),
                    ),
                  ),
                  if (streakData.longestStreak > streakData.currentStreak) ...[
                    const SizedBox(height: 8),
                    Text(
                      'En uzun: ${streakData.longestStreak} gün 🏆',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark
                            ? Colors.white.withOpacity(0.5)
                            : AppColors.textDark.withOpacity(0.5),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: isDark
                  ? Colors.white.withOpacity(0.5)
                  : AppColors.textDark.withOpacity(0.5),
            ),
          ],
        ),
      ),
    );
  }

  Color _getStreakColor() {
    if (streakData.currentStreak == 0) {
      return Colors.grey;
    } else if (streakData.currentStreak < 7) {
      return AppColors.warning;
    } else if (streakData.currentStreak < 30) {
      return AppColors.accentPurple;
    } else {
      return AppColors.gold;
    }
  }
}
