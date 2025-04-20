import 'package:acer_app/main.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class Address {
  final String id;
  final String name;
  final String addressLine1;
  final String addressLine2;
  final String city;
  final String state;
  final String zipCode;
  final String country;
  final bool isDefault;

  Address({
    required this.id,
    required this.name,
    required this.addressLine1,
    required this.addressLine2,
    required this.city,
    required this.state,
    required this.zipCode,
    required this.country,
    this.isDefault = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'addressLine1': addressLine1,
      'addressLine2': addressLine2,
      'city': city,
      'state': state,
      'zipCode': zipCode,
      'country': country,
      'isDefault': isDefault,
    };
  }

  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      id: json['id'],
      name: json['name'],
      addressLine1: json['addressLine1'],
      addressLine2: json['addressLine2'],
      city: json['city'],
      state: json['state'],
      zipCode: json['zipCode'],
      country: json['country'],
      isDefault: json['isDefault'] ?? false,
    );
  }

  Address copyWith({
    String? id,
    String? name,
    String? addressLine1,
    String? addressLine2,
    String? city,
    String? state,
    String? zipCode,
    String? country,
    bool? isDefault,
  }) {
    return Address(
      id: id ?? this.id,
      name: name ?? this.name,
      addressLine1: addressLine1 ?? this.addressLine1,
      addressLine2: addressLine2 ?? this.addressLine2,
      city: city ?? this.city,
      state: state ?? this.state,
      zipCode: zipCode ?? this.zipCode,
      country: country ?? this.country,
      isDefault: isDefault ?? this.isDefault,
    );
  }
}

class AddressManagement extends StatefulWidget {
  const AddressManagement({Key? key}) : super(key: key);

  @override
  State<AddressManagement> createState() => _AddressManagementState();
}

class _AddressManagementState extends State<AddressManagement> {
  List<Address> _addresses = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAddresses();
  }

  Future<void> _loadAddresses() async {
    final prefs = await SharedPreferences.getInstance();
    final addressesJson = prefs.getString('user_addresses');

    setState(() {
      if (addressesJson != null) {
        final List<dynamic> decodedList = jsonDecode(addressesJson);
        _addresses = decodedList.map((item) => Address.fromJson(item)).toList();
      } else {
        // If no addresses found, add a sample address
        if (_addresses.isEmpty) {
          _addresses = [
            Address(
              id: '1',
              name: 'Home',
              addressLine1: '123 Acer Street',
              addressLine2: 'Apt 456',
              city: 'Techville',
              state: 'CA',
              zipCode: '12345',
              country: 'United States',
              isDefault: true,
            ),
          ];
          _saveAddresses();
        }
      }
      _isLoading = false;
    });
  }

  Future<void> _saveAddresses() async {
    final prefs = await SharedPreferences.getInstance();
    final addressesJson =
        jsonEncode(_addresses.map((e) => e.toJson()).toList());
    await prefs.setString('user_addresses', addressesJson);
  }

  void _setDefaultAddress(String id) {
    setState(() {
      _addresses = _addresses.map((address) {
        return address.copyWith(
          isDefault: address.id == id,
        );
      }).toList();
      _saveAddresses();
    });
  }

  void _deleteAddress(String id) {
    final address = _addresses.firstWhere((address) => address.id == id);
    final isDefault = address.isDefault;

    setState(() {
      _addresses.removeWhere((address) => address.id == id);

      // If we deleted the default address, set a new default if there are any addresses left
      if (isDefault && _addresses.isNotEmpty) {
        _addresses[0] = _addresses[0].copyWith(isDefault: true);
      }

      _saveAddresses();
    });
  }

  void _addEditAddress(Address? address) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddressFormScreen(
          address: address,
          onSave: (newAddress) {
            setState(() {
              if (address != null) {
                // Edit existing address
                final index = _addresses.indexWhere((a) => a.id == address.id);
                if (index >= 0) {
                  _addresses[index] = newAddress;
                }
              } else {
                // Add new address
                // If this is the first address, make it default
                final isDefault = _addresses.isEmpty || newAddress.isDefault;

                // If this is going to be the default address, make sure others aren't
                if (isDefault) {
                  _addresses = _addresses
                      .map((a) => a.copyWith(isDefault: false))
                      .toList();
                }

                _addresses.add(newAddress.copyWith(isDefault: isDefault));
              }
              _saveAddresses();
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
        title: const Text('Address Management'),
        backgroundColor: acerPrimaryColor,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: acerPrimaryColor))
          : _addresses.isEmpty
              ? _buildEmptyState()
              : _buildAddressList(),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addEditAddress(null),
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
            Icons.location_off_outlined,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No Addresses Found',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add your first address to get started',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _addEditAddress(null),
            icon: const Icon(Icons.add),
            label: const Text('Add New Address'),
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

  Widget _buildAddressList() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Padding(
          padding: EdgeInsets.only(bottom: 16),
          child: Text(
            'Your Saved Addresses',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: acerPrimaryColor,
            ),
          ),
        ),
        ..._addresses.map((address) => _buildAddressCard(address)).toList(),
        const SizedBox(height: 80), // Space for FAB
      ],
    );
  }

  Widget _buildAddressCard(Address address) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: address.isDefault ? acerPrimaryColor : Colors.transparent,
          width: address.isDefault ? 2 : 0,
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
                  child: const Icon(
                    Icons.location_on,
                    color: acerPrimaryColor,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    address.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
                if (address.isDefault)
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
            const SizedBox(height: 16),
            Text(
              address.addressLine1,
              style: const TextStyle(fontSize: 16),
            ),
            if (address.addressLine2.isNotEmpty) Text(address.addressLine2),
            const SizedBox(height: 4),
            Text(
              '${address.city}, ${address.state} ${address.zipCode}',
              style: const TextStyle(fontSize: 16),
            ),
            Text(
              address.country,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (!address.isDefault)
                  TextButton.icon(
                    onPressed: () => _setDefaultAddress(address.id),
                    icon: const Icon(Icons.check_circle_outline, size: 18),
                    label: const Text('Set as Default'),
                    style: TextButton.styleFrom(
                      foregroundColor: acerPrimaryColor,
                    ),
                  ),
                const Spacer(),
                IconButton(
                  onPressed: () => _addEditAddress(address),
                  icon: const Icon(Icons.edit_outlined),
                  tooltip: 'Edit Address',
                  color: acerPrimaryColor,
                ),
                IconButton(
                  onPressed: () {
                    // Show confirmation dialog before deleting
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Delete Address'),
                        content: const Text(
                          'Are you sure you want to delete this address?',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                              _deleteAddress(address.id);
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
                  tooltip: 'Delete Address',
                  color: Colors.red,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class AddressFormScreen extends StatefulWidget {
  final Address? address;
  final Function(Address) onSave;

  const AddressFormScreen({
    Key? key,
    this.address,
    required this.onSave,
  }) : super(key: key);

  @override
  State<AddressFormScreen> createState() => _AddressFormScreenState();
}

class _AddressFormScreenState extends State<AddressFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _addressLine1Controller = TextEditingController();
  final _addressLine2Controller = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _zipCodeController = TextEditingController();
  final _countryController = TextEditingController();
  bool _isDefault = false;

  @override
  void initState() {
    super.initState();

    // Pre-fill form if editing an existing address
    if (widget.address != null) {
      _nameController.text = widget.address!.name;
      _addressLine1Controller.text = widget.address!.addressLine1;
      _addressLine2Controller.text = widget.address!.addressLine2;
      _cityController.text = widget.address!.city;
      _stateController.text = widget.address!.state;
      _zipCodeController.text = widget.address!.zipCode;
      _countryController.text = widget.address!.country;
      _isDefault = widget.address!.isDefault;
    } else {
      // Set United States as default country
      _countryController.text = 'United States';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressLine1Controller.dispose();
    _addressLine2Controller.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _zipCodeController.dispose();
    _countryController.dispose();
    super.dispose();
  }

  void _saveAddress() {
    if (_formKey.currentState!.validate()) {
      final newAddress = Address(
        id: widget.address?.id ??
            DateTime.now().millisecondsSinceEpoch.toString(),
        name: _nameController.text,
        addressLine1: _addressLine1Controller.text,
        addressLine2: _addressLine2Controller.text,
        city: _cityController.text,
        state: _stateController.text,
        zipCode: _zipCodeController.text,
        country: _countryController.text,
        isDefault: _isDefault,
      );

      widget.onSave(newAddress);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            Text(widget.address == null ? 'Add New Address' : 'Edit Address'),
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
                labelText: 'Address Name',
                hintText: 'Home, Work, etc.',
                prefixIcon: Icon(Icons.label_outline),
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter an address name';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _addressLine1Controller,
              decoration: const InputDecoration(
                labelText: 'Address Line 1',
                hintText: 'Street address, P.O. box',
                prefixIcon: Icon(Icons.home_outlined),
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your address';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _addressLine2Controller,
              decoration: const InputDecoration(
                labelText: 'Address Line 2 (Optional)',
                hintText: 'Apartment, suite, unit, building, floor, etc.',
                prefixIcon: Icon(Icons.apartment_outlined),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextFormField(
                    controller: _cityController,
                    decoration: const InputDecoration(
                      labelText: 'City',
                      prefixIcon: Icon(Icons.location_city_outlined),
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your city';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _stateController,
                    decoration: const InputDecoration(
                      labelText: 'State',
                      prefixIcon: Icon(Icons.map_outlined),
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Required';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _zipCodeController,
                    decoration: const InputDecoration(
                      labelText: 'ZIP Code',
                      prefixIcon: Icon(Icons.pin_outlined),
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter ZIP code';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 2,
                  child: TextFormField(
                    controller: _countryController,
                    decoration: const InputDecoration(
                      labelText: 'Country',
                      prefixIcon: Icon(Icons.public_outlined),
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your country';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            SwitchListTile(
              title: const Text('Set as Default Address'),
              subtitle: const Text(
                'This address will be used as the default for shipping and billing',
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
                onPressed: _saveAddress,
                style: ElevatedButton.styleFrom(
                  backgroundColor: acerPrimaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  widget.address == null ? 'Add Address' : 'Save Changes',
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
