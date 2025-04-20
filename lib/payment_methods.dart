import 'package:flutter/material.dart';
import 'main.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class PaymentMethod {
  final String id;
  final String type; // 'card', 'upi', 'netbanking', etc.
  final String name;
  final String? cardNumber;
  final String? cardHolderName;
  final String? expiryDate;
  final String? upiId;
  final String? bankName;
  final bool isDefault;

  PaymentMethod({
    required this.id,
    required this.type,
    required this.name,
    this.cardNumber,
    this.cardHolderName,
    this.expiryDate,
    this.upiId,
    this.bankName,
    this.isDefault = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'name': name,
      'cardNumber': cardNumber,
      'cardHolderName': cardHolderName,
      'expiryDate': expiryDate,
      'upiId': upiId,
      'bankName': bankName,
      'isDefault': isDefault,
    };
  }

  factory PaymentMethod.fromJson(Map<String, dynamic> json) {
    return PaymentMethod(
      id: json['id'],
      type: json['type'],
      name: json['name'],
      cardNumber: json['cardNumber'],
      cardHolderName: json['cardHolderName'],
      expiryDate: json['expiryDate'],
      upiId: json['upiId'],
      bankName: json['bankName'],
      isDefault: json['isDefault'] ?? false,
    );
  }

  PaymentMethod copyWith({
    String? id,
    String? type,
    String? name,
    String? cardNumber,
    String? cardHolderName,
    String? expiryDate,
    String? upiId,
    String? bankName,
    bool? isDefault,
  }) {
    return PaymentMethod(
      id: id ?? this.id,
      type: type ?? this.type,
      name: name ?? this.name,
      cardNumber: cardNumber ?? this.cardNumber,
      cardHolderName: cardHolderName ?? this.cardHolderName,
      expiryDate: expiryDate ?? this.expiryDate,
      upiId: upiId ?? this.upiId,
      bankName: bankName ?? this.bankName,
      isDefault: isDefault ?? this.isDefault,
    );
  }

  // Returns a masked version of the card number (e.g., **** **** **** 1234)
  String get maskedCardNumber {
    if (cardNumber == null || cardNumber!.isEmpty) return '';
    final lastFour = cardNumber!.length > 4
        ? cardNumber!.substring(cardNumber!.length - 4)
        : cardNumber;
    return '**** **** **** $lastFour';
  }

  // Returns the card type (Visa, Mastercard, etc.) based on the card number
  String get cardType {
    if (cardNumber == null || cardNumber!.isEmpty) return 'Unknown';

    if (cardNumber!.startsWith('4')) {
      return 'Visa';
    } else if (cardNumber!.startsWith('5')) {
      return 'Mastercard';
    } else if (cardNumber!.startsWith('3')) {
      return 'Amex';
    } else if (cardNumber!.startsWith('6')) {
      return 'Discover';
    } else {
      return 'Unknown';
    }
  }
}

class PaymentMethods extends StatefulWidget {
  const PaymentMethods({Key? key}) : super(key: key);

  @override
  State<PaymentMethods> createState() => _PaymentMethodsState();
}

class _PaymentMethodsState extends State<PaymentMethods> {
  List<PaymentMethod> _paymentMethods = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPaymentMethods();
  }

  Future<void> _loadPaymentMethods() async {
    final prefs = await SharedPreferences.getInstance();
    final paymentMethodsJson = prefs.getString('user_payment_methods');

    setState(() {
      if (paymentMethodsJson != null) {
        final List<dynamic> decodedList = jsonDecode(paymentMethodsJson);
        _paymentMethods =
            decodedList.map((item) => PaymentMethod.fromJson(item)).toList();
      } else {
        // If no payment methods found, add sample methods
        if (_paymentMethods.isEmpty) {
          _paymentMethods = [
            PaymentMethod(
              id: '1',
              type: 'card',
              name: 'Personal Card',
              cardNumber: '4111111111111111',
              cardHolderName: 'John Doe',
              expiryDate: '12/25',
              isDefault: true,
            ),
            PaymentMethod(
              id: '2',
              type: 'upi',
              name: 'Personal UPI',
              upiId: 'johndoe@okbank',
              isDefault: false,
            ),
          ];
          _savePaymentMethods();
        }
      }
      _isLoading = false;
    });
  }

  Future<void> _savePaymentMethods() async {
    final prefs = await SharedPreferences.getInstance();
    final paymentMethodsJson =
        jsonEncode(_paymentMethods.map((e) => e.toJson()).toList());
    await prefs.setString('user_payment_methods', paymentMethodsJson);
  }

  void _setDefaultPaymentMethod(String id) {
    setState(() {
      _paymentMethods = _paymentMethods.map((method) {
        return method.copyWith(
          isDefault: method.id == id,
        );
      }).toList();
      _savePaymentMethods();
    });
  }

  void _deletePaymentMethod(String id) {
    final method = _paymentMethods.firstWhere((method) => method.id == id);
    final isDefault = method.isDefault;

    setState(() {
      _paymentMethods.removeWhere((method) => method.id == id);

      // If we deleted the default method, set a new default if there are any methods left
      if (isDefault && _paymentMethods.isNotEmpty) {
        _paymentMethods[0] = _paymentMethods[0].copyWith(isDefault: true);
      }

      _savePaymentMethods();
    });
  }

  void _showAddPaymentMethodBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Add Payment Method',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 24),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: acerPrimaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.credit_card_outlined,
                      color: acerPrimaryColor,
                    ),
                  ),
                  title: const Text('Credit/Debit Card'),
                  subtitle: const Text('Add a new card'),
                  onTap: () {
                    Navigator.pop(context);
                    _addEditPaymentMethod(PaymentMethodType.card);
                  },
                ),
                const Divider(),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: acerPrimaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.account_balance_outlined,
                      color: acerPrimaryColor,
                    ),
                  ),
                  title: const Text('UPI'),
                  subtitle: const Text('Pay using UPI ID'),
                  onTap: () {
                    Navigator.pop(context);
                    _addEditPaymentMethod(PaymentMethodType.upi);
                  },
                ),
                const Divider(),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: acerPrimaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.account_balance_wallet_outlined,
                      color: acerPrimaryColor,
                    ),
                  ),
                  title: const Text('Net Banking'),
                  subtitle: const Text('Pay using your bank account'),
                  onTap: () {
                    Navigator.pop(context);
                    _addEditPaymentMethod(PaymentMethodType.netBanking);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _addEditPaymentMethod(PaymentMethodType type,
      [PaymentMethod? existingMethod]) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PaymentMethodFormScreen(
          type: type,
          paymentMethod: existingMethod,
          onSave: (newMethod) {
            setState(() {
              if (existingMethod != null) {
                // Edit existing method
                final index = _paymentMethods
                    .indexWhere((m) => m.id == existingMethod.id);
                if (index >= 0) {
                  _paymentMethods[index] = newMethod;
                }
              } else {
                // Add new method
                // If this is the first method, make it default
                final isDefault =
                    _paymentMethods.isEmpty || newMethod.isDefault;

                // If this is going to be the default method, make sure others aren't
                if (isDefault) {
                  _paymentMethods = _paymentMethods
                      .map((m) => m.copyWith(isDefault: false))
                      .toList();
                }

                _paymentMethods.add(newMethod.copyWith(isDefault: isDefault));
              }
              _savePaymentMethods();
            });
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment Methods'),
        backgroundColor: acerPrimaryColor,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: acerPrimaryColor))
          : _paymentMethods.isEmpty
              ? _buildEmptyState()
              : _buildPaymentMethodsList(),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddPaymentMethodBottomSheet,
        backgroundColor: acerPrimaryColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.credit_card_off_outlined,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No Payment Methods Found',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add your first payment method to get started',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _showAddPaymentMethodBottomSheet,
            icon: const Icon(Icons.add),
            label: const Text('Add Payment Method'),
            style: ElevatedButton.styleFrom(
              backgroundColor: acerPrimaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodsList() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Padding(
          padding: EdgeInsets.only(bottom: 16),
          child: Text(
            'Your Payment Methods',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: acerPrimaryColor,
            ),
          ),
        ),
        ..._paymentMethods
            .map((method) => _buildPaymentMethodCard(method))
            .toList(),
        const SizedBox(height: 80), // Space for FAB
      ],
    );
  }

  Widget _buildPaymentMethodCard(PaymentMethod method) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: method.isDefault ? acerPrimaryColor : Colors.transparent,
          width: method.isDefault ? 2 : 0,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
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
                  child: Icon(
                    _getPaymentMethodIcon(method.type),
                    color: acerPrimaryColor,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        method.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _getPaymentMethodSubtitle(method),
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                if (method.isDefault)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: acerPrimaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: acerPrimaryColor),
                    ),
                    child: const Text(
                      'Default',
                      style: TextStyle(
                        color: acerPrimaryColor,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
            if (method.type == 'card')
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Row(
                  children: [
                    Text(
                      method.maskedCardNumber,
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 16,
                        letterSpacing: 1,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      method.cardType,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[700],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            if (method.type == 'card' && method.expiryDate != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  'Expires: ${method.expiryDate}',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ),
            if (method.type == 'upi' && method.upiId != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  'UPI ID: ${method.upiId}',
                  style: const TextStyle(
                    fontSize: 14,
                  ),
                ),
              ),
            if (method.type == 'netbanking' && method.bankName != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  'Bank: ${method.bankName}',
                  style: const TextStyle(
                    fontSize: 14,
                  ),
                ),
              ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (!method.isDefault)
                  TextButton.icon(
                    onPressed: () => _setDefaultPaymentMethod(method.id),
                    icon: const Icon(Icons.check_circle_outline, size: 18),
                    label: const Text('Set as Default'),
                    style: TextButton.styleFrom(
                      foregroundColor: acerPrimaryColor,
                    ),
                  ),
                const Spacer(),
                IconButton(
                  onPressed: () {
                    final type = method.type == 'card'
                        ? PaymentMethodType.card
                        : method.type == 'upi'
                            ? PaymentMethodType.upi
                            : PaymentMethodType.netBanking;
                    _addEditPaymentMethod(type, method);
                  },
                  icon: const Icon(Icons.edit_outlined),
                  tooltip: 'Edit Payment Method',
                  color: acerPrimaryColor,
                ),
                IconButton(
                  onPressed: () {
                    // Show confirmation dialog before deleting
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Delete Payment Method'),
                        content: const Text(
                          'Are you sure you want to delete this payment method?',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                              _deletePaymentMethod(method.id);
                            },
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.red,
                            ),
                            child: const Text('Delete'),
                          ),
                        ],
                      ),
                    );
                  },
                  icon: const Icon(Icons.delete_outline),
                  tooltip: 'Delete Payment Method',
                  color: Colors.red,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  IconData _getPaymentMethodIcon(String type) {
    switch (type) {
      case 'card':
        return Icons.credit_card;
      case 'upi':
        return Icons.account_balance_wallet;
      case 'netbanking':
        return Icons.account_balance;
      default:
        return Icons.payment;
    }
  }

  String _getPaymentMethodSubtitle(PaymentMethod method) {
    switch (method.type) {
      case 'card':
        return 'Credit/Debit Card';
      case 'upi':
        return 'UPI Payment';
      case 'netbanking':
        return 'Net Banking';
      default:
        return 'Payment Method';
    }
  }
}

enum PaymentMethodType { card, upi, netBanking }

class PaymentMethodFormScreen extends StatefulWidget {
  final PaymentMethodType type;
  final PaymentMethod? paymentMethod;
  final Function(PaymentMethod) onSave;

  const PaymentMethodFormScreen({
    Key? key,
    required this.type,
    this.paymentMethod,
    required this.onSave,
  }) : super(key: key);

  @override
  State<PaymentMethodFormScreen> createState() =>
      _PaymentMethodFormScreenState();
}

class _PaymentMethodFormScreenState extends State<PaymentMethodFormScreen> {
  final _formKey = GlobalKey<FormState>();

  // Common fields
  final _nameController = TextEditingController();
  bool _isDefault = false;

  // Card specific fields
  final _cardNumberController = TextEditingController();
  final _cardHolderNameController = TextEditingController();
  final _expiryDateController = TextEditingController();
  final _cvvController = TextEditingController();

  // UPI specific fields
  final _upiIdController = TextEditingController();

  // Net Banking specific fields
  final _bankNameController = TextEditingController();
  String _selectedBank = 'Select Bank';

  final List<String> _banksList = [
    'Select Bank',
    'HDFC Bank',
    'ICICI Bank',
    'State Bank of India',
    'Axis Bank',
    'Kotak Mahindra Bank',
    'Yes Bank',
    'Bank of Baroda',
    'Punjab National Bank',
    'Other'
  ];

  @override
  void initState() {
    super.initState();

    // Pre-fill form if editing an existing payment method
    if (widget.paymentMethod != null) {
      _nameController.text = widget.paymentMethod!.name;
      _isDefault = widget.paymentMethod!.isDefault;

      switch (widget.type) {
        case PaymentMethodType.card:
          if (widget.paymentMethod!.cardNumber != null) {
            _cardNumberController.text = widget.paymentMethod!.cardNumber!;
          }
          if (widget.paymentMethod!.cardHolderName != null) {
            _cardHolderNameController.text =
                widget.paymentMethod!.cardHolderName!;
          }
          if (widget.paymentMethod!.expiryDate != null) {
            _expiryDateController.text = widget.paymentMethod!.expiryDate!;
          }
          break;

        case PaymentMethodType.upi:
          if (widget.paymentMethod!.upiId != null) {
            _upiIdController.text = widget.paymentMethod!.upiId!;
          }
          break;

        case PaymentMethodType.netBanking:
          if (widget.paymentMethod!.bankName != null) {
            _bankNameController.text = widget.paymentMethod!.bankName!;
            if (_banksList.contains(widget.paymentMethod!.bankName)) {
              _selectedBank = widget.paymentMethod!.bankName!;
            } else {
              _selectedBank = 'Other';
            }
          }
          break;
      }
    } else {
      // Default values for new payment methods
      switch (widget.type) {
        case PaymentMethodType.card:
          _nameController.text = 'My Card';
          break;
        case PaymentMethodType.upi:
          _nameController.text = 'My UPI';
          break;
        case PaymentMethodType.netBanking:
          _nameController.text = 'My Net Banking';
          break;
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _cardNumberController.dispose();
    _cardHolderNameController.dispose();
    _expiryDateController.dispose();
    _cvvController.dispose();
    _upiIdController.dispose();
    _bankNameController.dispose();
    super.dispose();
  }

  String _getFormattedCardNumber(String text) {
    // Remove all non-digit characters
    text = text.replaceAll(RegExp(r'\D'), '');

    // Add a space after every 4 digits
    final buffer = StringBuffer();
    for (int i = 0; i < text.length; i++) {
      buffer.write(text[i]);
      if ((i + 1) % 4 == 0 && i != text.length - 1) {
        buffer.write(' ');
      }
    }

    return buffer.toString();
  }

  void _savePaymentMethod() {
    if (_formKey.currentState!.validate()) {
      String typeString;
      switch (widget.type) {
        case PaymentMethodType.card:
          typeString = 'card';
          break;
        case PaymentMethodType.upi:
          typeString = 'upi';
          break;
        case PaymentMethodType.netBanking:
          typeString = 'netbanking';
          break;
      }

      final newMethod = PaymentMethod(
        id: widget.paymentMethod?.id ??
            DateTime.now().millisecondsSinceEpoch.toString(),
        type: typeString,
        name: _nameController.text,
        cardNumber: widget.type == PaymentMethodType.card
            ? _cardNumberController.text.replaceAll(' ', '')
            : null,
        cardHolderName: widget.type == PaymentMethodType.card
            ? _cardHolderNameController.text
            : null,
        expiryDate: widget.type == PaymentMethodType.card
            ? _expiryDateController.text
            : null,
        upiId:
            widget.type == PaymentMethodType.upi ? _upiIdController.text : null,
        bankName: widget.type == PaymentMethodType.netBanking
            ? (_selectedBank == 'Other'
                ? _bankNameController.text
                : _selectedBank)
            : null,
        isDefault: _isDefault,
      );

      widget.onSave(newMethod);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    String title;
    switch (widget.type) {
      case PaymentMethodType.card:
        title = widget.paymentMethod == null ? 'Add Card' : 'Edit Card';
        break;
      case PaymentMethodType.upi:
        title = widget.paymentMethod == null ? 'Add UPI' : 'Edit UPI';
        break;
      case PaymentMethodType.netBanking:
        title = widget.paymentMethod == null
            ? 'Add Net Banking'
            : 'Edit Net Banking';
        break;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: acerPrimaryColor,
        foregroundColor: Colors.white,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Payment Method Name',
                hintText: 'e.g., Personal Card, Work UPI',
                prefixIcon: Icon(Icons.label_outline),
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a name';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Card specific fields
            if (widget.type == PaymentMethodType.card) ...[
              TextFormField(
                controller: _cardNumberController,
                decoration: const InputDecoration(
                  labelText: 'Card Number',
                  hintText: 'XXXX XXXX XXXX XXXX',
                  prefixIcon: Icon(Icons.credit_card_outlined),
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  final formattedValue = _getFormattedCardNumber(value);
                  if (formattedValue != value) {
                    _cardNumberController.value = TextEditingValue(
                      text: formattedValue,
                      selection: TextSelection.collapsed(
                          offset: formattedValue.length),
                    );
                  }
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter card number';
                  }
                  final digitsOnly = value.replaceAll(' ', '');
                  if (digitsOnly.length < 13 || digitsOnly.length > 19) {
                    return 'Invalid card number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _cardHolderNameController,
                decoration: const InputDecoration(
                  labelText: 'Card Holder Name',
                  hintText: 'Name as it appears on the card',
                  prefixIcon: Icon(Icons.person_outline),
                  border: OutlineInputBorder(),
                ),
                textCapitalization: TextCapitalization.characters,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter card holder name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _expiryDateController,
                      decoration: const InputDecoration(
                        labelText: 'Expiry Date',
                        hintText: 'MM/YY',
                        prefixIcon: Icon(Icons.calendar_today_outlined),
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Required';
                        }
                        if (!RegExp(r'^\d{2}/\d{2}$').hasMatch(value)) {
                          return 'Use MM/YY format';
                        }
                        final parts = value.split('/');
                        final month = int.tryParse(parts[0]);
                        if (month == null || month < 1 || month > 12) {
                          return 'Invalid month';
                        }
                        return null;
                      },
                      onChanged: (value) {
                        // Auto-format to MM/YY
                        if (value.length == 2 && !value.contains('/')) {
                          _expiryDateController.text = '$value/';
                          _expiryDateController.selection =
                              TextSelection.fromPosition(
                            const TextPosition(offset: 3),
                          );
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _cvvController,
                      decoration: const InputDecoration(
                        labelText: 'CVV',
                        hintText: '3-4 digits',
                        prefixIcon: Icon(Icons.security_outlined),
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      obscureText: true,
                      maxLength: 4,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Required';
                        }
                        if (value.length < 3) {
                          return 'Invalid CVV';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
            ],

            // UPI specific fields
            if (widget.type == PaymentMethodType.upi) ...[
              TextFormField(
                controller: _upiIdController,
                decoration: const InputDecoration(
                  labelText: 'UPI ID',
                  hintText: 'username@bank',
                  prefixIcon: Icon(Icons.account_balance_wallet_outlined),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter UPI ID';
                  }
                  if (!value.contains('@')) {
                    return 'Invalid UPI ID format';
                  }
                  return null;
                },
              ),
            ],

            // Net Banking specific fields
            if (widget.type == PaymentMethodType.netBanking) ...[
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Select Bank',
                  prefixIcon: Icon(Icons.account_balance_outlined),
                  border: OutlineInputBorder(),
                ),
                value: _selectedBank,
                items: _banksList.map((bank) {
                  return DropdownMenuItem<String>(
                    value: bank,
                    child: Text(bank),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedBank = value!;
                  });
                },
                validator: (value) {
                  if (value == null || value == 'Select Bank') {
                    return 'Please select a bank';
                  }
                  return null;
                },
              ),
              if (_selectedBank == 'Other') ...[
                const SizedBox(height: 16),
                TextFormField(
                  controller: _bankNameController,
                  decoration: const InputDecoration(
                    labelText: 'Bank Name',
                    hintText: 'Enter your bank name',
                    prefixIcon: Icon(Icons.account_balance_outlined),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (_selectedBank == 'Other' &&
                        (value == null || value.isEmpty)) {
                      return 'Please enter bank name';
                    }
                    return null;
                  },
                ),
              ],
            ],

            const SizedBox(height: 24),
            SwitchListTile(
              title: const Text('Set as Default Payment Method'),
              subtitle: const Text(
                'This payment method will be selected by default during checkout',
              ),
              value: _isDefault,
              activeColor: acerPrimaryColor,
              onChanged: (bool value) {
                setState(() {
                  _isDefault = value;
                });
              },
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 50,
              child: ElevatedButton(
                onPressed: _savePaymentMethod,
                style: ElevatedButton.styleFrom(
                  backgroundColor: acerPrimaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  widget.paymentMethod == null
                      ? 'Add Payment Method'
                      : 'Save Changes',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
