import 'package:flutter/material.dart';
import 'order_tracker_page.dart'; // Ensure this path is correct

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Other homepage content...

            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const OrderTrackerPage(),
                  ),
                );
              },
              child: const Text('Track My Orders'),
            ),
          ],
        ),
      ),
    );
  }
}
