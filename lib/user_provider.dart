import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'user.dart';

class UserProvider extends ChangeNotifier {
  User? _currentUser;
  final auth.FirebaseAuth? _firebaseAuth;
  final SharedPreferences? _prefs;

  UserProvider(dynamic authOrPrefs)
      : _firebaseAuth = authOrPrefs is auth.FirebaseAuth ? authOrPrefs : null,
        _prefs = authOrPrefs is SharedPreferences ? authOrPrefs : null {
    if (_firebaseAuth != null) {
      // Listen to Firebase auth state changes
      _firebaseAuth!.authStateChanges().listen(_onAuthStateChanged);
    } else if (_prefs != null) {
      // Load user from shared preferences
      _loadUserFromPrefs();
    }
  }

  User? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null;

  // Handle Firebase auth state changes
  void _onAuthStateChanged(auth.User? firebaseUser) {
    if (firebaseUser != null) {
      // Convert Firebase user to our User model
      _currentUser = User(
        name: firebaseUser.displayName ?? 'User',
        email: firebaseUser.email ?? '',
        phone: firebaseUser.phoneNumber ?? '',
      );

      // Save to SharedPreferences for persistence
      if (_prefs != null) {
        _saveUserToPrefs(_currentUser!);
      }
    } else {
      _currentUser = null;

      // Clear from SharedPreferences
      if (_prefs != null) {
        _prefs!.remove('user');
      }
    }
    notifyListeners();
  }

  // Load user from SharedPreferences
  void _loadUserFromPrefs() {
    final userJson = _prefs?.getString('user');
    if (userJson != null) {
      try {
        final userData = jsonDecode(userJson);
        _currentUser = User(
          name: userData['name'] ?? '',
          email: userData['email'] ?? '',
          phone: userData['phone'] ?? '',
          imageUrl: userData['imageUrl'],
        );
        notifyListeners();
      } catch (e) {
        print('Error loading user data: $e');
        _prefs?.remove('user'); // Remove corrupted data
      }
    }
  }

  // Save user to SharedPreferences
  void _saveUserToPrefs(User user) {
    if (_prefs != null) {
      final userData = {
        'name': user.name,
        'email': user.email,
        'phone': user.phone,
        'imageUrl': user.imageUrl,
      };
      _prefs!.setString('user', jsonEncode(userData));
    }
  }

  // Set user data
  void setUser(User user) {
    _currentUser = user;

    // Save to SharedPreferences
    if (_prefs != null) {
      _saveUserToPrefs(user);
    }

    notifyListeners();
  }

  // Update specific user fields
  void updateUserData({String? name, String? phone, String? imageUrl}) {
    if (_currentUser == null) return;

    _currentUser = User(
      name: name ?? _currentUser!.name,
      email: _currentUser!.email,
      phone: phone ?? _currentUser!.phone,
      imageUrl: imageUrl ?? _currentUser!.imageUrl,
    );

    // Save updated user to SharedPreferences
    if (_prefs != null) {
      _saveUserToPrefs(_currentUser!);
    }

    // Update Firebase profile if available
    if (_firebaseAuth != null && _firebaseAuth!.currentUser != null) {
      _firebaseAuth!.currentUser!.updateDisplayName(name);
      // Note: Updating phone number requires verification in a real app
    }

    notifyListeners();
  }

  // Sign out user
  Future<void> signOut() async {
    // Sign out from Firebase if available
    if (_firebaseAuth != null) {
      await _firebaseAuth!.signOut();
    }

    // Clear user data
    _currentUser = null;

    // Clear from SharedPreferences
    if (_prefs != null) {
      _prefs!.remove('user');
    }

    notifyListeners();
  }

  // Check if email exists (can be used before signup)
  Future<bool> checkIfEmailExists(String email) async {
    try {
      if (_firebaseAuth != null) {
        final methods = await _firebaseAuth!.fetchSignInMethodsForEmail(email);
        return methods.isNotEmpty;
      }
      return false;
    } catch (e) {
      print('Error checking email: $e');
      return false;
    }
  }
}
