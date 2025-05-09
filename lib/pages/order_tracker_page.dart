import 'package:acer_app/order_details_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../main.dart'; // Import main.dart which contains OrderProvider and OrderStatus

class OrderTrackerPage extends StatelessWidget {
  const OrderTrackerPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final orderProvider = Provider.of<OrderProvider>(context);
    final orders = orderProvider.orders;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Order Tracker'),
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
                  margin: const EdgeInsets.all(8.0),
                  child: ListTile(
                    title: Text('Order ID: ${order.id}'),
                    subtitle: Text(
                        'Status: ${order.status.toString().split('.').last}'),
                    trailing:
                        Text('Total: ₹${order.totalAmount.toStringAsFixed(0)}'),
                    onTap: () {
                      // Navigate to Order Details Page
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
}
