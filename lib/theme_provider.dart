import 'package:flutter/material.dart';

class AppTheme {
  final String name;
  final Color primaryColor;
  final Color secondaryColor;
  final Color backgroundColor;
  final Color buttonColor;
  final Color textColor;

  const AppTheme({
    required this.name,
    required this.primaryColor,
    required this.secondaryColor,
    required this.backgroundColor,
    required this.buttonColor,
    required this.textColor,
  });
}

class ThemeProvider extends ChangeNotifier {
  static final List<AppTheme> _themes = [
    const AppTheme(
      name: 'Ocean Blue',
      primaryColor: Color(0xFF63B4FF),
      secondaryColor: Color(0xFFCAE1FF),
      backgroundColor: Color(0xFF63B4FF),
      buttonColor: Color(0xFFCAE1FF),
      textColor: Colors.white,
    ),
    const AppTheme(
      name: 'Sunset Pink',
      primaryColor: Color(0xFFFF9AF5),
      secondaryColor: Color(0xFFFFE1F5),
      backgroundColor: Color(0xFFFF9AF5),
      buttonColor: Color(0xFFFFE1F5),
      textColor: Colors.white,
    ),
    const AppTheme(
      name: 'Lavender Purple',
      primaryColor: Color(0xFFB4A8FA),
      secondaryColor: Color(0xFFE8E5FF),
      backgroundColor: Color(0xFFB4A8FA),
      buttonColor: Color(0xFFE8E5FF),
      textColor: Colors.white,
    ),
    const AppTheme(
      name: 'Forest Green',
      primaryColor: Color(0xFF4CAF50),
      secondaryColor: Color(0xFFC8E6C9),
      backgroundColor: Color(0xFF4CAF50),
      buttonColor: Color(0xFFC8E6C9),
      textColor: Colors.white,
    ),
    const AppTheme(
      name: 'Sunset Orange',
      primaryColor: Color(0xFFFF7043),
      secondaryColor: Color(0xFFFFCCBC),
      backgroundColor: Color(0xFFFF7043),
      buttonColor: Color(0xFFFFCCBC),
      textColor: Colors.white,
    ),
    const AppTheme(
      name: 'Midnight Blue',
      primaryColor: Color(0xFF3F51B5),
      secondaryColor: Color(0xFFC5CAE9),
      backgroundColor: Color(0xFF3F51B5),
      buttonColor: Color(0xFFC5CAE9),
      textColor: Colors.white,
    ),
  ];

  int _currentThemeIndex = 0;
  
  // Background settings
  double _brightness = 1.0;
  double _contrast = 1.0;
  double _saturation = 1.0;
  double _hue = 0.0;
  double _blur = 0.0;

  AppTheme get currentTheme => _themes[_currentThemeIndex];
  List<AppTheme> get themes => _themes;
  int get currentThemeIndex => _currentThemeIndex;
  
  // Background settings getters
  double get brightness => _brightness;
  double get contrast => _contrast;
  double get saturation => _saturation;
  double get hue => _hue;
  double get blur => _blur;

  void setTheme(int index) {
    if (index >= 0 && index < _themes.length) {
      _currentThemeIndex = index;
      notifyListeners();
    }
  }

  void nextTheme() {
    _currentThemeIndex = (_currentThemeIndex + 1) % _themes.length;
    notifyListeners();
  }

  void setBackgroundSettings({
    double? brightness,
    double? contrast,
    double? saturation,
    double? hue,
    double? blur,
  }) {
    if (brightness != null) _brightness = brightness;
    if (contrast != null) _contrast = contrast;
    if (saturation != null) _saturation = saturation;
    if (hue != null) _hue = hue;
    if (blur != null) _blur = blur;
    notifyListeners();
  }

  ThemeData getThemeData() {
    final theme = currentTheme;
    return ThemeData(
      primarySwatch: Colors.blue,
      fontFamily: 'Belanosima',
      scaffoldBackgroundColor: theme.backgroundColor,
      appBarTheme: AppBarTheme(
        backgroundColor: theme.primaryColor,
        foregroundColor: theme.textColor,
        elevation: 0,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: theme.buttonColor,
          foregroundColor: theme.primaryColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: theme.textColor,
        ),
      ),
    );
  }
} 