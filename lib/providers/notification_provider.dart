import 'package:flutter/material.dart';
import '../notification.dart';

class NotificationsProvider extends ChangeNotifier {
  final List<NotificationModel> _notifications = [];
  
  List<NotificationModel> get notifications => _notifications;
  
  bool get hasUnreadNotifications => _notifications.any((notification) => !notification.isRead);
  
  int get unreadCount => _notifications.where((notification) => !notification.isRead).length;
  
  void addNotification(NotificationModel notification) {
    _notifications.add(notification);
    notifyListeners();
  }
  
  void markAsRead(String id) {
    final index = _notifications.indexWhere((notification) => notification.id == id);
    if (index != -1) {
      _notifications[index] = _notifications[index].copyWith(isRead: true);
      notifyListeners();
    }
  }
  
  void markAllAsRead() {
    for (int i = 0; i < _notifications.length; i++) {
      _notifications[i] = _notifications[i].copyWith(isRead: true);
    }
    notifyListeners();
  }
  
  void removeNotification(String id) {
    _notifications.removeWhere((notification) => notification.id == id);
    notifyListeners();
  }
  
  void clearAllNotifications() {
    _notifications.clear();
    notifyListeners();
  }
} 