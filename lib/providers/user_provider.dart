import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';

class UserProvider extends ChangeNotifier {
  User? _currentUser;
  final SharedPreferences _prefs;

  UserProvider(this._prefs) {
    // Load saved user data when provider is initialized
    _loadSavedUser();
  }

  User? get currentUser => _currentUser;

  void setUser(User user) async {
    _currentUser = user;
    // Save user data to SharedPreferences
    await _prefs.setString('user_name', user.name);
    await _prefs.setString('user_email', user.email);
    await _prefs.setString('user_phone', user.phone);
    await _prefs.setString('user_image_url', user.imageUrl ?? '');
    notifyListeners();
  }

  void clearUser() async {
    _currentUser = null;
    // Clear saved user data
    await _prefs.remove('user_name');
    await _prefs.remove('user_email');
    await _prefs.remove('user_phone');
    await _prefs.remove('user_image_url');
    notifyListeners();
  }

  void _loadSavedUser() {
    final name = _prefs.getString('user_name');
    final email = _prefs.getString('user_email');
    final phone = _prefs.getString('user_phone');
    final imageUrl = _prefs.getString('user_image_url');

    if (name != null && email != null && phone != null) {
      _currentUser = User(
        name: name,
        email: email,
        phone: phone,
        imageUrl: imageUrl?.isEmpty ?? true ? null : imageUrl,
      );
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    clearUser();
  }
}
