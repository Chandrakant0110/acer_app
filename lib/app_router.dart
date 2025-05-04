import 'package:flutter/material.dart';
import 'pages/beautiful_cart_page.dart';

/// This class provides navigation methods to the beautiful cart page
/// It's used to replace the old cart page with the new beautiful one
class AppRouter {
  /// Navigate to the beautiful cart page
  static void navigateToCart(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const BeautifulCartPage()),
    );
  }

  /// Navigate to the beautiful cart page and replace the current route
  static void navigateToCartReplacement(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const BeautifulCartPage()),
    );
  }
}
