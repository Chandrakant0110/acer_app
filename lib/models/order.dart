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

// Discount rates by product category
class DiscountRates {
  static const Map<String, double> categoryDiscounts = {
    'Laptop': 0.05, // 5% discount for laptops
    'Monitor': 0.08, // 8% discount for monitors
    'Desktop': 0.06, // 6% discount for desktops
    'Accessories': 0.10, // 10% discount for accessories
    'Tablet': 0.07, // 7% discount for tablets
    'Software': 0.15, // 15% discount for software
  };

  // Default discount for categories not listed above
  static const double defaultDiscount = 0.03; // 3%

  static double getDiscountRate(String category) {
    return categoryDiscounts[category] ?? defaultDiscount;
  }
}

class Order {
  final String id;
  final List<OrderItem> items;
  final double subtotalAmount; // Amount before discounts and shipping
  final double discountAmount; // Total discount applied
  final double shippingPrice; // Shipping cost
  final double totalAmount; // Final amount after discounts and shipping
  final DateTime orderDate;
  final OrderStatus status;
  final Address deliveryAddress;
  final String paymentMethod;
  final String? trackingId;
  final DateTime? estimatedDelivery;

  Order({
    required this.id,
    required this.items,
    required this.orderDate,
    required this.status,
    required this.deliveryAddress,
    required this.paymentMethod,
    required this.shippingPrice,
    this.trackingId,
    this.estimatedDelivery,
  })  : subtotalAmount =
            items.fold(0.0, (sum, item) => sum + (item.price * item.quantity)),
        discountAmount =
            items.fold(0.0, (sum, item) => sum + item.discountAmount),
        totalAmount =
            items.fold(0.0, (sum, item) => sum + (item.price * item.quantity)) -
                items.fold(0.0, (sum, item) => sum + item.discountAmount) +
                shippingPrice;

  // Factory constructor to create order with manually specified amounts
  factory Order.withCustomAmounts({
    required String id,
    required List<OrderItem> items,
    required double subtotalAmount,
    required double discountAmount,
    required double shippingPrice,
    required double totalAmount,
    required DateTime orderDate,
    required OrderStatus status,
    required Address deliveryAddress,
    required String paymentMethod,
    String? trackingId,
    DateTime? estimatedDelivery,
  }) {
    return Order(
      id: id,
      items: items,
      orderDate: orderDate,
      status: status,
      deliveryAddress: deliveryAddress,
      paymentMethod: paymentMethod,
      shippingPrice: shippingPrice,
      trackingId: trackingId,
      estimatedDelivery: estimatedDelivery,
    );
  }
}

class OrderItem {
  final Product product;
  final int quantity;
  final double price;
  final double discountRate;
  final double discountAmount;

  OrderItem({
    required this.product,
    required this.quantity,
    required this.price,
    double? discountRate,
  })  : discountRate =
            discountRate ?? DiscountRates.getDiscountRate(product.category),
        discountAmount = (price * quantity) *
            (discountRate ?? DiscountRates.getDiscountRate(product.category));

  // Calculate the total price after discount
  double get totalAfterDiscount => (price * quantity) - discountAmount;
}
