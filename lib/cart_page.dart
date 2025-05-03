import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// ignore: unused_import
import 'add_new_address_page.dart';
import 'main.dart'; // Import main.dart to access OrdersPage and other providers
import 'pages/my_orders_page.dart'; // Import the new MyOrdersPage
import 'checkout_page.dart' as new_checkout; // Import our new beautiful checkout page with prefix

class CartPage extends StatelessWidget {
  const CartPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Access the cart provider to display items
    final cartProvider = Provider.of<CartProvider>(context);
    final cartItems = cartProvider.items;
    final totalAmount = cartProvider.totalAmount;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cart'),
        actions: [
          // Order history icon
          IconButton(
            icon: const Icon(Icons.shopping_bag_outlined),
            tooltip: 'My Orders',
            onPressed: () {
              // Navigate to MyOrdersPage
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const MyOrdersPage(),
                ),
              );
            },
          ),
        ],
      ),
      body: cartItems.isEmpty
          ? _buildEmptyCart(context)
          : _buildCartContent(context, cartItems, totalAmount),
    );
  }

  Widget _buildEmptyCart(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_cart_outlined,
            size: 80,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 16),
          Text(
            'Your cart is empty',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add items to your cart to begin shopping',
            style: TextStyle(
              color: Colors.grey[500],
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              // Go back to home page
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const HomePage(),
                ),
              );
            },
            icon: const Icon(Icons.shopping_bag),
            label: const Text('BROWSE PRODUCTS'),
            style: ElevatedButton.styleFrom(
              backgroundColor: acerPrimaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCartContent(
      BuildContext context, Map<Product, int> cartItems, double totalAmount) {
    return Column(
      children: [
        // Cart items list
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: cartItems.length,
            itemBuilder: (context, index) {
              final product = cartItems.keys.elementAt(index);
              final quantity = cartItems[product] ?? 0;

              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Product image
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          product.imageUrl,
                          width: 80,
                          height: 80,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              Container(
                            width: 80,
                            height: 80,
                            color: Colors.grey[200],
                            child: const Icon(Icons.image_not_supported,
                                color: Colors.grey),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),

                      // Product details
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              product.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '₹${product.price.toStringAsFixed(0)}',
                              style: TextStyle(
                                color: Colors.grey[700],
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 8),

                            // Quantity controls
                            Row(
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    border:
                                        Border.all(color: Colors.grey[300]!),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Row(
                                    children: [
                                      // Decrement button
                                      IconButton(
                                        icon:
                                            const Icon(Icons.remove, size: 16),
                                        onPressed: () {
                                          final cartProvider =
                                              Provider.of<CartProvider>(context,
                                                  listen: false);
                                          cartProvider.removeItem(product);
                                        },
                                        constraints: const BoxConstraints(
                                            minWidth: 36, minHeight: 36),
                                        padding: EdgeInsets.zero,
                                      ),

                                      // Quantity display
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 12),
                                        child: Text(
                                          '$quantity',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),

                                      // Increment button
                                      IconButton(
                                        icon: const Icon(Icons.add, size: 16),
                                        onPressed: () {
                                          final cartProvider =
                                              Provider.of<CartProvider>(context,
                                                  listen: false);
                                          cartProvider.addItem(product);
                                        },
                                        constraints: const BoxConstraints(
                                            minWidth: 36, minHeight: 36),
                                        padding: EdgeInsets.zero,
                                      ),
                                    ],
                                  ),
                                ),

                                const Spacer(),

                                // Remove button
                                IconButton(
                                  icon: const Icon(Icons.delete_outline,
                                      color: Colors.red),
                                  onPressed: () {
                                    final cartProvider =
                                        Provider.of<CartProvider>(context,
                                            listen: false);
                                    cartProvider.removeItemCompletely(product);
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),

        // Checkout section
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 4,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: Column(
            children: [
              // Price summary
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Total Amount:',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '₹${totalAmount.toStringAsFixed(0)}',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: acerPrimaryColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // View Orders link
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const MyOrdersPage(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.shopping_bag_outlined, size: 18),
                    label: const Text('View My Orders'),
                    style: TextButton.styleFrom(
                      foregroundColor: acerAccentColor,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              // Checkout button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    // Navigate to checkout (or AddNewAddressPage as interim step)
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => new_checkout.CheckoutPage(
                          cartItems: cartItems,
                          totalAmount: totalAmount,
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: acerPrimaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'PROCEED TO CHECKOUT',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
