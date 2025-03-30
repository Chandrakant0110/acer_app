import 'package:flutter/material.dart';

class ThemeProvider extends ChangeNotifier {
  bool _darkMode = false;

  bool get darkMode => _darkMode;

  void setDarkMode(bool value) {
    _darkMode = value;
    notifyListeners();
  }
} 