import 'package:flutter/material.dart';

class AppColors {
  // Dark theme colors
  static const bgDark = Color(0xFF0A0E27);
  static const cardDark = Color(0xFF1A1F3A);
  static const surfaceDark = Color(0xFF252B48);
  
  // Light theme colors
  static const bgLight = Color(0xFFF5F7FA);
  static const cardLight = Color(0xFFFFFFFF);
  static const surfaceLight = Color(0xFFE8ECF4);
  
  // Accent colors
  static const accentPurple = Color(0xFF8B5CF6);
  static const accentBlue = Color(0xFF3B82F6);
  static const accentPink = Color(0xFFEC4899);
  static const accentCyan = Color(0xFF06B6D4);
  
  // Gradient definitions
  static const purpleGradient = LinearGradient(
    colors: [Color(0xFF8B5CF6), Color(0xFF6366F1)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const blueGradient = LinearGradient(
    colors: [Color(0xFF3B82F6), Color(0xFF06B6D4)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const pinkGradient = LinearGradient(
    colors: [Color(0xFFEC4899), Color(0xFFF97316)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const goldGradient = LinearGradient(
    colors: [Color(0xFFFBBF24), Color(0xFFF59E0B)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const cosmicGradient = LinearGradient(
    colors: [
      Color(0xFF8B5CF6),
      Color(0xFF6366F1),
      Color(0xFF3B82F6),
      Color(0xFF06B6D4),
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
  static const textPrimary = Color(0xFFFFFFFF);      // Pure white - main titles
  static const textSecondary = Color(0xFFF0F4FF);    // Almost white with purple hint - very readable
  static const textTertiary = Color(0xFFDDE4FF);     // Light purple-white - readable
  static const textDark = Color(0xFF1E1B4B);         // Deep purple-black - for light mode
  static const textLight = Color(0xFFFFFFFF);        // Pure white
  static const textMuted = Color(0xFFBDC9FF);        // Bright purple-white - NO GRAY!
  
  // Shimmer colors
  static const shimmerBase = Color(0xFF1A1F3A);
  static const shimmerHighlight = Color(0xFF252B48);
}
