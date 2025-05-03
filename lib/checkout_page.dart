import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:ui';

// Import your existing models and providers
import 'main.dart';
import 'pages/my_orders_page.dart';

// Placeholder for HomePage if needed
class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Acer Store'),
        backgroundColor: acerPrimaryColor,
      ),
      body: const Center(
        child: Text('Home Page'),
      ),
    );
  }
}

class CheckoutPage extends StatefulWidget {
  final Map<Product, int> cartItems;
  final double totalAmount;

  const CheckoutPage(
      {Key? key, required this.cartItems, required this.totalAmount})
      : super(key: key);

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage>
    with SingleTickerProviderStateMixin {
  // Controller for the page view
  late PageController _pageController;

  // Tab controller for the top navigation
  late TabController _tabController;

  // Current page index
  int _currentPage = 0;

  // Selected address and payment method
  Address? _selectedAddress;
  String _selectedPaymentMethod = 'Credit/Debit Card';
  bool _isLoading = false;

  // Payment methods
  final List<Map<String, dynamic>> _paymentMethods = [
    {
      'id': 'card',
      'name': 'Credit/Debit Card',
      'icon': Icons.credit_card,
      'description': 'Pay securely with your credit or debit card',
    },
    {
      'id': 'upi',
      'name': 'UPI',
      'icon': Icons.account_balance_wallet,
      'description': 'Google Pay, PhonePe, Paytm, etc.',
    },
    {
      'id': 'netbanking',
      'name': 'Net Banking',
      'icon': Icons.account_balance,
      'description': 'All major banks supported',
    },
    {
      'id': 'cod',
      'name': 'Cash on Delivery',
      'icon': Icons.money,
      'description': 'Pay when your order is delivered',
    },
  ];

  // Sample delivery address for demo
  final List<Address> _addresses = [
    Address(
      name: 'Rahul Sharma',
      street: '123, Lotus Apartments, Andheri East',
      city: 'Mumbai',
      state: 'Maharashtra',
      zipCode: '400069',
      phone: '9876543210',
      isDefault: true,
      addressType: 'Home',
    ),
    Address(
      name: 'Rahul Sharma',
      street: 'Block C, Tech Park, Whitefield',
      city: 'Bangalore',
      state: 'Karnataka',
      zipCode: '560066',
      phone: '9876543210',
      isDefault: false,
      addressType: 'Work',
    ),
  ];

  // Add these new fields for validation and selection
  final _cardFormKey = GlobalKey<FormState>();
  final _upiFormKey = GlobalKey<FormState>();

  // Controllers for payment inputs
  late TextEditingController cardNumberController;
  late TextEditingController cardNameController;
  late TextEditingController cardExpiryController;
  late TextEditingController cardCvvController;
  late TextEditingController upiIdController;

  // Selected bank and UPI app
  String? _selectedBank;
  String? _selectedUpiApp;

  // Error messages
  String? _paymentErrorMessage;
  bool _showErrors = false;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _tabController = TabController(length: 3, vsync: this);

    // Initialize controllers
    cardNumberController = TextEditingController();
    cardNameController = TextEditingController();
    cardExpiryController = TextEditingController();
    cardCvvController = TextEditingController();
    upiIdController = TextEditingController();

    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {
          _currentPage = _tabController.index;
        });
        _pageController.animateToPage(
          _tabController.index,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    });

    // Initialize selected address to default one
    _selectedAddress = _addresses.firstWhere(
      (address) => address.isDefault,
      orElse: () => _addresses.first,
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    _tabController.dispose();

    // Dispose controllers
    cardNumberController.dispose();
    cardNameController.dispose();
    cardExpiryController.dispose();
    cardCvvController.dispose();
    upiIdController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Custom app bar with checkout steps
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            backgroundColor: acerPrimaryColor,
            elevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.only(bottom: 50),
              title: Container(
                alignment: Alignment.bottomCenter,
                padding: const EdgeInsets.only(bottom: 5),
                child: const Text(
                  'Secure Checkout',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // Gradient background
                  Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          acerPrimaryColor,
                          acerAccentColor,
                        ],
                      ),
                    ),
                  ),

                  // Pattern overlay
                  Opacity(
                    opacity: 0.1,
                    child: CustomPaint(
                      painter: CheckoutPatternPainter(),
                    ),
                  ),

                  // Content
                  SafeArea(
                    child: Column(
                      children: [
                        const SizedBox(height: 45),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _buildStepIndicator(
                                0, 'Address', Icons.location_on),
                            _buildStepConnector(_currentPage >= 1),
                            _buildStepIndicator(1, 'Payment', Icons.payment),
                            _buildStepConnector(_currentPage >= 2),
                            _buildStepIndicator(
                                2, 'Review', Icons.check_circle),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            bottom: TabBar(
              controller: _tabController,
              indicatorColor: Colors.white,
              indicatorWeight: 3,
              indicatorSize: TabBarIndicatorSize.label,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white.withOpacity(0.7),
              tabs: const [
                Tab(text: 'ADDRESS'),
                Tab(text: 'PAYMENT'),
                Tab(text: 'REVIEW'),
              ],
            ),
          ),

          // Main content
          SliverFillRemaining(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              onPageChanged: (index) {
                setState(() {
                  _currentPage = index;
                  _tabController.animateTo(index);
                });
              },
              children: [
                _buildAddressPage(),
                _buildPaymentPage(),
                _buildReviewPage(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Step indicator for the checkout process
  Widget _buildStepIndicator(int step, String label, IconData icon) {
    final isActive = _currentPage >= step;
    final isCurrent = _currentPage == step;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: isActive ? Colors.white : Colors.white.withOpacity(0.3),
            shape: BoxShape.circle,
            boxShadow: isCurrent
                ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      spreadRadius: 1,
                      offset: const Offset(0, 3),
                    )
                  ]
                : null,
          ),
          child: Center(
            child: Icon(
              icon,
              color:
                  isActive ? acerPrimaryColor : Colors.white.withOpacity(0.7),
              size: 20,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  // Connector between step indicators
  Widget _buildStepConnector(bool isActive) {
    return Container(
      width: 30,
      height: 2,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      color: isActive ? Colors.white : Colors.white.withOpacity(0.3),
    );
  }

  // Address selection page
  Widget _buildAddressPage() {
    return Container(
      color: Colors.grey[50],
      child: Stack(
        children: [
          // Address list
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Select Delivery Address',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: ListView.builder(
                    itemCount: _addresses.length,
                    itemBuilder: (context, index) {
                      final address = _addresses[index];
                      final isSelected = _selectedAddress == address;

                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isSelected
                                ? acerPrimaryColor
                                : Colors.grey[200]!,
                            width: isSelected ? 2 : 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: isSelected
                                  ? acerPrimaryColor.withOpacity(0.2)
                                  : Colors.grey.withOpacity(0.1),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: InkWell(
                          onTap: () {
                            setState(() {
                              _selectedAddress = address;
                            });
                          },
                          borderRadius: BorderRadius.circular(20),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    // Icon and radio selection
                                    Container(
                                      width: 40,
                                      height: 40,
                                      decoration: BoxDecoration(
                                        color: isSelected
                                            ? acerPrimaryColor.withOpacity(0.1)
                                            : Colors.grey[100],
                                        shape: BoxShape.circle,
                                      ),
                                      child: Center(
                                        child: isSelected
                                            ? const Icon(
                                                Icons.check_circle,
                                                color: acerPrimaryColor,
                                                size: 24,
                                              )
                                            : Icon(
                                                Icons.radio_button_unchecked,
                                                color: Colors.grey[400],
                                                size: 24,
                                              ),
                                      ),
                                    ),
                                    const SizedBox(width: 16),

                                    // Name and address type
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Text(
                                                address.name,
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16,
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                  horizontal: 8,
                                                  vertical: 2,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: isSelected
                                                      ? acerPrimaryColor
                                                          .withOpacity(0.2)
                                                      : Colors.grey[200],
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                ),
                                                child: Text(
                                                  address.addressType ?? 'Home',
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    color: isSelected
                                                        ? acerPrimaryColor
                                                        : Colors.grey[700],
                                                  ),
                                                ),
                                              ),
                                              if (address.isDefault) ...[
                                                const SizedBox(width: 8),
                                                Container(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                    horizontal: 8,
                                                    vertical: 2,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    color: Colors.amber
                                                        .withOpacity(0.2),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            12),
                                                  ),
                                                  child: const Text(
                                                    'Default',
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                      color: Colors.amber,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 12),

                                // Address details with location icon
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(width: 16),
                                    Icon(
                                      Icons.location_on,
                                      size: 18,
                                      color: isSelected
                                          ? acerPrimaryColor
                                          : Colors.grey[500],
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            address.street,
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: Colors.grey[800],
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            '${address.city}, ${address.state} - ${address.zipCode}',
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: Colors.grey[800],
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Row(
                                            children: [
                                              Icon(
                                                Icons.phone,
                                                size: 14,
                                                color: Colors.grey[600],
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                address.phone,
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  color: Colors.grey[800],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 12),

                                // Edit and remove buttons
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    TextButton.icon(
                                      onPressed: () {
                                        // Edit address functionality would go here
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                                'Edit address functionality coming soon!'),
                                          ),
                                        );
                                      },
                                      icon: const Icon(
                                        Icons.edit_outlined,
                                        size: 16,
                                        color: acerAccentColor,
                                      ),
                                      label: const Text(
                                        'Edit',
                                        style: TextStyle(
                                          color: acerAccentColor,
                                        ),
                                      ),
                                      style: TextButton.styleFrom(
                                        tapTargetSize:
                                            MaterialTapTargetSize.shrinkWrap,
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 8,
                                        ),
                                      ),
                                    ),
                                    TextButton.icon(
                                      onPressed: () {
                                        // Remove address functionality would go here
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                                'Remove address functionality coming soon!'),
                                          ),
                                        );
                                      },
                                      icon: const Icon(
                                        Icons.delete_outline,
                                        size: 16,
                                        color: Colors.redAccent,
                                      ),
                                      label: const Text(
                                        'Remove',
                                        style: TextStyle(
                                          color: Colors.redAccent,
                                        ),
                                      ),
                                      style: TextButton.styleFrom(
                                        tapTargetSize:
                                            MaterialTapTargetSize.shrinkWrap,
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 8,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          // Bottom navigation to continue
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, -3),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: () {
                  if (_selectedAddress != null) {
                    _pageController.animateToPage(
                      1,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Please select a delivery address'),
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: acerPrimaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                ),
                child: const Text(
                  'CONTINUE TO PAYMENT',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ),
          ),

          // Add new address button
          Positioned(
            bottom: 88,
            right: 16,
            child: FloatingActionButton(
              onPressed: () {
                // Add new address functionality would go here
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Add new address functionality coming soon!'),
                  ),
                );
              },
              backgroundColor: acerAccentColor,
              child: const Icon(Icons.add_location_alt),
            ),
          ),
        ],
      ),
    );
  }

  // Payment selection page
  Widget _buildPaymentPage() {
    return Container(
      color: Colors.grey[50],
      child: Stack(
        children: [
          // Payment methods list
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Select Payment Method',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),

                // Error message if validation fails
                if (_showErrors && _paymentErrorMessage != null)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.red[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red[300]!),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.error_outline,
                            color: Colors.red[700], size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _paymentErrorMessage!,
                            style: TextStyle(color: Colors.red[700]),
                          ),
                        ),
                      ],
                    ),
                  ),

                Expanded(
                  child: ListView(
                    children: [
                      // Payment methods
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _paymentMethods.length,
                        itemBuilder: (context, index) {
                          final method = _paymentMethods[index];
                          final isSelected =
                              _selectedPaymentMethod == method['name'];

                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            margin: const EdgeInsets.only(bottom: 16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isSelected
                                    ? acerPrimaryColor
                                    : Colors.grey[200]!,
                                width: isSelected ? 2 : 1,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: isSelected
                                      ? acerPrimaryColor.withOpacity(0.2)
                                      : Colors.grey.withOpacity(0.1),
                                  blurRadius: 8,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                // Payment method selector
                                InkWell(
                                  onTap: () {
                                    setState(() {
                                      _selectedPaymentMethod = method['name'];
                                      _showErrors = false;
                                      _paymentErrorMessage = null;
                                    });
                                  },
                                  borderRadius: BorderRadius.circular(16),
                                  child: Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Row(
                                      children: [
                                        // Payment icon in a circle
                                        Container(
                                          width: 48,
                                          height: 48,
                                          decoration: BoxDecoration(
                                            color: isSelected
                                                ? acerPrimaryColor
                                                    .withOpacity(0.1)
                                                : Colors.grey[100],
                                            shape: BoxShape.circle,
                                          ),
                                          child: Center(
                                            child: Icon(
                                              method['icon'],
                                              color: isSelected
                                                  ? acerPrimaryColor
                                                  : Colors.grey[500],
                                              size: 24,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 16),

                                        // Payment method details
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                method['name'],
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16,
                                                  color: isSelected
                                                      ? acerPrimaryColor
                                                      : Colors.black87,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                method['description'],
                                                style: TextStyle(
                                                  fontSize: 13,
                                                  color: Colors.grey[600],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),

                                        // Selection indicator
                                        Container(
                                          width: 24,
                                          height: 24,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              color: isSelected
                                                  ? acerPrimaryColor
                                                  : Colors.grey[400]!,
                                              width: 2,
                                            ),
                                            color: isSelected
                                                ? acerPrimaryColor
                                                : Colors.transparent,
                                          ),
                                          child: isSelected
                                              ? const Center(
                                                  child: Icon(
                                                    Icons.check,
                                                    size: 16,
                                                    color: Colors.white,
                                                  ),
                                                )
                                              : null,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),

                                // Payment detail fields - show based on selected method
                                if (isSelected)
                                  _buildPaymentDetails(method['id']),
                              ],
                            ),
                          );
                        },
                      ),

                      // Secure payment message
                      Container(
                        margin: const EdgeInsets.symmetric(vertical: 16),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey[200]!),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.security,
                              color: Colors.green[700],
                              size: 24,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Your payment information is encrypted and secure. We do not store your credit card details.',
                                style: TextStyle(
                                  color: Colors.grey[800],
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Bottom navigation
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, -3),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // Back button
                  OutlinedButton(
                    onPressed: () {
                      _pageController.animateToPage(
                        0,
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
                      side: const BorderSide(color: acerPrimaryColor),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'BACK',
                      style: TextStyle(
                        color: acerPrimaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),

                  // Continue button
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        // Validate payment details based on selected method
                        if (_validatePaymentDetails()) {
                          _pageController.animateToPage(
                            2,
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        } else {
                          // Show error if validation fails
                          setState(() {
                            _showErrors = true;
                          });
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: acerPrimaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 2,
                      ),
                      child: const Text(
                        'CONTINUE TO REVIEW',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Validate payment details based on selected method
  bool _validatePaymentDetails() {
    switch (_getPaymentMethodId(_selectedPaymentMethod)) {
      case 'card':
        if (cardNumberController.text.isEmpty) {
          _paymentErrorMessage = 'Please enter your card number';
          return false;
        }
        if (cardNameController.text.isEmpty) {
          _paymentErrorMessage = 'Please enter the name on your card';
          return false;
        }
        if (cardExpiryController.text.isEmpty) {
          _paymentErrorMessage = 'Please enter card expiry date';
          return false;
        }
        if (cardCvvController.text.isEmpty) {
          _paymentErrorMessage = 'Please enter CVV';
          return false;
        }
        if (cardNumberController.text.replaceAll(' ', '').length < 16) {
          _paymentErrorMessage = 'Please enter a valid 16-digit card number';
          return false;
        }
        if (!RegExp(r'^\d{2}/\d{2}$').hasMatch(cardExpiryController.text)) {
          _paymentErrorMessage = 'Please enter expiry date in MM/YY format';
          return false;
        }
        if (cardCvvController.text.length < 3) {
          _paymentErrorMessage = 'CVV must be 3 digits';
          return false;
        }
        return true;

      case 'upi':
        if (upiIdController.text.isEmpty) {
          _paymentErrorMessage = 'Please enter your UPI ID';
          return false;
        }
        if (_selectedUpiApp == null) {
          _paymentErrorMessage = 'Please select a UPI app';
          return false;
        }
        if (!RegExp(r'^[a-zA-Z0-9_.-]+@[a-zA-Z0-9.-]+$')
            .hasMatch(upiIdController.text)) {
          _paymentErrorMessage =
              'Please enter a valid UPI ID (e.g. yourname@upi)';
          return false;
        }
        return true;

      case 'netbanking':
        if (_selectedBank == null) {
          _paymentErrorMessage = 'Please select your bank';
          return false;
        }
        return true;

      case 'cod':
        // No validation needed for COD
        return true;

      default:
        _paymentErrorMessage = 'Please select a payment method';
        return false;
    }
  }

  // Get the payment method ID from its name
  String _getPaymentMethodId(String methodName) {
    for (var method in _paymentMethods) {
      if (method['name'] == methodName) {
        return method['id'] as String;
      }
    }
    return '';
  }

  // Build payment detail fields based on the selected payment method
  Widget _buildPaymentDetails(String methodId) {
    switch (methodId) {
      case 'card':
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(16),
              bottomRight: Radius.circular(16),
            ),
          ),
          child: Form(
            key: _cardFormKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                const Text(
                  'Card Details',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 16),

                // Card number field
                TextField(
                  controller: cardNumberController,
                  decoration: InputDecoration(
                    labelText: 'Card Number',
                    hintText: 'XXXX XXXX XXXX XXXX',
                    errorText: _showErrors && cardNumberController.text.isEmpty
                        ? 'Required'
                        : null,
                    prefixIcon: const Icon(Icons.credit_card),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  keyboardType: TextInputType.number,
                  maxLength: 19, // 16 digits + 3 spaces
                ),
                const SizedBox(height: 16),

                // Name on card field
                TextField(
                  controller: cardNameController,
                  decoration: InputDecoration(
                    labelText: 'Name on Card',
                    hintText: 'e.g. JOHN SMITH',
                    errorText: _showErrors && cardNameController.text.isEmpty
                        ? 'Required'
                        : null,
                    prefixIcon: const Icon(Icons.person),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  textCapitalization: TextCapitalization.characters,
                ),
                const SizedBox(height: 16),

                // Expiry and CVV in a row
                Row(
                  children: [
                    // Expiry date
                    Expanded(
                      child: TextField(
                        controller: cardExpiryController,
                        decoration: InputDecoration(
                          labelText: 'Expiry (MM/YY)',
                          hintText: 'MM/YY',
                          errorText:
                              _showErrors && cardExpiryController.text.isEmpty
                                  ? 'Required'
                                  : null,
                          prefixIcon: const Icon(Icons.date_range),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        keyboardType: TextInputType.number,
                        maxLength: 5, // MM/YY format
                      ),
                    ),
                    const SizedBox(width: 16),

                    // CVV
                    Expanded(
                      child: TextField(
                        controller: cardCvvController,
                        decoration: InputDecoration(
                          labelText: 'CVV',
                          hintText: 'XXX',
                          errorText:
                              _showErrors && cardCvvController.text.isEmpty
                                  ? 'Required'
                                  : null,
                          prefixIcon: const Icon(Icons.security),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        keyboardType: TextInputType.number,
                        maxLength: 3,
                        obscureText: true,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );

      case 'upi':
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(16),
              bottomRight: Radius.circular(16),
            ),
          ),
          child: Form(
            key: _upiFormKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                const Text(
                  'UPI Details',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 16),

                // UPI ID field
                TextField(
                  controller: upiIdController,
                  decoration: InputDecoration(
                    labelText: 'UPI ID',
                    hintText: 'yourname@upi',
                    errorText: _showErrors && upiIdController.text.isEmpty
                        ? 'Required'
                        : null,
                    prefixIcon: const Icon(Icons.account_balance_wallet),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),

                const SizedBox(height: 16),

                Text(
                  'Select UPI App',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[800],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),

                // UPI apps selection
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    _buildUpiOption('Google Pay', 'assets/logos/gpay.png'),
                    _buildUpiOption('PhonePe', 'assets/logos/phonepe.png'),
                    _buildUpiOption('Paytm', 'assets/logos/paytm.png'),
                    _buildUpiOption('BHIM', 'assets/logos/bhim.png'),
                  ],
                ),

                if (_showErrors && _selectedUpiApp == null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      'Please select a UPI app',
                      style: TextStyle(
                        color: Colors.red[700],
                        fontSize: 12,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );

      case 'netbanking':
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(16),
              bottomRight: Radius.circular(16),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              const Text(
                'Net Banking Details',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 16),

              // Bank selection dropdown
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: _showErrors && _selectedBank == null
                        ? Colors.red
                        : Colors.grey[400]!,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    isExpanded: true,
                    hint: const Text('Select your bank'),
                    value: _selectedBank,
                    items: [
                      'State Bank of India',
                      'HDFC Bank',
                      'ICICI Bank',
                      'Axis Bank',
                      'Kotak Mahindra Bank',
                      'Punjab National Bank',
                      'Yes Bank',
                    ].map((String bank) {
                      return DropdownMenuItem<String>(
                        value: bank,
                        child: Text(bank),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedBank = value;
                      });
                    },
                  ),
                ),
              ),

              if (_showErrors && _selectedBank == null)
                Padding(
                  padding: const EdgeInsets.only(top: 8, left: 12),
                  child: Text(
                    'Please select your bank',
                    style: TextStyle(
                      color: Colors.red[700],
                      fontSize: 12,
                    ),
                  ),
                ),

              const SizedBox(height: 20),
              const Text(
                'You will be redirected to your bank\'s payment page to complete the transaction securely.',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        );

      case 'cod':
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(16),
              bottomRight: Radius.circular(16),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.info_outline, size: 16, color: Colors.amber[800]),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Please keep exact change ready during delivery',
                      style: TextStyle(
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );

      default:
        return const SizedBox.shrink();
    }
  }

  // Helper method to build UPI payment option
  Widget _buildUpiOption(String name, String imagePath) {
    final isSelected = _selectedUpiApp == name;

    return InkWell(
      onTap: () {
        setState(() {
          _selectedUpiApp = name;
        });
      },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? acerPrimaryColor.withOpacity(0.1) : Colors.white,
          border: Border.all(
            color: isSelected ? acerPrimaryColor : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // In a real app, this would be an image of the UPI provider
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: isSelected
                    ? acerPrimaryColor.withOpacity(0.2)
                    : Colors.grey[300],
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.payment,
                size: 14,
                color: isSelected ? acerPrimaryColor : Colors.grey[700],
              ),
            ),
            const SizedBox(width: 8),
            Text(
              name,
              style: TextStyle(
                color: isSelected ? acerPrimaryColor : Colors.black87,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            if (isSelected)
              Padding(
                padding: const EdgeInsets.only(left: 8),
                child: Icon(
                  Icons.check_circle,
                  size: 16,
                  color: acerPrimaryColor,
                ),
              ),
          ],
        ),
      ),
    );
  }

  // Order review page
  Widget _buildReviewPage() {
    // Check if address is selected before building the page
    if (_selectedAddress == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 56,
              color: Colors.red[400],
            ),
            const SizedBox(height: 16),
            const Text(
              'Please select a delivery address',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                _pageController.animateToPage(
                  0,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: acerPrimaryColor,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: const Text('GO TO ADDRESS PAGE'),
            ),
          ],
        ),
      );
    }

    // Calculate subtotal
    final subtotal = widget.totalAmount;

    // Calculate shipping (free over 10000)
    final shipping = subtotal > 10000 ? 150 : 499.0;

    // Calculate tax (18% GST)
    final tax = subtotal * 0.18;

    // Calculate total
    final total = subtotal + shipping + tax;

    return Container(
      color: Colors.grey[50],
      child: Stack(
        children: [
          // Order summary
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Order heading with animation
                TweenAnimationBuilder(
                  tween: Tween<double>(begin: 0, end: 1),
                  duration: const Duration(milliseconds: 500),
                  builder: (context, value, child) {
                    return Opacity(
                      opacity: value,
                      child: Transform.translate(
                        offset: Offset(0, 20 * (1 - value)),
                        child: child,
                      ),
                    );
                  },
                  child: const Text(
                    'Order Summary',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Order items
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Section header
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: acerPrimaryColor.withOpacity(0.1),
                            border: Border(
                              bottom: BorderSide(
                                color: Colors.grey[200]!,
                                width: 1,
                              ),
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.shopping_bag,
                                color: acerPrimaryColor,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Items (${widget.cartItems.values.fold(0, (sum, quantity) => sum + quantity)})',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey[800],
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Item list
                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          separatorBuilder: (context, index) => Divider(
                            height: 1,
                            color: Colors.grey[200],
                          ),
                          itemCount: widget.cartItems.length,
                          itemBuilder: (context, index) {
                            final product =
                                widget.cartItems.keys.elementAt(index);
                            final quantity = widget.cartItems[product] ?? 0;
                            final itemTotal = product.price * quantity;

                            return Padding(
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Product image
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: Image.network(
                                      product.imageUrl,
                                      width: 70,
                                      height: 70,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  const SizedBox(width: 16),

                                  // Product details
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          product.name,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15,
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          product.category,
                                          style: TextStyle(
                                            fontSize: 13,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Row(
                                          children: [
                                            Text(
                                              '₹${product.price.toStringAsFixed(0)}',
                                              style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.grey[800],
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              'x $quantity',
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: Colors.grey[600],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),

                                  // Item price
                                  Text(
                                    '₹${itemTotal.toStringAsFixed(0)}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: acerPrimaryColor,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Delivery address
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Section header
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: acerPrimaryColor.withOpacity(0.1),
                            border: Border(
                              bottom: BorderSide(
                                color: Colors.grey[200]!,
                                width: 1,
                              ),
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.location_on,
                                color: acerPrimaryColor,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Delivery Address',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey[800],
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Address details
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _selectedAddress!.name,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    _selectedAddress!.street,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey[800],
                                    ),
                                  ),
                                  Text(
                                    '${_selectedAddress!.city}, ${_selectedAddress!.state} - ${_selectedAddress!.zipCode}',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey[800],
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Phone: ${_selectedAddress!.phone}',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey[800],
                                    ),
                                  ),
                                ],
                              ),
                              const Spacer(),
                              // Change button
                              TextButton(
                                onPressed: () {
                                  _pageController.animateToPage(
                                    0,
                                    duration: const Duration(milliseconds: 300),
                                    curve: Curves.easeInOut,
                                  );
                                },
                                child: const Text(
                                  'Change',
                                  style: TextStyle(
                                    color: acerAccentColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Payment method
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Section header
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: acerPrimaryColor.withOpacity(0.1),
                            border: Border(
                              bottom: BorderSide(
                                color: Colors.grey[200]!,
                                width: 1,
                              ),
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.payment,
                                color: acerPrimaryColor,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Payment Method',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey[800],
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Payment method details
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              // Icon
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: acerPrimaryColor.withOpacity(0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: Icon(
                                    _getPaymentIcon(_selectedPaymentMethod),
                                    color: acerPrimaryColor,
                                    size: 20,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),

                              // Payment method name
                              Expanded(
                                child: Text(
                                  _selectedPaymentMethod,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                    color: Colors.grey[800],
                                  ),
                                ),
                              ),

                              // Change button
                              TextButton(
                                onPressed: () {
                                  _pageController.animateToPage(
                                    1,
                                    duration: const Duration(milliseconds: 300),
                                    curve: Curves.easeInOut,
                                  );
                                },
                                child: const Text(
                                  'Change',
                                  style: TextStyle(
                                    color: acerAccentColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Price breakdown
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Section header
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: acerPrimaryColor.withOpacity(0.1),
                            border: Border(
                              bottom: BorderSide(
                                color: Colors.grey[200]!,
                                width: 1,
                              ),
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.receipt_long,
                                color: acerPrimaryColor,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Price Details',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey[800],
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Price breakdown
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              // Subtotal
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Subtotal',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey[700],
                                    ),
                                  ),
                                  Text(
                                    '₹${subtotal.toStringAsFixed(0)}',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey[800],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),

                              // Shipping
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Shipping',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey[700],
                                    ),
                                  ),
                                  shipping > 0
                                      ? Text(
                                          '₹${shipping.toStringAsFixed(0)}',
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.grey[800],
                                          ),
                                        )
                                      : const Text(
                                          'FREE',
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.green,
                                          ),
                                        ),
                                ],
                              ),
                              const SizedBox(height: 12),

                              // Tax
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'GST (18%)',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey[700],
                                    ),
                                  ),
                                  Text(
                                    '₹${tax.toStringAsFixed(0)}',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey[800],
                                    ),
                                  ),
                                ],
                              ),
                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 12),
                                child: Divider(),
                              ),

                              // Total
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'Total',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    '₹${total.toStringAsFixed(0)}',
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: acerPrimaryColor,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Add space for the bottom button
                const SizedBox(height: 100),
              ],
            ),
          ),

          // Bottom navigation
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, -3),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // Back button
                  OutlinedButton(
                    onPressed: () {
                      _pageController.animateToPage(
                        1,
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
                      side: const BorderSide(color: acerPrimaryColor),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'BACK',
                      style: TextStyle(
                        color: acerPrimaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),

                  // Place order button
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _showLoadingAnimation,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: acerPrimaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 2,
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text(
                              'PLACE ORDER',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getPaymentIcon(String method) {
    switch (method) {
      case 'Credit/Debit Card':
        return Icons.credit_card;
      case 'UPI':
        return Icons.account_balance_wallet;
      case 'Net Banking':
        return Icons.account_balance;
      case 'Cash on Delivery':
        return Icons.money;
      default:
        return Icons.payment;
    }
  }

  void _showLoadingAnimation() {
    // Basic validation before proceeding
    if (_selectedAddress == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'Please select a delivery address before placing your order'),
        ),
      );
      _pageController.animateToPage(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // First show only the Lottie animation
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Use a simple loading animation instead of Lottie to avoid potential issues
                    Container(
                      width: 120,
                      height: 120,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: acerPrimaryColor.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const CircularProgressIndicator(
                        color: acerPrimaryColor,
                        strokeWidth: 4,
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Processing Order...',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );

      // Simulate processing time, then proceed
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted && Navigator.of(context).canPop()) {
          Navigator.pop(context); // Close loading dialog
          _showProcessingDialog(); // Show next dialog
        }
      });
    } catch (e) {
      // Handle any errors with the dialog
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  void _showProcessingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Processing animation
                  Container(
                    width: 80,
                    height: 80,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: acerPrimaryColor.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const CircularProgressIndicator(
                      color: acerPrimaryColor,
                      strokeWidth: 3,
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Processing your order...',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Please do not close this window',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );

    // Simulate processing time, then place the order
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted && Navigator.of(context).canPop()) {
        Navigator.pop(context); // Close loading dialog
        _placeOrder();
        setState(() => _isLoading = false);
      }
    });
  }

  void _placeOrder() {
    try {
      if (_selectedAddress == null) {
        throw Exception("No delivery address selected");
      }

      // Generate a random order ID
      final orderId =
          'ORD${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}';

      // Create order items from cart
      final orderItems = widget.cartItems.entries.map((entry) {
        return OrderItem(
          product: entry.key,
          quantity: entry.value,
          price: entry.key.price,
        );
      }).toList();

      // Calculate total amount (with tax)
      final subtotal = widget.totalAmount;
      final shipping = subtotal > 10000 ? 0.0 : 499.0;
      final tax = subtotal * 0.18;
      final totalWithTax = subtotal + shipping + tax;

      // Create new order
      final newOrder = Order(
        id: orderId,
        items: orderItems,
        totalAmount: totalWithTax,
        orderDate: DateTime.now(),
        status: OrderStatus.confirmed,
        deliveryAddress: _selectedAddress!,
        paymentMethod: _selectedPaymentMethod,
        trackingId:
            'TRK${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
        estimatedDelivery: DateTime.now().add(const Duration(days: 5)),
      );

      // Add to order provider with error handling
      try {
        final orderProvider =
            Provider.of<OrderProvider>(context, listen: false);
        orderProvider.addOrder(newOrder);

        // Clear cart
        final cartProvider = Provider.of<CartProvider>(context, listen: false);
        cartProvider.clearCart();

        // Show success dialog
        _showOrderConfirmationDialog(newOrder);
      } catch (providerError) {
        // Handle provider-specific errors
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error processing order: $providerError')),
        );
        setState(() => _isLoading = false);
      }
    } catch (e) {
      // Handle any errors
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error placing order: $e')),
      );
      print('Error placing order: $e');
    }
  }

  void _showOrderConfirmationDialog(Order order) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Success header
              Container(
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      acerPrimaryColor,
                      acerAccentColor,
                    ],
                  ),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: Column(
                  children: [
                    // Animated success icon
                    TweenAnimationBuilder<double>(
                      tween: Tween<double>(begin: 0, end: 1),
                      duration: const Duration(milliseconds: 800),
                      curve: Curves.elasticOut,
                      builder: (context, value, child) {
                        return Transform.scale(
                          scale: value,
                          child: Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: const Center(
                              child: Icon(
                                Icons.check_circle_outline,
                                color: acerPrimaryColor,
                                size: 50,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Order Placed Successfully!',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Order ID: ${order.id}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),

              // Order details
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Thank you for your order!',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Your order has been confirmed and will be shipped soon. You can track your order using the order ID above.',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.calendar_today,
                            size: 16, color: Colors.grey[700]),
                        const SizedBox(width: 8),
                        Text(
                          'Estimated Delivery: ${_formatDate(order.estimatedDelivery!)}',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey[800],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const HomePage(),
                                ),
                              );
                            },
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              side: const BorderSide(color: acerPrimaryColor),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              minimumSize: const Size.fromHeight(48),
                              alignment: Alignment.center,
                            ),
                            child: const Text(
                              'CONTINUE SHOPPING',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const MyOrdersPage(),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: acerPrimaryColor,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              minimumSize: const Size.fromHeight(48),
                              alignment: Alignment.center,
                            ),
                            child: const Text(
                              'VIEW ORDERS',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
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
        ),
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

// Pattern painter for the checkout header
class CheckoutPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final dotPaint = Paint()
      ..color = Colors.white
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 2;

    const dotSpacing = 20.0;

    for (double x = 0; x < size.width; x += dotSpacing) {
      for (double y = 0; y < size.height; y += dotSpacing) {
        canvas.drawCircle(Offset(x, y), 1, dotPaint);
      }
    }

    // Add some larger circles for visual interest
    final accentPaint = Paint()
      ..color = Colors.white.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    canvas.drawCircle(
        Offset(size.width * 0.8, size.height * 0.3), 30, accentPaint);
    canvas.drawCircle(
        Offset(size.width * 0.2, size.height * 0.8), 20, accentPaint);
    canvas.drawCircle(
        Offset(size.width * 0.6, size.height * 0.7), 15, accentPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
