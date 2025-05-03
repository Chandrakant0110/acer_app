import 'package:flutter/material.dart';
import 'checkout_page.dart' as new_checkout;
import 'main.dart';

/// This router class ensures all navigation to checkout pages uses the new beautiful checkout page
class CheckoutRouter {
  static void navigateToCheckout(
      BuildContext context, Map<Product, int> cartItems, double totalAmount) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => new_checkout.CheckoutPage(
          cartItems: cartItems,
          totalAmount: totalAmount,
        ),
      ),
    );
  }
}
