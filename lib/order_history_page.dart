import 'package:acer_app/order_details_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'main.dart'; // Import main.dart which contains OrderProvider and acerPrimaryColor

class OrderHistoryPage extends StatelessWidget {
  const OrderHistoryPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final orderProvider = Provider.of<OrderProvider>(context);
    final orders = orderProvider.orders;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Order History'),
        backgroundColor: acerPrimaryColor,
        foregroundColor: Colors.white,
      ),
      body: orders.isEmpty
          ? const Center(
              child: Text('No orders found.'),
            )
          : ListView.builder(
              itemCount: orders.length,
              itemBuilder: (context, index) {
                final order = orders[index];
                return Card(
                  margin: const EdgeInsets.all(8),
                  child: ListTile(
                    title: Text('Order ID: ${order.id}'),
                    subtitle: Text(
                        'Status: ${order.status.toString().split('.').last}\nTotal: ₹${order.totalAmount.toStringAsFixed(0)}\nExpected Delivery: ${_formatDate(order.estimatedDelivery!)}'),
                    onTap: () {
                      // Navigate to order details
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => OrderDetailsPage(order: order),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
    );
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
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }
}
