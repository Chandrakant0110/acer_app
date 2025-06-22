import 'dart:io';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';

class LocalNotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static bool _isInitialized = false;

  static Future<void> initialize() async {
    if (_isInitialized) return;

    // Initialize the plugin
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    const LinuxInitializationSettings initializationSettingsLinux =
        LinuxInitializationSettings(defaultActionName: 'Open notification');

    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
      linux: initializationSettingsLinux,
    );

    await _notificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onNotificationTap,
    );

    // Request permissions for iOS
    if (Platform.isIOS) {
      await _requestIOSPermissions();
    }

    // Request permission for Android 13+
    if (Platform.isAndroid) {
      await _requestAndroidPermissions();
    }

    _isInitialized = true;
  }

  static Future<void> _requestIOSPermissions() async {
    await _notificationsPlugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
  }

  static Future<void> _requestAndroidPermissions() async {
    final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
        _notificationsPlugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    await androidImplementation?.requestNotificationsPermission();
  }

  static void _onNotificationTap(NotificationResponse notificationResponse) {
    final String? payload = notificationResponse.payload;
    if (payload != null) {
      // Handle notification tap based on payload
      debugPrint('Notification payload: $payload');
      // You can navigate to specific screens based on payload
    }
  }

  static Future<void> showOrderNotification({
    required String orderId,
    required String title,
    required String body,
    String? status,
  }) async {
    if (!_isInitialized) {
      await initialize();
    }

    final AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'order_notifications',
      'Order Notifications',
      channelDescription: 'Notifications for order updates',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
      color: Color(0xFF83B81A), // Acer green color
      playSound: true,
      enableVibration: true,
    );

    const DarwinNotificationDetails iOSPlatformChannelSpecifics =
        DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const LinuxNotificationDetails linuxPlatformChannelSpecifics =
        LinuxNotificationDetails();

    final NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
      linux: linuxPlatformChannelSpecifics,
    );

    await _notificationsPlugin.show(
      orderId.hashCode, // Use order ID hash as notification ID
      title,
      body,
      platformChannelSpecifics,
      payload: 'order:$orderId', // Payload to identify the order
    );
  }

  static Future<void> showWelcomeNotification({
    required String userName,
  }) async {
    if (!_isInitialized) {
      await initialize();
    }

    final AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'welcome_notifications',
      'Welcome Notifications',
      channelDescription: 'Welcome notifications for new users',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
      color: Color(0xFF83B81A), // Acer green color
      playSound: true,
      enableVibration: true,
    );

    const DarwinNotificationDetails iOSPlatformChannelSpecifics =
        DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const LinuxNotificationDetails linuxPlatformChannelSpecifics =
        LinuxNotificationDetails();

    final NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
      linux: linuxPlatformChannelSpecifics,
    );

    await _notificationsPlugin.show(
      999, // Fixed ID for welcome notifications
      'Welcome to Acer Store! 👋',
      'Hi $userName! Welcome to the Acer family. Start exploring amazing laptops, monitors, and accessories.',
      platformChannelSpecifics,
      payload: 'welcome',
    );
  }

  static Future<void> showServiceReminderNotification() async {
    if (!_isInitialized) {
      await initialize();
    }

    final AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'service_notifications',
      'Service Notifications',
      channelDescription: 'Service reminder notifications',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
      color: Color(0xFF83B81A), // Acer green color
      playSound: true,
      enableVibration: true,
    );

    const DarwinNotificationDetails iOSPlatformChannelSpecifics =
        DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const LinuxNotificationDetails linuxPlatformChannelSpecifics =
        LinuxNotificationDetails();

    final NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
      linux: linuxPlatformChannelSpecifics,
    );

    await _notificationsPlugin.show(
      998, // Fixed ID for service notifications
      'Service Reminder 🔧',
      'It\'s been a month since your last service check. Visit your nearest Acer service center to keep your device running smoothly.',
      platformChannelSpecifics,
      payload: 'service',
    );
  }

  static Future<void> showCartReminderNotification({
    required String title,
    required String body,
    required int itemCount,
    required double totalAmount,
  }) async {
    if (!_isInitialized) {
      await initialize();
    }

    final AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'cart_reminders',
      'Cart Reminders',
      channelDescription: 'Notifications for cart reminders and deals',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
      color: Color(0xFF83B81A), // Acer green color
      playSound: true,
      enableVibration: true,
      styleInformation: BigTextStyleInformation(
        body,
        htmlFormatBigText: true,
        contentTitle: 'Acer Store - Great Deals Waiting! 🛒',
        htmlFormatContentTitle: true,
        summaryText: '$itemCount items • ₹${totalAmount.toStringAsFixed(0)}',
        htmlFormatSummaryText: true,
      ),
      actions: [
        AndroidNotificationAction(
          'view_cart',
          'View Cart',
          showsUserInterface: true,
        ),
        AndroidNotificationAction(
          'dismiss',
          'Later',
          showsUserInterface: false,
        ),
      ],
    );

    const DarwinNotificationDetails iOSPlatformChannelSpecifics =
        DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      subtitle: 'Great deals waiting for you!',
    );

    final LinuxNotificationDetails linuxPlatformChannelSpecifics =
        LinuxNotificationDetails(
      actions: [
        LinuxNotificationAction(
          key: 'view_cart',
          label: 'View Cart',
        ),
        LinuxNotificationAction(
          key: 'dismiss',
          label: 'Later',
        ),
      ],
    );

    final NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
      linux: linuxPlatformChannelSpecifics,
    );

    await _notificationsPlugin.show(
      997, // Fixed ID for cart reminders
      title,
      body,
      platformChannelSpecifics,
      payload: 'cart_reminder:$itemCount:$totalAmount',
    );
  }

  static Future<void> showDiscountNotification({
    required String productName,
    required double originalPrice,
    required double discountPrice,
    required int discountPercent,
  }) async {
    if (!_isInitialized) {
      await initialize();
    }

    final AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'discount_alerts',
      'Discount Alerts',
      channelDescription: 'Notifications for special discounts and offers',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
      color: Color(0xFF83B81A), // Acer green color
      playSound: true,
      enableVibration: true,
      styleInformation: BigTextStyleInformation(
        'Was ₹${originalPrice.toStringAsFixed(0)}, now only ₹${discountPrice.toStringAsFixed(0)}. Limited time offer!',
        htmlFormatBigText: true,
        contentTitle: '🎉 $discountPercent% OFF - Limited Time!',
        htmlFormatContentTitle: true,
        summaryText: 'Save ₹${(originalPrice - discountPrice).toStringAsFixed(0)}',
        htmlFormatSummaryText: true,
      ),
      actions: [
        AndroidNotificationAction(
          'buy_now',
          'Buy Now',
          showsUserInterface: true,
        ),
        AndroidNotificationAction(
          'view_details',
          'View Details',
          showsUserInterface: true,
        ),
      ],
    );

    const DarwinNotificationDetails iOSPlatformChannelSpecifics =
        DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      subtitle: 'Limited time offer!',
    );

    final LinuxNotificationDetails linuxPlatformChannelSpecifics =
        LinuxNotificationDetails(
      actions: [
        LinuxNotificationAction(
          key: 'buy_now',
          label: 'Buy Now',
        ),
        LinuxNotificationAction(
          key: 'view_details',
          label: 'View Details',
        ),
      ],
    );

    final NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
      linux: linuxPlatformChannelSpecifics,
    );

    await _notificationsPlugin.show(
      996, // Fixed ID for discount notifications
      '$discountPercent% OFF on $productName! 🔥',
      'Was ₹${originalPrice.toStringAsFixed(0)}, now only ₹${discountPrice.toStringAsFixed(0)}. Limited time offer!',
      platformChannelSpecifics,
      payload: 'discount:$productName:$discountPercent',
    );
  }

  static Future<void> showCartAbandonmentNotification({
    required int itemCount,
    required double totalAmount,
  }) async {
    if (!_isInitialized) {
      await initialize();
    }

    final AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'cart_abandonment',
      'Cart Abandonment',
      channelDescription: 'Reminders for abandoned cart items',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
      color: Color(0xFF83B81A), // Acer green color
      playSound: true,
      enableVibration: true,
      styleInformation: BigTextStyleInformation(
        'Don\'t miss out on these amazing Acer products! Complete your purchase now and enjoy premium quality tech.',
        htmlFormatBigText: true,
        contentTitle: 'Your Cart is Waiting! 🛍️',
        htmlFormatContentTitle: true,
        summaryText: '$itemCount items • ₹${totalAmount.toStringAsFixed(0)}',
        htmlFormatSummaryText: true,
      ),
      actions: [
        AndroidNotificationAction(
          'complete_purchase',
          'Complete Purchase',
          showsUserInterface: true,
        ),
        AndroidNotificationAction(
          'view_cart',
          'View Cart',
          showsUserInterface: true,
        ),
      ],
    );

    const DarwinNotificationDetails iOSPlatformChannelSpecifics =
        DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      subtitle: 'Don\'t forget your items!',
    );

    final LinuxNotificationDetails linuxPlatformChannelSpecifics =
        LinuxNotificationDetails(
      actions: [
        LinuxNotificationAction(
          key: 'complete_purchase',
          label: 'Complete Purchase',
        ),
        LinuxNotificationAction(
          key: 'view_cart',
          label: 'View Cart',
        ),
      ],
    );

    final NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
      linux: linuxPlatformChannelSpecifics,
    );

    await _notificationsPlugin.show(
      995, // Fixed ID for cart abandonment
      'Your Cart is Waiting! 🛍️',
      'Complete your purchase of $itemCount items (₹${totalAmount.toStringAsFixed(0)}) and get them delivered to your doorstep!',
      platformChannelSpecifics,
      payload: 'cart_abandonment:$itemCount:$totalAmount',
    );
  }

  static Future<void> cancelNotification(int id) async {
    await _notificationsPlugin.cancel(id);
  }

  static Future<void> cancelAllNotifications() async {
    await _notificationsPlugin.cancelAll();
  }

  static Future<void> cancelCartNotifications() async {
    // Cancel cart-related notifications
    await _notificationsPlugin.cancel(997); // Cart reminders
    await _notificationsPlugin.cancel(996); // Discount notifications
    await _notificationsPlugin.cancel(995); // Cart abandonment
  }
} 