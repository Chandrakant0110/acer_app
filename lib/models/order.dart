import '../main.dart'; // Import for Product and Address classes

enum OrderStatus {
  pending,
  confirmed,
  processing,
  shipped,
  outForDelivery,
  delivered,
  cancelled,
  returned
}

class Order {
  final String id;
  final List<OrderItem> items;
  final double totalAmount;
  final DateTime orderDate;
  final OrderStatus status;
  final Address deliveryAddress;
  final String paymentMethod;
  final String? trackingId;
  final DateTime? estimatedDelivery;

  Order({
    required this.id,
    required this.items,
    required this.totalAmount,
    required this.orderDate,
    required this.status,
    required this.deliveryAddress,
    required this.paymentMethod,
    this.trackingId,
    this.estimatedDelivery,
  });
}

class OrderItem {
  final Product product;
  final int quantity;
  final double price;

  OrderItem({
    required this.product,
    required this.quantity,
    required this.price,
  });
}
