import 'package:flutter/material.dart';
import '../models/user.dart'; // Ensure this path is correct

class UserProvider extends ChangeNotifier {
  User? _currentUser;

  User? get currentUser => _currentUser;

  void setUser(User user) {
    _currentUser = user;
    notifyListeners();
  }
} 