import 'package:flutter/material.dart';

class AppColors {
  // === COSMIC PURPLE THEME - Kozmik Büyücü Maskottan Türetilmiş ===
  static const bgLight = Color(0xFFF8F5FF);            // Kozmik lavanta arka plan
  static const cardLight = Color(0xFFFFFFFF);           // Beyaz kartlar
  static const surfaceLight = Color(0xFFEDE9FE);        // Yumuşak lavanta surface

  // === COSMIC ACCENT COLORS - Maskot Renk Paleti ===
  static const primaryPink = Color(0xFF7C3AED);         // Cosmic Purple (ana renk)
  static const secondaryPink = Color(0xFFA78BFA);       // Violet (ikincil)
  static const accentRose = Color(0xFFEC4899);          // Rose Pink
  static const accentPurple = Color(0xFF7C3AED);        // Cosmic Purple
  static const accentLavender = Color(0xFFC084FC);      // Purple 400
  static const accentGold = Color(0xFFF59E0B);          // Golden Star (maskot altın detay)
  static const accentCoral = Color(0xFFFB923C);         // Orange
  static const accentBlue = Color(0xFF60A5FA);          // Blue

  // === STATUS COLORS ===
  static const gold = Color(0xFFF59E0B);                // Golden Star
  static const positive = Color(0xFF10B981);            // Emerald Green
  static const negative = Color(0xFFEF4444);            // Red
  static const warning = Color(0xFFF59E0B);             // Amber (=goldenStar)

  // === BORDER COLORS ===
  static const borderLight = Color(0xFFD8B4FE);         // Purple 300 border

  // === TEXT COLORS - Kozmik Kontrast ===
  static const textPrimary = Color(0xFF1E1B4B);         // Koyu mor-lacivert
  static const textSecondary = Color(0xFF6B7280);       // Gri
  static const textTertiary = Color(0xFF9CA3AF);        // Açık gri
  static const textDark = Color(0xFF1E1B4B);            // Koyu mor-lacivert
  static const textLight = Color(0xFFFFFFFF);           // Beyaz metin
  static const textMuted = Color(0xFF9CA3AF);           // Soluk gri

  // === DARK THEME ===
  static const bgDark = Color(0xFF0F0A2E);              // Kozmik koyu
  static const cardDark = Color(0xFF1E1B4B);            // Koyu kart
  static const surfaceDark = Color(0xFF2D2B5E);         // Koyu surface
  static const borderDark = Color(0xFF4C1D95);          // Koyu mor border

  // === GRADIENT DEFINITIONS - Kozmik Gradyanlar ===
  static const pinkGradient = LinearGradient(
    colors: [Color(0xFF7C3AED), Color(0xFFA78BFA)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const purpleGradient = LinearGradient(
    colors: [Color(0xFF4C1D95), Color(0xFF7C3AED)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const roseGradient = LinearGradient(
    colors: [Color(0xFFEC4899), Color(0xFFF9A8D4)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const goldGradient = LinearGradient(
    colors: [Color(0xFFF59E0B), Color(0xFFFCD34D)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const cosmicGradient = LinearGradient(
    colors: [
      Color(0xFF4C1D95),
      Color(0xFF7C3AED),
      Color(0xFFA78BFA),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const vibrantGradient = LinearGradient(
    colors: [
      Color(0xFFF8F5FF),
      Color(0xFFEDE9FE),
      Color(0xFFE9D5FF),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // === SHIMMER COLORS ===
  static const shimmerBase = Color(0xFFE9D5FF);
  static const shimmerHighlight = Color(0xFFFFFFFF);

  // === ESKİ RENKLER (GERİYE DÖNÜK UYUMLULUK İÇİN) ===
  static const accentPink = Color(0xFFA78BFA);          // Violet (eski Hot Pink yerine)
  static const pastelLavender = Color(0xFFC084FC);
  static const blueGradient = LinearGradient(
    colors: [Color(0xFF60A5FA), Color(0xFF7C3AED)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  static const elegantGradient = LinearGradient(
    colors: [
      Color(0xFFF8F5FF),
      Color(0xFFEDE9FE),
      Color(0xFFE9D5FF),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
