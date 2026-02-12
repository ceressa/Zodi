import 'package:flutter/material.dart';
import '../services/storage_service.dart';
import '../services/firebase_service.dart';

class ThemeProvider with ChangeNotifier {
  final StorageService _storage = StorageService();
  final FirebaseService _firebaseService = FirebaseService();
  ThemeMode _themeMode = ThemeMode.dark;

  ThemeMode get themeMode => _themeMode;
  bool get isDarkMode => _themeMode == ThemeMode.dark;

  ThemeProvider() {
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final mode = await _storage.getThemeMode();
    _themeMode = mode == 'light' ? ThemeMode.light : ThemeMode.dark;
    notifyListeners();
  }

  Future<void> toggleTheme() async {
    _themeMode = _themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    await _storage.saveThemeMode(_themeMode == ThemeMode.dark ? 'dark' : 'light');
    
    // Firebase'e tema tercihini kaydet
    if (_firebaseService.isAuthenticated) {
      await _firebaseService.updateThemePreference(_themeMode == ThemeMode.dark);
    }
    
    notifyListeners();
  }
}
