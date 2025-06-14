import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/app_theme.dart';

class ThemeProvider extends ChangeNotifier {
  bool _darkMode = false;
  static const String _darkModeKey = 'darkMode';

  // Light theme
  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: ColorScheme.light(
      primary: AppColors.acerGreen,
      onPrimary: Colors.white,
      secondary: AppColors.acerDarkGray,
      onSecondary: Colors.white,
      tertiary: AppColors.acerBlue,
      surface: AppColors.lightSurface,
      background: AppColors.lightBackground,
      onBackground: AppColors.textOnLight,
      onSurface: AppColors.textOnLight,
      error: Colors.red[700]!,
    ),
    scaffoldBackgroundColor: AppColors.lightBackground,
    cardColor: AppColors.lightCard,
    dividerColor: Colors.grey[300],
    textTheme: const TextTheme(
      displayLarge: TextStyle(color: AppColors.textOnLight, fontWeight: FontWeight.bold),
      displayMedium: TextStyle(color: AppColors.textOnLight, fontWeight: FontWeight.bold),
      displaySmall: TextStyle(color: AppColors.textOnLight, fontWeight: FontWeight.bold),
      headlineLarge: TextStyle(color: AppColors.textOnLight, fontWeight: FontWeight.bold),
      headlineMedium: TextStyle(color: AppColors.textOnLight, fontWeight: FontWeight.bold),
      headlineSmall: TextStyle(color: AppColors.textOnLight, fontWeight: FontWeight.w600),
      titleLarge: TextStyle(color: AppColors.textOnLight, fontWeight: FontWeight.bold),
      titleMedium: TextStyle(color: AppColors.textOnLight, fontWeight: FontWeight.w600),
      titleSmall: TextStyle(color: AppColors.textOnLight, fontWeight: FontWeight.w600),
      bodyLarge: TextStyle(color: AppColors.textOnLight),
      bodyMedium: TextStyle(color: AppColors.textOnLight),
      bodySmall: TextStyle(color: AppColors.textOnLightSecondary),
      labelLarge: TextStyle(color: AppColors.textOnLight, fontWeight: FontWeight.w600),
      labelMedium: TextStyle(color: AppColors.textOnLight),
      labelSmall: TextStyle(color: AppColors.textOnLightSecondary),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.acerGreen,
      foregroundColor: Colors.white,
      centerTitle: false,
      elevation: 0,
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: AppColors.lightBackground,
      selectedItemColor: AppColors.acerGreen,
      unselectedItemColor: Colors.grey,
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: AppColors.lightBackground,
      indicatorColor: AppColors.acerGreen.withOpacity(0.2),
      labelTextStyle: WidgetStateProperty.all(
        const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
      ),
    ),
  );

  // Dark theme
  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: ColorScheme.dark(
      primary: AppColors.acerGreen,
      onPrimary: AppColors.textOnDark,
      secondary: AppColors.acerDarkGray,
      onSecondary: AppColors.textOnDark,
      tertiary: AppColors.acerBlue,
      surface: AppColors.darkSurface,
      background: AppColors.darkBackground,
      onBackground: AppColors.textOnDark,
      onSurface: AppColors.textOnDark,
      error: Colors.red[400]!,
    ),
    scaffoldBackgroundColor: AppColors.darkBackground,
    cardColor: AppColors.darkCard,
    dividerColor: Colors.grey[800],
    textTheme: const TextTheme(
      displayLarge: TextStyle(color: AppColors.textOnDark, fontWeight: FontWeight.bold),
      displayMedium: TextStyle(color: AppColors.textOnDark, fontWeight: FontWeight.bold),
      displaySmall: TextStyle(color: AppColors.textOnDark, fontWeight: FontWeight.bold),
      headlineLarge: TextStyle(color: AppColors.textOnDark, fontWeight: FontWeight.bold),
      headlineMedium: TextStyle(color: AppColors.textOnDark, fontWeight: FontWeight.bold),
      headlineSmall: TextStyle(color: AppColors.textOnDark, fontWeight: FontWeight.w600),
      titleLarge: TextStyle(color: AppColors.textOnDark, fontWeight: FontWeight.bold),
      titleMedium: TextStyle(color: AppColors.textOnDark, fontWeight: FontWeight.w600),
      titleSmall: TextStyle(color: AppColors.textOnDark, fontWeight: FontWeight.w600),
      bodyLarge: TextStyle(color: AppColors.textOnDark),
      bodyMedium: TextStyle(color: AppColors.textOnDark),
      bodySmall: TextStyle(color: AppColors.textOnDarkSecondary),
      labelLarge: TextStyle(color: AppColors.textOnDark, fontWeight: FontWeight.w600),
      labelMedium: TextStyle(color: AppColors.textOnDark),
      labelSmall: TextStyle(color: AppColors.textOnDarkSecondary),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.acerGreen,
      foregroundColor: AppColors.textOnDark,
      centerTitle: false,
      elevation: 0,
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: AppColors.darkSurface,
      selectedItemColor: AppColors.acerGreen,
      unselectedItemColor: Colors.grey,
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: AppColors.darkSurface,
      indicatorColor: AppColors.acerGreen.withOpacity(0.2),
      labelTextStyle: WidgetStateProperty.all(
        const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
      ),
    ),
  );

  ThemeProvider() {
    _loadThemePreference();
  }

  bool get darkMode => _darkMode;
  ThemeData get currentTheme => _darkMode ? darkTheme : lightTheme;

  // Load theme preference from SharedPreferences
  Future<void> _loadThemePreference() async {
    final prefs = await SharedPreferences.getInstance();
    _darkMode = prefs.getBool(_darkModeKey) ?? false;
    notifyListeners();
  }

  // Update theme and save preference
  Future<void> setDarkMode(bool value) async {
    if (_darkMode == value) return;
    
    _darkMode = value;
    notifyListeners();
    
    // Save preference
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_darkModeKey, value);
  }
} 