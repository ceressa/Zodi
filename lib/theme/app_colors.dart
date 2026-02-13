import 'package:flutter/material.dart';

class AppColors {
  // Arka plan gradientleri
  static const violet100 = Color(0xFFEDE9FE);
  static const fuchsia50 = Color(0xFFFDF4FF);
  static const cyan100 = Color(0xFFCFFAFE);
  
  // Ana renkler - Purple/Violet
  static const purple600 = Color(0xFF9333EA);
  static const purple500 = Color(0xFFA855F7);
  static const purple400 = Color(0xFFC084FC);
  static const purple300 = Color(0xFFD8B4FE);
  static const purple200 = Color(0xFFE9D5FF);
  static const purple100 = Color(0xFFF3E8FF);
  static const purple800 = Color(0xFF6B21A8);
  
  static const violet600 = Color(0xFF7C3AED);
  static const violet500 = Color(0xFF8B5CF6);
  static const violet400 = Color(0xFFA78BFA);
  
  // Fuchsia/Pink
  static const fuchsia600 = Color(0xFFC026D3);
  static const fuchsia500 = Color(0xFFD946EF);
  static const fuchsia400 = Color(0xFFE879F9);
  
  static const pink400 = Color(0xFFF472B6);
  static const pink300 = Color(0xFFF9A8D4);
  static const pink200 = Color(0xFFFBCFE8);
  static const pink100 = Color(0xFFFCE7F3);
  
  static const rose400 = Color(0xFFFB7185);
  
  // Blue/Cyan
  static const cyan400 = Color(0xFF22D3EE);
  static const cyan300 = Color(0xFF67E8F9);
  static const blue400 = Color(0xFF60A5FA);
  static const indigo400 = Color(0xFF818CF8);
  
  // Green/Teal
  static const emerald400 = Color(0xFF34D399);
  static const green400 = Color(0xFF4ADE80);
  static const teal400 = Color(0xFF2DD4BF);
  static const teal300 = Color(0xFF5EEAD4);
  
  // Yellow/Orange
  static const yellow400 = Color(0xFFFACC15);
  static const yellow300 = Color(0xFFFDE047);
  static const yellow200 = Color(0xFFFEF08A);
  static const yellow500 = Color(0xFFEAB308);
  static const amber400 = Color(0xFFFBBF24);
  static const amber300 = Color(0xFFFCD34D);
  static const orange400 = Color(0xFFFB923C);
  static const orange200 = Color(0xFFFED7AA);
  
  // Red
  static const red400 = Color(0xFFF87171);
  static const red500 = Color(0xFFEF4444);
  
  // Lime
  static const lime300 = Color(0xFFBEF264);
  static const lime400 = Color(0xFFA3E635);
  
  // Gray
  static const gray400 = Color(0xFF9CA3AF);
  static const gray600 = Color(0xFF4B5563);
  static const gray700 = Color(0xFF374151);
  
  // Gradients
  static const backgroundGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [violet100, fuchsia50, cyan100],
  );
  
  static const purpleGradient = LinearGradient(
    colors: [purple400, fuchsia400],
  );
  
  static const pinkGradient = LinearGradient(
    colors: [pink400, rose400, red400],
  );
  
  static const blueGradient = LinearGradient(
    colors: [cyan400, blue400, indigo400],
  );
  
  static const greenGradient = LinearGradient(
    colors: [emerald400, green400, teal400],
  );
  
  static const goldGradient = LinearGradient(
    colors: [yellow400, amber400, orange400],
  );
}
