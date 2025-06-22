import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'dart:ui';
import 'main.dart'; // For CartProvider, Product, etc.
import 'checkout_page.dart' as new_checkout; // For CheckoutPage

const Color acerPrimaryColor = Color(0xFF83B81A);
const Color acerSecondaryColor = Color(0xFF1A1A1A);
const Color acerAccentColor = Color(0xFF0079C1);
const Color professionalGray = Color(0xFF6B7280);
const Color lightGray = Color(0xFFF9FAFB);
const Color borderGray = Color(0xFFE5E7EB);

class BeautifulCartPage extends StatefulWidget {
  const BeautifulCartPage({Key? key}) : super(key: key);

  @override
  State<BeautifulCartPage> createState() => _BeautifulCartPageState();
}

class _BeautifulCartPageState extends State<BeautifulCartPage>
    with SingleTickerProviderStateMixin {
  final TextEditingController _promoController = TextEditingController();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );
    _slideAnimation = Tween<double>(begin: 30.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.2, 1.0, curve: Curves.easeOutCubic),
      ),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _promoController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: lightGray,
      appBar: _buildProfessionalAppBar(),
      body: Consumer<CartProvider>(
        builder: (context, cart, child) {
          if (cart.items.isEmpty) {
            return _buildProfessionalEmptyCart();
          }
          
          return AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(0, _slideAnimation.value),
                child: Opacity(
                  opacity: _fadeAnimation.value,
                  child: Column(
                    children: [
                      // Professional Header Stats
                      _buildCartSummaryHeader(cart),
                      
                      Expanded(
                        child: ListView(
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                          children: [
                            // Cart Items Section
                            _buildSectionHeader('Items in Cart', cart.itemCount),
                            const SizedBox(height: 16),
                            
                            ...cart.items.entries.map((entry) {
                              final product = entry.key;
                              final quantity = entry.value;
                              return _buildProfessionalCartItem(product, quantity, cart);
                            }).toList(),
                            
                            const SizedBox(height: 32),
                            
                            // Promo Code Section
                            _buildSectionHeader('Promotional Code', null),
                            const SizedBox(height: 16),
                            _buildProfessionalPromoSection(),
                            
                            const SizedBox(height: 32),
                            
                            // Delivery Information
                            _buildSectionHeader('Delivery Information', null),
                            const SizedBox(height: 16),
                            _buildProfessionalDeliveryInfo(),
                            
                            const SizedBox(height: 32),
                            
                            // Order Summary
                            _buildSectionHeader('Order Summary', null),
                            const SizedBox(height: 16),
                            _buildProfessionalOrderSummary(cart),
                            
                            const SizedBox(height: 120), // Space for checkout button
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      bottomNavigationBar: Consumer<CartProvider>(
        builder: (context, cart, child) {
          if (cart.items.isEmpty) return const SizedBox.shrink();
          return _buildProfessionalCheckoutButton(cart);
        },
      ),
    );
  }

  PreferredSizeWidget _buildProfessionalAppBar() {
    return AppBar(
      backgroundColor: acerPrimaryColor,
      elevation: 0,
      systemOverlayStyle: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),

      title: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Shopping Cart',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.5,
            ),
          ),
          Text(
            'Review your selected items',
            style: TextStyle(
              color: professionalGray,
              fontSize: 13,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
      centerTitle: false,
      actions: [
        Consumer<CartProvider>(
          builder: (context, cart, child) {
            if (cart.items.isEmpty) return const SizedBox.shrink();
            return Container(
              margin: const EdgeInsets.all(8),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [acerPrimaryColor.withOpacity(0.1), acerPrimaryColor.withOpacity(0.05)],
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: acerPrimaryColor.withOpacity(0.2)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.shopping_bag_outlined,
                    color: acerPrimaryColor,
                    size: 16,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '${cart.itemCount}',
                    style: const TextStyle(
                      color: acerPrimaryColor,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildCartSummaryHeader(CartProvider cart) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: borderGray.withOpacity(0.5)),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildStatItem(
              'Total Items',
              '${cart.itemCount}',
              Icons.inventory_2_outlined,
              acerAccentColor,
            ),
          ),
          Container(
            width: 1,
            height: 40,
            color: borderGray,
          ),
          Expanded(
            child: _buildStatItem(
              'Subtotal',
              '₹${cart.totalAmount.toStringAsFixed(2)}',
              Icons.account_balance_wallet_outlined,
              acerPrimaryColor,
            ),
          ),
          Container(
            width: 1,
            height: 40,
            color: borderGray,
          ),
          Expanded(
            child: _buildStatItem(
              'Savings',
              '₹0.00',
              Icons.local_offer_outlined,
              Colors.green[600]!,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: acerSecondaryColor,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: professionalGray,
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title, int? count) {
    return Row(
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: acerSecondaryColor,
            letterSpacing: -0.3,
          ),
        ),
        if (count != null) ...[
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: professionalGray.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '$count',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: professionalGray,
              ),
            ),
          ),
        ],
        const Spacer(),
        Container(
          width: 40,
          height: 2,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [acerPrimaryColor, acerPrimaryColor.withOpacity(0.3)],
            ),
            borderRadius: BorderRadius.circular(1),
          ),
        ),
      ],
    );
  }

  Widget _buildProfessionalEmptyCart() {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _slideAnimation.value),
          child: Opacity(
            opacity: _fadeAnimation.value,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 140,
                    height: 140,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          acerPrimaryColor.withOpacity(0.1),
                          acerPrimaryColor.withOpacity(0.05),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(70),
                      border: Border.all(
                        color: acerPrimaryColor.withOpacity(0.2),
                        width: 2,
                      ),
                    ),
                    child: Icon(
                      Icons.shopping_cart_outlined,
                      size: 64,
                      color: acerPrimaryColor.withOpacity(0.7),
                    ),
                  ),
                  const SizedBox(height: 32),
                  const Text(
                    'Your cart is empty',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: acerSecondaryColor,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Discover our premium products and\nadd them to your cart',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      color: professionalGray,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 40),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [acerPrimaryColor, acerPrimaryColor.withOpacity(0.8)],
                      ),
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: acerPrimaryColor.withOpacity(0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(14),
                        onTap: () => Navigator.pop(context),
                        child: const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.storefront, color: Colors.white, size: 20),
                              SizedBox(width: 12),
                              Text(
                                'Browse Products',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.3,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildProfessionalCartItem(Product product, int quantity, CartProvider cart) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: borderGray.withOpacity(0.5)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Professional Product Image
                Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    color: lightGray,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: borderGray),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: Image.network(
                      product.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: lightGray,
                        child: const Icon(
                          Icons.laptop_mac,
                          size: 40,
                          color: professionalGray,
                        ),
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(width: 20),
                
                // Product Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              product.name,
                              style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w700,
                                color: acerSecondaryColor,
                                height: 1.3,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 12),
                          // Price
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                '₹${(product.price * quantity).toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                  color: acerSecondaryColor,
                                ),
                              ),
                              if (quantity > 1) ...[
                                const SizedBox(height: 2),
                                Text(
                                  '₹${product.price.toStringAsFixed(2)} each',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: professionalGray,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 8),
                      
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: acerAccentColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: acerAccentColor.withOpacity(0.2)),
                        ),
                        child: Text(
                          product.category.toUpperCase(),
                          style: const TextStyle(
                            fontSize: 11,
                            color: acerAccentColor,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 16),
                      
                      Wrap(
                        alignment: WrapAlignment.spaceBetween,
                        children: [
                          // Professional Quantity Controls
                          _buildProfessionalQuantityControls(product, quantity, cart),
                          
                          // Remove Button
                          GestureDetector(
                            onTap: () => _removeItemWithAnimation(product, cart),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.red.withOpacity(0.08),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: Colors.red.withOpacity(0.2)),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.delete_outline,
                                    size: 14,
                                    color: Colors.red[600],
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Remove',
                                    style: TextStyle(
                                      color: Colors.red[600],
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfessionalQuantityControls(Product product, int quantity, CartProvider cart) {
    return Container(
      decoration: BoxDecoration(
        color: lightGray,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderGray),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildQuantityButton(
            icon: Icons.remove,
            onTap: () => cart.removeItem(product),
            isDecrease: true,
          ),
          Container(
            width: 50,
            padding: const EdgeInsets.symmetric(vertical: 12),
            alignment: Alignment.center,
            child: Text(
              '$quantity',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: acerSecondaryColor,
              ),
            ),
          ),
          _buildQuantityButton(
            icon: Icons.add,
            onTap: () => cart.addItem(product),
            isDecrease: false,
          ),
        ],
      ),
    );
  }

  Widget _buildQuantityButton({
    required IconData icon,
    required VoidCallback onTap,
    required bool isDecrease,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isDecrease ? Colors.grey[100] : acerPrimaryColor,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          icon,
          size: 16,
          color: isDecrease ? professionalGray : Colors.white,
        ),
      ),
    );
  }

  Widget _buildProfessionalPromoSection() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: borderGray.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: acerPrimaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.local_offer_outlined,
                  color: acerPrimaryColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Apply Promotional Code',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: acerSecondaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _promoController,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Enter promotional code',
                    hintStyle: TextStyle(
                      color: professionalGray.withOpacity(0.7),
                      fontWeight: FontWeight.w400,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: borderGray),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: borderGray),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: acerPrimaryColor, width: 2),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    filled: true,
                    fillColor: lightGray,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [acerPrimaryColor, acerPrimaryColor.withOpacity(0.8)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: acerPrimaryColor.withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Row(
                            children: [
                              Icon(Icons.check_circle_outline, color: Colors.white),
                              SizedBox(width: 12),
                              Text(
                                'Promotional code applied successfully',
                                style: TextStyle(fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                          backgroundColor: acerPrimaryColor,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          margin: const EdgeInsets.all(16),
                        ),
                      );
                    },
                    child: const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                      child: Text(
                        'Apply',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProfessionalDeliveryInfo() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: borderGray.withOpacity(0.5)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: acerAccentColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.local_shipping_outlined,
              color: acerAccentColor,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Free Express Delivery',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: acerSecondaryColor,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Estimated delivery: 3-5 business days',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: professionalGray,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.verified_outlined,
                      size: 16,
                      color: Colors.green[600],
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Insured & Tracked',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.green[600],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.green.withOpacity(0.2)),
            ),
            child: Text(
              'FREE',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: Colors.green[600],
                letterSpacing: 0.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfessionalOrderSummary(CartProvider cart) {
    final double subtotal = cart.totalAmount;
    const double taxRate = 0.18; // 18% tax
    final double taxAmount = subtotal * taxRate;
    final double totalWithTax = subtotal + taxAmount;
    
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: borderGray.withOpacity(0.5)),
      ),
      child: Column(
        children: [
          _buildSummaryRow(
            'Subtotal (${cart.itemCount} items)',
            '₹${subtotal.toStringAsFixed(2)}',
            false,
          ),
          const SizedBox(height: 16),
          _buildSummaryRow('Shipping & Handling', 'Free', false),
          const SizedBox(height: 16),
          _buildSummaryRow('Tax (18%)', '₹${taxAmount.toStringAsFixed(2)}', false),
          const SizedBox(height: 16),
          _buildSummaryRow('Promotional Discount', '-₹0.00', false),
          
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: Divider(thickness: 1.5),
          ),
          
          _buildSummaryRow(
            'Total Amount',
            '₹${totalWithTax.toStringAsFixed(2)}',
            true,
          ),
          
          const SizedBox(height: 16),
          
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: lightGray,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: borderGray),
            ),
            child: const Row(
              children: [
                Icon(
                  Icons.info_outline,
                  size: 20,
                  color: professionalGray,
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Final amount will be calculated at checkout including applicable taxes.',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: professionalGray,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, bool isTotal) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isTotal ? 18 : 15,
            fontWeight: isTotal ? FontWeight.w700 : FontWeight.w500,
            color: isTotal ? acerSecondaryColor : professionalGray,
          ),
        ),
        if (isTotal)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [acerPrimaryColor.withOpacity(0.1), acerPrimaryColor.withOpacity(0.05)],
              ),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: acerPrimaryColor.withOpacity(0.2)),
            ),
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: acerPrimaryColor,
              ),
            ),
          )
        else
          Text(
            value,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: value.contains('Free') ? Colors.green[600] : acerSecondaryColor,
            ),
          ),
      ],
    );
  }

  Widget _buildProfessionalCheckoutButton(CartProvider cart) {
    final double subtotal = cart.totalAmount;
    final double taxAmount = subtotal * 0.18; // 18% tax
    final double totalWithTax = subtotal + taxAmount;
    
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 30,
            offset: const Offset(0, -8),
          ),
        ],
      ),
      child: SafeArea(
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [acerPrimaryColor, acerPrimaryColor.withOpacity(0.8)],
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: acerPrimaryColor.withOpacity(0.4),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () => _proceedToCheckout(cart),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 18),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.lock_outline,
                      color: Colors.white,
                      size: 22,
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Secure Checkout',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.3,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '₹${totalWithTax.toStringAsFixed(2)}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _removeItemWithAnimation(Product product, CartProvider cart) {
    cart.removeItemCompletely(product);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_outline, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                '${product.name} removed from cart',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
        duration: const Duration(seconds: 4),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.orange[600],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.all(16),
        action: SnackBarAction(
          label: 'UNDO',
          textColor: Colors.white,
          onPressed: () => cart.addItem(product),
        ),
      ),
    );
  }

  void _proceedToCheckout(CartProvider cart) {
    final double subtotal = cart.totalAmount;
    final double taxAmount = subtotal * 0.18; // 18% tax
    final double totalWithTax = subtotal + taxAmount;
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => new_checkout.CheckoutPage(
          cartItems: cart.items,
          totalAmount: totalWithTax,
        ),
      ),
    );
  }
}

// Custom painter for background pattern
class BackgroundPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = acerPrimaryColor.withOpacity(0.03)
      ..style = PaintingStyle.fill;

    // Draw subtle geometric pattern
    for (int i = 0; i < 20; i++) {
      for (int j = 0; j < 20; j++) {
        final x = (i * size.width / 20) + (j % 2) * (size.width / 40);
        final y = j * size.height / 20;
        
        canvas.drawCircle(
          Offset(x, y),
          2,
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Extension for decorated containers
extension DecoratedWidget on Widget {
  Widget decorated({required BoxDecoration decoration}) {
    return Container(
      decoration: decoration,
      child: this,
    );
  }
} 