import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class ConnectivityService extends ChangeNotifier {
  static final ConnectivityService _instance = ConnectivityService._internal();
  factory ConnectivityService() => _instance;
  ConnectivityService._internal();

  final Connectivity _connectivity = Connectivity();
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;
  
  bool _isOnline = true; // Default to online to prevent false offline state during startup
  bool _isInitialized = false; // Track if service has been properly initialized
  bool get isOnline => _isOnline;
  bool get isOffline => !_isOnline && _isInitialized; // Only show offline if actually initialized

  List<String> _offlineMessages = [];
  List<String> get offlineMessages => _offlineMessages;

  /// Initialize connectivity monitoring
  Future<void> initialize() async {
    // Load offline messages first
    await _loadOfflineMessages();
    
    // Check initial connectivity
    await _checkConnectivity();
    
    // Mark as initialized after first check
    _isInitialized = true;
    
    // Listen for connectivity changes
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen(
      (List<ConnectivityResult> results) async {
        await _updateConnectivityStatus(results);
      },
    );
    
    // Notify listeners after full initialization
    notifyListeners();
  }

  /// Check current connectivity status
  Future<void> _checkConnectivity() async {
    try {
      final List<ConnectivityResult> results = await _connectivity.checkConnectivity();
      await _updateConnectivityStatus(results, isInitialCheck: true);
    } catch (e) {
      print('Error checking connectivity: $e');
      _isOnline = false;
      if (_isInitialized) {
        notifyListeners();
      }
    }
  }

  /// Update connectivity status based on results
  Future<void> _updateConnectivityStatus(List<ConnectivityResult> results, {bool isInitialCheck = false}) async {
    final bool wasOnline = _isOnline;
    
    // Check if any connection type is available (not none)
    _isOnline = results.any((result) => result != ConnectivityResult.none);
    
    // Only show connectivity messages after initialization and if status actually changed
    if (_isInitialized && wasOnline != _isOnline) {
      print('Connectivity changed: ${_isOnline ? 'Online' : 'Offline'}');
      
      if (_isOnline) {
        // Back online - sync any pending data
        await _syncOfflineData();
      } else {
        // Gone offline - add message
        await _addOfflineMessage('You are now offline. Some features may be limited.');
      }
      
      notifyListeners();
    } else if (isInitialCheck) {
      // For initial check, just log the status
      print('Initial connectivity status: ${_isOnline ? 'Online' : 'Offline'}');
    }
  }

  /// Add message when going offline
  Future<void> _addOfflineMessage(String message) async {
    _offlineMessages.insert(0, message);
    if (_offlineMessages.length > 10) {
      _offlineMessages = _offlineMessages.take(10).toList();
    }
    await _saveOfflineMessages();
  }

  /// Sync data when back online
  Future<void> _syncOfflineData() async {
    await _addOfflineMessage('Back online! Syncing data...');
    // Here you can add logic to sync any offline changes
    // For example: sync cart, orders, user preferences, etc.
  }

  /// Save offline messages to local storage
  Future<void> _saveOfflineMessages() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('offline_messages', jsonEncode(_offlineMessages));
    } catch (e) {
      print('Error saving offline messages: $e');
    }
  }

  /// Load offline messages from local storage
  Future<void> _loadOfflineMessages() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? messagesJson = prefs.getString('offline_messages');
      if (messagesJson != null) {
        final List<dynamic> messagesList = jsonDecode(messagesJson);
        _offlineMessages = messagesList.cast<String>();
      }
    } catch (e) {
      print('Error loading offline messages: $e');
      _offlineMessages = [];
    }
  }

  /// Clear offline messages
  Future<void> clearOfflineMessages() async {
    _offlineMessages.clear();
    await _saveOfflineMessages();
    notifyListeners();
  }

  /// Force refresh connectivity status
  Future<void> refreshConnectivity() async {
    await _checkConnectivity();
  }

  /// Dispose resources
  @override
  void dispose() {
    _connectivitySubscription?.cancel();
    super.dispose();
  }
} 