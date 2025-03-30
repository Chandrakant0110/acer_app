import 'package:flutter/material.dart';
import '../main.dart'; // Import for Order, OrderItem, Product, Address classes

class OrderProvider extends ChangeNotifier {
  final List<Order> _orders = [];

  List<Order> get orders => _orders;

  void addOrder(Order order) {
    _orders.add(order);
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

  // Add any other methods needed to manage orders
}
