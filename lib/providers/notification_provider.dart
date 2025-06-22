import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:async';

// Essential notification types only
enum NotificationType { welcome, order, service }

class NotificationItem {
  final String id;
  final String title;
  final String body;
  final DateTime timestamp;
  final NotificationType type;
  final bool isRead;

  NotificationItem({
    required this.id,
    required this.title,
    required this.body,
    required this.timestamp,
    required this.type,
    this.isRead = false,
  });

  NotificationItem copyWith({
    String? id,
    String? title,
    String? body,
    DateTime? timestamp,
    NotificationType? type,
    bool? isRead,
  }) {
    return NotificationItem(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      timestamp: timestamp ?? this.timestamp,
      type: type ?? this.type,
      isRead: isRead ?? this.isRead,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'body': body,
      'timestamp': timestamp.toIso8601String(),
      'type': type.toString().split('.').last,
      'isRead': isRead,
    };
  }

  factory NotificationItem.fromJson(Map<String, dynamic> json) {
    return NotificationItem(
      id: json['id'],
      title: json['title'],
      body: json['body'],
      timestamp: DateTime.parse(json['timestamp']),
      type: NotificationType.values.firstWhere(
        (e) => e.toString().split('.').last == json['type'],
      ),
      isRead: json['isRead'] ?? false,
    );
  }
}

class NotificationsProvider extends ChangeNotifier {
  final List<NotificationItem> _notifications = [];
  Timer? _serviceReminderTimer;
  SharedPreferences? _prefs;

  NotificationsProvider() {
    _initProvider();
  }

  List<NotificationItem> get notifications => List.unmodifiable(_notifications);
  bool get hasUnreadNotifications => _notifications.any((notification) => !notification.isRead);
  int get unreadCount => _notifications.where((notification) => !notification.isRead).length;

  Future<void> _initProvider() async {
    _prefs = await SharedPreferences.getInstance();
    await _loadNotifications();
    _startServiceReminderTimer();
  }

  // Load notifications from SharedPreferences
  Future<void> _loadNotifications() async {
    try {
      final notificationsJson = _prefs?.getString('notifications');
      if (notificationsJson != null && notificationsJson.isNotEmpty) {
        final List<dynamic> decodedList = jsonDecode(notificationsJson);
        _notifications.clear();
        _notifications.addAll(
          decodedList.map((item) => NotificationItem.fromJson(item)).toList(),
        );
        notifyListeners();
      }
    } catch (e) {
      print('Error loading notifications: $e');
    }
  }

  Future<void> _saveNotifications() async {
    try {
      final notificationsJson = jsonEncode(
        _notifications.map((notification) => notification.toJson()).toList(),
      );
      await _prefs?.setString('notifications', notificationsJson);
    } catch (e) {
      print('Error saving notifications: $e');
    }
  }

  void addNotification(NotificationItem notification) {
    _notifications.insert(0, notification);
    _saveNotifications();
    notifyListeners();
  }

  void markAsRead(String id) {
    final index = _notifications.indexWhere((notification) => notification.id == id);
    if (index != -1) {
      _notifications[index] = _notifications[index].copyWith(isRead: true);
      _saveNotifications();
      notifyListeners();
    }
  }

  void markAllAsRead() {
    for (int i = 0; i < _notifications.length; i++) {
      _notifications[i] = _notifications[i].copyWith(isRead: true);
    }
    _saveNotifications();
    notifyListeners();
  }

  void removeNotification(String id) {
    _notifications.removeWhere((notification) => notification.id == id);
    _saveNotifications();
    notifyListeners();
  }

  void clearAllNotifications() {
    _notifications.clear();
    _saveNotifications();
    notifyListeners();
  }

  // Add welcome notification when user signs up
  void addWelcomeNotification(String userName) {
    final welcomeNotification = NotificationItem(
      id: 'welcome_${DateTime.now().millisecondsSinceEpoch}',
      title: 'Welcome to Acer Store! 👋',
      body: 'Hi $userName! Welcome to the Acer family. Start exploring amazing laptops, monitors, and accessories.',
      timestamp: DateTime.now(),
      type: NotificationType.welcome,
      isRead: false,
    );
    addNotification(welcomeNotification);
  }

  // Add order notification when user places an order
  void addOrderNotification(String orderId, String status, double amount) {
    String title;
    String body;

    switch (status.toLowerCase()) {
      case 'placed':
        title = 'Order Placed Successfully! 🎉';
        body = 'Your order #$orderId worth ₹${amount.toStringAsFixed(0)} has been placed successfully. You\'ll receive updates as it progresses.';
        break;
      case 'confirmed':
        title = 'Order Confirmed';
        body = 'Your order #$orderId has been confirmed and is being prepared for shipping.';
        break;
      case 'shipped':
        title = 'Order Shipped 📦';
        body = 'Great news! Your order #$orderId is on its way. Expected delivery in 2-3 business days.';
        break;
      case 'delivered':
        title = 'Order Delivered ✅';
        body = 'Your order #$orderId has been delivered successfully. Enjoy your new Acer product!';
        break;
      default:
        title = 'Order Update';
        body = 'Your order #$orderId status has been updated to: $status';
    }

    final orderNotification = NotificationItem(
      id: 'order_${orderId}_${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      body: body,
      timestamp: DateTime.now(),
      type: NotificationType.order,
      isRead: false,
    );
    addNotification(orderNotification);
  }

  // Start monthly service reminder timer
  void _startServiceReminderTimer() {
    // Check if we should show service reminder
    final lastServiceReminder = _prefs?.getString('last_service_reminder');
    final now = DateTime.now();
    
    DateTime? lastReminderDate;
    if (lastServiceReminder != null) {
      lastReminderDate = DateTime.tryParse(lastServiceReminder);
    }

    // If no previous reminder or it's been more than 30 days
    if (lastReminderDate == null || 
        now.difference(lastReminderDate).inDays >= 30) {
      _addServiceReminder();
      _prefs?.setString('last_service_reminder', now.toIso8601String());
    }

    // Set up timer for next month
    _serviceReminderTimer = Timer.periodic(
      const Duration(days: 30), // Monthly reminder
      (timer) => _addServiceReminder(),
    );
  }

  void _addServiceReminder() {
    final serviceNotification = NotificationItem(
      id: 'service_${DateTime.now().millisecondsSinceEpoch}',
      title: 'Service Reminder 🔧',
      body: 'It\'s been a month since your last service check. Visit your nearest Acer service center to keep your device running smoothly.',
      timestamp: DateTime.now(),
      type: NotificationType.service,
      isRead: false,
    );
    addNotification(serviceNotification);
    _prefs?.setString('last_service_reminder', DateTime.now().toIso8601String());
  }

  @override
  void dispose() {
    _serviceReminderTimer?.cancel();
    super.dispose();
  }
} 