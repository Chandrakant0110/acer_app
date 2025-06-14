import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../main.dart'; // Import for Order, OrderItem, Product, Address classes

class OrderProvider extends ChangeNotifier {
  final List<Order> _orders = [];
  final SharedPreferences? _prefs;

  List<Order> get orders => _orders;

  OrderProvider([this._prefs]) {
    _loadOrders();
  }

  // Load orders from SharedPreferences
  Future<void> _loadOrders() async {
    try {
      final prefs = _prefs ?? await SharedPreferences.getInstance();
      final ordersJson = prefs.getString('user_orders');
      
      if (ordersJson != null && ordersJson.isNotEmpty) {
        final List<dynamic> decodedList = jsonDecode(ordersJson);
        _orders.clear();
        _orders.addAll(decodedList.map((item) => _orderFromJson(item)).toList());
        notifyListeners();
      } else {
        // If no orders found, add sample orders for demo
        addSampleOrders();
      }
    } catch (e) {
      print('Error loading orders: $e');
      // Fallback to sample orders if loading fails
      addSampleOrders();
    }
  }

  // Save orders to SharedPreferences
  Future<void> _saveOrders() async {
    try {
      final prefs = _prefs ?? await SharedPreferences.getInstance();
      final ordersJson = jsonEncode(_orders.map((order) => _orderToJson(order)).toList());
      await prefs.setString('user_orders', ordersJson);
    } catch (e) {
      print('Error saving orders: $e');
    }
  }

  void addOrder(Order order) {
    _orders.add(order);
    _saveOrders(); // Save to persistent storage
    notifyListeners();
  }

  Order? getOrderById(String id) {
    try {
      return _orders.firstWhere((order) => order.id == id);
    } catch (e) {
      return null;
    }
  }

  void addSampleOrders() {
    if (_orders.isNotEmpty) return;

    // Sample addresses
    final homeAddress = Address(
      name: 'Rahul Sharma',
      street: '123, Lotus Apartments, Andheri East',
      city: 'Mumbai',
      state: 'Maharashtra',
      zipCode: '400069',
      phone: '9876543210',
      isDefault: true,
      addressType: 'Home',
    );

    // Sample products for orders
    final sampleProducts = [
      Product(
        name: 'Acer Nitro 5',
        imageUrl: 'https://example.com/images/nitro5.jpg',
        price: 69999,
        description: 'Gaming laptop with RTX 3050',
        category: 'Laptops',
      ),
      Product(
        name: 'Acer Predator Helios',
        imageUrl: 'https://example.com/images/predator.jpg',
        price: 129999,
        description: 'Gaming laptop with RTX 3070',
        category: 'Laptops',
      ),
    ];

    // Sample order 1 - Delivered
    final orderItems1 = [
      OrderItem(
        product: sampleProducts[0],
        quantity: 1,
        price: sampleProducts[0].price,
      ),
    ];

    addOrder(Order(
      id: 'ORD123456789',
      items: orderItems1,
      totalAmount: orderItems1.fold(
          0, (sum, item) => sum + (item.price * item.quantity)),
      orderDate: DateTime.now().subtract(const Duration(days: 15)),
      status: OrderStatus.delivered,
      deliveryAddress: homeAddress,
      paymentMethod: 'Credit Card',
      trackingId: 'TRK987654321',
      estimatedDelivery: DateTime.now().subtract(const Duration(days: 2)),
    ));

    // Sample order 2 - In progress
    final orderItems2 = [
      OrderItem(
        product: sampleProducts[1],
        quantity: 1,
        price: sampleProducts[1].price,
      ),
    ];

    addOrder(Order(
      id: 'ORD987654321',
      items: orderItems2,
      totalAmount: orderItems2.fold(
          0, (sum, item) => sum + (item.price * item.quantity)),
      orderDate: DateTime.now().subtract(const Duration(days: 3)),
      status: OrderStatus.shipped,
      deliveryAddress: homeAddress,
      paymentMethod: 'UPI',
      trackingId: 'TRK123456789',
      estimatedDelivery: DateTime.now().add(const Duration(days: 2)),
    ));
  }

  // Clear all orders (for testing purposes)
  Future<void> clearOrders() async {
    _orders.clear();
    await _saveOrders();
    notifyListeners();
  }

  // JSON serialization helper methods
  Map<String, dynamic> _orderToJson(Order order) {
    return {
      'id': order.id,
      'items': order.items.map((item) => _orderItemToJson(item)).toList(),
      'totalAmount': order.totalAmount,
      'orderDate': order.orderDate.toIso8601String(),
      'status': order.status.toString(),
      'deliveryAddress': _addressToJson(order.deliveryAddress),
      'paymentMethod': order.paymentMethod,
      'trackingId': order.trackingId,
      'estimatedDelivery': order.estimatedDelivery?.toIso8601String(),
    };
  }

  Order _orderFromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'],
      items: (json['items'] as List)
          .map((item) => _orderItemFromJson(item))
          .toList(),
      totalAmount: json['totalAmount'],
      orderDate: DateTime.parse(json['orderDate']),
      status: _orderStatusFromString(json['status']),
      deliveryAddress: _addressFromJson(json['deliveryAddress']),
      paymentMethod: json['paymentMethod'],
      trackingId: json['trackingId'],
      estimatedDelivery: json['estimatedDelivery'] != null
          ? DateTime.parse(json['estimatedDelivery'])
          : null,
    );
  }

  Map<String, dynamic> _orderItemToJson(OrderItem item) {
    return {
      'product': _productToJson(item.product),
      'quantity': item.quantity,
      'price': item.price,
    };
  }

  OrderItem _orderItemFromJson(Map<String, dynamic> json) {
    return OrderItem(
      product: _productFromJson(json['product']),
      quantity: json['quantity'],
      price: json['price'],
    );
  }

  Map<String, dynamic> _productToJson(Product product) {
    return {
      'name': product.name,
      'imageUrl': product.imageUrl,
      'price': product.price,
      'description': product.description,
      'category': product.category,
    };
  }

  Product _productFromJson(Map<String, dynamic> json) {
    return Product(
      name: json['name'],
      imageUrl: json['imageUrl'],
      price: json['price'],
      description: json['description'],
      category: json['category'],
    );
  }

  Map<String, dynamic> _addressToJson(Address address) {
    return {
      'name': address.name,
      'street': address.street,
      'city': address.city,
      'state': address.state,
      'zipCode': address.zipCode,
      'phone': address.phone,
      'isDefault': address.isDefault,
      'landmark': address.landmark,
      'addressType': address.addressType,
    };
  }

  Address _addressFromJson(Map<String, dynamic> json) {
    return Address(
      name: json['name'],
      street: json['street'],
      city: json['city'],
      state: json['state'],
      zipCode: json['zipCode'],
      phone: json['phone'],
      isDefault: json['isDefault'] ?? false,
      landmark: json['landmark'],
      addressType: json['addressType'],
    );
  }

  OrderStatus _orderStatusFromString(String status) {
    return OrderStatus.values.firstWhere(
      (e) => e.toString() == status,
      orElse: () => OrderStatus.pending,
    );
  }
}
