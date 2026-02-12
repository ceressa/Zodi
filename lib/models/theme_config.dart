import 'package:flutter/material.dart';

enum AnimationType {
  none,
  particles,
  gradient,
  constellation,
  zodiacSymbol,
}

class ThemeConfig {
  final String zodiacSign;
  final ColorScheme colorScheme;
  final AnimationType backgroundAnimation;
  final String? fontFamily;
  final bool darkMode;

  ThemeConfig({
    required this.zodiacSign,
    required this.colorScheme,
    this.backgroundAnimation = AnimationType.none,
    this.fontFamily,
    required this.darkMode,
  });

  factory ThemeConfig.fromJson(Map<String, dynamic> json) {
    return ThemeConfig(
      zodiacSign: json['zodiacSign'] ?? 'aries',
      colorScheme: ColorScheme.fromSeed(
        seedColor: Color(int.parse(json['primaryColor'] ?? '0xFFE74C3C')),
        brightness: json['darkMode'] == true ? Brightness.dark : Brightness.light,
      ),
      backgroundAnimation: AnimationType.values.firstWhere(
        (e) => e.name == json['backgroundAnimation'],
        orElse: () => AnimationType.none,
      ),
      fontFamily: json['fontFamily'],
      darkMode: json['darkMode'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'zodiacSign': zodiacSign,
      'primaryColor': '0x${colorScheme.primary.value.toRadixString(16).padLeft(8, '0')}',
      'backgroundAnimation': backgroundAnimation.name,
      'fontFamily': fontFamily,
      'darkMode': darkMode,
    };
  }

  ThemeConfig copyWith({
    String? zodiacSign,
    ColorScheme? colorScheme,
    AnimationType? backgroundAnimation,
    String? fontFamily,
    bool? darkMode,
  }) {
    return ThemeConfig(
      zodiacSign: zodiacSign ?? this.zodiacSign,
      colorScheme: colorScheme ?? this.colorScheme,
      backgroundAnimation: backgroundAnimation ?? this.backgroundAnimation,
      fontFamily: fontFamily ?? this.fontFamily,
      darkMode: darkMode ?? this.darkMode,
    );
  }
}

class ZodiacColorScheme {
  final Color primary;
  final Color secondary;
  final Color accent;
  final String name;
  final String description;

  const ZodiacColorScheme({
    required this.primary,
    required this.secondary,
    required this.accent,
    required this.name,
    required this.description,
  });
}
