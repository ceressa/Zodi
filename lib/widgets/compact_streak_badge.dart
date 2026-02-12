import 'package:flutter/material.dart';
import '../models/streak_data.dart';
import '../constants/colors.dart';

class CompactStreakBadge extends StatelessWidget {
  final StreakData streakData;
  final VoidCallback? onTap;

  const CompactStreakBadge({
    super.key,
    required this.streakData,
    this.onTap,
  });

  Color _getStreakColor() {
    if (streakData.currentStreak >= 30) return AppColors.gold;
    if (streakData.currentStreak >= 7) return AppColors.accentPurple;
    return AppColors.accentBlue;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              _getStreakColor().withOpacity(0.2),
              _getStreakColor().withOpacity(0.1),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: _getStreakColor().withOpacity(0.3),
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.local_fire_department,
              color: _getStreakColor(),
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              '${streakData.currentStreak} Gün',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: _getStreakColor(),
              ),
            ),
            if (streakData.protectionActive) ...[
              const SizedBox(width: 6),
              Icon(
                Icons.shield,
                size: 16,
                color: AppColors.gold,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
