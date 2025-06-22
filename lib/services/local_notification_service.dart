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
    double? totalAmount,
    int? itemCount,
  }) async {
    if (!_isInitialized) {
      await initialize();
    }

    // Determine notification style based on status
    String summaryText = 'Order #$orderId';
    if (totalAmount != null && itemCount != null) {
      summaryText = '$itemCount items • ₹${totalAmount.toStringAsFixed(0)}';
    }

    List<AndroidNotificationAction> actions = [];
    if (status?.toLowerCase() == 'confirmed') {
      actions = [
        AndroidNotificationAction(
          'track_order',
          'Track Order',
          showsUserInterface: true,
        ),
        AndroidNotificationAction(
          'view_details',
          'View Details',
          showsUserInterface: true,
        ),
      ];
    } else {
      actions = [
        AndroidNotificationAction(
          'view_order',
          'View Order',
          showsUserInterface: true,
        ),
      ];
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
      styleInformation: BigTextStyleInformation(
        body,
        htmlFormatBigText: true,
        contentTitle: title,
        htmlFormatContentTitle: true,
        summaryText: summaryText,
        htmlFormatSummaryText: true,
      ),
      actions: actions,
    );

    const DarwinNotificationDetails iOSPlatformChannelSpecifics =
        DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      subtitle: 'Acer Store Order Update',
    );

    final LinuxNotificationDetails linuxPlatformChannelSpecifics =
        LinuxNotificationDetails(
      actions: actions.map((action) => LinuxNotificationAction(
        key: action.id,
        label: action.title,
      )).toList(),
    );

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
      payload: 'order:$orderId:${status ?? 'update'}', // Enhanced payload
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
      styleInformation: BigTextStyleInformation(
        'Hi $userName! Welcome to the Acer family. Start exploring amazing laptops, monitors, and accessories tailored just for you!',
        htmlFormatBigText: true,
        contentTitle: 'Welcome to Acer Store! 👋',
        htmlFormatContentTitle: true,
        summaryText: 'Your tech journey begins here',
        htmlFormatSummaryText: true,
      ),
      actions: [
        AndroidNotificationAction(
          'explore_products',
          'Explore Products',
          showsUserInterface: true,
        ),
        AndroidNotificationAction(
          'view_offers',
          'View Offers',
          showsUserInterface: true,
        ),
      ],
    );

    const DarwinNotificationDetails iOSPlatformChannelSpecifics =
        DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      subtitle: 'Your tech journey begins here',
    );

    final LinuxNotificationDetails linuxPlatformChannelSpecifics =
        LinuxNotificationDetails(
      actions: [
        LinuxNotificationAction(
          key: 'explore_products',
          label: 'Explore Products',
        ),
        LinuxNotificationAction(
          key: 'view_offers',
          label: 'View Offers',
        ),
      ],
    );

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
      payload: 'welcome:$userName',
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
      styleInformation: BigTextStyleInformation(
        'It\'s been a month since your last service check. Visit your nearest Acer service center to keep your device running smoothly and maintain warranty coverage.',
        htmlFormatBigText: true,
        contentTitle: 'Service Reminder 🔧',
        htmlFormatContentTitle: true,
        summaryText: 'Keep your Acer device in top condition',
        htmlFormatSummaryText: true,
      ),
      actions: [
        AndroidNotificationAction(
          'find_service_center',
          'Find Service Center',
          showsUserInterface: true,
        ),
        AndroidNotificationAction(
          'schedule_service',
          'Schedule Service',
          showsUserInterface: true,
        ),
        AndroidNotificationAction(
          'remind_later',
          'Remind Later',
          showsUserInterface: false,
        ),
      ],
    );

    const DarwinNotificationDetails iOSPlatformChannelSpecifics =
        DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      subtitle: 'Keep your device in top condition',
    );

    final LinuxNotificationDetails linuxPlatformChannelSpecifics =
        LinuxNotificationDetails(
      actions: [
        LinuxNotificationAction(
          key: 'find_service_center',
          label: 'Find Service Center',
        ),
        LinuxNotificationAction(
          key: 'schedule_service',
          label: 'Schedule Service',
        ),
        LinuxNotificationAction(
          key: 'remind_later',
          label: 'Remind Later',
        ),
      ],
    );

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
      payload: 'service:reminder',
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

  static Future<void> showOrderConfirmedNotification({
    required String orderId,
    required double totalAmount,
    required int itemCount,
    String? deliveryDate,
  }) async {
    if (!_isInitialized) {
      await initialize();
    }

    String deliveryInfo = deliveryDate != null 
        ? 'Expected delivery: $deliveryDate'
        : 'We\'ll keep you updated on delivery';

    final AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'order_confirmed',
      'Order Confirmed',
      channelDescription: 'Notifications for confirmed orders',
      importance: Importance.max,
      priority: Priority.max,
      icon: '@mipmap/ic_launcher',
      color: Color(0xFF83B81A), // Acer green color
      playSound: true,
      enableVibration: true,
      styleInformation: BigTextStyleInformation(
        'Thank you for your order! Your $itemCount items worth ₹${totalAmount.toStringAsFixed(0)} have been confirmed and will be processed shortly. $deliveryInfo',
        htmlFormatBigText: true,
        contentTitle: '🎉 Order Confirmed Successfully!',
        htmlFormatContentTitle: true,
        summaryText: 'Order #$orderId • $itemCount items • ₹${totalAmount.toStringAsFixed(0)}',
        htmlFormatSummaryText: true,
      ),
      actions: [
        AndroidNotificationAction(
          'track_order',
          'Track Order',
          showsUserInterface: true,
        ),
        AndroidNotificationAction(
          'view_details',
          'View Details',
          showsUserInterface: true,
        ),
        AndroidNotificationAction(
          'share_order',
          'Share',
          showsUserInterface: false,
        ),
      ],
    );

    const DarwinNotificationDetails iOSPlatformChannelSpecifics =
        DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      subtitle: 'Your order is being processed',
    );

    final LinuxNotificationDetails linuxPlatformChannelSpecifics =
        LinuxNotificationDetails(
      actions: [
        LinuxNotificationAction(
          key: 'track_order',
          label: 'Track Order',
        ),
        LinuxNotificationAction(
          key: 'view_details',
          label: 'View Details',
        ),
        LinuxNotificationAction(
          key: 'share_order',
          label: 'Share',
        ),
      ],
    );

    final NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
      linux: linuxPlatformChannelSpecifics,
    );

    await _notificationsPlugin.show(
      orderId.hashCode + 1000, // Different ID for confirmation notifications
      '🎉 Order Confirmed Successfully!',
      'Thank you for your order! Your $itemCount items worth ₹${totalAmount.toStringAsFixed(0)} have been confirmed.',
      platformChannelSpecifics,
      payload: 'order_confirmed:$orderId:$totalAmount:$itemCount',
    );
  }

  static Future<void> showSignUpWelcomeNotification({
    required String userName,
    String? userEmail,
  }) async {
    if (!_isInitialized) {
      await initialize();
    }

    final welcomeMessages = [
      'Welcome aboard, $userName! 🚀',
      'Hello $userName! Ready to explore? 👋',
      'Great to have you, $userName! 🎉',
      'Welcome to Acer, $userName! 💻',
    ];

    final welcomeBodies = [
      'Discover premium Acer laptops, monitors, and accessories. Your perfect tech companion awaits!',
      'Explore our latest collection of gaming laptops, business machines, and cutting-edge monitors.',
      'Get ready for exclusive deals, early access to new products, and personalized recommendations.',
      'Join thousands of satisfied customers who trust Acer for their technology needs.',
    ];

    final randomIndex = DateTime.now().millisecond % welcomeMessages.length;

    final AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'signup_welcome',
      'Sign Up Welcome',
      channelDescription: 'Welcome notifications for new sign-ups',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
      color: Color(0xFF83B81A), // Acer green color
      playSound: true,
      enableVibration: true,
      styleInformation: BigTextStyleInformation(
        '${welcomeBodies[randomIndex]} Start your journey with Acer today and experience innovation at its finest!',
        htmlFormatBigText: true,
        contentTitle: welcomeMessages[randomIndex],
        htmlFormatContentTitle: true,
        summaryText: 'Welcome to the Acer family!',
        htmlFormatSummaryText: true,
      ),
      actions: [
        AndroidNotificationAction(
          'browse_products',
          'Browse Products',
          showsUserInterface: true,
        ),
        AndroidNotificationAction(
          'view_deals',
          'View Deals',
          showsUserInterface: true,
        ),
        AndroidNotificationAction(
          'complete_profile',
          'Complete Profile',
          showsUserInterface: true,
        ),
      ],
    );

    const DarwinNotificationDetails iOSPlatformChannelSpecifics =
        DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      subtitle: 'Welcome to the Acer family!',
    );

    final LinuxNotificationDetails linuxPlatformChannelSpecifics =
        LinuxNotificationDetails(
      actions: [
        LinuxNotificationAction(
          key: 'browse_products',
          label: 'Browse Products',
        ),
        LinuxNotificationAction(
          key: 'view_deals',
          label: 'View Deals',
        ),
        LinuxNotificationAction(
          key: 'complete_profile',
          label: 'Complete Profile',
        ),
      ],
    );

    final NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
      linux: linuxPlatformChannelSpecifics,
    );

    await _notificationsPlugin.show(
      userName.hashCode + 2000, // Unique ID for sign-up notifications
      welcomeMessages[randomIndex],
      welcomeBodies[randomIndex],
      platformChannelSpecifics,
      payload: 'signup_welcome:$userName:${userEmail ?? ''}',
    );
  }

  static Future<void> cancelCartNotifications() async {
    // Cancel cart-related notifications
    await _notificationsPlugin.cancel(997); // Cart reminders
    await _notificationsPlugin.cancel(996); // Discount notifications
    await _notificationsPlugin.cancel(995); // Cart abandonment
  }
} 