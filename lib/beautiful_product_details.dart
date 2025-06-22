import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'main.dart';
import 'checkout_page.dart' as new_checkout;

class BeautifulProductDetails extends StatefulWidget {
  final Product product;

  const BeautifulProductDetails({Key? key, required this.product}) : super(key: key);

  @override
  State<BeautifulProductDetails> createState() => _BeautifulProductDetailsState();
}

class _BeautifulProductDetailsState extends State<BeautifulProductDetails>
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
  // ignore: prefer_final_fields
  List<Map<String, dynamic>> _reviews = [
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
    // Generate dynamic specifications based on the actual product
    String productName = widget.product.name.toLowerCase();
    String productCategory = widget.product.category;
    double productPrice = widget.product.price;
    
    // Determine specs based on product name and category
    if (productName.contains('predator') || productCategory.contains('Gaming')) {
      return {
        'Performance': {
          'Product': widget.product.name,
          'Category': productCategory,
          'Processor': productName.contains('helios') ? 'Intel Core i7-13700HX' : 
                      productName.contains('triton') ? 'Intel Core i9-13900HX' : 'Intel Core i7-12700H',
          'Graphics': productPrice > 150000 ? 'NVIDIA GeForce RTX 4080' : 
                     productPrice > 100000 ? 'NVIDIA GeForce RTX 4070' : 'NVIDIA GeForce RTX 4060',
          'RAM': productPrice > 120000 ? '32GB DDR5' : '16GB DDR4',
          'Storage': '1TB NVMe SSD',
        },
        'Display': {
          'Screen Size': '15.6-inch to 17.3-inch',
          'Resolution': productPrice > 100000 ? '2560×1440 (QHD)' : '1920×1080 (FHD)',
          'Refresh Rate': productPrice > 150000 ? '240Hz' : productPrice > 80000 ? '144Hz' : '120Hz',
          'Panel Type': 'IPS Gaming Display',
        },
        'Build & Design': {
          'Weight': '2.3 - 2.8 kg',
          'Keyboard': 'RGB Backlit Gaming Keyboard',
          'Cooling': 'Advanced Thermal Management',
          'Price Range': '₹${productPrice.toStringAsFixed(0)}',
        },
      };
    } else if (productName.contains('swift') || productCategory.contains('Business')) {
      return {
        'Performance': {
          'Product': widget.product.name,
          'Category': productCategory,
          'Processor': productPrice > 80000 ? 'Intel Core i7-1360P' : 'Intel Core i5-1240P',
          'Graphics': 'Intel Iris Xe Graphics',
          'RAM': productPrice > 70000 ? '16GB LPDDR5' : '8GB LPDDR4',
          'Storage': productPrice > 60000 ? '512GB NVMe SSD' : '256GB NVMe SSD',
        },
        'Display & Design': {
          'Screen Size': '13.3-inch to 14-inch',
          'Resolution': productPrice > 90000 ? '2880×1800 (3K)' : '1920×1080 (FHD)',
          'Weight': '1.2 - 1.5 kg (Ultraportable)',
          'Build': 'Premium Aluminum Body',
          'Price Range': '₹${productPrice.toStringAsFixed(0)}',
        },
        'Business Features': {
          'Battery Life': 'Up to 12-15 hours',
          'Security': 'Fingerprint Reader, TPM 2.0',
          'Connectivity': 'Wi-Fi 6E, Bluetooth 5.3',
          'Ports': 'USB-C, Thunderbolt 4, USB-A',
        },
      };
    } else if (productName.contains('aspire') || productName.contains('travelmate')) {
      return {
        'Performance': {
          'Product': widget.product.name,
          'Category': productCategory,
          'Processor': productPrice > 60000 ? 'Intel Core i5-1240P' : 'Intel Core i3-1215U',
          'Graphics': 'Intel UHD Graphics',
          'RAM': productPrice > 50000 ? '8GB DDR4' : '4GB DDR4',
          'Storage': '256GB NVMe SSD + 1TB HDD',
        },
        'Display & Build': {
          'Screen Size': '15.6-inch',
          'Resolution': '1920×1080 (Full HD)',
          'Weight': '1.7 - 2.1 kg',
          'Price Range': '₹${productPrice.toStringAsFixed(0)}',
        },
        'Features': {
          'Battery': 'Up to 8 hours',
          'Connectivity': 'Wi-Fi 6, Bluetooth 5.1',
          'Ports': 'USB-C, USB-A, HDMI, Audio',
          'Warranty': '1 Year International',
        },
      };
    } else if (productCategory.contains('Monitor')) {
      return {
        'Display Specifications': {
          'Product': widget.product.name,
          'Category': productCategory,
          'Screen Size': productPrice > 40000 ? '27-inch to 32-inch' : '21.5-inch to 24-inch',
          'Resolution': productPrice > 50000 ? '4K UHD (3840×2160)' : 
                       productPrice > 25000 ? '2K QHD (2560×1440)' : 'Full HD (1920×1080)',
          'Refresh Rate': productName.contains('gaming') ? '144Hz - 240Hz' : '60Hz - 75Hz',
          'Panel Type': 'IPS / VA Panel',
        },
        'Features': {
          'HDR Support': productPrice > 30000 ? 'HDR10 Support' : 'Standard Display',
          'Color Accuracy': productPrice > 40000 ? '99% sRGB, 95% DCI-P3' : '99% sRGB',
          'Connectivity': 'HDMI, DisplayPort, USB-C',
          'Price Range': '₹${productPrice.toStringAsFixed(0)}',
        },
      };
    } else if (productCategory.contains('Accessories')) {
      return {
        'Product Details': {
          'Product': widget.product.name,
          'Category': productCategory,
          'Type': productName.contains('mouse') ? 'Gaming Mouse' : 
                 productName.contains('keyboard') ? 'Gaming Keyboard' : 'Gaming Accessory',
          'Price Range': '₹${productPrice.toStringAsFixed(0)}',
        },
        'Features': {
          'Connectivity': productName.contains('wireless') ? 'Wireless + Wired' : 'Wired',
          'RGB Lighting': productPrice > 5000 ? 'Full RGB Support' : 'Basic Lighting',
          'DPI': productName.contains('mouse') ? 
                 (productPrice > 6000 ? 'Up to 16,000 DPI' : 'Up to 12,000 DPI') : 'N/A',
          'Warranty': '1 Year Limited Warranty',
        },
      };
    } else {
      return {
        'Product Information': {
          'Product': widget.product.name,
          'Category': productCategory,
          'Price Range': '₹${productPrice.toStringAsFixed(0)}',
        },
        'General Specifications': {
          'Brand': 'Acer',
          'Warranty': '1 Year International Warranty',
          'Support': '24/7 Customer Support',
          'Availability': 'In Stock',
        },
      };
    }
  }

  void _addNewReview(int rating, String comment) {
    final newReview = {
      'name': 'You',
      'avatar': 'https://randomuser.me/api/portraits/men/1.jpg',
      'rating': rating,
      'date': 'Just now',
      'verified': true,
      'comment': comment,
      'helpful': 0,
      'images': [],
      'replies': <Map<String, dynamic>>[],
    };
    
    setState(() {
      _reviews.insert(0, newReview);
    });
  }

  void _addReplyToReview(String reviewerName, String replyText) {
    final newReply = {
      'name': 'You',
      'comment': replyText,
      'date': 'Just now',
    };
    
    setState(() {
      for (var review in _reviews) {
        if (review['name'] == reviewerName) {
          if (review['replies'] == null) {
            review['replies'] = <Map<String, dynamic>>[];
          }
          review['replies'].add(newReply);
          break;
        }
      }
    });
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
      expandedHeight: 280,
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
                          margin: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.08),
                                blurRadius: 15,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                                                      child: ClipRRect(
                            borderRadius: BorderRadius.circular(16),
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
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 15,
            offset: const Offset(0, 4),
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
                    fontSize: 22,
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
          const SizedBox(height: 12),
          
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
          const SizedBox(height: 16),
          
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
                        fontSize: 24,
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
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Container(
              height: 48,
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
                      behavior: SnackBarBehavior.floating,
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
                    fontSize: 15,
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
              height: 48,
              decoration: BoxDecoration(
                border: Border.all(color: acerPrimaryColor, width: 2),
                borderRadius: BorderRadius.circular(16),
              ),
              child: ElevatedButton(
                onPressed: () {
                  // Create a temporary cart with just this product for buy now
                  final Map<Product, int> buyNowItems = {widget.product: 1};
                  Navigator.push(
                    context, 
                    MaterialPageRoute(
                      builder: (context) => new_checkout.CheckoutPage(
                        cartItems: buyNowItems,
                        totalAmount: widget.product.price,
                      )
                    )
                  );
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
                    fontSize: 15,
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
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 15,
            offset: const Offset(0, 4),
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
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
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
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
              unselectedLabelStyle: const TextStyle(
                fontSize: 13,
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
            height: 350,
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
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Product Overview',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          
          Text(
            widget.product.description,
            style: TextStyle(
              fontSize: 15,
              height: 1.5,
              color: Colors.grey[700],
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Key features
          Container(
            padding: const EdgeInsets.all(16),
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
      padding: const EdgeInsets.all(20),
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
      padding: const EdgeInsets.all(20),
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
                  _showWriteReviewDialog();
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
                onPressed: () {
                  _showReplyDialog(review['name']);
                },
                child: const Text('Reply'),
                style: TextButton.styleFrom(
                  foregroundColor: acerPrimaryColor,
                  padding: EdgeInsets.zero,
                ),
              ),
            ],
          ),
          
          // Display replies
          if (review['replies'] != null && review['replies'].isNotEmpty)
            Container(
              margin: const EdgeInsets.only(top: 12, left: 20),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Replies (${review['replies'].length})',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: acerPrimaryColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...review['replies'].map<Widget>((reply) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                reply['name'],
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                reply['date'],
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            reply['comment'],
                            style: const TextStyle(fontSize: 13),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ],
              ),
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
            behavior: SnackBarBehavior.floating,
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

  // Method to show write review dialog
  void _showWriteReviewDialog() {
    int selectedRating = 5;
    TextEditingController reviewController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Write a Review'),
              content: SizedBox(
                width: double.maxFinite,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        const Text('Rating: '),
                        ...List.generate(5, (index) {
                          return GestureDetector(
                            onTap: () {
                              setDialogState(() {
                                selectedRating = index + 1;
                              });
                            },
                            child: Icon(
                              index < selectedRating ? Icons.star : Icons.star_border,
                              color: acerPrimaryColor,
                            ),
                          );
                        }),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: reviewController,
                      maxLines: 4,
                      decoration: const InputDecoration(
                        hintText: 'Share your experience with this product...',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (reviewController.text.trim().isNotEmpty) {
                      _addNewReview(selectedRating, reviewController.text.trim());
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Thank you for your review!'),
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: acerPrimaryColor,
                  ),
                  child: const Text('Submit Review', style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // Method to show reply dialog
  void _showReplyDialog(String reviewerName) {
    TextEditingController replyController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Reply to $reviewerName'),
          content: TextField(
            controller: replyController,
            maxLines: 3,
            decoration: const InputDecoration(
              hintText: 'Write your reply...',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (replyController.text.trim().isNotEmpty) {
                  _addReplyToReview(reviewerName, replyController.text.trim());
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Reply posted successfully!'),
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: acerPrimaryColor,
              ),
              child: const Text('Post Reply', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }
} 