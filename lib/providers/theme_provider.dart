import 'package:flutter/material.dart';
import '../services/storage_service.dart';

class ThemeProvider extends ChangeNotifier {
  final StorageService _storageService;
  late bool _isDarkMode;

  ThemeProvider(this._storageService) {
    _isDarkMode = _storageService.loadIsDarkMode();
  }

  bool get isDarkMode => _isDarkMode;

  ThemeMode get themeMode => _isDarkMode ? ThemeMode.dark : ThemeMode.light;

  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    _storageService.saveIsDarkMode(_isDarkMode);
    notifyListeners();
  }

  void setTheme(bool isDark) {
    if (_isDarkMode == isDark) return;
    _isDarkMode = isDark;
    _storageService.saveIsDarkMode(_isDarkMode);
    notifyListeners();
  }

  // Soothing Theme Palette
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: const Color(0xFF121418), // Deep calm slate
      colorScheme: const ColorScheme.dark(
        primary: Color(0xFF818CF8), // Soft Indigo Accent
        secondary: Color(0xFF34D399), // Soothing Emerald Accent
        surface: Color(0xFF1E222A),
        onSurface: Color(0xFFF3F4F6),
        onPrimary: Colors.white,
      ),
      cardColor: const Color(0xFF1E222A),
      fontFamily: 'Roboto',
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF121418),
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: Color(0xFFF3F4F6),
          fontSize: 20,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: const Color(0xFFF8FAFC), // Soft off-white
      colorScheme: const ColorScheme.light(
        primary: Color(0xFF6366F1), // Clean Indigo
        secondary: Color(0xFF10B981), // Soothing Emerald
        surface: Colors.white,
        onSurface: Color(0xFF1F2937),
        onPrimary: Colors.white,
      ),
      cardColor: Colors.white,
      fontFamily: 'Roboto',
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFFF8FAFC),
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: Color(0xFF1F2937),
          fontSize: 20,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
