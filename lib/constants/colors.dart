import 'package:flutter/material.dart';

class AppColors {
  // Dark theme colors
  static const bgDark = Color(0xFF1B1F3B);
  static const cardDark = Color(0xFF252A4C);
  static const surfaceDark = Color(0xFF30375C);

  // Light theme colors
  static const bgLight = Color(0xFFFDF9FF);
  static const cardLight = Color(0xFFFFFDFF);
  static const surfaceLight = Color(0xFFF2EEFF);

  // Accent colors
  static const accentPurple = Color(0xFFA78BFA);
  static const accentBlue = Color(0xFF93C5FD);
  static const accentPink = Color(0xFFF9A8D4);
  static const accentCyan = Color(0xFF99F6E4);

  // Gradient definitions
  static const purpleGradient = LinearGradient(
    colors: [Color(0xFFB9A4FF), Color(0xFF9FA8FF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const blueGradient = LinearGradient(
    colors: [Color(0xFFA5B4FC), Color(0xFF93C5FD)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const pinkGradient = LinearGradient(
    colors: [Color(0xFFF9A8D4), Color(0xFFFBCFE8)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const goldGradient = LinearGradient(
    colors: [Color(0xFFFDE68A), Color(0xFFFCD34D)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const cosmicGradient = LinearGradient(
    colors: [
      Color(0xFFC4B5FD),
      Color(0xFFA5B4FC),
      Color(0xFFBFDBFE),
      Color(0xFFBAE6FD),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const homePastelLightGradient = LinearGradient(
    colors: [
      Color(0xFFF7F3FF),
      Color(0xFFF1F8FF),
      Color(0xFFECFEFF),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const homePastelDarkGradient = LinearGradient(
    colors: [
      Color(0xFF141B36),
      Color(0xFF1B2347),
      Color(0xFF1A2C4A),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Status colors
  static const gold = Color(0xFFFBBF24);
  static const positive = Color(0xFF10B981);
  static const negative = Color(0xFFEF4444);
  static const warning = Color(0xFFF59E0B);

  // Border colors
  static const borderDark = Color(0xFF252B48);
  static const borderLight = Color(0xFFE8ECF4);

  // Text colors - VIBRANT & READABLE!
  static const textPrimary = Color(0xFFFFFFFF); // Pure white - main titles
  static const textSecondary =
      Color(0xFFF0F4FF); // Almost white with purple hint - very readable
  static const textTertiary =
      Color(0xFFDDE4FF); // Light purple-white - readable
  static const textDark =
      Color(0xFF1E1B4B); // Deep purple-black - for light mode
  static const textLight = Color(0xFFFFFFFF); // Pure white
  static const textMuted = Color(0xFF7E7AA3); // Bright purple-white - NO GRAY!

  // Shimmer colors
  static const shimmerBase = Color(0xFF1A1F3A);
  static const shimmerHighlight = Color(0xFF252B48);
}
