import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:ui';
import 'main.dart';

class ProductDetailsPage extends StatefulWidget {
  final Product product;

  const ProductDetailsPage({Key? key, required this.product}) : super(key: key);

  @override
  State<ProductDetailsPage> createState() => _ProductDetailsPageState();
}

class _ProductDetailsPageState extends State<ProductDetailsPage>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _fadeController;
  late AnimationController _scaleController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  
  bool _isFavorite = false;
  int _selectedImageIndex = 0;
  final PageController _imagePageController = PageController();
  final ScrollController _scrollController = ScrollController();
  
  double _scrollOffset = 0.0;
  bool _showFloatingButton = false;

  // Enhanced product images with better variety
  late List<String> _productImages;

  // Sample specifications with dynamic content based on product
  late Map<String, Map<String, String>> _specifications;

  // Enhanced reviews with more realistic data
  final List<Map<String, dynamic>> _reviews = [
    {
      'name': 'Arjun Malhotra',
      'avatar': 'https://randomuser.me/api/portraits/men/32.jpg',
      'rating': 5,
      'date': '2 days ago',
      'verified': true,
      'comment': 'Outstanding performance! This exceeded my expectations in every way. The build quality is premium and the display is absolutely stunning.',
      'helpful': 47,
      'images': ['https://images.unsplash.com/photo-1593642702821-c8da6771f0c6?w=300'],
    },
    {
      'name': 'Sneha Patel',
      'avatar': 'https://randomuser.me/api/portraits/women/44.jpg',
      'rating': 4,
      'date': '1 week ago',
      'verified': true,
      'comment': 'Great value for money. The performance is solid and the design is sleek. Battery life could be better but overall very satisfied.',
      'helpful': 32,
      'images': [],
    },
    {
      'name': 'Rajesh Kumar',
      'avatar': 'https://randomuser.me/api/portraits/men/62.jpg',
      'rating': 5,
      'date': '2 weeks ago',
      'verified': true,
      'comment': 'Perfect for professional work and gaming. The keyboard is incredibly comfortable and the cooling system works flawlessly.',
      'helpful': 28,
      'images': [],
    },
    {
      'name': 'Meera Singh',
      'avatar': 'https://randomuser.me/api/portraits/women/68.jpg',
      'rating': 4,
      'date': '3 weeks ago',
      'verified': false,
      'comment': 'Impressed with the overall package. The display colors are vibrant and the audio quality is surprisingly good.',
      'helpful': 15,
      'images': [],
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut),
    );

    _setupProductData();
    _scrollController.addListener(_scrollListener);
    
    // Start animations
    _fadeController.forward();
    _scaleController.forward();
  }

  void _scrollListener() {
    setState(() {
      _scrollOffset = _scrollController.offset;
      _showFloatingButton = _scrollOffset > 200;
    });
  }

  void _setupProductData() {
    // Dynamic product images based on category
    _productImages = [
      widget.product.imageUrl,
      'https://images.unsplash.com/photo-1593642702821-c8da6771f0c6?w=800',
      'https://images.unsplash.com/photo-1616788492006-040ec28a4d5d?w=800',
      'https://images.unsplash.com/photo-1518208206632-c8235f5c3dc3?w=800',
    ];

    // Dynamic specifications based on product category
    _specifications = _getSpecificationsForProduct();
  }

  Map<String, Map<String, String>> _getSpecificationsForProduct() {
    if (widget.product.category.contains('Gaming')) {
      return {
        'Performance': {
          'Processor': 'Intel Core i7-13700HX / AMD Ryzen 9 7940HS',
          'Graphics': 'NVIDIA GeForce RTX 4070 / RTX 4080',
          'RAM': '32GB DDR5-5600 (Upgradable to 64GB)',
          'Storage': '1TB PCIe Gen4 NVMe SSD + Empty M.2 Slot',
        },
        'Display': {
          'Screen Size': '16-inch QHD+ / 15.6-inch FHD',
          'Resolution': '2560×1600 / 1920×1080 pixels',
          'Refresh Rate': '240Hz / 165Hz with G-SYNC',
          'Panel Type': 'IPS with 100% DCI-P3 color gamut',
          'Brightness': '500 nits peak brightness',
        },
        'Design & Build': {
          'Dimensions': '358 × 280 × 23.9 mm',
          'Weight': '2.6 kg (gaming configuration)',
          'Keyboard': 'Per-key RGB backlit mechanical',
          'Cooling': 'Dual-fan AeroBlade 3D technology',
          'Materials': 'Premium aluminum chassis',
        },
        'Connectivity': {
          'Wireless': 'Intel Wi-Fi 6E + Bluetooth 5.3',
          'Ports': 'USB-C Thunderbolt 4, 3× USB-A 3.2, HDMI 2.1',
          'Audio': 'DTS:X Ultra quad speakers',
          'Network': 'Killer Ethernet E3100G',
        },
      };
    } else if (widget.product.category.contains('Business')) {
      return {
        'Performance': {
          'Processor': 'Intel Core i7-1360P / AMD Ryzen 7 7730U',
          'Graphics': 'Intel Iris Xe / AMD Radeon Graphics',
          'RAM': '16GB LPDDR5 (Soldered)',
          'Storage': '512GB PCIe NVMe SSD',
        },
        'Display': {
          'Screen Size': '14-inch / 13.3-inch',
          'Resolution': '2880×1800 / 1920×1080 pixels',
          'Panel Type': 'IPS with anti-glare coating',
          'Touch': 'Multi-touch support available',
          'Brightness': '400 nits with 99% sRGB',
        },
        'Design & Portability': {
          'Dimensions': '312 × 225 × 17.9 mm',
          'Weight': '1.25 kg (ultraportable)',
          'Build': 'CNC-machined aluminum unibody',
          'Colors': 'Mist Green / Pure Silver',
          'Certification': 'MIL-STD 810H tested',
        },
        'Business Features': {
          'Security': 'Fingerprint reader, TPM 2.0, IR camera',
          'Connectivity': 'Thunderbolt 4, Wi-Fi 6E, 5G optional',
          'Battery': '65Wh with fast charging',
          'Warranty': '3-year international coverage',
        },
      };
    } else {
      return {
        'Display': {
          'Screen Size': widget.product.category.contains('Monitor') ? '27-inch / 32-inch' : '15.6-inch',
          'Resolution': widget.product.category.contains('Monitor') ? '4K UHD (3840×2160)' : 'Full HD (1920×1080)',
          'Panel Type': 'IPS with wide color gamut',
          'Refresh Rate': widget.product.category.contains('Monitor') ? '144Hz' : '60Hz',
        },
        'Performance': {
          'Processor': 'Intel Core i5-1240P / AMD Ryzen 5 5625U',
          'Graphics': 'Integrated Intel Iris Xe',
          'RAM': '8GB DDR4 (Upgradable to 32GB)',
          'Storage': '256GB NVMe SSD + 1TB HDD',
        },
        'Connectivity': {
          'Wireless': 'Wi-Fi 6 + Bluetooth 5.1',
          'Ports': 'USB-C, 2× USB-A, HDMI, Audio jack',
          'Card Reader': 'SD card reader',
        },
        'General': {
          'Dimensions': '363 × 238 × 19.9 mm',
          'Weight': '1.7 kg',
          'Battery': '48Wh lithium polymer',
          'Operating System': 'Windows 11 Home',
        },
      };
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _fadeController.dispose();
    _scaleController.dispose();
    _imagePageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          _buildSliverAppBar(),
          SliverToBoxAdapter(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: Column(
                  children: [
                    _buildProductHeader(),
                    _buildActionButtons(),
                    _buildTabSection(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: _showFloatingButton
          ? _buildFloatingActionButton()
          : null,
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 400,
      floating: false,
      pinned: true,
      backgroundColor: Colors.white,
      elevation: 0,
      iconTheme: const IconThemeData(color: Colors.black),
      leading: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      actions: [
        Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.9),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: IconButton(
            icon: Icon(
              _isFavorite ? Icons.favorite : Icons.favorite_border,
              color: _isFavorite ? Colors.red : Colors.black,
            ),
            onPressed: () {
              setState(() {
                _isFavorite = !_isFavorite;
              });
            },
          ),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.grey[100]!,
                Colors.white,
              ],
            ),
          ),
          child: Stack(
            children: [
              // Product image carousel with parallax effect
              Positioned.fill(
                child: Transform.translate(
                  offset: Offset(0, _scrollOffset * 0.5),
                  child: PageView.builder(
                    controller: _imagePageController,
                    itemCount: _productImages.length,
                    onPageChanged: (index) {
                      setState(() {
                        _selectedImageIndex = index;
                      });
                    },
                    itemBuilder: (context, index) {
                      return Hero(
                        tag: 'product-${widget.product.name}-$index',
                        child: Container(
                          margin: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: Image.network(
                              _productImages[index],
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  Container(
                                color: Colors.grey[200],
                                child: const Icon(
                                  Icons.image_not_supported,
                                  size: 80,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              // Image indicators
              Positioned(
                bottom: 20,
                left: 0,
                right: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: _productImages.asMap().entries.map((entry) {
                    return Container(
                      width: _selectedImageIndex == entry.key ? 24 : 8,
                      height: 8,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4),
                        color: _selectedImageIndex == entry.key
                            ? acerPrimaryColor
                            : Colors.white.withOpacity(0.5),
                        boxShadow: _selectedImageIndex == entry.key
                            ? [
                                BoxShadow(
                                  color: acerPrimaryColor.withOpacity(0.4),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ]
                            : null,
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProductHeader() {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product name and category
          Row(
            children: [
              Expanded(
                child: Text(
                  widget.product.name,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                    letterSpacing: -0.5,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: acerPrimaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: acerPrimaryColor.withOpacity(0.3)),
                ),
                child: Text(
                  widget.product.category,
                  style: const TextStyle(
                    color: acerPrimaryColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Rating and reviews
          Row(
            children: [
              Row(
                children: List.generate(5, (index) {
                  return Icon(
                    index < 4 ? Icons.star : Icons.star_border,
                    color: Colors.amber,
                    size: 20,
                  );
                }),
              ),
              const SizedBox(width: 8),
              Text(
                '4.8 (${_reviews.length} reviews)',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              const Icon(Icons.verified, color: acerPrimaryColor, size: 16),
              const SizedBox(width: 4),
              const Text(
                'Verified Product',
                style: TextStyle(
                  color: acerPrimaryColor,
                  fontWeight: FontWeight.w500,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          // Price section with enhanced styling
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  acerPrimaryColor.withOpacity(0.1),
                  acerAccentColor.withOpacity(0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '₹${widget.product.price.toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: acerPrimaryColor,
                      ),
                    ),
                    Row(
                      children: [
                        Text(
                          '₹${(widget.product.price * 1.15).toStringAsFixed(0)}',
                          style: TextStyle(
                            fontSize: 16,
                            decoration: TextDecoration.lineThrough,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.green,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            '13% OFF',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const Spacer(),
                const Column(
                  children: [
                    Icon(Icons.local_shipping, color: acerPrimaryColor),
                    SizedBox(height: 4),
                    Text(
                      'Free Delivery',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Container(
              height: 56,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [acerPrimaryColor, acerAccentColor],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: acerPrimaryColor.withOpacity(0.4),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: ElevatedButton.icon(
                onPressed: () {
                  Provider.of<CartProvider>(context, listen: false)
                      .addItem(widget.product);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${widget.product.name} added to cart!'),
                      backgroundColor: acerPrimaryColor,

                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.shopping_cart, color: Colors.white),
                label: const Text(
                  'Add to Cart',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              height: 56,
              decoration: BoxDecoration(
                border: Border.all(color: acerPrimaryColor, width: 2),
                borderRadius: BorderRadius.circular(16),
              ),
              child: ElevatedButton(
                onPressed: () {
                  // Buy now functionality
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: acerPrimaryColor,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text(
                  'Buy Now',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabSection() {
    return Container(
      margin: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          // Enhanced tab bar
          Container(
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: TabBar(
              controller: _tabController,
              labelColor: acerPrimaryColor,
              unselectedLabelColor: Colors.grey[600],
              indicatorColor: acerPrimaryColor,
              indicatorWeight: 3,
              indicatorSize: TabBarIndicatorSize.label,
              labelStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
              unselectedLabelStyle: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              tabs: const [
                Tab(text: 'Overview'),
                Tab(text: 'Specifications'),
                Tab(text: 'Reviews'),
              ],
            ),
          ),
          
          // Tab content
          SizedBox(
            height: 500,
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildOverviewTab(),
                _buildSpecificationsTab(),
                _buildReviewsTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Product Overview',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          
          Text(
            widget.product.description,
            style: TextStyle(
              fontSize: 16,
              height: 1.6,
              color: Colors.grey[700],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Key features
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  acerPrimaryColor.withOpacity(0.05),
                  acerAccentColor.withOpacity(0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Key Features',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: acerPrimaryColor,
                  ),
                ),
                const SizedBox(height: 16),
                _buildFeatureItem(Icons.speed, 'High Performance', 'Powered by latest processors for exceptional speed'),
                _buildFeatureItem(Icons.display_settings, 'Premium Display', 'Crystal clear visuals with accurate colors'),
                _buildFeatureItem(Icons.security, 'Built-in Security', 'Advanced security features for peace of mind'),
                _buildFeatureItem(Icons.battery_charging_full, 'Long Battery Life', 'All-day battery for uninterrupted productivity'),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // What's in the box
          const Text(
            'What\'s in the Box',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          
          ...['Acer ${widget.product.name}', 'Power Adapter', 'User Manual', 'Warranty Card', 'Quick Start Guide']
              .map((item) => _buildBoxItem(item))
              .toList(),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(IconData icon, String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: acerPrimaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: acerPrimaryColor, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  description,
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
    );
  }

  Widget _buildBoxItem(String item) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: acerPrimaryColor, size: 20),
          const SizedBox(width: 12),
          Text(
            item,
            style: const TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildSpecificationsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Technical Specifications',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 20),
          
          ..._specifications.entries.map((category) {
            return Container(
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: ExpansionTile(
                title: Text(
                  category.key,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: acerPrimaryColor,
                  ),
                ),
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: category.value.entries.map((spec) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                flex: 2,
                                child: Text(
                                  spec.key,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 3,
                                child: Text(
                                  spec.value,
                                  style: TextStyle(
                                    color: Colors.grey[700],
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildReviewsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'Customer Reviews',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const Spacer(),
              TextButton.icon(
                onPressed: () {
                  // Write review functionality
                },
                icon: const Icon(Icons.edit),
                label: const Text('Write Review'),
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          // Review summary
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  acerPrimaryColor.withOpacity(0.05),
                  acerAccentColor.withOpacity(0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Column(
                  children: [
                    const Text(
                      '4.8',
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: acerPrimaryColor,
                      ),
                    ),
                    Row(
                      children: List.generate(5, (index) {
                        return Icon(
                          index < 4 ? Icons.star : Icons.star_border,
                          color: Colors.amber,
                          size: 20,
                        );
                      }),
                    ),
                    Text(
                      '${_reviews.length} reviews',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 30),
                Expanded(
                  child: Column(
                    children: [
                      _buildRatingBar(5, 70),
                      _buildRatingBar(4, 20),
                      _buildRatingBar(3, 7),
                      _buildRatingBar(2, 2),
                      _buildRatingBar(1, 1),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Reviews list
          ..._reviews.map((review) => _buildReviewCard(review)).toList(),
        ],
      ),
    );
  }

  Widget _buildRatingBar(int stars, int percentage) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Text('$stars'),
          const SizedBox(width: 8),
          Expanded(
            child: LinearProgressIndicator(
              value: percentage / 100,
              backgroundColor: Colors.grey[300],
              valueColor: const AlwaysStoppedAnimation<Color>(acerPrimaryColor),
            ),
          ),
          const SizedBox(width: 8),
          Text('$percentage%', style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildReviewCard(Map<String, dynamic> review) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundImage: NetworkImage(review['avatar']),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          review['name'],
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        if (review['verified'])
                          Container(
                            margin: const EdgeInsets.only(left: 8),
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: acerPrimaryColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              'Verified',
                              style: TextStyle(
                                color: acerPrimaryColor,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                    Row(
                      children: [
                        ...List.generate(5, (index) {
                          return Icon(
                            index < review['rating'] ? Icons.star : Icons.star_border,
                            color: Colors.amber,
                            size: 16,
                          );
                        }),
                        const SizedBox(width: 8),
                        Text(
                          review['date'],
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
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
          Text(
            review['comment'],
            style: const TextStyle(
              fontSize: 14,
              height: 1.5,
            ),
          ),
          if (review['images'].isNotEmpty) ...[
            const SizedBox(height: 12),
            SizedBox(
              height: 60,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: review['images'].length,
                itemBuilder: (context, index) {
                  return Container(
                    margin: const EdgeInsets.only(right: 8),
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        review['images'][index],
                        fit: BoxFit.cover,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
          const SizedBox(height: 12),
          Row(
            children: [
              TextButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.thumb_up_outlined, size: 16),
                label: Text('Helpful (${review['helpful']})'),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.grey[600],
                  padding: EdgeInsets.zero,
                ),
              ),
              const SizedBox(width: 16),
              TextButton(
                onPressed: () {},
                child: const Text('Reply'),
                style: TextButton.styleFrom(
                  foregroundColor: acerPrimaryColor,
                  padding: EdgeInsets.zero,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    return FloatingActionButton.extended(
      onPressed: () {
        Provider.of<CartProvider>(context, listen: false)
            .addItem(widget.product);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${widget.product.name} added to cart!'),
            backgroundColor: acerPrimaryColor,

            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      },
      backgroundColor: acerPrimaryColor,
      icon: const Icon(Icons.shopping_cart),
      label: const Text('Add to Cart'),
    );
  }
} 
