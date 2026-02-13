import 'package:flutter/material.dart';

class AppColors {
  // === VIBRANT PINK THEME - Cıvıl Cıvıl ve Parlak! ===
  static const bgLight = Color(0xFFFFE4EC);           // Canlı pembe arka plan
  static const cardLight = Color(0xFFFFFFFF);         // Beyaz kartlar
  static const surfaceLight = Color(0xFFFFCCE2);      // Parlak pembe surface
  
  // === VIBRANT ACCENT COLORS - Çok Parlak ve Canlı! ===
  static const primaryPink = Color(0xFFFF1493);       // Deep Pink - çok parlak!
  static const secondaryPink = Color(0xFFFF69B4);     // Hot Pink
  static const accentRose = Color(0xFFFF1493);        // Deep Pink
  static const accentPurple = Color(0xFF9400D3);      // Dark Violet - canlı mor
  static const accentLavender = Color(0xFFBA55D3);    // Medium Orchid
  static const accentGold = Color(0xFFFFD700);        // Altın
  static const accentCoral = Color(0xFFFF6347);       // Tomato - canlı mercan
  static const accentBlue = Color(0xFF00BFFF);        // Deep Sky Blue - çok parlak mavi!
  
  // === STATUS COLORS - Canlı ve Net ===
  static const gold = Color(0xFFFFD700);              // Altın
  static const positive = Color(0xFF00FA9A);          // Medium Spring Green
  static const negative = Color(0xFFFF1493);          // Deep Pink
  static const warning = Color(0xFFFF8C00);           // Dark Orange
  
  // === BORDER COLORS - Belirgin ===
  static const borderLight = Color(0xFFFF69B4);       // Hot Pink border
  
  // === TEXT COLORS - Koyu ve Net (Yüksek Kontrast!) ===
  static const textPrimary = Color(0xFF8B008B);       // Dark Magenta - çok net!
  static const textSecondary = Color(0xFFC71585);     // Medium Violet Red
  static const textTertiary = Color(0xFFDB7093);      // Pale Violet Red
  static const textDark = Color(0xFF4B0082);          // Indigo
  static const textLight = Color(0xFFFFFFFF);         // Beyaz metin
  static const textMuted = Color(0xFFCD5C5C);         // Indian Red
  
  // === DARK THEME (KULLANILMAYACAK) ===
  static const bgDark = Color(0xFFFFE4EC);            // Aynı açık tema
  static const cardDark = Color(0xFFFFFFFF);          // Aynı açık tema
  static const surfaceDark = Color(0xFFFFCCE2);       // Aynı açık tema
  static const borderDark = Color(0xFFFF69B4);        // Aynı açık tema
  
  // === GRADIENT DEFINITIONS - Çok Parlak Gradyanlar! ===
  static const pinkGradient = LinearGradient(
    colors: [Color(0xFFFF1493), Color(0xFFFF69B4)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const purpleGradient = LinearGradient(
    colors: [Color(0xFF9400D3), Color(0xFFBA55D3)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const roseGradient = LinearGradient(
    colors: [Color(0xFFFF1493), Color(0xFFFF69B4)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const goldGradient = LinearGradient(
    colors: [Color(0xFFFFD700), Color(0xFFFFE4B5)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const cosmicGradient = LinearGradient(
    colors: [
      Color(0xFF9400D3),
      Color(0xFFFF1493),
      Color(0xFFFF69B4),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const vibrantGradient = LinearGradient(
    colors: [
      Color(0xFFFFE4EC),
      Color(0xFFFFCCE2),
      Color(0xFFFFB6C1),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  // === SHIMMER COLORS ===
  static const shimmerBase = Color(0xFFFFCCE2);
  static const shimmerHighlight = Color(0xFFFFFFFF);
  
  // === ESKI RENKLER (GERIYE DÖNÜK UYUMLULUK İÇİN) ===
  static const accentPink = Color(0xFFFF69B4);        // Hot pink
  static const pastelLavender = Color(0xFFAA7FFF);
  static const blueGradient = LinearGradient(
    colors: [Color(0xFF00BFFF), Color(0xFF9400D3)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  static const elegantGradient = LinearGradient(
    colors: [
      Color(0xFFFFE4EC),
      Color(0xFFFFCCE2),
      Color(0xFFFFB6C1),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}