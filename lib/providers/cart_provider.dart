import 'package:flutter/material.dart';

class CartProvider extends ChangeNotifier {
  final List<CartItem> _items = [];

  List<CartItem> get items => _items;

  int get itemCount => _items.length;

  double get totalPrice =>
      _items.fold(0, (sum, item) => sum + (item.price * item.quantity));

  void addToCart(CartItem item) {
    final existingItemIndex =
        _items.indexWhere((element) => element.id == item.id);

    if (existingItemIndex >= 0) {
      _items[existingItemIndex].quantity += item.quantity;
    } else {
      _items.add(item);
    }

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
    notifyListeners();
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
