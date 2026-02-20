import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import 'zodi_logo.dart';

class AppHeader extends StatelessWidget {
  final int streakCount;
  final int coinCount;
  final String? zodiacSymbol;
  final String? userName;

  const AppHeader({
    super.key,
    this.streakCount = 0,
    this.coinCount = 0,
    this.zodiacSymbol,
    this.userName,
  });

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 6) return 'İyi geceler';
    if (hour < 12) return 'Günaydın';
    if (hour < 18) return 'İyi günler';
    return 'İyi akşamlar';
  }

  @override
  Widget build(BuildContext context) {
    final firstName = (userName ?? '').split(' ').first;

    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Row(
          children: [
            // ─── Logo with gradient ring ───
            Container(
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF7C3AED), Color(0xFFDB2777), Color(0xFFF59E0B)],
                ),
              ),
              child: const ZodiLogo(size: 42),
            ),

            const SizedBox(width: 12),

            // ─── Center: Greeting + Name + Zodiac ───
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _getGreeting(),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey.shade500,
                    ),
                  ),
                  Row(
                    children: [
                      if (firstName.isNotEmpty)
                        Flexible(
                          child: Text(
                            firstName,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF1E1B4B),
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      if (zodiacSymbol != null) ...[
                        const SizedBox(width: 6),
                        Text(
                          zodiacSymbol!,
                          style: const TextStyle(fontSize: 16),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),

            // ─── Right: Streak + Coins pills ───
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Streak pill
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    gradient: const LinearGradient(
                      colors: [AppColors.orange200, AppColors.pink200],
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.local_fire_department,
                        size: 16,
                        color: Colors.orange.shade700,
                      ),
                      const SizedBox(width: 3),
                      Text(
                        '$streakCount',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 6),
                // Coin pill
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    gradient: const LinearGradient(
                      colors: [AppColors.yellow300, AppColors.amber400],
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.monetization_on,
                        size: 15,
                        color: Color(0xFFB45309),
                      ),
                      const SizedBox(width: 3),
                      Text(
                        coinCount >= 1000
                            ? '${(coinCount / 1000).toStringAsFixed(1)}K'
                            : '$coinCount',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFFB45309),
                        ),
                      ),
                    ],
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
