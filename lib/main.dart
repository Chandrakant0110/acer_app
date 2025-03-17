import 'package:flutter/material.dart';
import 'dart:async';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'location_page.dart';
import 'all_categories_page.dart';
import 'all_products_page.dart';
import 'dart:ui';

// Define Acer brand colors
const Color acerPrimaryColor = Color(0xFF83B81A); // Acer green
const Color acerSecondaryColor = Color(0xFF1A1A1A); // Dark gray/black
const Color acerAccentColor = Color(0xFF0079C1); // Acer blue

// Custom theme for the Acer Store app
ThemeData acerTheme = ThemeData(
  useMaterial3: true,
  colorScheme: ColorScheme.light(
    primary: acerPrimaryColor,
    onPrimary: Colors.white,
    secondary: acerSecondaryColor,
    onSecondary: Colors.white,
    tertiary: acerAccentColor,
    surface: Colors.white,
    background: Colors.grey[50]!,
    error: Colors.red[700]!,
  ),
  textTheme: const TextTheme(
    headlineLarge: TextStyle(
      fontWeight: FontWeight.bold,
      letterSpacing: -0.5,
    ),
    headlineMedium: TextStyle(
      fontWeight: FontWeight.bold,
      letterSpacing: -0.25,
    ),
    titleLarge: TextStyle(
      fontWeight: FontWeight.bold,
    ),
    titleMedium: TextStyle(
      fontWeight: FontWeight.w600,
    ),
    bodyLarge: TextStyle(
      fontSize: 16,
    ),
    bodyMedium: TextStyle(
      fontSize: 14,
    ),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: acerPrimaryColor,
      foregroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    ),
  ),
  cardTheme: CardTheme(
    elevation: 2,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
    clipBehavior: Clip.antiAlias,
  ),
  appBarTheme: const AppBarTheme(
    backgroundColor: acerPrimaryColor,
    foregroundColor: Colors.white,
    centerTitle: false,
    elevation: 0,
  ),
  navigationBarTheme: NavigationBarThemeData(
    indicatorColor: acerPrimaryColor.withOpacity(0.2),
    labelTextStyle: MaterialStateProperty.all(
      const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
    ),
  ),
);

// Product model class
class Product {
  final String name;
  final String imageUrl;
  final double price;
  final String description;
  final String category;

  Product({
    required this.name,
    required this.imageUrl,
    required this.price,
    required this.description,
    required this.category,
  });
}

// Cart Provider to manage cart state
class CartProvider extends ChangeNotifier {
  final Map<Product, int> _items = {};

  Map<Product, int> get items => _items;
  int get itemCount => _items.values.fold(0, (sum, quantity) => sum + quantity);
  double get totalAmount => _items.entries
      .fold(0, (sum, entry) => sum + (entry.key.price * entry.value));

  void addItem(Product product) {
    _items[product] = (_items[product] ?? 0) + 1;
    notifyListeners();
  }

  void removeItem(Product product) {
    if (_items.containsKey(product)) {
      if (_items[product] == 1) {
        _items.remove(product);
      } else {
        _items[product] = _items[product]! - 1;
      }
      notifyListeners();
    }
  }

  void removeItemCompletely(Product product) {
    _items.remove(product);
    notifyListeners();
  }

  void clearCart() {
    _items.clear();
    notifyListeners();
  }
}

// Add this after CartProvider class
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
    await _prefs.clear();
  }
}

// Add NotificationsProvider class after UserProvider class
class NotificationsProvider extends ChangeNotifier {
  final List<NotificationItem> _notifications = [];
  bool _hasUnreadNotifications = false;

  NotificationsProvider() {
    // Adding sample notifications for demo purposes
    _addSampleNotifications();
  }

  List<NotificationItem> get notifications => _notifications;
  bool get hasUnreadNotifications => _hasUnreadNotifications;
  int get unreadCount => _notifications.where((item) => !item.isRead).length;

  void _addSampleNotifications() {
    _notifications.addAll([
      NotificationItem(
        id: '1',
        title: 'Exclusive Offer: 15% Off Acer Monitors',
        body:
            'Limited time offer on all Acer monitors. Use code ACER15 at checkout.',
        timestamp: DateTime.now().subtract(const Duration(minutes: 30)),
        type: NotificationType.offer,
        isRead: false,
      ),
      NotificationItem(
        id: '2',
        title: 'New Arrival: Predator Helios 300',
        body: 'The latest Predator Helios 300 is now available with RTX 4060.',
        timestamp: DateTime.now().subtract(const Duration(hours: 5)),
        type: NotificationType.product,
        isRead: false,
      ),
      NotificationItem(
        id: '3',
        title: 'Your Order #AC45678 Has Been Shipped',
        body:
            'Your order has been shipped and will be delivered in 2-3 business days.',
        timestamp: DateTime.now().subtract(const Duration(days: 1)),
        type: NotificationType.order,
        isRead: true,
      ),
      NotificationItem(
        id: '4',
        title: 'Service Reminder',
        body:
            'Your Acer laptop is due for a service check. Book an appointment now.',
        timestamp: DateTime.now().subtract(const Duration(days: 3)),
        type: NotificationType.service,
        isRead: true,
      ),
    ]);
    _hasUnreadNotifications = true;
  }

  void markAsRead(String id) {
    final index =
        _notifications.indexWhere((notification) => notification.id == id);
    if (index != -1) {
      _notifications[index] = _notifications[index].copyWith(isRead: true);
      _updateUnreadStatus();
      notifyListeners();
    }
  }

  void markAllAsRead() {
    for (var i = 0; i < _notifications.length; i++) {
      _notifications[i] = _notifications[i].copyWith(isRead: true);
    }
    _hasUnreadNotifications = false;
    notifyListeners();
  }

  void removeNotification(String id) {
    _notifications.removeWhere((notification) => notification.id == id);
    _updateUnreadStatus();
    notifyListeners();
  }

  void _updateUnreadStatus() {
    _hasUnreadNotifications =
        _notifications.any((notification) => !notification.isRead);
  }

  void addNotification(NotificationItem notification) {
    _notifications.insert(0, notification);
    _hasUnreadNotifications = true;
    notifyListeners();
  }
}

// Notification Models
enum NotificationType { offer, product, order, service }

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
}

class User {
  final String name;
  final String email;
  final String phone;
  final String? imageUrl;

  User({
    required this.name,
    required this.email,
    required this.phone,
    this.imageUrl,
  });
}

// Sample product data
final List<Product> products = [
  // Entry Level Gaming
  Product(
    name: 'Acer Nitro 5',
    imageUrl:
        'https://plus.unsplash.com/premium_photo-1711051475117-f3a4d3ff6778?fm=jpg&q=60&w=3000&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
    price: 69999,
    description: 'Entry Level Gaming Laptop with RTX 3050, 16GB RAM, 512GB SSD',
    category: 'Entry Level Gaming',
  ),
  Product(
    name: 'Acer Aspire 7',
    imageUrl:
        'https://plus.unsplash.com/premium_photo-1711051475117-f3a4d3ff6778?fm=jpg&q=60&w=3000&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
    price: 54999,
    description: 'Budget Gaming Laptop with GTX 1650, 8GB RAM, 256GB SSD',
    category: 'Entry Level Gaming',
  ),
  Product(
    name: 'Acer Nitro V',
    imageUrl:
        'https://plus.unsplash.com/premium_photo-1711051475117-f3a4d3ff6778?fm=jpg&q=60&w=3000&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
    price: 62999,
    description: 'Entry Level Gaming Laptop with RTX 2050, 12GB RAM, 512GB SSD',
    category: 'Entry Level Gaming',
  ),

  // Mid-Range Gaming
  Product(
    name: 'Acer Nitro 5 (RTX 3060)',
    imageUrl:
        'https://plus.unsplash.com/premium_photo-1711051475117-f3a4d3ff6778?fm=jpg&q=60&w=3000&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
    price: 79999,
    description: 'Mid-Range Gaming Laptop with RTX 3060, 16GB RAM, 512GB SSD',
    category: 'Mid-Range Gaming',
  ),
  Product(
    name: 'Acer Predator Helios 300',
    imageUrl:
        'https://plus.unsplash.com/premium_photo-1711051475117-f3a4d3ff6778?fm=jpg&q=60&w=3000&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
    price: 89999,
    description: 'High-end Gaming Laptop with RTX 3060, 16GB RAM, 1TB SSD',
    category: 'Mid-Range Gaming',
  ),
  Product(
    name: 'Acer Predator Helios Neo 16',
    imageUrl:
        'https://plus.unsplash.com/premium_photo-1711051475117-f3a4d3ff6778?fm=jpg&q=60&w=3000&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
    price: 94999,
    description: 'Mid-Range Gaming Laptop with RTX 3070, 16GB RAM, 1TB SSD',
    category: 'Mid-Range Gaming',
  ),

  // High-End Gaming
  Product(
    name: 'Acer Predator Triton 500 SE',
    imageUrl:
        'https://plus.unsplash.com/premium_photo-1711051475117-f3a4d3ff6778?fm=jpg&q=60&w=3000&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
    price: 149999,
    description: 'Premium Gaming Laptop with RTX 3070 Ti, 32GB RAM, 1TB SSD',
    category: 'High-End Gaming',
  ),
  Product(
    name: 'Acer Predator Helios 500',
    imageUrl:
        'https://plus.unsplash.com/premium_photo-1711051475117-f3a4d3ff6778?fm=jpg&q=60&w=3000&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
    price: 199999,
    description: 'Ultimate Gaming Laptop with RTX 3080, 32GB RAM, 2TB SSD',
    category: 'High-End Gaming',
  ),
  Product(
    name: 'Acer Predator Triton 700',
    imageUrl:
        'https://plus.unsplash.com/premium_photo-1711051475117-f3a4d3ff6778?fm=jpg&q=60&w=3000&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
    price: 219999,
    description: 'Elite Gaming Laptop with RTX 3080 Ti, 64GB RAM, 2TB SSD',
    category: 'High-End Gaming',
  ),

  // Business & Productivity
  Product(
    name: 'Acer Swift 3',
    imageUrl:
        'https://plus.unsplash.com/premium_photo-1711051475117-f3a4d3ff6778?fm=jpg&q=60&w=3000&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
    price: 54999,
    description: 'Ultra-thin Laptop with Intel i5, 8GB RAM, 256GB SSD',
    category: 'Business & Productivity',
  ),
  Product(
    name: 'Acer Spin 5',
    imageUrl:
        'https://plus.unsplash.com/premium_photo-1711051475117-f3a4d3ff6778?fm=jpg&q=60&w=3000&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
    price: 64999,
    description: '2-in-1 Convertible Laptop with Intel i7, 16GB RAM, 512GB SSD',
    category: 'Business & Productivity',
  ),
  Product(
    name: 'Acer TravelMate P6',
    imageUrl:
        'https://plus.unsplash.com/premium_photo-1711051475117-f3a4d3ff6778?fm=jpg&q=60&w=3000&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
    price: 74999,
    description:
        'Professional Business Laptop with Intel i7, 16GB RAM, 1TB SSD',
    category: 'Business & Productivity',
  ),

  // Monitors
  Product(
    name: 'Acer Predator XB273K',
    imageUrl:
        'https://plus.unsplash.com/premium_photo-1711051475117-f3a4d3ff6778?fm=jpg&q=60&w=3000&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
    price: 49999,
    description: '27" 4K Gaming Monitor, 144Hz, G-Sync Compatible',
    category: 'Monitors',
  ),
  Product(
    name: 'Acer Nitro XV272U',
    imageUrl:
        'https://plus.unsplash.com/premium_photo-1711051475117-f3a4d3ff6778?fm=jpg&q=60&w=3000&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
    price: 24999,
    description: '27" WQHD IPS Gaming Monitor, 170Hz, 1ms Response Time',
    category: 'Monitors',
  ),
  Product(
    name: 'Acer ProDesigner PE320QK',
    imageUrl:
        'https://plus.unsplash.com/premium_photo-1711051475117-f3a4d3ff6778?fm=jpg&q=60&w=3000&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
    price: 59999,
    description: '32" 4K UHD Professional Monitor, 100% Adobe RGB, USB-C',
    category: 'Monitors',
  ),
  Product(
    name: 'Acer CB342CK',
    imageUrl:
        'https://plus.unsplash.com/premium_photo-1711051475117-f3a4d3ff6778?fm=jpg&q=60&w=3000&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
    price: 19999,
    description: '34" UltraWide QHD Monitor, 75Hz, HDR10, FreeSync',
    category: 'Monitors',
  ),

  // Accessories
  Product(
    name: 'Acer Predator Cestus 350',
    imageUrl:
        'https://plus.unsplash.com/premium_photo-1711051475117-f3a4d3ff6778?fm=jpg&q=60&w=3000&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
    price: 4999,
    description: 'Wireless Gaming Mouse, 16000 DPI, RGB Lighting',
    category: 'Accessories',
  ),
  Product(
    name: 'Acer Predator Aethon 500',
    imageUrl:
        'https://plus.unsplash.com/premium_photo-1711051475117-f3a4d3ff6778?fm=jpg&q=60&w=3000&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
    price: 7999,
    description: 'Mechanical Gaming Keyboard with Blue Switches, RGB Lighting',
    category: 'Accessories',
  ),
  Product(
    name: 'Acer Nitro Headset',
    imageUrl:
        'https://plus.unsplash.com/premium_photo-1711051475117-f3a4d3ff6778?fm=jpg&q=60&w=3000&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
    price: 3999,
    description: '7.1 Surround Sound Gaming Headset with Retractable Mic',
    category: 'Accessories',
  ),
  Product(
    name: 'Acer Predator Gaming Chair',
    imageUrl:
        'https://plus.unsplash.com/premium_photo-1711051475117-f3a4d3ff6778?fm=jpg&q=60&w=3000&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
    price: 19999,
    description:
        'Ergonomic Gaming Chair with Lumbar Support, Adjustable Armrests',
    category: 'Accessories',
  ),
];

// Add categories list at the top level
final List<String> categories = [
  'All',
  'Entry Level Gaming',
  'Mid-Range Gaming',
  'High-End Gaming',
  'Business & Productivity',
  'Monitors',
  'Accessories',
];

// Sample products data
final List<Product> sampleProducts = [
  // Gaming Laptops
  Product(
    name: 'Predator Helios 16',
    imageUrl:
        'https://plus.unsplash.com/premium_photo-1711051475117-f3a4d3ff6778?fm=jpg&q=60&w=3000&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
    price: 199999.99,
    description: 'Intel Core i9-14900HX, NVIDIA RTX 4090, 32GB RAM, 2TB SSD',
    category: 'High-End Gaming',
  ),
  Product(
    name: 'Predator Triton 17 X',
    imageUrl:
        'https://plus.unsplash.com/premium_photo-1711051475117-f3a4d3ff6778?fm=jpg&q=60&w=3000&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
    price: 189999.99,
    description: 'Intel Core i9-13900HX, NVIDIA RTX 4080, 32GB RAM, 2TB SSD',
    category: 'High-End Gaming',
  ),
  Product(
    name: 'Nitro 5',
    imageUrl:
        'https://plus.unsplash.com/premium_photo-1711051475117-f3a4d3ff6778?fm=jpg&q=60&w=3000&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
    price: 89999.99,
    description: 'Intel Core i5-13500H, NVIDIA RTX 4060, 16GB RAM, 512GB SSD',
    category: 'Mid-Range Gaming',
  ),
  Product(
    name: 'Nitro 7',
    imageUrl:
        'https://plus.unsplash.com/premium_photo-1711051475117-f3a4d3ff6778?fm=jpg&q=60&w=3000&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
    price: 109999.99,
    description: 'Intel Core i7-13700H, NVIDIA RTX 4070, 16GB RAM, 1TB SSD',
    category: 'Mid-Range Gaming',
  ),
  Product(
    name: 'Aspire Gaming 5',
    imageUrl:
        'https://plus.unsplash.com/premium_photo-1711051475117-f3a4d3ff6778?fm=jpg&q=60&w=3000&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
    price: 59999.99,
    description: 'Intel Core i5-12450H, NVIDIA RTX 3050, 8GB RAM, 512GB SSD',
    category: 'Entry Level Gaming',
  ),

  // Business Laptops
  Product(
    name: 'Swift Edge 16',
    imageUrl:
        'https://plus.unsplash.com/premium_photo-1711051475117-f3a4d3ff6778?fm=jpg&q=60&w=3000&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
    price: 129999.99,
    description: 'AMD Ryzen 7 7840U, 16GB RAM, 1TB SSD, 3.2K OLED Display',
    category: 'Business & Productivity',
  ),
  Product(
    name: 'Swift Go 14',
    imageUrl:
        'https://plus.unsplash.com/premium_photo-1711051475117-f3a4d3ff6778?fm=jpg&q=60&w=3000&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
    price: 89999.99,
    description: 'Intel Core i7-13700H, 16GB RAM, 1TB SSD, 2.8K OLED Display',
    category: 'Business & Productivity',
  ),
  Product(
    name: 'TravelMate P4',
    imageUrl:
        'https://plus.unsplash.com/premium_photo-1711051475117-f3a4d3ff6778?fm=jpg&q=60&w=3000&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
    price: 79999.99,
    description: 'Intel Core i5-1335U, 16GB RAM, 512GB SSD, Full HD Display',
    category: 'Business & Productivity',
  ),
  Product(
    name: 'TravelMate P2',
    imageUrl:
        'https://plus.unsplash.com/premium_photo-1711051475117-f3a4d3ff6778?fm=jpg&q=60&w=3000&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
    price: 54999.99,
    description: 'Intel Core i3-1315U, 8GB RAM, 256GB SSD, Full HD Display',
    category: 'Business & Productivity',
  ),

  // Monitors
  Product(
    name: 'Predator X45',
    imageUrl:
        'https://plus.unsplash.com/premium_photo-1711051475117-f3a4d3ff6778?fm=jpg&q=60&w=3000&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
    price: 149999.99,
    description: '45" OLED Gaming Monitor, 3440x1440, 240Hz, 0.01ms',
    category: 'Monitors',
  ),
  Product(
    name: 'Predator X27',
    imageUrl:
        'https://plus.unsplash.com/premium_photo-1711051475117-f3a4d3ff6778?fm=jpg&q=60&w=3000&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
    price: 89999.99,
    description: '27" 4K Gaming Monitor, 160Hz, G-SYNC Ultimate',
    category: 'Monitors',
  ),
  Product(
    name: 'Nitro XV272U',
    imageUrl:
        'https://plus.unsplash.com/premium_photo-1711051475117-f3a4d3ff6778?fm=jpg&q=60&w=3000&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
    price: 29999.99,
    description: '27" QHD Gaming Monitor, 170Hz, AMD FreeSync Premium',
    category: 'Monitors',
  ),
  Product(
    name: 'CB342CK',
    imageUrl:
        'https://plus.unsplash.com/premium_photo-1711051475117-f3a4d3ff6778?fm=jpg&q=60&w=3000&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
    price: 34999.99,
    description: '34" UltraWide QHD Monitor, 100Hz, USB-C',
    category: 'Monitors',
  ),

  // Accessories
  Product(
    name: 'Predator Cestus 350',
    imageUrl:
        'https://plus.unsplash.com/premium_photo-1711051475117-f3a4d3ff6778?fm=jpg&q=60&w=3000&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
    price: 7999.99,
    description: 'Wireless Gaming Mouse, 16000 DPI, RGB',
    category: 'Accessories',
  ),
  Product(
    name: 'Predator Aethon 500',
    imageUrl:
        'https://plus.unsplash.com/premium_photo-1711051475117-f3a4d3ff6778?fm=jpg&q=60&w=3000&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
    price: 12999.99,
    description: 'Mechanical Gaming Keyboard, Blue Switches, RGB',
    category: 'Accessories',
  ),
  Product(
    name: 'Predator Galea 350',
    imageUrl:
        'https://plus.unsplash.com/premium_photo-1711051475117-f3a4d3ff6778?fm=jpg&q=60&w=3000&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
    price: 5999.99,
    description: '7.1 Virtual Surround Gaming Headset',
    category: 'Accessories',
  ),
  Product(
    name: 'Nitro Gaming Mouse Pad',
    imageUrl:
        'https://plus.unsplash.com/premium_photo-1711051475117-f3a4d3ff6778?fm=jpg&q=60&w=3000&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
    price: 1499.99,
    description: 'XXL Size, Anti-slip Base, Cloth Surface',
    category: 'Accessories',
  ),
];

// Add DotPatternPainter class at the top level (outside of any other classes)
class DotPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final dotSize = 2.0;
    final spacing = 20.0;
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = dotSize
      ..strokeCap = StrokeCap.round;

    for (double x = 0; x < size.width; x += spacing) {
      for (double y = 0; y < size.height; y += spacing) {
        canvas.drawPoints(
          PointMode.points,
          [Offset(x, y)],
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

// Add missing classes required by navigation
class SearchPage extends StatefulWidget {
  const SearchPage({Key? key}) : super(key: key);

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  List<Product> _searchResults = [];

  void _performSearch(String query) {
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
      });
      return;
    }

    List<Product> results = products.where((product) {
      return product.name.toLowerCase().contains(query.toLowerCase()) ||
          product.category.toLowerCase().contains(query.toLowerCase()) ||
          product.description.toLowerCase().contains(query.toLowerCase());
    }).toList();

    setState(() {
      _searchResults = results;
    });
  }

  Widget _buildProductCard(BuildContext context, Product product) {
    return Container(
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.network(
              product.imageUrl,
              fit: BoxFit.cover,
              height: 120,
              width: double.infinity,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Text(
                  '₹${product.price.toStringAsFixed(0)}',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: acerPrimaryColor,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search Products'),
        backgroundColor: acerPrimaryColor,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search for products...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                filled: true,
                fillColor: Colors.grey[100],
              ),
              onChanged: _performSearch,
            ),
          ),
          Expanded(
            child: _searchResults.isEmpty
                ? const Center(
                    child: Text(
                      'Search for Acer products by name, category, or features',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                  )
                : GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.7,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                    ),
                    itemCount: _searchResults.length,
                    itemBuilder: (context, index) {
                      return _buildProductCard(context, _searchResults[index]);
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class CartPage extends StatelessWidget {
  const CartPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Shopping Cart'),
        backgroundColor: acerPrimaryColor,
        foregroundColor: Colors.white,
      ),
      body: Consumer<CartProvider>(
        builder: (context, cart, child) {
          if (cart.items.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.shopping_cart_outlined,
                    size: 100,
                    color: Colors.grey[300],
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Your cart is empty',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Add products to your cart to see them here',
                    style: TextStyle(
                      color: Colors.grey[500],
                    ),
                  ),
                  const SizedBox(height: 30),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const HomePage(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.shopping_bag),
                    label: const Text('Continue Shopping'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: acerPrimaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  itemCount: cart.items.length,
                  itemBuilder: (context, index) {
                    final product = cart.items.keys.elementAt(index);
                    final quantity = cart.items[product] ?? 0;
                    final itemTotal = product.price * quantity;

                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Product image
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                width: 100,
                                height: 100,
                                color: acerPrimaryColor.withOpacity(0.1),
                                child: Image.network(
                                  product.imageUrl,
                                  fit: BoxFit.contain,
                                  errorBuilder: (context, error, stackTrace) =>
                                      Container(
                                    color: acerPrimaryColor.withOpacity(0.1),
                                    child: const Icon(
                                      Icons.image_not_supported,
                                      size: 40,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            // Product details
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    product.name,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Unit Price: ₹${product.price.toStringAsFixed(0)}',
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      // Quantity controls
                                      Container(
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                              color: Colors.grey[300]!),
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: Row(
                                          children: [
                                            // Decrease button
                                            InkWell(
                                              onTap: () {
                                                cart.removeItem(product);
                                              },
                                              child: Container(
                                                padding:
                                                    const EdgeInsets.all(8),
                                                decoration: BoxDecoration(
                                                  color: Colors.grey[200],
                                                  borderRadius:
                                                      const BorderRadius.only(
                                                    topLeft: Radius.circular(7),
                                                    bottomLeft:
                                                        Radius.circular(7),
                                                  ),
                                                ),
                                                child: const Icon(Icons.remove,
                                                    size: 16),
                                              ),
                                            ),
                                            // Quantity display
                                            Container(
                                              width: 40,
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 8),
                                              alignment: Alignment.center,
                                              child: Text(
                                                '$quantity',
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                            // Increase button
                                            InkWell(
                                              onTap: () {
                                                cart.addItem(product);
                                              },
                                              child: Container(
                                                padding:
                                                    const EdgeInsets.all(8),
                                                decoration: const BoxDecoration(
                                                  color: acerPrimaryColor,
                                                  borderRadius:
                                                      BorderRadius.only(
                                                    topRight:
                                                        Radius.circular(7),
                                                    bottomRight:
                                                        Radius.circular(7),
                                                  ),
                                                ),
                                                child: const Icon(
                                                  Icons.add,
                                                  size: 16,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      // Item total
                                      Text(
                                        '₹${itemTotal.toStringAsFixed(0)}',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                          color: acerPrimaryColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            // Remove button
                            IconButton(
                              icon: const Icon(
                                Icons.delete_outline,
                                color: Colors.redAccent,
                              ),
                              onPressed: () {
                                cart.removeItemCompletely(product);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                        '${product.name} removed from cart'),
                                    duration: const Duration(seconds: 2),
                                    action: SnackBarAction(
                                      label: 'UNDO',
                                      onPressed: () {
                                        cart.addItem(product);
                                      },
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              // Order summary
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, -5),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Order Summary',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Total Items:',
                          style: TextStyle(
                            color: Colors.grey[600],
                          ),
                        ),
                        Text(
                          '${cart.itemCount}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Subtotal:',
                          style: TextStyle(
                            color: Colors.grey[600],
                          ),
                        ),
                        Text(
                          '₹${cart.totalAmount.toStringAsFixed(0)}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Shipping:',
                          style: TextStyle(
                            color: Colors.grey[600],
                          ),
                        ),
                        const Text(
                          'FREE',
                          style: TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 32),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Total:',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '₹${cart.totalAmount.toStringAsFixed(0)}',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: acerPrimaryColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          // Implement checkout functionality
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Proceeding to checkout...'),
                              duration: Duration(seconds: 2),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: acerPrimaryColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'PROCEED TO CHECKOUT',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage>
    with SingleTickerProviderStateMixin {
  bool _darkMode = false;
  bool _notifications = true;
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _loadSettings();

    // Initialize animation controller
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _darkMode = prefs.getBool('darkMode') ?? false;
      _notifications = prefs.getBool('notifications') ?? true;
    });

    // Apply theme immediately
    _applyTheme();
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('darkMode', _darkMode);
    await prefs.setBool('notifications', _notifications);
  }

  void _applyTheme() {
    // Apply theme changes immediately
    if (!mounted) return;
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    themeProvider.setDarkMode(_darkMode);
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context).currentUser;

    return Scaffold(
      body: Stack(
        children: [
          // Background gradient
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  acerPrimaryColor.withAlpha(20),
                  Colors.white,
                ],
              ),
            ),
          ),

          // Main content
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // App Bar
              SliverAppBar(
                expandedHeight: 120,
                pinned: true,
                backgroundColor: acerPrimaryColor,
                flexibleSpace: FlexibleSpaceBar(
                  title: const Text(
                    'Settings',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  titlePadding: const EdgeInsets.only(left: 16.0, bottom: 16.0),
                  centerTitle: false,
                  background: Stack(
                    children: [
                      // Decorative background
                      Positioned.fill(
                        child: Container(
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                acerPrimaryColor,
                                acerAccentColor,
                              ],
                            ),
                          ),
                        ),
                      ),

                      // Decorative pattern
                      Positioned.fill(
                        child: Opacity(
                          opacity: 0.1,
                          child: CustomPaint(
                            painter: DotPatternPainter(),
                          ),
                        ),
                      ),

                      // Diagonal line decoration
                      Positioned(
                        right: -50,
                        top: 0,
                        bottom: 0,
                        width: 200,
                        child: Transform.rotate(
                          angle: -0.2,
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.white.withOpacity(0.1),
                                  Colors.white.withOpacity(0.05),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.help_outline),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Help & Support coming soon'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    },
                  ),
                ],
              ),

              // Content
              SliverToBoxAdapter(
                child: FadeTransition(
                  opacity: _animation,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // User Profile Card
                        if (user != null) _buildProfileCard(user),

                        const SizedBox(height: 24),

                        // Account Section
                        _buildSectionHeader('Account', Icons.person),
                        _buildAnimatedSettingsCard(
                          children: [
                            _buildListTile(
                              icon: Icons.person_outline,
                              title: 'Profile Information',
                              onTap: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content:
                                        Text('Profile management coming soon'),
                                  ),
                                );
                              },
                            ),
                            const Divider(height: 1),
                            _buildListTile(
                              icon: Icons.location_on_outlined,
                              title: 'Address Management',
                              onTap: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content:
                                        Text('Address management coming soon'),
                                  ),
                                );
                              },
                            ),
                            const Divider(height: 1),
                            _buildListTile(
                              icon: Icons.payment_outlined,
                              title: 'Payment Methods',
                              subtitle: 'Credit cards, UPI, and more',
                              onTap: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content:
                                        Text('Payment management coming soon'),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),

                        const SizedBox(height: 24),

                        // Appearance Section
                        _buildSectionHeader(
                            'Appearance', Icons.palette_outlined),
                        _buildAnimatedSettingsCard(
                          children: [
                            SwitchListTile(
                              title: const Text('Dark Mode'),
                              subtitle:
                                  const Text('Enable dark theme for the app'),
                              secondary: AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                decoration: BoxDecoration(
                                  color: _darkMode
                                      ? Colors.indigo.withAlpha(30)
                                      : Colors.amber.withAlpha(30),
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: (_darkMode
                                              ? Colors.indigo
                                              : Colors.amber)
                                          .withAlpha(100),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                padding: const EdgeInsets.all(8),
                                child: Icon(
                                  _darkMode
                                      ? Icons.dark_mode
                                      : Icons.light_mode,
                                  color:
                                      _darkMode ? Colors.indigo : Colors.amber,
                                ),
                              ),
                              value: _darkMode,
                              activeColor: acerPrimaryColor,
                              onChanged: (value) {
                                setState(() {
                                  _darkMode = value;
                                  _saveSettings();
                                  _applyTheme();
                                });
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Theme updated'),
                                    duration: Duration(seconds: 1),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),

                        const SizedBox(height: 24),

                        // Notifications Section
                        _buildSectionHeader(
                            'Notifications', Icons.notifications_outlined),
                        _buildAnimatedSettingsCard(
                          children: [
                            SwitchListTile(
                              title: const Text('Push Notifications'),
                              subtitle: const Text(
                                  'Receive alerts about deals and new products'),
                              secondary: AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                decoration: BoxDecoration(
                                  color: _notifications
                                      ? acerAccentColor.withAlpha(30)
                                      : Colors.grey.withAlpha(30),
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: (_notifications
                                              ? acerAccentColor
                                              : Colors.grey)
                                          .withAlpha(100),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                padding: const EdgeInsets.all(8),
                                child: Icon(
                                  _notifications
                                      ? Icons.notifications_active
                                      : Icons.notifications_off,
                                  color: _notifications
                                      ? acerAccentColor
                                      : Colors.grey,
                                ),
                              ),
                              value: _notifications,
                              activeColor: acerPrimaryColor,
                              onChanged: (value) {
                                setState(() {
                                  _notifications = value;
                                  _saveSettings();
                                });
                              },
                            ),
                            const Divider(height: 1),
                            _buildListTile(
                              icon: Icons.email_outlined,
                              title: 'Email Notifications',
                              subtitle: 'Manage email preferences',
                              onTap: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content:
                                        Text('Email preferences coming soon'),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),

                        const SizedBox(height: 24),

                        // About Section
                        _buildSectionHeader('About', Icons.info_outline),
                        _buildAnimatedSettingsCard(
                          children: [
                            _buildListTile(
                              icon: Icons.security_outlined,
                              title: 'Privacy Policy',
                              onTap: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Privacy Policy coming soon'),
                                  ),
                                );
                              },
                            ),
                            const Divider(height: 1),
                            _buildListTile(
                              icon: Icons.description_outlined,
                              title: 'Terms of Service',
                              onTap: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content:
                                        Text('Terms of Service coming soon'),
                                  ),
                                );
                              },
                            ),
                            const Divider(height: 1),
                            _buildListTile(
                              icon: Icons.help_outline,
                              title: 'Help & Support',
                              onTap: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Help Center coming soon'),
                                  ),
                                );
                              },
                            ),
                            const Divider(height: 1),
                            _buildListTile(
                              icon: Icons.info_outline,
                              title: 'About Acer Store',
                              subtitle: 'Version 1.0.0',
                              onTap: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('About page coming soon'),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),

                        const SizedBox(height: 30),

                        // Sign Out Button
                        _buildSignOutButton(),

                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProfileCard(User user) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: acerPrimaryColor.withAlpha(40),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withOpacity(0.8),
                  Colors.white.withOpacity(0.6),
                ],
              ),
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
                width: 1.5,
              ),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // User avatar with glowing effect
                Semantics(
                  label: 'Profile picture of ${user.name}',
                  child: Center(
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: acerAccentColor.withAlpha(60),
                            blurRadius: 20,
                            spreadRadius: 2,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: CircleAvatar(
                        radius: 55,
                        backgroundColor: acerPrimaryColor.withOpacity(0.2),
                        child: CircleAvatar(
                          radius: 52,
                          backgroundColor: Colors.white,
                          child: user.imageUrl != null
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(52),
                                  child: Image.network(
                                    user.imageUrl!,
                                    width: 104,
                                    height: 104,
                                    fit: BoxFit.cover,
                                    errorBuilder:
                                        (context, error, stackTrace) =>
                                            const Icon(
                                      Icons.person,
                                      size: 54,
                                      color: acerPrimaryColor,
                                    ),
                                    loadingBuilder:
                                        (context, child, loadingProgress) {
                                      if (loadingProgress == null) return child;
                                      return Center(
                                        child: CircularProgressIndicator(
                                          value: loadingProgress
                                                      .expectedTotalBytes !=
                                                  null
                                              ? loadingProgress
                                                      .cumulativeBytesLoaded /
                                                  loadingProgress
                                                      .expectedTotalBytes!
                                              : null,
                                          color: acerPrimaryColor,
                                        ),
                                      );
                                    },
                                  ),
                                )
                              : const Icon(
                                  Icons.person,
                                  size: 54,
                                  color: acerPrimaryColor,
                                ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // User name with shadow effect
                Text(
                  user.name,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    shadows: [
                      Shadow(
                        color: Colors.black.withOpacity(0.1),
                        offset: const Offset(0, 1),
                        blurRadius: 2,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // User contact info with better visual separation
                Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.grey.withOpacity(0.2),
                    ),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: acerPrimaryColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.email_outlined,
                              size: 16,
                              color: acerPrimaryColor,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Flexible(
                            child: Text(
                              user.email,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                                color: Colors.grey[800],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: acerPrimaryColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.phone_outlined,
                              size: 16,
                              color: acerPrimaryColor,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            user.phone,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey[800],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Edit profile button with improved styling
                Material(
                  borderRadius: BorderRadius.circular(30),
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(30),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EditProfilePage(user: user),
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30),
                        gradient: LinearGradient(
                          colors: [
                            acerPrimaryColor.withOpacity(0.1),
                            acerAccentColor.withOpacity(0.1),
                          ],
                        ),
                        border: Border.all(
                          color: acerAccentColor,
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: acerAccentColor.withOpacity(0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.edit_outlined,
                            size: 18,
                            color: acerAccentColor,
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Edit Profile',
                            style: TextStyle(
                              fontSize: 15,
                              color: acerAccentColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0, left: 8.0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: acerPrimaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: acerPrimaryColor,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              height: 1,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    acerPrimaryColor.withOpacity(0.3),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedSettingsCard({required List<Widget> children}) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: Container(
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
                border: Border.all(
                  color: Colors.grey[200]!,
                  width: 1,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: child,
              ),
            ),
          ),
        );
      },
      child: Column(children: children),
    );
  }

  Widget _buildListTile({
    required IconData icon,
    required String title,
    String? subtitle,
    Widget? trailing,
    required VoidCallback onTap,
  }) {
    return Semantics(
      button: true,
      label: title,
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: acerPrimaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: acerPrimaryColor,
            size: 20,
          ),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 15,
          ),
        ),
        subtitle: subtitle != null
            ? Text(
                subtitle,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey[600],
                ),
              )
            : null,
        trailing: trailing ??
            const Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Colors.grey,
            ),
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 8,
        ),
        dense: true,
      ),
    );
  }

  Widget _buildSignOutButton() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 16, horizontal: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          colors: [
            Colors.redAccent,
            Colors.red,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.red.withAlpha(60),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ElevatedButton.icon(
        icon: const Icon(Icons.logout, color: Colors.white),
        label: const Text(
          'SIGN OUT',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.0,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        onPressed: () {
          _showSignOutConfirmation();
        },
      ),
    );
  }

  Future<void> _showSignOutConfirmation() async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.logout,
                  color: Colors.red,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Text('Sign Out'),
            ],
          ),
          content: const Text(
            'Are you sure you want to sign out of your account?',
            style: TextStyle(fontSize: 15),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('CANCEL'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Colors.red,
              ),
              child: TextButton(
                child: const Text(
                  'SIGN OUT',
                  style: TextStyle(color: Colors.white),
                ),
                onPressed: () async {
                  // Sign out the user
                  final userProvider =
                      Provider.of<UserProvider>(context, listen: false);
                  await userProvider.signOut();

                  // Close the dialog
                  Navigator.of(context).pop();

                  // Navigate to login page
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (context) => const LoginPage()),
                    (route) => false,
                  );
                },
              ),
            ),
          ],
          actionsPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 8,
          ),
        );
      },
    );
  }
}

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
      ),
      body: Consumer<NotificationsProvider>(
        builder: (context, notificationsProvider, child) {
          if (notificationsProvider.notifications.isEmpty) {
            return const Center(
              child: Text('No notifications'),
            );
          }

          return ListView.builder(
            itemCount: notificationsProvider.notifications.length,
            itemBuilder: (context, index) {
              final notification = notificationsProvider.notifications[index];
              return ListTile(
                title: Text(notification.title),
                subtitle: Text(notification.body),
                leading: Icon(
                  _getNotificationIcon(notification.type),
                  color: _getNotificationColor(notification.type),
                ),
                trailing: Text(
                  _formatDate(notification.timestamp),
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  IconData _getNotificationIcon(NotificationType type) {
    switch (type) {
      case NotificationType.offer:
        return Icons.local_offer;
      case NotificationType.product:
        return Icons.new_releases;
      case NotificationType.order:
        return Icons.shopping_bag;
      case NotificationType.service:
        return Icons.build;
    }
  }

  Color _getNotificationColor(NotificationType type) {
    switch (type) {
      case NotificationType.offer:
        return Colors.orange;
      case NotificationType.product:
        return acerPrimaryColor;
      case NotificationType.order:
        return Colors.blue;
      case NotificationType.service:
        return Colors.purple;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

class CategoryPage extends StatefulWidget {
  final String category;
  final String title;

  const CategoryPage({
    Key? key,
    required this.category,
    required this.title,
  }) : super(key: key);

  @override
  State<CategoryPage> createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {
  late List<Product> _filteredProducts;

  @override
  void initState() {
    super.initState();
    _filterProducts();
  }

  void _filterProducts() {
    setState(() {
      _filteredProducts = products.where((product) {
        return product.category.contains(widget.category);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.7,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: _filteredProducts.length,
        itemBuilder: (context, index) {
          final product = _filteredProducts[index];
          return Card(
            clipBehavior: Clip.antiAlias,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AspectRatio(
                  aspectRatio: 1.0,
                  child: Image.network(
                    product.imageUrl,
                    fit: BoxFit.cover,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(2.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '₹${product.price.toStringAsFixed(2)}',
                        style: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// Add ProductDetailsPage class after CartModel class
class ProductDetailsPage extends StatefulWidget {
  final Product product;

  const ProductDetailsPage({Key? key, required this.product}) : super(key: key);

  @override
  State<ProductDetailsPage> createState() => _ProductDetailsPageState();
}

class _ProductDetailsPageState extends State<ProductDetailsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isFavorite = false;
  int _selectedImageIndex = 0;
  final PageController _imagePageController = PageController();

  // Sample specs map - in a real app these would come from the product data
  late Map<String, Map<String, String>> _specifications;

  // Sample reviews - in a real app these would come from a database
  final List<Map<String, dynamic>> _reviews = [
    {
      'name': 'Rahul Sharma',
      'avatar': 'https://randomuser.me/api/portraits/men/32.jpg',
      'rating': 5,
      'date': '15 May 2023',
      'comment':
          'Excellent laptop! The performance is outstanding for gaming and the battery life is impressive. The display quality is exceptional with vibrant colors.',
      'liked': 24,
    },
    {
      'name': 'Priya Patel',
      'avatar': 'https://randomuser.me/api/portraits/women/44.jpg',
      'rating': 4,
      'date': '2 Jun 2023',
      'comment':
          'Great product for the price. The keyboard feels nice to type on and the trackpad is responsive. Only issue is that it runs a bit hot during intensive tasks.',
      'liked': 18,
    },
    {
      'name': 'Amit Kumar',
      'avatar': 'https://randomuser.me/api/portraits/men/62.jpg',
      'rating': 5,
      'date': '23 Apr 2023',
      'comment':
          'Build quality is premium and the design is sleek. Very happy with my purchase. The audio quality is also excellent with rich bass and clear highs.',
      'liked': 10,
    },
  ];

  // Multiple product images for the image carousel
  final List<String> _productImages = [
    'https://www.notebookcheck.net/fileadmin/Notebooks/Acer/Predator_Helios_16_PH16-71/AcerPredatorHelios16_Teaser.jpg',
    'https://www.notebookcheck.net/fileadmin/Notebooks/Acer/Predator_Helios_16_PH16-71/4zu3_Acer_Predator_Helios_16_PH16-71.jpg',
    'https://www.notebookcheck.net/fileadmin/Notebooks/Acer/Predator_Helios_16_PH16-71/Predator_Helios_16__1_.png',
    'https://www.notebookcheck.net/fileadmin/Notebooks/Acer/Predator_Helios_16_PH16-71/Predator_Helios_16__10_.png',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _setupSpecifications();
  }

  void _setupSpecifications() {
    _specifications = {
      'Performance': {
        'Processor': 'Intel Core i7-13700HX / AMD Ryzen 9-7950X',
        'Graphics': 'NVIDIA GeForce RTX 4080 / AMD Radeon RX 7600M XT',
        'RAM': '32GB DDR5 5200MHz (Upgradable to 64GB)',
        'Storage': '1TB PCIe NVMe SSD (Expandable)',
      },
      'Display': {
        'Screen Size': '16-inch WQXGA',
        'Resolution': '2560 x 1600 pixels',
        'Refresh Rate': '240Hz with G-SYNC support',
        'Panel Type': 'IPS Mini-LED with HDR support',
        'Brightness': '600 nits with 100% DCI-P3 color gamut',
      },
      'Design': {
        'Dimensions': '36.2 x 28.0 x 2.85 cm',
        'Weight': '2.6 kg',
        'Keyboard': 'Per-key RGB backlit with anti-ghosting',
        'Cooling': 'Advanced AeroBlade 3D Fan technology',
        'Color': 'Eclipse Black / Abyssal Black',
      },
      'Connectivity': {
        'Wireless': 'Wi-Fi 6E + Bluetooth 5.3',
        'Ports': '2x USB-C (Thunderbolt 4), 3x USB-A 3.2, HDMI 2.1, Ethernet',
        'Audio': 'DTS:X Ultra with dual speakers',
        'Webcam': 'FHD 1080p with dual microphones',
        'Card Reader': 'SD Card reader (UHS-II)',
      },
      'Battery': {
        'Capacity': '90Wh Li-ion battery',
        'Runtime': 'Up to 8 hours of normal usage',
        'Fast Charging': '0 to 50% in 30 minutes',
        'Power Supply': '300W AC adapter',
      },
      'Software': {
        'Operating System': 'Windows 11 Home / Pro',
        'Software Suite': 'Acer PredatorSense, Acer Care Center',
        'Security': 'BIOS password, Kensington lock slot, TPM 2.0',
        'Warranty': '1-year International Travelers Warranty',
      },
    };
  }

  @override
  void dispose() {
    _tabController.dispose();
    _imagePageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Custom app bar with product name
          SliverAppBar(
            expandedHeight: 350,
            floating: false,
            pinned: true,
            backgroundColor: acerPrimaryColor,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                widget.product.name,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // Product image carousel
                  PageView.builder(
                    controller: _imagePageController,
                    itemCount: _productImages.length,
                    onPageChanged: (index) {
                      setState(() {
                        _selectedImageIndex = index;
                      });
                    },
                    itemBuilder: (context, index) {
                      return Stack(
                        children: [
                          // Image with gradient overlay
                          Positioned.fill(
                            child: Image.network(
                              index == 0
                                  ? widget.product.imageUrl
                                  : _productImages[index],
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  Container(
                                color: Colors.grey[200],
                                child: const Icon(Icons.image_not_supported,
                                    size: 100, color: Colors.grey),
                              ),
                            ),
                          ),
                          // Gradient overlay for text visibility
                          Positioned.fill(
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.black.withOpacity(0.7),
                                    Colors.transparent,
                                    Colors.transparent,
                                    Colors.black.withOpacity(0.7),
                                  ],
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  stops: const [0.0, 0.3, 0.6, 1.0],
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                  // Carousel indicators
                  Positioned(
                    bottom: 20,
                    left: 0,
                    right: 0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        _productImages.length,
                        (index) => Container(
                          width: 8,
                          height: 8,
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _selectedImageIndex == index
                                ? acerPrimaryColor
                                : Colors.white.withOpacity(0.5),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              // Favorite button
              IconButton(
                icon: Icon(
                  _isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: Colors.white,
                ),
                onPressed: () {
                  setState(() {
                    _isFavorite = !_isFavorite;
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(_isFavorite
                          ? '${widget.product.name} added to wishlist'
                          : '${widget.product.name} removed from wishlist'),
                      duration: const Duration(seconds: 1),
                    ),
                  );
                },
              ),
              // Share button
              IconButton(
                icon: const Icon(Icons.share, color: Colors.white),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Sharing product...'),
                      duration: Duration(seconds: 1),
                    ),
                  );
                },
              ),
            ],
          ),

          // Product content
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Price and rating
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                '₹${widget.product.price.toStringAsFixed(0)}',
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: acerPrimaryColor,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '₹${(widget.product.price * 1.1).toStringAsFixed(0)}',
                                style: TextStyle(
                                  fontSize: 16,
                                  decoration: TextDecoration.lineThrough,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.green[100],
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              '10% OFF',
                              style: TextStyle(
                                color: Colors.green[800],
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                      _buildRatingIndicator(4.5, 125),
                    ],
                  ),
                ),

                // Availability and delivery info
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      Icon(Icons.check_circle,
                          color: Colors.green[600], size: 16),
                      const SizedBox(width: 4),
                      Text(
                        'In Stock',
                        style: TextStyle(
                          color: Colors.green[600],
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 16),
                      const Icon(Icons.local_shipping_outlined, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        'Free Delivery',
                        style: TextStyle(
                          color: Colors.grey[700],
                        ),
                      ),
                      const SizedBox(width: 16),
                      const Icon(Icons.access_time, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        'Delivery in 2-3 days',
                        style: TextStyle(
                          color: Colors.grey[700],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Tab bar for switching between details, specs, and reviews
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: TabBar(
                    controller: _tabController,
                    labelColor: acerPrimaryColor,
                    unselectedLabelColor: Colors.grey[600],
                    indicatorColor: acerPrimaryColor,
                    indicatorWeight: 3,
                    tabs: const [
                      Tab(text: 'DETAILS'),
                      Tab(text: 'SPECIFICATIONS'),
                      Tab(text: 'REVIEWS'),
                    ],
                  ),
                ),

                // Tab content
                SizedBox(
                  height: 600, // Fixed height for the tab content
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      // Details tab
                      _buildDetailsTab(),

                      // Specifications tab
                      _buildSpecificationsTab(),

                      // Reviews tab
                      _buildReviewsTab(),
                    ],
                  ),
                ),

                // Add to cart section
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, -5),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      // Buy now button
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: acerAccentColor,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Proceeding to checkout...'),
                              ),
                            );
                          },
                          child: const Text(
                            'BUY NOW',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Add to cart button
                      Expanded(
                        child: Consumer<CartProvider>(
                          builder: (context, cart, child) {
                            return ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: acerPrimaryColor,
                                foregroundColor: Colors.white,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              onPressed: () {
                                cart.addItem(widget.product);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                        '${widget.product.name} added to cart'),
                                    action: SnackBarAction(
                                      label: 'VIEW CART',
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                const CartPage(),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                );
                              },
                              child: const Text(
                                'ADD TO CART',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Enhanced description section with Amazon-like formatting
          const Text(
            'About This Item',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),

          // Formatted description with rich content
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Main description paragraph with enhanced details
              Text(
                widget.product.description,
                style: TextStyle(
                  color: Colors.grey[800],
                  height: 1.6,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 20),

              // Product highlights section
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[200]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Product Highlights',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: acerPrimaryColor,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildBulletPoint(
                        'Powered by the latest ${widget.product.category.contains("Gaming") ? "Intel Core i7/i9 or AMD Ryzen 7/9 processors" : "Intel Core or AMD Ryzen processors"} to deliver exceptional performance for all your computing needs'),
                    _buildBulletPoint(
                        'Stunning ${widget.product.category.contains("Gaming") ? "high-refresh rate" : "high-resolution"} display with vibrant colors and excellent viewing angles for immersive visuals'),
                    _buildBulletPoint(
                        'Advanced cooling technology ensures optimal performance even during extended use sessions'),
                    _buildBulletPoint(
                        'Premium build quality with ${widget.product.category.contains("Gaming") ? "RGB backlit keyboard for gaming aesthetics" : "backlit keyboard for productivity in all environments"}'),
                    _buildBulletPoint(
                        'Long-lasting battery life with quick charge technology gets you back to ${widget.product.category.contains("Gaming") ? "gaming" : "work"} faster'),
                    _buildBulletPoint(
                        'Enhanced audio system with ${widget.product.category.contains("Gaming") ? "DTS:X Ultra sound for gaming immersion" : "crystal-clear sound for video conferences and media consumption"}'),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Technical details section
              const Text(
                'Technical Details',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: acerPrimaryColor,
                ),
              ),
              const SizedBox(height: 12),
              Table(
                border: TableBorder.all(
                  color: Colors.grey[300]!,
                  width: 1,
                ),
                columnWidths: const {
                  0: FlexColumnWidth(2),
                  1: FlexColumnWidth(3),
                },
                children: [
                  _buildTableRow('Brand', 'Acer'),
                  _buildTableRow('Series', widget.product.category),
                  _buildTableRow(
                      'Screen Size',
                      widget.product.category.contains("Gaming")
                          ? '15.6 to 17.3 inches'
                          : '13.3 to 15.6 inches'),
                  _buildTableRow(
                      'RAM',
                      widget.product.category.contains("Gaming")
                          ? '16GB to 32GB DDR5'
                          : '8GB to 16GB DDR4'),
                  _buildTableRow(
                      'Storage',
                      widget.product.category.contains("Gaming")
                          ? '1TB NVMe SSD'
                          : '512GB NVMe SSD'),
                  _buildTableRow(
                      'Graphics',
                      widget.product.category.contains("Gaming")
                          ? 'NVIDIA GeForce RTX or AMD Radeon RX'
                          : 'Integrated Intel/AMD Graphics'),
                  _buildTableRow('Operating System', 'Windows 11 Home'),
                  _buildTableRow(
                      'Battery Life',
                      widget.product.category.contains("Gaming")
                          ? 'Up to 6 hours'
                          : 'Up to 12 hours'),
                  _buildTableRow(
                      'Weight',
                      widget.product.category.contains("Gaming")
                          ? '2.5 to 3.0 kg'
                          : '1.3 to 1.8 kg'),
                ],
              ),
              const SizedBox(height: 24),

              // Usage scenarios section
              const Text(
                'Perfect For',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: acerPrimaryColor,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: _getUsageScenarios()
                    .map((scenario) => Chip(
                          label: Text(scenario),
                          backgroundColor: acerPrimaryColor.withOpacity(0.1),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 10),
                        ))
                    .toList(),
              ),
              const SizedBox(height: 24),

              // Additional information with callouts
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      acerPrimaryColor.withOpacity(0.1),
                      Colors.white,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: acerPrimaryColor.withOpacity(0.3),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Why Choose This ${widget.product.category}?',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: acerPrimaryColor,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _getExtendedDescription(),
                      style: TextStyle(
                        color: Colors.grey[800],
                        height: 1.6,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Row(
                      children: [
                        Icon(Icons.verified, color: acerPrimaryColor, size: 20),
                        SizedBox(width: 8),
                        Text(
                          'Acer Certified Quality',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: acerPrimaryColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Row(
                      children: [
                        Icon(Icons.support_agent,
                            color: acerPrimaryColor, size: 20),
                        SizedBox(width: 8),
                        Text(
                          '24/7 Technical Support',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: acerPrimaryColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Row(
                      children: [
                        Icon(Icons.update, color: acerPrimaryColor, size: 20),
                        SizedBox(width: 8),
                        Text(
                          'Free Software Updates',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: acerPrimaryColor,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 30),

          // Key features header
          const Text(
            'Key Features',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),

          // Key features grid
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            childAspectRatio: 1.5,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            children: [
              _buildFeatureCard(
                Icons.memory,
                'High Performance',
                'Latest generation processor for exceptional speed',
                Colors.blue,
              ),
              _buildFeatureCard(
                Icons.battery_charging_full,
                'Long Battery Life',
                'Up to 8 hours of usage on a single charge',
                Colors.green,
              ),
              _buildFeatureCard(
                Icons.laptop,
                'Premium Display',
                'High resolution screen with vibrant colors',
                Colors.purple,
              ),
              _buildFeatureCard(
                Icons.speaker,
                'Immersive Audio',
                'Crystal-clear sound with deep bass response',
                Colors.orange,
              ),
              _buildFeatureCard(
                Icons.keyboard,
                'Ergonomic Keyboard',
                'Comfortable typing with RGB backlighting',
                Colors.red,
              ),
              _buildFeatureCard(
                Icons.flash_on,
                'Fast Charging',
                '50% charge in just 30 minutes',
                Colors.amber,
              ),
            ],
          ),
          const SizedBox(height: 24),

          // What's in the box
          const Text(
            'What\'s in the Box',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),

          // Box contents list with improved styling
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildBoxItem('1 x Acer ${widget.product.name}'),
                _buildBoxItem(
                    '1 x AC Power Adapter (${widget.product.category.contains("Gaming") ? "180W" : "65W"})'),
                _buildBoxItem('1 x Power Cord'),
                _buildBoxItem('1 x User Manual and Quick Start Guide'),
                _buildBoxItem(
                    '1 x Warranty Card (12-month International Warranty)'),
                if (widget.product.category.contains("Gaming"))
                  _buildBoxItem('1 x Acer Gaming Mouse Pad'),
              ],
            ),
          ),

          const SizedBox(height: 30),

          // Compare with similar items section
          const Text(
            'Compare with Similar Items',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Visit our All Products page to compare this item with other similar products in our catalog.',
            style: TextStyle(fontSize: 15),
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AllProductsPage(),
                ),
              );
            },
            icon: const Icon(Icons.compare),
            label: const Text('Compare Now'),
            style: OutlinedButton.styleFrom(
              foregroundColor: acerPrimaryColor,
              side: const BorderSide(color: acerPrimaryColor),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),

          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildBulletPoint(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '• ',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: acerPrimaryColor,
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 15, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }

  TableRow _buildTableRow(String property, String value) {
    return TableRow(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            property,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(value),
        ),
      ],
    );
  }

  List<String> _getUsageScenarios() {
    if (widget.product.category.contains("Gaming")) {
      return [
        'AAA Gaming',
        'Esports',
        'Game Development',
        'Live Streaming',
        'Video Editing',
        '3D Rendering',
        'Virtual Reality',
      ];
    } else if (widget.product.category.contains("Business")) {
      return [
        'Office Work',
        'Video Conferencing',
        'Data Analysis',
        'Presentations',
        'Web Development',
        'Document Management',
        'Remote Work',
      ];
    } else {
      return [
        'Everyday Computing',
        'Web Browsing',
        'Content Consumption',
        'Student Projects',
        'Light Photo Editing',
        'Office Applications',
        'Email & Communication',
      ];
    }
  }

  String _getExtendedDescription() {
    if (widget.product.category.contains("Gaming")) {
      return 'This premium gaming laptop delivers exceptional performance for the most demanding games and creative applications. The advanced cooling system with dual fans ensures that your system maintains peak performance during intense gaming sessions. The vibrant display with high refresh rate provides smooth gameplay with minimal motion blur, while the RGB keyboard enhances your gaming experience with customizable lighting effects. The powerful speakers deliver immersive audio that puts you right in the middle of the action.';
    } else if (widget.product.category.contains("Business")) {
      return 'Designed for professionals who need reliability, security, and performance, this business laptop helps you stay productive wherever work takes you. The fingerprint reader and facial recognition provide secure and convenient login options, while the military-grade durability ensures your device can withstand the rigors of daily use and travel. The anti-glare display reduces eye strain during long work sessions, and the extended battery life keeps you productive throughout the day without searching for a power outlet.';
    } else {
      return 'Perfect for everyday use, this versatile laptop balances performance and portability to suit your lifestyle. The efficient processor handles multitasking with ease, while the thin and light design makes it easy to take your work or entertainment anywhere. The crisp, clear display is ideal for browsing the web, watching videos, or video chatting with friends and family. With fast charging technology and long battery life, you can stay productive and connected throughout your day.';
    }
  }

  Widget _buildSpecificationsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: _specifications.entries.map((entry) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding:
                    const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                decoration: BoxDecoration(
                  color: acerPrimaryColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      _getSpecIcon(entry.key),
                      color: Colors.white,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      entry.key,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
              ...entry.value.entries.map((spec) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 2,
                        child: Text(
                          spec.key,
                          style: TextStyle(
                            color: Colors.grey[700],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 3,
                        child: Text(
                          spec.value,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
              const Divider(height: 32),
            ],
          );
        }).toList(),
      ),
    );
  }

  IconData _getSpecIcon(String category) {
    switch (category) {
      case 'Performance':
        return Icons.speed;
      case 'Display':
        return Icons.desktop_windows;
      case 'Design':
        return Icons.design_services;
      case 'Connectivity':
        return Icons.wifi;
      case 'Battery':
        return Icons.battery_charging_full;
      case 'Software':
        return Icons.apps;
      default:
        return Icons.info;
    }
  }

  Widget _buildReviewsTab() {
    return Column(
      children: [
        // Rating summary
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            border: Border(
              bottom: BorderSide(color: Colors.grey[300]!, width: 1),
            ),
          ),
          child: Row(
            children: [
              // Average rating
              Column(
                children: [
                  const Text(
                    '4.5',
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: acerPrimaryColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: List.generate(5, (index) {
                      return Icon(
                        index < 4 ? Icons.star : Icons.star_half,
                        color: Colors.amber,
                        size: 20,
                      );
                    }),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Based on 125 reviews',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 24),

              // Rating bars
              Expanded(
                child: Column(
                  children: [
                    _buildRatingBar(5, 0.7),
                    _buildRatingBar(4, 0.2),
                    _buildRatingBar(3, 0.05),
                    _buildRatingBar(2, 0.03),
                    _buildRatingBar(1, 0.02),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Review list
        Expanded(
          child: _reviews.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.rate_review,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No reviews yet',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey[700],
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Be the first to review this product',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: _reviews.length,
                  separatorBuilder: (context, index) =>
                      const Divider(height: 32),
                  itemBuilder: (context, index) {
                    final review = _reviews[index];
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Review header with user info and rating
                        Row(
                          children: [
                            // User avatar
                            CircleAvatar(
                              radius: 20,
                              backgroundImage: NetworkImage(review['avatar']),
                              backgroundColor: Colors.grey[300],
                            ),
                            const SizedBox(width: 12),

                            // User name and date
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  review['name'],
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Posted on ${review['date']}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                            const Spacer(),

                            // Rating stars
                            Row(
                              children: List.generate(5, (i) {
                                return Icon(
                                  i < review['rating']
                                      ? Icons.star
                                      : Icons.star_border,
                                  color: Colors.amber,
                                  size: 16,
                                );
                              }),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Review content
                        Text(
                          review['comment'],
                          style: TextStyle(
                            color: Colors.grey[800],
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Review actions
                        Row(
                          children: [
                            InkWell(
                              onTap: () {
                                // Toggle liked state
                                setState(() {
                                  review['isLiked'] =
                                      !(review['isLiked'] ?? false);
                                  if (review['isLiked']) {
                                    review['liked']++;
                                  } else {
                                    review['liked']--;
                                  }
                                });
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: (review['isLiked'] ?? false)
                                      ? acerPrimaryColor.withOpacity(0.1)
                                      : Colors.grey[200],
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      (review['isLiked'] ?? false)
                                          ? Icons.thumb_up
                                          : Icons.thumb_up_outlined,
                                      size: 14,
                                      color: (review['isLiked'] ?? false)
                                          ? acerPrimaryColor
                                          : Colors.grey[700],
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${review['liked']}',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: (review['isLiked'] ?? false)
                                            ? acerPrimaryColor
                                            : Colors.grey[700],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            InkWell(
                              onTap: () {
                                // Show reply dialog
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Reply feature coming soon'),
                                  ),
                                );
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.grey[200],
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.reply,
                                      size: 14,
                                      color: Colors.grey[700],
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Reply',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.grey[700],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildRatingBar(int rating, double percentage) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Text(
            '$rating',
            style: TextStyle(
              color: Colors.grey[700],
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
          const SizedBox(width: 4),
          const Icon(Icons.star, color: Colors.amber, size: 12),
          const SizedBox(width: 8),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(2),
              child: LinearProgressIndicator(
                value: percentage,
                backgroundColor: Colors.grey[300],
                valueColor:
                    const AlwaysStoppedAnimation<Color>(acerPrimaryColor),
                minHeight: 8,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '${(percentage * 100).toInt()}%',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRatingIndicator(double rating, int reviewCount) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Row(
          children: [
            ...List.generate(5, (index) {
              if (index < rating.floor()) {
                return const Icon(Icons.star, color: Colors.amber, size: 20);
              } else if (index == rating.floor() && rating % 1 > 0) {
                return const Icon(Icons.star_half,
                    color: Colors.amber, size: 20);
              } else {
                return Icon(Icons.star_border,
                    color: Colors.grey[400], size: 20);
              }
            }),
            const SizedBox(width: 8),
            Text(
              rating.toString(),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          '$reviewCount reviews',
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildFeatureCard(
      IconData icon, String title, String description, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 12),
          Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: color.withOpacity(0.8),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            description,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[700],
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildBoxItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: Colors.green, size: 20),
          const SizedBox(width: 12),
          Text(
            text,
            style: const TextStyle(fontSize: 15),
          ),
        ],
      ),
    );
  }
}

// Add LoginPage class before HomePage class
class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>
    with SingleTickerProviderStateMixin {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  bool _isLoading = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.65, curve: Curves.easeOut),
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.2),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.65, curve: Curves.easeOut),
      ),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _login() async {
    setState(() {
      _isLoading = true;
    });

    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));

    // Get user provider
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    // This is just a mock login for demo
    // In a real app, you would validate credentials with a backend
    if (_emailController.text.isNotEmpty &&
        _passwordController.text.isNotEmpty &&
        _nameController.text.isNotEmpty) {
      // Create a demo user with the user-entered name
      final user = User(
        name: _nameController.text,
        email: _emailController.text,
        phone: '9876543210',
      );

      // Set the user in provider
      userProvider.setUser(user);

      // Navigate to home page
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const HomePage()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please fill in all fields'),
          backgroundColor: acerAccentColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Animated background
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white,
                    Colors.grey[100]!,
                    Colors.grey[200]!,
                  ],
                ),
              ),
            ),
          ),

          // Decorative patterns
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: acerPrimaryColor.withOpacity(0.1),
              ),
            ),
          ),
          Positioned(
            bottom: -80,
            left: -80,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: acerAccentColor.withOpacity(0.1),
              ),
            ),
          ),

          // Main content
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: Center(
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Logo with animated shadow
                          _buildAnimatedLogo(),
                          const SizedBox(height: 40),

                          // Form fields with staggered animation
                          _buildStaggeredFormFields(),

                          // Forgot password link
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: const Text(
                                        'Forgot password functionality coming soon'),
                                    backgroundColor: acerAccentColor,
                                    behavior: SnackBarBehavior.floating,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                );
                              },
                              style: TextButton.styleFrom(
                                foregroundColor: acerAccentColor,
                              ),
                              child: const Text(
                                'Forgot Password?',
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 30),

                          // Login button with pulse animation
                          _buildAnimatedLoginButton(),

                          const SizedBox(height: 24),

                          // Sign up link
                          _buildSignUpContainer(),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedLogo() {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 1500),
      curve: Curves.elasticOut,
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: Container(
            alignment: Alignment.center,
            margin: const EdgeInsets.only(bottom: 10),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: [
                      BoxShadow(
                        color: acerPrimaryColor.withOpacity(0.2),
                        blurRadius: 20,
                        spreadRadius: value * 5,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Image.asset(
                    'assets/logos/acer_logo.png',
                    height: 55,
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(height: 20),
                ShaderMask(
                  shaderCallback: (Rect bounds) {
                    return const LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [acerPrimaryColor, acerAccentColor],
                    ).createShader(bounds);
                  },
                  child: Text(
                    'Sign in to your account',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                        ),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(top: 8),
                  height: 2,
                  width: 100,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [acerPrimaryColor, acerAccentColor],
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStaggeredFormFields() {
    return Column(
      children: [
        // Name field
        TweenAnimationBuilder<double>(
          tween: Tween<double>(begin: 0.0, end: 1.0),
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeOutCubic,
          builder: (context, value, child) {
            return Transform.translate(
              offset: Offset(0, 20 * (1 - value)),
              child: Opacity(
                opacity: value,
                child: _buildInputField(
                  controller: _nameController,
                  label: 'Your Name',
                  icon: Icons.person_outline,
                  textInputAction: TextInputAction.next,
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 20),

        // Email field with delay
        FutureBuilder(
          future: Future.delayed(const Duration(milliseconds: 200)),
          builder: (context, snapshot) {
            return TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 800),
              curve: Curves.easeOutCubic,
              builder: (context, value, child) {
                return Transform.translate(
                  offset: Offset(0, 20 * (1 - value)),
                  child: Opacity(
                    opacity: value,
                    child: _buildInputField(
                      controller: _emailController,
                      label: 'Email',
                      icon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                    ),
                  ),
                );
              },
            );
          },
        ),
        const SizedBox(height: 20),

        // Password field with delay
        FutureBuilder(
          future: Future.delayed(const Duration(milliseconds: 400)),
          builder: (context, snapshot) {
            return TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 800),
              curve: Curves.easeOutCubic,
              builder: (context, value, child) {
                return Transform.translate(
                  offset: Offset(0, 20 * (1 - value)),
                  child: Opacity(
                    opacity: value,
                    child: _buildInputField(
                      controller: _passwordController,
                      label: 'Password',
                      icon: Icons.lock_outline,
                      obscureText: true,
                      textInputAction: TextInputAction.done,
                    ),
                  ),
                );
              },
            );
          },
        ),
      ],
    );
  }

  Widget _buildAnimatedLoginButton() {
    return FutureBuilder(
      future: Future.delayed(const Duration(milliseconds: 600)),
      builder: (context, snapshot) {
        return TweenAnimationBuilder<double>(
          tween: Tween<double>(begin: 0.0, end: 1.0),
          duration: const Duration(milliseconds: 1000),
          curve: Curves.easeOutCubic,
          builder: (context, value, child) {
            return Transform.translate(
              offset: Offset(0, 20 * (1 - value)),
              child: Opacity(
                opacity: value,
                child: Container(
                  height: 55,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: acerPrimaryColor.withOpacity(0.3),
                        blurRadius: 12,
                        spreadRadius: 0,
                        offset: const Offset(0, 6),
                      ),
                    ],
                    gradient: const LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [acerPrimaryColor, Color(0xFF69A214)],
                    ),
                  ),
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _login,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      foregroundColor: Colors.white,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
                            'LOGIN',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.5,
                            ),
                          ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildSignUpContainer() {
    return FutureBuilder(
      future: Future.delayed(const Duration(milliseconds: 800)),
      builder: (context, snapshot) {
        return TweenAnimationBuilder<double>(
          tween: Tween<double>(begin: 0.0, end: 1.0),
          duration: const Duration(milliseconds: 1000),
          curve: Curves.easeOutCubic,
          builder: (context, value, child) {
            return Transform.translate(
              offset: Offset(0, 20 * (1 - value)),
              child: Opacity(
                opacity: value,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  padding:
                      const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Don\'t have an account?',
                        style: TextStyle(
                          color: Colors.grey[700],
                          fontSize: 14,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const SignupPage()),
                          );
                        },
                        style: TextButton.styleFrom(
                          foregroundColor: acerPrimaryColor,
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                        ),
                        child: const Text(
                          'Sign Up',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    TextInputAction textInputAction = TextInputAction.next,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        obscureText: obscureText,
        textInputAction: textInputAction,
        style: TextStyle(color: Colors.grey[800]),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
            color: Colors.grey[600],
            fontSize: 14,
          ),
          prefixIcon: Icon(
            icon,
            color: acerPrimaryColor.withOpacity(0.7),
            size: 20,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(
              color: Colors.grey[300]!,
              width: 1,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(
              color: acerPrimaryColor,
              width: 1.5,
            ),
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
    );
  }
}

// Add SignupPage class
class SignupPage extends StatefulWidget {
  const SignupPage({Key? key}) : super(key: key);

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage>
    with SingleTickerProviderStateMixin {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  bool _isLoading = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.65, curve: Curves.easeOut),
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.2),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.65, curve: Curves.easeOut),
      ),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _signup() async {
    if (_nameController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _phoneController.text.isEmpty ||
        _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please fill all fields'),
          backgroundColor: acerAccentColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
      return;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Passwords do not match'),
          backgroundColor: acerAccentColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));

    // Get user provider
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    // Create user with the entered name
    final user = User(
      name: _nameController.text,
      email: _emailController.text,
      phone: _phoneController.text,
    );

    // Set the user in provider
    userProvider.setUser(user);

    // Navigate to home page
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const HomePage()),
      (route) => false,
    );

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Animated background
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white,
                    Colors.grey[100]!,
                    Colors.grey[200]!,
                  ],
                ),
              ),
            ),
          ),

          // Decorative patterns
          Positioned(
            top: -80,
            left: -80,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: acerPrimaryColor.withOpacity(0.1),
              ),
            ),
          ),
          Positioned(
            bottom: -100,
            right: -100,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: acerAccentColor.withOpacity(0.1),
              ),
            ),
          ),

          // Back button
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back_ios_new,
                    color: acerPrimaryColor),
              ),
            ),
          ),

          // Main content
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24.0, 40.0, 24.0, 24.0),
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: Center(
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Header with animated logo
                          _buildAnimatedHeader(),
                          const SizedBox(height: 30),

                          // Form fields with staggered animation
                          _buildStaggeredFormFields(),

                          const SizedBox(height: 30),

                          // Signup button with pulse animation
                          _buildAnimatedSignupButton(),

                          const SizedBox(height: 24),

                          // Login link
                          _buildLoginContainer(),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedHeader() {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 1500),
      curve: Curves.elasticOut,
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: Container(
            margin: const EdgeInsets.only(bottom: 10),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: [
                      BoxShadow(
                        color: acerPrimaryColor.withOpacity(0.2),
                        blurRadius: 20,
                        spreadRadius: value * 5,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: ShaderMask(
                    shaderCallback: (Rect bounds) {
                      return const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [acerPrimaryColor, acerAccentColor],
                      ).createShader(bounds);
                    },
                    child: Text(
                      'Sign Up',
                      style:
                          Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                ShaderMask(
                  shaderCallback: (Rect bounds) {
                    return const LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [acerAccentColor, acerPrimaryColor],
                    ).createShader(bounds);
                  },
                  child: const Text(
                    'Create a new Acer Store account',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(top: 8),
                  height: 2,
                  width: 100,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [acerAccentColor, acerPrimaryColor],
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStaggeredFormFields() {
    return Column(
      children: [
        // Name field
        FutureBuilder(
          future: Future.delayed(const Duration(milliseconds: 0)),
          builder: (context, snapshot) {
            return TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 800),
              curve: Curves.easeOutCubic,
              builder: (context, value, child) {
                return Transform.translate(
                  offset: Offset(0, 20 * (1 - value)),
                  child: Opacity(
                    opacity: value,
                    child: _buildInputField(
                      controller: _nameController,
                      label: 'Full Name',
                      icon: Icons.person_outline,
                      textInputAction: TextInputAction.next,
                    ),
                  ),
                );
              },
            );
          },
        ),
        const SizedBox(height: 16),

        // Email field with delay
        FutureBuilder(
          future: Future.delayed(const Duration(milliseconds: 150)),
          builder: (context, snapshot) {
            return TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 800),
              curve: Curves.easeOutCubic,
              builder: (context, value, child) {
                return Transform.translate(
                  offset: Offset(0, 20 * (1 - value)),
                  child: Opacity(
                    opacity: value,
                    child: _buildInputField(
                      controller: _emailController,
                      label: 'Email',
                      icon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                    ),
                  ),
                );
              },
            );
          },
        ),
        const SizedBox(height: 16),

        // Phone field with delay
        FutureBuilder(
          future: Future.delayed(const Duration(milliseconds: 300)),
          builder: (context, snapshot) {
            return TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 800),
              curve: Curves.easeOutCubic,
              builder: (context, value, child) {
                return Transform.translate(
                  offset: Offset(0, 20 * (1 - value)),
                  child: Opacity(
                    opacity: value,
                    child: _buildInputField(
                      controller: _phoneController,
                      label: 'Phone Number',
                      icon: Icons.phone_outlined,
                      keyboardType: TextInputType.phone,
                      textInputAction: TextInputAction.next,
                    ),
                  ),
                );
              },
            );
          },
        ),
        const SizedBox(height: 16),

        // Password field with delay
        FutureBuilder(
          future: Future.delayed(const Duration(milliseconds: 450)),
          builder: (context, snapshot) {
            return TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 800),
              curve: Curves.easeOutCubic,
              builder: (context, value, child) {
                return Transform.translate(
                  offset: Offset(0, 20 * (1 - value)),
                  child: Opacity(
                    opacity: value,
                    child: _buildInputField(
                      controller: _passwordController,
                      label: 'Password',
                      icon: Icons.lock_outline,
                      obscureText: true,
                      textInputAction: TextInputAction.next,
                    ),
                  ),
                );
              },
            );
          },
        ),
        const SizedBox(height: 16),

        // Confirm password field with delay
        FutureBuilder(
          future: Future.delayed(const Duration(milliseconds: 600)),
          builder: (context, snapshot) {
            return TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 800),
              curve: Curves.easeOutCubic,
              builder: (context, value, child) {
                return Transform.translate(
                  offset: Offset(0, 20 * (1 - value)),
                  child: Opacity(
                    opacity: value,
                    child: _buildInputField(
                      controller: _confirmPasswordController,
                      label: 'Confirm Password',
                      icon: Icons.lock_outline,
                      obscureText: true,
                      textInputAction: TextInputAction.done,
                    ),
                  ),
                );
              },
            );
          },
        ),
      ],
    );
  }

  Widget _buildAnimatedSignupButton() {
    return FutureBuilder(
      future: Future.delayed(const Duration(milliseconds: 750)),
      builder: (context, snapshot) {
        return TweenAnimationBuilder<double>(
          tween: Tween<double>(begin: 0.0, end: 1.0),
          duration: const Duration(milliseconds: 1000),
          curve: Curves.easeOutCubic,
          builder: (context, value, child) {
            return Transform.translate(
              offset: Offset(0, 20 * (1 - value)),
              child: Opacity(
                opacity: value,
                child: Container(
                  height: 55,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: acerPrimaryColor.withOpacity(0.3),
                        blurRadius: 12,
                        spreadRadius: 0,
                        offset: const Offset(0, 6),
                      ),
                    ],
                    gradient: const LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [acerPrimaryColor, Color(0xFF69A214)],
                    ),
                  ),
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _signup,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      foregroundColor: Colors.white,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
                            'CREATE ACCOUNT',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.5,
                            ),
                          ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildLoginContainer() {
    return FutureBuilder(
      future: Future.delayed(const Duration(milliseconds: 900)),
      builder: (context, snapshot) {
        return TweenAnimationBuilder<double>(
          tween: Tween<double>(begin: 0.0, end: 1.0),
          duration: const Duration(milliseconds: 1000),
          curve: Curves.easeOutCubic,
          builder: (context, value, child) {
            return Transform.translate(
              offset: Offset(0, 20 * (1 - value)),
              child: Opacity(
                opacity: value,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  padding:
                      const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Already have an account?',
                        style: TextStyle(
                          color: Colors.grey[700],
                          fontSize: 14,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        style: TextButton.styleFrom(
                          foregroundColor: acerPrimaryColor,
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                        ),
                        child: const Text(
                          'Login',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    TextInputAction textInputAction = TextInputAction.next,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        obscureText: obscureText,
        textInputAction: textInputAction,
        style: TextStyle(color: Colors.grey[800]),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
            color: Colors.grey[600],
            fontSize: 14,
          ),
          prefixIcon: Icon(
            icon,
            color: acerPrimaryColor.withOpacity(0.7),
            size: 20,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(
              color: Colors.grey[300]!,
              width: 1,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(
              color: acerPrimaryColor,
              width: 1.5,
            ),
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
    );
  }
}

// Add ThemeProvider class
class ThemeProvider extends ChangeNotifier {
  bool _darkMode = false;

  bool get darkMode => _darkMode;

  void setDarkMode(bool value) {
    _darkMode = value;
    notifyListeners();
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => CartProvider()),
        ChangeNotifierProvider(create: (context) => UserProvider(prefs)),
        ChangeNotifierProvider(create: (context) => NotificationsProvider()),
        ChangeNotifierProvider(create: (context) => ThemeProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, _) {
        return MaterialApp(
          title: 'Acer Store & Service',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            primarySwatch: Colors.green,
            primaryColor: acerPrimaryColor,
            colorScheme: ColorScheme.light(
              primary: acerPrimaryColor,
              secondary: acerSecondaryColor,
              tertiary: acerAccentColor,
              surface: Colors.white,
              background: Colors.grey[50]!,
            ),
            brightness:
                themeProvider.darkMode ? Brightness.dark : Brightness.light,
            scaffoldBackgroundColor:
                themeProvider.darkMode ? Colors.grey[900] : Colors.grey[50],
            appBarTheme: AppBarTheme(
              backgroundColor:
                  themeProvider.darkMode ? Colors.grey[850] : acerPrimaryColor,
              foregroundColor: Colors.white,
            ),
            cardTheme: CardTheme(
              color: themeProvider.darkMode ? Colors.grey[800] : Colors.white,
            ),
            bottomNavigationBarTheme: const BottomNavigationBarThemeData(
              selectedItemColor: acerPrimaryColor,
              unselectedItemColor: Colors.grey,
            ),
            navigationBarTheme: NavigationBarThemeData(
              indicatorColor: acerPrimaryColor.withOpacity(0.2),
              labelTextStyle: MaterialStateProperty.resolveWith((states) {
                if (states.contains(MaterialState.selected)) {
                  return const TextStyle(color: acerPrimaryColor, fontSize: 12);
                }
                return const TextStyle(color: Colors.grey, fontSize: 12);
              }),
              iconTheme: MaterialStateProperty.resolveWith((states) {
                if (states.contains(MaterialState.selected)) {
                  return const IconThemeData(color: acerPrimaryColor);
                }
                return const IconThemeData(color: Colors.grey);
              }),
            ),
            iconTheme: const IconThemeData(color: acerPrimaryColor),
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                backgroundColor: acerPrimaryColor,
                foregroundColor: Colors.white,
              ),
            ),
          ),
          home: Consumer<UserProvider>(
            builder: (context, userProvider, _) {
              // Check if user is logged in
              if (userProvider.currentUser != null) {
                // User is logged in, show home page
                return const HomePage();
              } else {
                // User is not logged in, show login page
                return const LoginPage();
              }
            },
          ),
        );
      },
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const HomeContent(),
    const SearchPage(),
    const CartPage(),
    const LocationPage(),
    const SettingsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Pages container
          IndexedStack(
            index: _selectedIndex,
            children: _pages,
          ),

          // Assistant button (only show on HomePage)
          if (_selectedIndex == 0)
            Positioned(
              right: 20,
              bottom: 90, // Position it above the bottom navigation bar
              child: AcerAssistant(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AcerAssistantChatPage(),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.search_outlined),
            selectedIcon: Icon(Icons.search),
            label: 'Search',
          ),
          NavigationDestination(
            icon: Icon(Icons.shopping_cart_outlined),
            selectedIcon: Icon(Icons.shopping_cart),
            label: 'Cart',
          ),
          NavigationDestination(
            icon: Icon(Icons.location_on_outlined),
            selectedIcon: Icon(Icons.location_on),
            label: 'Stores',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}

class HomeContent extends StatelessWidget {
  const HomeContent({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Image.asset(
          'assets/logos/acer_logo.png',
          height: 30,
          fit: BoxFit.contain,
        ),
        backgroundColor: Colors.white,
        foregroundColor: acerPrimaryColor,
        elevation: 2,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // Navigate to search tab (index 1)
              if (context.findAncestorStateOfType<_HomePageState>() != null) {
                context.findAncestorStateOfType<_HomePageState>()!.setState(() {
                  context
                      .findAncestorStateOfType<_HomePageState>()!
                      ._selectedIndex = 1;
                });
              }
            },
          ),
          IconButton(
            icon: Consumer<NotificationsProvider>(
                builder: (context, notificationsProvider, child) {
              return Badge(
                isLabelVisible: notificationsProvider.hasUnreadNotifications,
                label: Text(notificationsProvider.unreadCount.toString()),
                child: const Icon(Icons.notifications),
              );
            }),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const NotificationsPage(),
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildBannerSlider(),
            _buildCategories(context),
            _buildPopularProducts(context),
          ],
        ),
      ),
    );
  }

  Widget _buildBannerSlider() {
    final PageController pageController = PageController();

    // Auto-scroll timer
    Timer.periodic(const Duration(seconds: 5), (timer) {
      if (pageController.hasClients) {
        if (pageController.page?.round() == 2) {
          pageController.animateToPage(
            0,
            duration: const Duration(milliseconds: 800),
            curve: Curves.easeInOut,
          );
        } else {
          pageController.nextPage(
            duration: const Duration(milliseconds: 800),
            curve: Curves.easeInOut,
          );
        }
      }
    });

    return Container(
      height: 220,
      child: Stack(
        children: [
          PageView(
            controller: pageController,
            children: [
              _buildBanner(
                'Predator Series',
                'Ultimate Gaming Experience',
                acerSecondaryColor,
                'https://plus.unsplash.com/premium_photo-1711051475117-f3a4d3ff6778?fm=jpg&q=60&w=3000',
              ),
              _buildBanner(
                'Swift Series',
                'Ultra-thin, Ultra-powerful',
                acerAccentColor,
                'https://images.unsplash.com/photo-1611078489935-0cb964de46d6?q=80&w=3000',
              ),
              _buildBanner(
                'Aspire Series',
                'Everyday Productivity',
                acerPrimaryColor,
                'https://images.unsplash.com/photo-1593642702749-b7d2a804fbcf?q=80&w=3000',
              ),
            ],
          ),
          // Page indicators
          Positioned(
            bottom: 15,
            left: 0,
            right: 0,
            child: Center(
              child: SmoothPageIndicator(
                controller: pageController,
                count: 3,
                effect: ExpandingDotsEffect(
                  dotHeight: 8,
                  dotWidth: 8,
                  activeDotColor: Colors.white,
                  dotColor: Colors.white.withOpacity(0.5),
                  spacing: 6,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBanner(
      String title, String subtitle, Color color, String imageUrl) {
    return Container(
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.network(
                imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: color,
                    child: Center(
                      child: Icon(
                        Icons.image_not_supported,
                        color: Colors.white.withOpacity(0.5),
                        size: 50,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    color.withOpacity(0.8),
                    color.withOpacity(0.3),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.8),
                  ],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () {},
                    child: const Text('Shop Now'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategories(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Enhanced header with gradient line (matching popular products)
          Container(
            margin: const EdgeInsets.only(bottom: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.only(left: 8),
                      decoration: const BoxDecoration(
                        border: Border(
                          left: BorderSide(
                            color: acerAccentColor,
                            width: 3,
                          ),
                        ),
                      ),
                      child: Text(
                        'Categories',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: () {
                        // Navigate to AllCategoriesPage
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const AllCategoriesPage(),
                          ),
                        );
                      },
                      icon: const Icon(Icons.category, size: 16),
                      label: const Text('View All'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: acerAccentColor,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ],
                ),
                // Decorative gradient line
                Container(
                  margin: const EdgeInsets.only(top: 6),
                  height: 3,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        acerAccentColor,
                        acerAccentColor.withOpacity(0.2),
                        Colors.transparent,
                      ],
                      stops: const [0.0, 0.5, 1.0],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Enhanced scrollable category cards
          Container(
            margin: const EdgeInsets.only(top: 8),
            height: 120,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildCategoryCard(context, 'Gaming', Icons.videogame_asset,
                      acerPrimaryColor),
                  _buildCategoryCard(
                      context, 'Business', Icons.business, acerAccentColor),
                  _buildCategoryCard(context, 'Monitors', Icons.desktop_windows,
                      Colors.purple),
                  _buildCategoryCard(
                      context, 'Accessories', Icons.headset, Colors.orange),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryCard(
      BuildContext context, String title, IconData icon, Color color) {
    // Map the display title to actual category values
    String categoryFilter;
    String categoryTitle;

    switch (title) {
      case 'Gaming':
        categoryFilter = 'Gaming';
        categoryTitle = 'Gaming Laptops';
        break;
      case 'Business':
        categoryFilter = 'Business';
        categoryTitle = 'Business Laptops';
        break;
      case 'Monitors':
        categoryFilter = 'Monitors';
        categoryTitle = 'Monitors';
        break;
      case 'Accessories':
        categoryFilter = 'Accessories';
        categoryTitle = 'Accessories';
        break;
      default:
        categoryFilter = title;
        categoryTitle = title;
    }

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CategoryPage(
              category: categoryFilter,
              title: categoryTitle,
            ),
          ),
        );
      },
      child: Container(
        width: 110,
        margin: const EdgeInsets.only(right: 16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              color.withOpacity(0.7),
              color.withOpacity(0.9),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 32,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPopularProducts(BuildContext context) {
    // Display first 4 products
    final displayProducts =
        products.length > 4 ? products.sublist(0, 4) : products;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            spreadRadius: 1,
          ),
        ],
      ),
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Enhanced header with animated background
          Container(
            margin: const EdgeInsets.only(bottom: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: acerPrimaryColor.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.star,
                            color: acerPrimaryColor,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Popular Products',
                          style:
                              Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                      ],
                    ),
                    ElevatedButton.icon(
                      onPressed: () {
                        // Navigate to AllProductsPage
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const AllProductsPage(),
                          ),
                        );
                      },
                      icon: const Icon(Icons.grid_view, size: 16),
                      label: const Text('View All'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: acerPrimaryColor,
                        foregroundColor: Colors.white,
                        elevation: 2,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ],
                ),
                // Decorative gradient line
                Container(
                  margin: const EdgeInsets.only(top: 10),
                  height: 3,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        acerPrimaryColor,
                        acerPrimaryColor.withOpacity(0.2),
                        Colors.transparent,
                      ],
                      stops: const [0.0, 0.5, 1.0],
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Enhanced grid layout with custom spacing
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.65, // Make cards taller for better layout
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: displayProducts.length,
            itemBuilder: (context, index) {
              return _buildProductCard(context, displayProducts[index]);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildProductCard(BuildContext context, Product product) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductDetailsPage(product: product),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Product image with discount badge
              Stack(
                children: [
                  // Product image
                  SizedBox(
                    height: 100,
                    width: double.infinity,
                    child: Image.network(
                      product.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: acerPrimaryColor.withOpacity(0.1),
                        child: const Icon(Icons.image_not_supported,
                            size: 60, color: Colors.grey),
                      ),
                    ),
                  ),
                  // Discount badge
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        '10% OFF',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              // Product details
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(4),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Product name
                      Text(
                        product.name,
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      // const SizedBox(height: 4),

                      // Price with original price strikethrough
                      Row(
                        children: [
                          Text(
                            '₹${product.price.toStringAsFixed(0)}',
                            style:
                                Theme.of(context).textTheme.bodyLarge?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: acerPrimaryColor,
                                      fontSize: 16,
                                    ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '₹${(product.price * 1.1).toStringAsFixed(0)}',
                            style: TextStyle(
                              decoration: TextDecoration.lineThrough,
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),

                      // Ratings
                      // const SizedBox(height: 6),
                      Row(
                        children: [
                          ...List.generate(5, (index) {
                            double rating = (product.hashCode % 15 + 35) /
                                10; // Generate pseudo-random rating based on product hash
                            return Icon(
                              index < rating.floor()
                                  ? Icons.star
                                  : (index == rating.floor() && rating % 1 > 0)
                                      ? Icons.star_half
                                      : Icons.star_border,
                              color: Colors.amber,
                              size: 12,
                            );
                          }),
                          const SizedBox(width: 4),
                          Text(
                            '${((product.hashCode % 15 + 35) / 10).toStringAsFixed(1)}',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.grey[700],
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            ' (${(product.hashCode % 100) + 10})',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),

                      const Spacer(),

                      // Add to cart button
                      Consumer<CartProvider>(
                        builder: (context, cart, child) {
                          return InkWell(
                            onTap: () {
                              cart.addItem(product);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content:
                                      Text('${product.name} added to cart'),
                                  duration: const Duration(seconds: 1),
                                ),
                              );
                            },
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              decoration: BoxDecoration(
                                color: acerPrimaryColor,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.shopping_cart_outlined,
                                    color: Colors.white,
                                    size: 16,
                                  ),
                                  SizedBox(width: 6),
                                  Text(
                                    'ADD TO CART',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Add EditProfilePage class after the SettingsPage class
class EditProfilePage extends StatefulWidget {
  final User user;

  const EditProfilePage({Key? key, required this.user}) : super(key: key);

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  String? _selectedImageUrl;
  bool _isLoading = false;
  bool _nameError = false;
  bool _emailError = false;
  bool _phoneError = false;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.user.name);
    _emailController = TextEditingController(text: widget.user.email);
    _phoneController = TextEditingController(text: widget.user.phone);
    _selectedImageUrl = widget.user.imageUrl;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  bool _validateInputs() {
    bool isValid = true;

    // Validate name
    if (_nameController.text.trim().isEmpty) {
      setState(() => _nameError = true);
      isValid = false;
    } else {
      setState(() => _nameError = false);
    }

    // Validate email
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(_emailController.text.trim())) {
      setState(() => _emailError = true);
      isValid = false;
    } else {
      setState(() => _emailError = false);
    }

    // Validate phone
    final phoneRegex = RegExp(r'^\d{10}$');
    if (!phoneRegex.hasMatch(_phoneController.text.trim())) {
      setState(() => _phoneError = true);
      isValid = false;
    } else {
      setState(() => _phoneError = false);
    }

    return isValid;
  }

  Future<void> _selectImage() async {
    setState(() {
      // For demo, we'll use some sample profile pictures
      final sampleAvatars = [
        'https://i.pravatar.cc/300?img=1',
        'https://i.pravatar.cc/300?img=2',
        'https://i.pravatar.cc/300?img=3',
        'https://i.pravatar.cc/300?img=4',
        'https://i.pravatar.cc/300?img=5',
        'https://i.pravatar.cc/300?img=6',
        'https://i.pravatar.cc/300?img=7',
        'https://i.pravatar.cc/300?img=8',
      ];

      // Show dialog to pick an image
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Select Profile Picture'),
          content: SizedBox(
            width: double.maxFinite,
            height: 300,
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemCount: sampleAvatars.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedImageUrl = sampleAvatars[index];
                    });
                    Navigator.pop(context);
                  },
                  child: CircleAvatar(
                    backgroundImage: NetworkImage(sampleAvatars[index]),
                  ),
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            )
          ],
        ),
      );
    });
  }

  Future<void> _saveProfile() async {
    if (!_validateInputs()) return;

    setState(() => _isLoading = true);

    try {
      // Simulate network delay
      await Future.delayed(const Duration(seconds: 1));

      final userProvider = Provider.of<UserProvider>(context, listen: false);

      // Create updated user
      final updatedUser = User(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        phone: _phoneController.text.trim(),
        imageUrl: _selectedImageUrl,
      );

      // Update user in provider
      userProvider.setUser(updatedUser);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating profile: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        backgroundColor: acerPrimaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Stack(
        children: [
          // Background gradient
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  acerPrimaryColor.withAlpha(20),
                  Colors.white,
                ],
              ),
            ),
          ),

          // Main content
          SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Profile picture selector
                      Center(
                        child: Stack(
                          children: [
                            // Profile image
                            Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: acerAccentColor.withAlpha(60),
                                    blurRadius: 20,
                                    spreadRadius: 2,
                                    offset: const Offset(0, 5),
                                  ),
                                ],
                              ),
                              child: CircleAvatar(
                                radius: 60,
                                backgroundColor:
                                    acerPrimaryColor.withOpacity(0.2),
                                child: CircleAvatar(
                                  radius: 58,
                                  backgroundColor: Colors.white,
                                  child: _selectedImageUrl != null
                                      ? ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(58),
                                          child: Image.network(
                                            _selectedImageUrl!,
                                            width: 116,
                                            height: 116,
                                            fit: BoxFit.cover,
                                            errorBuilder:
                                                (context, error, stackTrace) =>
                                                    const Icon(
                                              Icons.person,
                                              size: 60,
                                              color: acerPrimaryColor,
                                            ),
                                          ),
                                        )
                                      : const Icon(
                                          Icons.person,
                                          size: 60,
                                          color: acerPrimaryColor,
                                        ),
                                ),
                              ),
                            ),

                            // Edit button overlay
                            Positioned(
                              right: 0,
                              bottom: 0,
                              child: GestureDetector(
                                onTap: _selectImage,
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: acerAccentColor,
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.1),
                                        blurRadius: 8,
                                        offset: const Offset(0, 3),
                                      ),
                                    ],
                                  ),
                                  child: const Icon(
                                    Icons.edit,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 32),

                      // Form fields
                      const Text(
                        'Personal Information',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: acerPrimaryColor,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Name field
                      _buildTextField(
                        controller: _nameController,
                        label: 'Full Name',
                        icon: Icons.person_outline,
                        hasError: _nameError,
                        errorText: 'Please enter your name',
                      ),
                      const SizedBox(height: 20),

                      // Email field
                      _buildTextField(
                        controller: _emailController,
                        label: 'Email Address',
                        icon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                        hasError: _emailError,
                        errorText: 'Please enter a valid email address',
                      ),
                      const SizedBox(height: 20),

                      // Phone field
                      _buildTextField(
                        controller: _phoneController,
                        label: 'Phone Number',
                        icon: Icons.phone_outlined,
                        keyboardType: TextInputType.phone,
                        hasError: _phoneError,
                        errorText: 'Please enter a valid 10-digit phone number',
                      ),

                      const SizedBox(height: 40),

                      // Save button
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _saveProfile,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: acerPrimaryColor,
                            foregroundColor: Colors.white,
                            disabledBackgroundColor: Colors.grey,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                            elevation: 2,
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text(
                                  'SAVE CHANGES',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    bool hasError = false,
    String errorText = '',
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
            border: Border.all(
              color: hasError
                  ? Colors.red.withOpacity(0.5)
                  : Colors.grey.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            decoration: InputDecoration(
              labelText: label,
              labelStyle: TextStyle(
                color: hasError ? Colors.red : Colors.grey[600],
                fontSize: 15,
              ),
              prefixIcon: Icon(
                icon,
                color:
                    hasError ? Colors.red : acerPrimaryColor.withOpacity(0.7),
                size: 20,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
            ),
          ),
        ),
        if (hasError)
          Padding(
            padding: const EdgeInsets.only(left: 16, top: 8),
            child: Text(
              errorText,
              style: const TextStyle(
                color: Colors.red,
                fontSize: 12,
              ),
            ),
          ),
      ],
    );
  }
}

// Add this after the EditProfilePage class
class AcerAssistant extends StatefulWidget {
  final Function() onTap;

  const AcerAssistant({Key? key, required this.onTap}) : super(key: key);

  @override
  State<AcerAssistant> createState() => _AcerAssistantState();
}

class _AcerAssistantState extends State<AcerAssistant>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _pulseAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.scale(
          scale: _isHovered ? _pulseAnimation.value : _scaleAnimation.value,
          child: MouseRegion(
            onEnter: (_) => setState(() => _isHovered = true),
            onExit: (_) => setState(() => _isHovered = false),
            child: GestureDetector(
              onTap: widget.onTap,
              child: Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [
                      acerPrimaryColor,
                      acerSecondaryColor,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: acerPrimaryColor.withOpacity(0.3),
                      blurRadius: 15,
                      spreadRadius: 5 * _scaleAnimation.value,
                    ),
                  ],
                ),
                child: Stack(
                  // clipBehavior: Clip.hardEdge,
                  alignment: Alignment.bottomRight,
                  children: [
                    const Center(
                      child: Icon(
                        Icons.smart_toy_rounded,
                        color: Colors.white,
                        size: 30,
                      ),
                    ),
                    Positioned(
                      top: 5,
                      right: 5,
                      child: Container(
                        width: 15,
                        height: 15,
                        decoration: BoxDecoration(
                          color: Colors.green,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white,
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                    if (_isHovered)
                      Positioned(
                        top: -30,
                        left: -30,
                        right: -30,
                        child: Center(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 8,
                                  spreadRadius: 1,
                                ),
                              ],
                            ),
                            child: const Text(
                              'Acer Assistant',
                              style: TextStyle(
                                fontSize: 12,
                                color: acerPrimaryColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

// Add this after the AcerAssistant class
class AcerAssistantChatPage extends StatefulWidget {
  const AcerAssistantChatPage({Key? key}) : super(key: key);

  @override
  State<AcerAssistantChatPage> createState() => _AcerAssistantChatPageState();
}

class _AcerAssistantChatPageState extends State<AcerAssistantChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final List<ChatMessage> _messages = [
    ChatMessage(
      text:
          'Hello! I\'m your Acer Assistant. I can help you find the right product, check prices, or get recommendations based on your budget. How can I help you today?',
      isUser: false,
      timestamp: DateTime.now(),
    ),
  ];
  bool _isTyping = false;

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  void _addMessage(String text, bool isUser) {
    setState(() {
      _messages.add(
        ChatMessage(
          text: text,
          isUser: isUser,
          timestamp: DateTime.now(),
        ),
      );
    });
  }

  Future<void> _handleSubmitted(String text) async {
    if (text.trim().isEmpty) return;

    _addMessage(text, true);
    _messageController.clear();

    // Show the assistant is typing indicator
    setState(() {
      _isTyping = true;
    });

    // Simulate processing delay
    await Future.delayed(const Duration(milliseconds: 800));

    // Process the user's message and generate a response
    final response = _generateResponse(text);

    // Hide the typing indicator and add the assistant's response
    setState(() {
      _isTyping = false;
    });

    _addMessage(response, false);
  }

  String _generateResponse(String userMessage) {
    final lowercaseMessage = userMessage.toLowerCase();

    // Budget recommendation
    if (lowercaseMessage.contains('budget') ||
        lowercaseMessage.contains('affordable') ||
        lowercaseMessage.contains('cheap')) {
      if (lowercaseMessage.contains('gaming') ||
          lowercaseMessage.contains('game')) {
        return 'For gaming on a budget, I recommend the Acer Nitro 5 at ₹69,999 or Acer Aspire 7 at ₹54,999. Both offer great performance for their price with dedicated graphics cards, good RAM, and SSD storage.';
      } else if (lowercaseMessage.contains('business') ||
          lowercaseMessage.contains('work')) {
        return 'For business use on a budget, the Acer Swift 3 at ₹59,999 offers excellent value with its lightweight design, long battery life, and performance suitable for everyday productivity tasks.';
      }
      return 'For budget options, we have several great choices: Acer Aspire 7 at ₹54,999, Acer Swift 3 at ₹59,999, or Acer Nitro V at ₹62,999. What will you be using the laptop for?';
    }

    // Price inquiries
    if (lowercaseMessage.contains('price') ||
        lowercaseMessage.contains('cost') ||
        lowercaseMessage.contains('how much')) {
      if (lowercaseMessage.contains('nitro 5')) {
        return 'The Acer Nitro 5 with RTX 3050 is priced at ₹69,999. It comes with 16GB RAM and 512GB SSD, making it excellent for entry-level gaming.';
      } else if (lowercaseMessage.contains('predator')) {
        return 'The Acer Predator Helios with RTX 3070 is priced at ₹129,999. It\'s our premium gaming laptop with 32GB RAM and 1TB SSD for high-performance gaming.';
      } else if (lowercaseMessage.contains('swift')) {
        return 'The Acer Swift 3 is priced at ₹59,999, while the premium Acer Swift X with dedicated graphics is ₹89,999.';
      }
      return 'I\'d be happy to check the price for you. Could you tell me which specific Acer model you\'re interested in?';
    }

    // Gaming laptop recommendations
    if (lowercaseMessage.contains('gaming') ||
        lowercaseMessage.contains('game') ||
        lowercaseMessage.contains('play')) {
      return 'For gaming, we have several great options:\n\n• Entry-level: Acer Nitro 5 (₹69,999) with RTX 3050\n• Mid-range: Acer Nitro 5 RTX 3060 (₹79,999)\n• High-end: Acer Predator Helios (₹129,999) with RTX 3070\n\nWhat\'s your budget range?';
    }

    // Business/productivity laptop recommendations
    if (lowercaseMessage.contains('business') ||
        lowercaseMessage.contains('work') ||
        lowercaseMessage.contains('office') ||
        lowercaseMessage.contains('productivity')) {
      return 'For business and productivity, I recommend:\n\n• Acer Swift 3 (₹59,999): Lightweight with great battery life\n• Acer TravelMate P6 (₹84,999): Professional-grade with security features\n• Acer Swift X (₹89,999): Powerful with dedicated graphics for content creation\n\nWhich features are most important to you?';
    }

    // General inquiry response
    return 'I can help you find the perfect Acer product. Are you looking for a gaming laptop, business laptop, monitor, or accessories? Or do you have a specific budget in mind?';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Acer Assistant'),
        backgroundColor: acerPrimaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Row(
                    children: [
                      Icon(Icons.smart_toy_rounded, color: acerPrimaryColor),
                      SizedBox(width: 10),
                      Text('About Acer Assistant'),
                    ],
                  ),
                  content: const Text(
                    'The Acer Assistant can help you with product recommendations, price information, and finding the right product for your needs. Just ask about products, prices, or your requirements!',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('OK'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => FocusScope.of(context).unfocus(),
              child: ListView.builder(
                padding: const EdgeInsets.all(16.0),
                reverse: false,
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  return _buildMessage(_messages[index]);
                },
              ),
            ),
          ),
          if (_isTyping)
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              alignment: Alignment.centerLeft,
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: List.generate(
                        3,
                        (index) => Container(
                          margin: const EdgeInsets.symmetric(horizontal: 2),
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(
                            color: acerPrimaryColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Acer Assistant is typing...',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          const Divider(height: 1.0),
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
            ),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      textCapitalization: TextCapitalization.sentences,
                      onSubmitted: _handleSubmitted,
                      decoration: const InputDecoration(
                        hintText:
                            'Ask about products, prices, or recommendations...',
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.all(16.0),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.send, color: acerPrimaryColor),
                    onPressed: () => _handleSubmitted(_messageController.text),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessage(ChatMessage message) {
    final isUser = message.isUser;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) ...[
            const CircleAvatar(
              backgroundColor: acerPrimaryColor,
              child:
                  Icon(Icons.smart_toy_outlined, color: Colors.white, size: 18),
            ),
            const SizedBox(width: 8.0),
          ],
          Flexible(
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
              decoration: BoxDecoration(
                color: isUser ? acerAccentColor : Colors.grey[200],
                borderRadius: BorderRadius.circular(20.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message.text,
                    style: TextStyle(
                      color: isUser ? Colors.white : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4.0),
                  Text(
                    _formatTime(message.timestamp),
                    style: TextStyle(
                      color: isUser
                          ? Colors.white.withOpacity(0.7)
                          : Colors.black54,
                      fontSize: 10.0,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (isUser) const SizedBox(width: 8.0),
        ],
      ),
    );
  }

  String _formatTime(DateTime timestamp) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final messageDate =
        DateTime(timestamp.year, timestamp.month, timestamp.day);

    if (messageDate == today) {
      return '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';
    } else {
      return '${timestamp.day}/${timestamp.month} ${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';
    }
  }
}

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
  });
}
