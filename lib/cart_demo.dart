import 'package:flutter/material.dart';
import 'pages/beautiful_cart_page.dart';

/// Demo application showing how to use the beautiful cart page
class CartDemo extends StatelessWidget {
  const CartDemo({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cart Demo'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Try the beautiful new cart page!',
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Navigate to the beautiful cart page
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const BeautifulCartPage(),
                  ),
                );
              },
              child: const Text('Open Beautiful Cart'),
            ),
          ],
        ),
      ),
    );
  }
}
