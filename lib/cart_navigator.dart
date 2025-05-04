import 'package:flutter/material.dart';
import 'pages/beautiful_cart_page.dart';

/// A helper class to navigate to the beautiful cart page
/// This is a simpler alternative that updates the navigation
/// without requiring modifications to main.dart
class CartNavigator {
  /// Navigate to the beautiful cart page
  static void navigateToCart(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const BeautifulCartPage()),
    );
  }
}
