import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import 'zodi_logo.dart';

class AppHeader extends StatelessWidget {
  final int streakCount;
  final int coinCount;
  
  const AppHeader({
    super.key,
    this.streakCount = 0,
    this.coinCount = 0,
  });
  
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const ZodiLogo(size: 40),
            Row(
              children: [
                // Streak butonu
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: const LinearGradient(
                      colors: [AppColors.orange200, AppColors.pink200],
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.local_fire_department,
                        size: 20,
                        color: Colors.orange.shade700,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '$streakCount',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                // Coins butonu
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [AppColors.yellow300, AppColors.amber400],
                    ),
                  ),
                  child: const Icon(
                    Icons.monetization_on,
                    size: 24,
                    color: Color(0xFFB45309),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
