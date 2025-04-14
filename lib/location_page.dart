import 'package:flutter/material.dart';
import 'main.dart';

class LocationPage extends StatefulWidget {
  const LocationPage({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _LocationPageState createState() => _LocationPageState();
}

class _LocationPageState extends State<LocationPage>
    with SingleTickerProviderStateMixin {
  String _selectedCity = 'Mumbai';
  String _selectedType = 'all'; // 'all', 'shop', 'service'
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    // Setup animations
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  // Sample data for Acer stores and service centers
  final Map<String, List<Map<String, dynamic>>> _locations = {
    'Mumbai': [
      {
        'name': 'Acer Exclusive Store - Andheri',
        'address': 'Shop No. 7, Link Road, Andheri West',
        'type': 'shop',
        'lat': 19.1367,
        'lng': 72.8296,
        'phone': '+91 9876543210',
      },
      {
        'name': 'Acer Service Center - Malad',
        'address': '1st Floor, Mall Plaza, Malad West',
        'type': 'service',
        'lat': 19.1859,
        'lng': 72.8484,
        'phone': '+91 9876543211',
      },
      {
        'name': 'Acer Premium Store - Bandra',
        'address': 'Shop 12, Linking Road, Bandra West',
        'type': 'shop',
        'lat': 19.0596,
        'lng': 72.8295,
        'phone': '+91 9876543299',
      },
      {
        'name': 'Acer Service Hub - Powai',
        'address': 'Hiranandani Gardens, Powai',
        'type': 'service',
        'lat': 19.1201,
        'lng': 72.9085,
        'phone': '+91 9876543201',
      },
    ],
    'Delhi': [
      {
        'name': 'Acer Store - Connaught Place',
        'address': 'Block A, Connaught Place',
        'type': 'shop',
        'lat': 28.6289,
        'lng': 77.2065,
        'phone': '+91 9876543212',
      },
      {
        'name': 'Acer Service Hub - Nehru Place',
        'address': 'Ground Floor, Nehru Place',
        'type': 'service',
        'lat': 28.5483,
        'lng': 77.2513,
        'phone': '+91 9876543213',
      },
      {
        'name': 'Acer Exclusive Store - Saket',
        'address': 'Select Citywalk Mall, Saket District Centre',
        'type': 'shop',
        'lat': 28.5273,
        'lng': 77.2207,
        'phone': '+91 9876543313',
      },
      {
        'name': 'Acer Service Center - Rajouri Garden',
        'address': 'J-Block, Rajouri Garden',
        'type': 'service',
        'lat': 28.6479,
        'lng': 77.1173,
        'phone': '+91 9876543214',
      },
    ],
    'Bangalore': [
      {
        'name': 'Acer Mall Store - MG Road',
        'address': 'Shop 12, MG Road Mall',
        'type': 'shop',
        'lat': 12.9716,
        'lng': 77.6189,
        'phone': '+91 9876543214',
      },
      {
        'name': 'Acer Care - Koramangala',
        'address': '5th Block, Koramangala',
        'type': 'service',
        'lat': 12.9279,
        'lng': 77.6271,
        'phone': '+91 9876543215',
      },
      {
        'name': 'Acer Premium Store - Indiranagar',
        'address': '100 Feet Road, Indiranagar',
        'type': 'shop',
        'lat': 12.9784,
        'lng': 77.6408,
        'phone': '+91 9876543255',
      },
      {
        'name': 'Acer Service Hub - Whitefield',
        'address': 'Phoenix Marketcity, Whitefield',
        'type': 'service',
        'lat': 12.9973,
        'lng': 77.7270,
        'phone': '+91 9876543256',
      },
    ],
    'Chennai': [
      {
        'name': 'Acer Exclusive Store - T Nagar',
        'address': 'North Usman Road, T Nagar',
        'type': 'shop',
        'lat': 13.0418,
        'lng': 80.2341,
        'phone': '+91 9876543216',
      },
      {
        'name': 'Acer Service Center - Anna Nagar',
        'address': '2nd Avenue, Anna Nagar',
        'type': 'service',
        'lat': 13.0850,
        'lng': 80.2101,
        'phone': '+91 9876543217',
      },
      {
        'name': 'Acer Premium Store - Velachery',
        'address': 'Phoenix Market City, Velachery',
        'type': 'shop',
        'lat': 12.9794,
        'lng': 80.2173,
        'phone': '+91 9876543218',
      },
    ],
    'Hyderabad': [
      {
        'name': 'Acer Mall Store - Banjara Hills',
        'address': 'Road No. 12, Banjara Hills',
        'type': 'shop',
        'lat': 17.4156,
        'lng': 78.4347,
        'phone': '+91 9876543219',
      },
      {
        'name': 'Acer Service Hub - Hitech City',
        'address': 'HITEC City Main Road, Madhapur',
        'type': 'service',
        'lat': 17.4450,
        'lng': 78.3811,
        'phone': '+91 9876543220',
      },
      {
        'name': 'Acer Exclusive Store - Jubilee Hills',
        'address': 'Road No. 36, Jubilee Hills',
        'type': 'shop',
        'lat': 17.4279,
        'lng': 78.4069,
        'phone': '+91 9876543221',
      },
    ],
    'Kolkata': [
      {
        'name': 'Acer Store - Park Street',
        'address': 'Park Street, Kolkata',
        'type': 'shop',
        'lat': 22.5515,
        'lng': 88.3525,
        'phone': '+91 9876543222',
      },
      {
        'name': 'Acer Service Center - Salt Lake',
        'address': 'Sector V, Salt Lake City',
        'type': 'service',
        'lat': 22.5697,
        'lng': 88.4332,
        'phone': '+91 9876543223',
      },
    ],
    'Pune': [
      {
        'name': 'Acer Premium Store - Koregaon Park',
        'address': 'North Main Road, Koregaon Park',
        'type': 'shop',
        'lat': 18.5362,
        'lng': 73.8939,
        'phone': '+91 9876543224',
      },
      {
        'name': 'Acer Service Hub - Aundh',
        'address': 'DP Road, Aundh',
        'type': 'service',
        'lat': 18.5589,
        'lng': 73.8078,
        'phone': '+91 9876543225',
      },
    ],
    'Ahmedabad': [
      {
        'name': 'Acer Exclusive Store - CG Road',
        'address': 'CG Road, Navrangpura',
        'type': 'shop',
        'lat': 23.0225,
        'lng': 72.5714,
        'phone': '+91 9876543226',
      },
      {
        'name': 'Acer Service Center - Satellite',
        'address': 'Satellite Road, Ahmedabad',
        'type': 'service',
        'lat': 23.0117,
        'lng': 72.5253,
        'phone': '+91 9876543227',
      },
    ],
    'Jaipur': [
      {
        'name': 'Acer Store - Tonk Road',
        'address': 'Tonk Road, Jaipur',
        'type': 'shop',
        'lat': 26.8578,
        'lng': 75.8020,
        'phone': '+91 9876543228',
      },
      {
        'name': 'Acer Service Hub - Vaishali Nagar',
        'address': 'Vaishali Nagar, Jaipur',
        'type': 'service',
        'lat': 26.9124,
        'lng': 75.7495,
        'phone': '+91 9876543229',
      },
    ],
    'Chandigarh': [
      {
        'name': 'Acer Premium Store - Sector 17',
        'address': 'Sector 17-C, Chandigarh',
        'type': 'shop',
        'lat': 30.7333,
        'lng': 76.7794,
        'phone': '+91 9876543230',
      },
      {
        'name': 'Acer Service Center - Industrial Area',
        'address': 'Phase 2, Industrial Area',
        'type': 'service',
        'lat': 30.7046,
        'lng': 76.8011,
        'phone': '+91 9876543231',
      },
    ],
    'Kochi': [
      {
        'name': 'Acer Exclusive Store - MG Road',
        'address': 'MG Road, Ernakulam',
        'type': 'shop',
        'lat': 9.9775,
        'lng': 76.2808,
        'phone': '+91 9876543232',
      },
      {
        'name': 'Acer Service Hub - Edappally',
        'address': 'Lulu Mall, Edappally',
        'type': 'service',
        'lat': 10.0274,
        'lng': 76.3083,
        'phone': '+91 9876543233',
      },
    ],
    'Lucknow': [
      {
        'name': 'Acer Store - Hazratganj',
        'address': 'Hazratganj, Lucknow',
        'type': 'shop',
        'lat': 26.8540,
        'lng': 80.9477,
        'phone': '+91 9876543234',
      },
      {
        'name': 'Acer Service Center - Gomti Nagar',
        'address': 'Vibhuti Khand, Gomti Nagar',
        'type': 'service',
        'lat': 26.8606,
        'lng': 81.0089,
        'phone': '+91 9876543235',
      },
    ],
    'Guwahati': [
      {
        'name': 'Acer Premium Store - GS Road',
        'address': 'GS Road, Christian Basti',
        'type': 'shop',
        'lat': 26.1445,
        'lng': 91.7362,
        'phone': '+91 9876543236',
      },
      {
        'name': 'Acer Service Hub - Zoo Road',
        'address': 'R.G. Baruah Road, Zoo Road',
        'type': 'service',
        'lat': 26.1758,
        'lng': 91.7673,
        'phone': '+91 9876543237',
      },
    ],
    'Bhopal': [
      {
        'name': 'Acer Exclusive Store - MP Nagar',
        'address': 'Zone I, MP Nagar',
        'type': 'shop',
        'lat': 23.2329,
        'lng': 77.4349,
        'phone': '+91 9876543238',
      },
      {
        'name': 'Acer Service Center - New Market',
        'address': 'New Market, TT Nagar',
        'type': 'service',
        'lat': 23.2350,
        'lng': 77.4027,
        'phone': '+91 9876543239',
      },
    ],
  };

  void _showLocationDetails(Map<String, dynamic> location) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.6,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(30),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with image
            Stack(
              children: [
                Container(
                  height: 180,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(24),
                      topRight: Radius.circular(24),
                    ),
                    gradient: LinearGradient(
                      begin: Alignment.topRight,
                      end: Alignment.bottomLeft,
                      colors: location['type'] == 'shop'
                          ? [acerPrimaryColor, acerAccentColor]
                          : [acerAccentColor, Colors.purple],
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(24),
                      topRight: Radius.circular(24),
                    ),
                    child: Icon(
                      location['type'] == 'shop'
                          ? Icons.storefront
                          : Icons.build_circle,
                      color: Colors.white.withAlpha(60),
                      size: 120,
                    ),
                  ),
                ),
                // Store/Service details card
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    margin: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha(20),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: location['type'] == 'shop'
                                  ? acerPrimaryColor.withAlpha(30)
                                  : acerAccentColor.withAlpha(30),
                              child: Icon(
                                location['type'] == 'shop'
                                    ? Icons.store
                                    : Icons.build,
                                color: location['type'] == 'shop'
                                    ? acerPrimaryColor
                                    : acerAccentColor,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    location['name'],
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    location['type'] == 'shop'
                                        ? 'Exclusive Store'
                                        : 'Service Center',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: location['type'] == 'shop'
                                          ? acerPrimaryColor
                                          : acerAccentColor,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                // Close button
                Positioned(
                  top: 16,
                  right: 16,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(180),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                      color: Colors.black87,
                    ),
                  ),
                ),
              ],
            ),
            // Additional details
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Location Details',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildDetailRow(
                      Icons.location_on_outlined,
                      'Address',
                      location['address'],
                    ),
                    _buildDetailRow(
                      Icons.phone_outlined,
                      'Phone',
                      location['phone'],
                    ),
                    _buildDetailRow(
                      Icons.access_time_outlined,
                      'Opening Hours',
                      '10:00 AM - 8:00 PM',
                    ),
                    _buildDetailRow(
                      Icons.calendar_today_outlined,
                      'Working Days',
                      'Monday - Saturday',
                    ),
                    const SizedBox(height: 24),
                    // Action buttons
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            icon: const Icon(Icons.directions),
                            label: const Text('Directions'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: acerPrimaryColor,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: () => _launchMaps(location),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton.icon(
                            icon: const Icon(Icons.phone),
                            label: const Text('Call'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: acerAccentColor,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: () => _launchPhone(location['phone']),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: acerAccentColor,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _launchMaps(Map<String, dynamic> location) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text('Maps would open directions to ${location['name']}')),
    );
  }

  void _launchPhone(String phone) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Calling $phone')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Header with animated title
            Container(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              decoration: BoxDecoration(
                color: acerPrimaryColor,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(24),
                  bottomRight: Radius.circular(24),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(30),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Store Locator',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 50,
                    child: Row(
                      children: [
                        Expanded(
                          child: AnimatedBuilder(
                            animation: _animationController,
                            builder: (context, child) {
                              return Transform.translate(
                                offset:
                                    Offset(0, (1 - _fadeAnimation.value) * 20),
                                child: Opacity(
                                  opacity: _fadeAnimation.value,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16),
                                    child: DropdownButtonHideUnderline(
                                      child: DropdownButton<String>(
                                        value: _selectedCity,
                                        icon: const Icon(
                                            Icons.keyboard_arrow_down),
                                        isExpanded: true,
                                        items: _locations.keys.map((city) {
                                          return DropdownMenuItem(
                                            value: city,
                                            child: Text(city),
                                          );
                                        }).toList(),
                                        onChanged: (value) {
                                          if (value != null) {
                                            setState(() {
                                              _selectedCity = value;
                                              _animationController.reset();
                                              _animationController.forward();
                                            });
                                          }
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        AnimatedBuilder(
                          animation: _animationController,
                          builder: (context, child) {
                            return Transform.translate(
                              offset:
                                  Offset(0, (1 - _fadeAnimation.value) * 20),
                              child: Opacity(
                                opacity: _fadeAnimation.value,
                                child: Container(
                                  width: 140,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16),
                                  child: DropdownButtonHideUnderline(
                                    child: DropdownButton<String>(
                                      value: _selectedType,
                                      icon:
                                          const Icon(Icons.keyboard_arrow_down),
                                      isExpanded: true,
                                      items: const [
                                        DropdownMenuItem(
                                          value: 'all',
                                          child: Text('All'),
                                        ),
                                        DropdownMenuItem(
                                          value: 'shop',
                                          child: Text('Stores'),
                                        ),
                                        DropdownMenuItem(
                                          value: 'service',
                                          child: Text('Service'),
                                        ),
                                      ],
                                      onChanged: (value) {
                                        if (value != null) {
                                          setState(() {
                                            _selectedType = value;
                                            _animationController.reset();
                                            _animationController.forward();
                                          });
                                        }
                                      },
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Location cards
            Expanded(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: _buildLocationList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationList() {
    List<Map<String, dynamic>> filteredLocations = [];

    if (_locations.containsKey(_selectedCity)) {
      filteredLocations = _locations[_selectedCity]!
          .where((location) =>
              _selectedType == 'all' || location['type'] == _selectedType)
          .toList();
    }

    if (filteredLocations.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.location_off,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No locations found',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Try changing your filters',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filteredLocations.length,
      itemBuilder: (context, index) {
        final location = filteredLocations[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: LocationCard(
            location: location,
            onTap: () => _showLocationDetails(location),
          ),
        );
      },
    );
  }
}

class LocationCard extends StatelessWidget {
  final Map<String, dynamic> location;
  final VoidCallback onTap;

  const LocationCard({
    Key? key,
    required this.location,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool isStore = location['type'] == 'shop';
    final Color primaryColor = isStore ? acerPrimaryColor : acerAccentColor;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(10),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            children: [
              // Header with tag
              Container(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Icon
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: primaryColor.withAlpha(20),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        isStore ? Icons.storefront : Icons.build,
                        color: primaryColor,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Details
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            location['name'],
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            location['address'],
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 8),
                          // Tag
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: primaryColor.withAlpha(30),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Text(
                              isStore ? 'Exclusive Store' : 'Service Center',
                              style: TextStyle(
                                color: primaryColor,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Chevron
                    Icon(
                      Icons.chevron_right,
                      color: Colors.grey[400],
                    ),
                  ],
                ),
              ),
              // Footer with actions
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          size: 14,
                          color: Colors.grey[500],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '10 AM - 8 PM',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    const Row(
                      children: [
                        Icon(
                          Icons.phone,
                          size: 14,
                          color: acerAccentColor,
                        ),
                        SizedBox(width: 4),
                        Text(
                          'Call',
                          style: TextStyle(
                            fontSize: 12,
                            color: acerAccentColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 16),
                    const Row(
                      children: [
                        Icon(
                          Icons.directions,
                          size: 14,
                          color: acerPrimaryColor,
                        ),
                        SizedBox(width: 4),
                        Text(
                          'Directions',
                          style: TextStyle(
                            fontSize: 12,
                            color: acerPrimaryColor,
                            fontWeight: FontWeight.w500,
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
}
