import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';

/// Theme controller utility class to provide easy access to theme functionality across the app
class ThemeController {
  /// Get the current theme mode (dark or light)
  static bool isDarkMode(BuildContext context) {
    return Provider.of<ThemeProvider>(context, listen: false).darkMode;
  }

  /// Get the current theme mode (dark or light) with listener
  static bool isDarkModeWithListener(BuildContext context) {
    return Provider.of<ThemeProvider>(context).darkMode;
  }

  /// Set the theme mode (dark or light)
  static Future<void> setDarkMode(BuildContext context, bool isDark) async {
    await Provider.of<ThemeProvider>(context, listen: false).setDarkMode(isDark);
  }

  /// Toggle the current theme mode
  static Future<void> toggleDarkMode(BuildContext context) async {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    await themeProvider.setDarkMode(!themeProvider.darkMode);
  }

  /// Get a color based on the current theme
  static Color getColor(BuildContext context, {required Color lightColor, required Color darkColor}) {
    return Theme.of(context).brightness == Brightness.dark ? darkColor : lightColor;
  }

  /// Get theme-aware colors for widgets
  static Color getSurfaceColor(BuildContext context) {
    return Theme.of(context).colorScheme.surface;
  }

  /// Get theme-aware background color
  static Color getBackgroundColor(BuildContext context) {
    return Theme.of(context).colorScheme.background;
  }

  /// Get theme-aware card color
  static Color getCardColor(BuildContext context) {
    return Theme.of(context).cardColor;
  }

  /// Get theme-aware primary color
  static Color getPrimaryColor(BuildContext context) {
    return Theme.of(context).colorScheme.primary;
  }

  /// Get theme-aware divider color
  static Color getDividerColor(BuildContext context) {
    return Theme.of(context).dividerColor;
  }
}

/// Utility class for color adjustments
class ColorUtils {
  /// Returns a softer version of white that's easier on the eyes in dark mode
  static Color getSofterWhite([double opacity = 1.0]) {
    return const Color(0xFFE1E1E1).withOpacity(opacity);
  }
  
  /// Returns a color with reduced brightness
  static Color reduceBrightness(Color color, double factor) {
    assert(factor >= 0 && factor <= 1, 'Factor must be between 0 and 1');
    final hslColor = HSLColor.fromColor(color);
    return hslColor.withLightness(hslColor.lightness * factor).toColor();
  }
  
  /// Returns a version of white with adjustable brightness for dark mode
  static Color getThemeAwareWhite(BuildContext context, [double brightness = 0.9]) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? Colors.white.withOpacity(brightness) : Colors.white;
  }
} 
