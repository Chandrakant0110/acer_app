import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../main.dart';

class MyOrdersPage extends StatefulWidget {
  const MyOrdersPage({Key? key}) : super(key: key);

  @override
  State<MyOrdersPage> createState() => _MyOrdersPageState();
}

class _MyOrdersPageState extends State<MyOrdersPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Orders'),
        backgroundColor: acerPrimaryColor,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(text: 'ACTIVE ORDERS'),
            Tab(text: 'COMPLETED ORDERS'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          ActiveOrdersTab(),
          CompletedOrdersTab(),
        ],
      ),
    );
  }
}

class ActiveOrdersTab extends StatelessWidget {
  const ActiveOrdersTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final orderProvider = Provider.of<OrderProvider>(context);

    // Get active orders (non-delivered, non-cancelled, non-returned)
    final activeOrders = orderProvider.orders
        .where((order) =>
            order.status != OrderStatus.delivered &&
            order.status != OrderStatus.cancelled &&
            order.status != OrderStatus.returned)
        .toList();

    if (activeOrders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.local_shipping_outlined,
              size: 80,
              color: Colors.grey[300],
            ),
            const SizedBox(height: 16),
            Text(
              'No active orders',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Your active orders will appear here',
              style: TextStyle(
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: activeOrders.length,
      itemBuilder: (context, index) {
        final order = activeOrders[index];
        return OrderCardWidget(order: order, isActive: true);
      },
    );
  }
}

class CompletedOrdersTab extends StatelessWidget {
  const CompletedOrdersTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final orderProvider = Provider.of<OrderProvider>(context);

    // Get completed orders (delivered, cancelled, returned)
    final completedOrders = orderProvider.orders
        .where((order) =>
            order.status == OrderStatus.delivered ||
            order.status == OrderStatus.cancelled ||
            order.status == OrderStatus.returned)
        .toList();

    if (completedOrders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inventory_2_outlined,
              size: 80,
              color: Colors.grey[300],
            ),
            const SizedBox(height: 16),
            Text(
              'No completed orders',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Your order history will appear here',
              style: TextStyle(
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: completedOrders.length,
      itemBuilder: (context, index) {
        final order = completedOrders[index];
        return OrderCardWidget(order: order, isActive: false);
      },
    );
  }
}

class OrderCardWidget extends StatelessWidget {
  final Order order;
  final bool isActive;

  const OrderCardWidget({
    Key? key,
    required this.order,
    required this.isActive,
  }) : super(key: key);

  // Calculate real-time order status based on order date
  OrderStatus getTimeBasedStatus(Order order) {
    // If order is already cancelled or returned, keep that status
    if (order.status == OrderStatus.cancelled || order.status == OrderStatus.returned) {
      return order.status;
    }

    final now = DateTime.now();
    final orderDate = order.orderDate;
    final difference = now.difference(orderDate);

    // Time-based status progression
    if (difference.inMinutes < 30) {
      return OrderStatus.pending; // First 30 minutes: Order is pending
    } else if (difference.inHours < 2) {
      return OrderStatus.confirmed; // 30 mins - 2 hours: Order is confirmed
    } else if (difference.inHours < 24) {
      return OrderStatus.processing; // 2 - 24 hours: Order is being processed
    } else if (difference.inHours < 72) {
      return OrderStatus.shipped; // 24 - 72 hours: Order is shipped
    } else if (difference.inHours < 96) {
      return OrderStatus.outForDelivery; // 72 - 96 hours: Out for delivery
    } else {
      return OrderStatus.delivered; // After 96 hours (4 days): Delivered
    }
  }

  @override
  Widget build(BuildContext context) {
    // Use time-based status instead of static status
    final calculatedStatus = getTimeBasedStatus(order);
    final statusColor = _getStatusColor(calculatedStatus);
    final formattedDate = _formatDate(order.orderDate);
    final statusLabel = calculatedStatus.toString().split('.').last.toUpperCase();

    // Calculate expected delivery date (5 days from order date)
    final expectedDelivery = order.orderDate.add(const Duration(days: 5));
    final isDelivered = calculatedStatus == OrderStatus.delivered;
    final deliveryText = isDelivered 
        ? 'Delivered on ${_formatDate(order.orderDate.add(const Duration(hours: 96)))}'
        : 'Expected delivery by ${_formatDate(expectedDelivery)}';

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ORDER #${order.id.substring(order.id.length - 6).toUpperCase()}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Placed on $formattedDate',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: statusColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        statusLabel,
                        style: TextStyle(
                          color: statusColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Add delivery status timeline
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Icon(
                  isDelivered ? Icons.check_circle : Icons.schedule,
                  size: 16,
                  color: isDelivered ? Colors.green : Colors.grey[600],
                ),
                const SizedBox(width: 8),
                Text(
                  deliveryText,
                  style: TextStyle(
                    fontSize: 12,
                    color: isDelivered ? Colors.green : Colors.grey[600],
                    fontWeight: isDelivered ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: order.items.length > 2 ? 2 : order.items.length,
            itemBuilder: (context, index) {
              final item = order.items[index];
              return Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          item.product.imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const Icon(
                            Icons.image_not_supported,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.product.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '₹${item.price.toStringAsFixed(0)} × ${item.quantity}',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 13,
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
          if (order.items.length > 2)
            Padding(
              padding: const EdgeInsets.only(left: 16, right: 16, bottom: 12),
              child: Text(
                '+ ${order.items.length - 2} more items',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 13,
                ),
              ),
            ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Total Amount',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '₹${order.totalAmount.toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                // Only show TRACK ORDER if not delivered, cancelled or returned
                (calculatedStatus != OrderStatus.delivered && 
                 calculatedStatus != OrderStatus.cancelled && 
                 calculatedStatus != OrderStatus.returned)
                    ? ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => OrderDetailsPage(
                                order: order,
                              ),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: acerPrimaryColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                        ),
                        child: const Text('TRACK ORDER'),
                      )
                    : OutlinedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => OrderDetailsPage(
                                order: order,
                              ),
                            ),
                          );
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: acerPrimaryColor,
                          side: const BorderSide(color: acerPrimaryColor),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                        ),
                        child: const Text('VIEW DETAILS'),
                      ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Helper functions moved inside the class
  Color _getStatusColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return Colors.orange;
      case OrderStatus.confirmed:
        return Colors.blue;
      case OrderStatus.processing:
        return Colors.purple;
      case OrderStatus.shipped:
        return Colors.indigo;
      case OrderStatus.outForDelivery:
        return Colors.teal;
      case OrderStatus.delivered:
        return Colors.green;
      case OrderStatus.cancelled:
        return Colors.red;
      case OrderStatus.returned:
        return Colors.red[300]!;
    }
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return '${date.day} ${months[date.month - 1]}, ${date.year}';
  }
}
