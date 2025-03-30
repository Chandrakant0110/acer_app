import 'package:flutter/material.dart';
import 'notification.dart' as app_notification; // Use a prefix for the app's Notification class

class NotificationProvider extends ChangeNotifier {
  final List<app_notification.Notification> _notifications =
      []; // Use the prefix here

  List<app_notification.Notification> get notifications => _notifications;

  void addNotification(app_notification.Notification notification) {
    // Use the prefix here
    _notifications.add(notification);
    notifyListeners();
  }

  void markAsRead(int index) {
    if (index >= 0 && index < _notifications.length) {
      _notifications[index].isRead = true;
      notifyListeners();
    }
  }
}
