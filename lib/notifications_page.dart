import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'notification_provider.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final notificationProvider = Provider.of<NotificationProvider>(context);
    final notifications = notificationProvider.notifications;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
      ),
      body: notifications.isEmpty
          ? const Center(child: Text('No notifications found.'))
          : ListView.builder(
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                final notification = notifications[index];
                return ListTile(
                  title: Text(notification.title ?? ''),
                  subtitle: Text(notification.message ?? ''),
                  onTap: () {
                    notificationProvider.markAsRead(index);
                    // Navigate to the relevant page or show details
                  },
                  tileColor:
                      notification.isRead ? Colors.white : Colors.grey[200],
                );
              },
            ),
    );
  }
}
