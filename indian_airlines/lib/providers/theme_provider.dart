import 'package:flutter/material.dart';
import '../data/local_storage.dart';

/// Provider managing Dark/Light theme mode state and persistence
class ThemeProvider extends ChangeNotifier {
  bool _isDarkMode = false;

  ThemeProvider() {
    _isDarkMode = LocalStorage.getDarkMode();
  }

  bool get isDarkMode => _isDarkMode;
  ThemeMode get themeMode => _isDarkMode ? ThemeMode.dark : ThemeMode.light;

  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    LocalStorage.setDarkMode(_isDarkMode);
    notifyListeners();
  }

  void setDarkMode(bool value) {
    if (_isDarkMode != value) {
      _isDarkMode = value;
      LocalStorage.setDarkMode(_isDarkMode);
      notifyListeners();
    }
  }
}
