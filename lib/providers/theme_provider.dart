import 'package:flutter/material.dart';

/// Tema sağlayıcı — uygulama sadece Light Mode destekler.
class ThemeProvider with ChangeNotifier {
  ThemeMode get themeMode => ThemeMode.light;
  bool get isDarkMode => false;
}
