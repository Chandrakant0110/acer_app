import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';
import '../services/local_notification_service.dart';

class CartProvider extends ChangeNotifier {
  final List<CartItem> _items = [];
  DateTime? _lastCartUpdate;
  Timer? _cartReminderTimer;
  Timer? _discountTimer;

  List<CartItem> get items => _items;

  int get itemCount => _items.length;

  double get totalPrice =>
      _items.fold(0, (sum, item) => sum + (item.price * item.quantity));

  DateTime? get lastCartUpdate => _lastCartUpdate;

  void addToCart(CartItem item) {
    final existingItemIndex =
        _items.indexWhere((element) => element.id == item.id);

    if (existingItemIndex >= 0) {
      _items[existingItemIndex].quantity += item.quantity;
    } else {
      _items.add(item);
    }

    _updateCartTimestamp();
    _scheduleCartNotifications();
    notifyListeners();
  }

  void removeFromCart(String id) {
    _items.removeWhere((element) => element.id == id);
    notifyListeners();
  }

  void updateQuantity(String id, int quantity) {
    final index = _items.indexWhere((element) => element.id == id);

    if (index >= 0) {
      _items[index].quantity = quantity;

      if (quantity <= 0) {
        _items.removeAt(index);
      }

      notifyListeners();
    }
  }

  void clearCart() {
    _items.clear();
    _cancelCartNotifications();
    notifyListeners();
  }

  void _updateCartTimestamp() {
    _lastCartUpdate = DateTime.now();
  }

  void _scheduleCartNotifications() {
    _cancelCartNotifications();

    if (_items.isNotEmpty) {
      // Schedule cart reminder after 30 minutes
      _cartReminderTimer = Timer(const Duration(minutes: 30), () {
        _showCartReminderNotification();
      });

      // Schedule discount notification after 1 hour
      _discountTimer = Timer(const Duration(hours: 1), () {
        _showRandomDiscountNotification();
      });
    }
  }

  void _cancelCartNotifications() {
    _cartReminderTimer?.cancel();
    _discountTimer?.cancel();
    LocalNotificationService.cancelCartNotifications();
  }

  void _showCartReminderNotification() {
    if (_items.isNotEmpty) {
      final messages = [
        'Hey! Great deals waiting for you! 🛒',
        'Your cart is calling! Amazing Acer products await! 📱',
        'Don\'t miss out! Complete your purchase now! 🔥',
        'Exclusive deals in your cart - Limited time! ⏰',
        'Your favorite Acer products are waiting! 💻',
      ];

      final bodies = [
        'Complete your purchase of ${_items.length} items and enjoy premium Acer quality!',
        'Get ${_items.length} amazing products delivered to your doorstep!',
        'Your cart has the best Acer deals - don\'t let them slip away!',
        'Free delivery on your ${_items.length} items! Complete purchase now!',
        'Premium Acer tech in your cart - grab them before they\'re gone!',
      ];

      final randomIndex = Random().nextInt(messages.length);

      LocalNotificationService.showCartReminderNotification(
        title: messages[randomIndex],
        body: bodies[randomIndex],
        itemCount: _items.length,
        totalAmount: totalPrice,
      );
    }
  }

  void _showRandomDiscountNotification() {
    if (_items.isNotEmpty) {
      // Pick a random item from cart
      final randomItem = _items[Random().nextInt(_items.length)];
      final discountPercent = 10 + Random().nextInt(21); // 10-30% discount
      final originalPrice = randomItem.price;
      final discountPrice = originalPrice * (1 - discountPercent / 100);

      LocalNotificationService.showDiscountNotification(
        productName: randomItem.name,
        originalPrice: originalPrice,
        discountPrice: discountPrice,
        discountPercent: discountPercent,
      );
    }
  }

  // Show cart abandonment notification after longer period
  void showCartAbandonmentNotification() {
    if (_items.isNotEmpty) {
      LocalNotificationService.showCartAbandonmentNotification(
        itemCount: _items.length,
        totalAmount: totalPrice,
      );
    }
  }

  @override
  void dispose() {
    _cancelCartNotifications();
    super.dispose();
  }
}

class CartItem {
  final String id;
  final String name;
  final double price;
  final String imageUrl;
  int quantity;

  CartItem({
    required this.id,
    required this.name,
    required this.price,
    required this.imageUrl,
    this.quantity = 1,
  });

  get product => null;
}
