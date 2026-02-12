import 'package:flutter/material.dart';
import '../models/theme_config.dart';
import '../constants/colors.dart';
import 'firebase_service.dart';
import 'storage_service.dart';

class ThemeService {
  static final ThemeService _instance = ThemeService._internal();
  factory ThemeService() => _instance;
  ThemeService._internal();

  final FirebaseService _firebaseService = FirebaseService();
  final StorageService _storageService = StorageService();

  // Zodiac-specific color schemes
  static const Map<String, ZodiacColorScheme> zodiacColors = {
    'aries': ZodiacColorScheme(
      primary: Color(0xFFE74C3C),
      secondary: Color(0xFFFF6B6B),
      accent: Color(0xFFFFD93D),
      name: 'Koç',
      description: 'Ateşli ve enerjik',
    ),
    'taurus': ZodiacColorScheme(
      primary: Color(0xFF27AE60),
      secondary: Color(0xFF6BCF7F),
      accent: Color(0xFFFFE66D),
      name: 'Boğa',
      description: 'Doğal ve sakin',
    ),
    'gemini': ZodiacColorScheme(
      primary: Color(0xFFF39C12),
      secondary: Color(0xFFFFB84D),
      accent: Color(0xFFFFE082),
      name: 'İkizler',
      description: 'Canlı ve dinamik',
    ),
    'cancer': ZodiacColorScheme(
      primary: Color(0xFF3498DB),
      secondary: Color(0xFF5DADE2),
      accent: Color(0xFFAED6F1),
      name: 'Yengeç',
      description: 'Duygusal ve koruyucu',
    ),
    'leo': ZodiacColorScheme(
      primary: Color(0xFFE67E22),
      secondary: Color(0xFFF39C12),
      accent: Color(0xFFFFD700),
      name: 'Aslan',
      description: 'Görkemli ve parlak',
    ),
    'virgo': ZodiacColorScheme(
      primary: Color(0xFF16A085),
      secondary: Color(0xFF1ABC9C),
      accent: Color(0xFF7DCEA0),
      name: 'Başak',
      description: 'Temiz ve düzenli',
    ),
    'libra': ZodiacColorScheme(
      primary: Color(0xFF9B59B6),
      secondary: Color(0xFFBB8FCE),
      accent: Color(0xFFE8DAEF),
      name: 'Terazi',
      description: 'Dengeli ve zarif',
    ),
    'scorpio': ZodiacColorScheme(
      primary: Color(0xFF8E44AD),
      secondary: Color(0xFF9B59B6),
      accent: Color(0xFFD7BDE2),
      name: 'Akrep',
      description: 'Gizemli ve güçlü',
    ),
    'sagittarius': ZodiacColorScheme(
      primary: Color(0xFFE74C3C),
      secondary: Color(0xFFEC7063),
      accent: Color(0xFFF1948A),
      name: 'Yay',
      description: 'Özgür ve maceracı',
    ),
    'capricorn': ZodiacColorScheme(
      primary: Color(0xFF34495E),
      secondary: Color(0xFF5D6D7E),
      accent: Color(0xFFAEB6BF),
      name: 'Oğlak',
      description: 'Ciddi ve kararlı',
    ),
    'aquarius': ZodiacColorScheme(
      primary: Color(0xFF3498DB),
      secondary: Color(0xFF5DADE2),
      accent: Color(0xFF85C1E2),
      name: 'Kova',
      description: 'Yenilikçi ve özgün',
    ),
    'pisces': ZodiacColorScheme(
      primary: Color(0xFF9B59B6),
      secondary: Color(0xFFBB8FCE),
      accent: Color(0xFFD7BDE2),
      name: 'Balık',
      description: 'Rüyacı ve sezgisel',
    ),
  };

  /// Get zodiac-themed color scheme
  ZodiacColorScheme getZodiacColors(String zodiacSign) {
    final key = zodiacSign.toLowerCase();
    return zodiacColors[key] ?? zodiacColors['aries']!;
  }

  /// Get ThemeData for a zodiac sign
  ThemeData getZodiacTheme(String zodiacSign, bool isDark) {
    final colors = getZodiacColors(zodiacSign);
    
    return ThemeData(
      useMaterial3: true,
      brightness: isDark ? Brightness.dark : Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: colors.primary,
        brightness: isDark ? Brightness.dark : Brightness.light,
        primary: colors.primary,
        secondary: colors.secondary,
      ),
      scaffoldBackgroundColor: isDark ? AppColors.bgDark : AppColors.bgLight,
      cardColor: isDark ? AppColors.cardDark : AppColors.cardLight,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(
          color: isDark ? Colors.white : AppColors.textDark,
        ),
      ),
    );
  }

  /// Apply theme configuration
  Future<void> applyTheme(String userId, ThemeConfig config) async {
    try {
      // Save to Firebase
      await _firebaseService.updateCustomFields({
        'preferences.theme': config.zodiacSign,
        'preferences.animatedBackground': config.backgroundAnimation.name,
        'preferences.customFont': config.fontFamily,
      });

      // Save to local storage
      await _storageService.saveString('theme_config', config.toJson().toString());
    } catch (e) {
      print('Error applying theme: $e');
    }
  }

  /// Enable animated background (Premium feature)
  Future<void> enableAnimatedBackground(String userId, AnimationType type) async {
    try {
      await _firebaseService.updateCustomFields({
        'preferences.animatedBackground': type.name,
      });

      await _storageService.saveString('animated_background', type.name);
    } catch (e) {
      print('Error enabling animated background: $e');
    }
  }

  /// Set custom font (VIP feature)
  Future<void> setCustomFont(String userId, String fontFamily) async {
    try {
      await _firebaseService.updateCustomFields({
        'preferences.customFont': fontFamily,
      });

      await _storageService.saveString('custom_font', fontFamily);
    } catch (e) {
      print('Error setting custom font: $e');
    }
  }

  /// Get user's theme configuration
  Future<ThemeConfig?> getUserTheme(String userId) async {
    try {
      final userData = await _firebaseService.getUserProfile();
      
      if (userData == null) return null;

      final preferences = userData.preferences;
      if (preferences == null) return null;

      final zodiacSign = preferences['theme'] as String? ?? 'aries';
      final animationType = preferences['animatedBackground'] as String?;
      final fontFamily = preferences['customFont'] as String?;
      final darkMode = preferences['darkMode'] as bool? ?? false;

      final colors = getZodiacColors(zodiacSign);

      return ThemeConfig(
        zodiacSign: zodiacSign,
        colorScheme: ColorScheme.fromSeed(
          seedColor: colors.primary,
          brightness: darkMode ? Brightness.dark : Brightness.light,
        ),
        backgroundAnimation: animationType != null
            ? AnimationType.values.firstWhere(
                (e) => e.name == animationType,
                orElse: () => AnimationType.none,
              )
            : AnimationType.none,
        fontFamily: fontFamily,
        darkMode: darkMode,
      );
    } catch (e) {
      print('Error getting user theme: $e');
      return null;
    }
  }

  /// Get gradient for zodiac sign
  LinearGradient getZodiacGradient(String zodiacSign) {
    final colors = getZodiacColors(zodiacSign);
    
    return LinearGradient(
      colors: [
        colors.primary,
        colors.secondary,
      ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }

  /// Get all available zodiac themes
  List<Map<String, dynamic>> getAllZodiacThemes() {
    return zodiacColors.entries.map((entry) {
      return {
        'key': entry.key,
        'name': entry.value.name,
        'description': entry.value.description,
        'colors': entry.value,
      };
    }).toList();
  }
}
