import 'package:flutter/material.dart';

// Acer brand colors
class AppColors {
  // Primary colors
  static const Color acerGreen = Color(0xFF83B81A);
  static const Color acerDarkGray = Color(0xFF1A1A1A);
  static const Color acerBlue = Color(0xFF0079C1);
  
  // Dark theme colors
  static const Color darkBackground = Color(0xFF121212);
  static const Color darkSurface = Color(0xFF1E1E1E);
  static const Color darkCard = Color(0xFF242424);
  
  // Light theme colors
  static const Color lightBackground = Colors.white;
  static const Color lightSurface = Colors.white;
  static const Color lightCard = Colors.white;
  
  // Common colors
  static const Color textOnDark = Color(0xFFE1E1E1); // Softer white for text on dark surfaces
  static const Color textOnDarkSecondary = Color(0xFFBBBBBB); // Even softer white for secondary text
  static const Color textOnLight = Color(0xFF212121); // Dark gray for text on light surfaces
  static const Color textOnLightSecondary = Color(0xFF666666); // Lighter gray for secondary text
}

// Text styles
class AppTextStyles {
  static const TextStyle headlineLarge = TextStyle(
    fontWeight: FontWeight.bold,
    letterSpacing: -0.5,
  );
  
  static const TextStyle headlineMedium = TextStyle(
    fontWeight: FontWeight.bold,
    letterSpacing: -0.25,
  );
  
  static const TextStyle titleLarge = TextStyle(
    fontWeight: FontWeight.bold,
  );
  
  static const TextStyle titleMedium = TextStyle(
    fontWeight: FontWeight.w600,
  );
  
  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
  );
  
  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
  );
}

// Helper methods for theme-aware colors
class AppTheme {
  static Color getPrimaryColor(BuildContext context) {
    return Theme.of(context).colorScheme.primary;
  }
  
  static Color getSecondaryColor(BuildContext context) {
    return Theme.of(context).colorScheme.secondary;
  }
  
  static Color getTertiaryColor(BuildContext context) {
    return Theme.of(context).colorScheme.tertiary;
  }
  
  static Color getBackgroundColor(BuildContext context) {
    return Theme.of(context).colorScheme.background;
  }
  
  static Color getSurfaceColor(BuildContext context) {
    return Theme.of(context).colorScheme.surface;
  }
  
  static bool isDarkMode(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark;
  }
  
  static Color getTextColor(BuildContext context) {
    return isDarkMode(context) ? Colors.white : Colors.black;
  }
} 