import 'package:flutter/material.dart';
import 'main.dart';
import 'beautiful_product_details.dart';

class AllProductsPage extends StatefulWidget {
  const AllProductsPage({super.key});

  @override
  State<AllProductsPage> createState() => _AllProductsPageState();
}

class _AllProductsPageState extends State<AllProductsPage> {
  RangeValues _selectedPriceRange = const RangeValues(0, 250000);
  String? _selectedCategory;
  String _sortBy = 'relevance';
  List<Product> _filteredProducts = [];
  final List<String> _categories = categories;

  @override
  void initState() {
    super.initState();
    _filterProducts();
  }

  void _filterProducts() {
    setState(() {
      _filteredProducts = products.where((product) {
        // Apply category filter if selected
        if (_selectedCategory != null && _selectedCategory != 'All') {
          bool categoryMatch = false;

          // Handle special category groupings
          if (_selectedCategory == 'Gaming') {
            categoryMatch = product.category.contains('Gaming');
          } else if (_selectedCategory == 'Business') {
            categoryMatch = product.category.contains('Business');
          } else {
            categoryMatch = product.category.contains(_selectedCategory!);
          }

          if (!categoryMatch) {
            return false;
          }
        }

        // Apply price filter
        return product.price >= _selectedPriceRange.start &&
            product.price <= _selectedPriceRange.end;
      }).toList();

      // Apply sorting
      switch (_sortBy) {
        case 'price_low_to_high':
          _filteredProducts.sort((a, b) => a.price.compareTo(b.price));
          break;
        case 'price_high_to_low':
          _filteredProducts.sort((a, b) => b.price.compareTo(a.price));
          break;
        case 'name_a_to_z':
          _filteredProducts.sort((a, b) => a.name.compareTo(b.name));
          break;
        case 'name_z_to_a':
          _filteredProducts.sort((a, b) => b.name.compareTo(a.name));
          break;
      }
    });
  }

  void _showFilterDrawer() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Container(
              padding: const EdgeInsets.all(16),
              height: MediaQuery.of(context).size.height * 0.7,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Filter & Sort',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const Divider(),
                  const Text(
                    'Price Range',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  RangeSlider(
                    values: _selectedPriceRange,
                    min: 0,
                    max: 250000,
                    divisions: 25,
                    labels: RangeLabels(
                      '₹${_selectedPriceRange.start.round()}',
                      '₹${_selectedPriceRange.end.round()}',
                    ),
                    onChanged: (values) {
                      setState(() {
                        _selectedPriceRange = values;
                      });
                    },
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('₹${_selectedPriceRange.start.round()}'),
                      Text('₹${_selectedPriceRange.end.round()}'),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Category',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  DropdownButton<String>(
                    value: _selectedCategory,
                    isExpanded: true,
                    hint: const Text('Select Category'),
                    items: [
                      const DropdownMenuItem<String>(
                        value: null,
                        child: Text('All Categories'),
                      ),
                      ..._categories.map((category) {
                        return DropdownMenuItem<String>(
                          value: category,
                          child: Text(category),
                        );
                      }).toList(),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedCategory = value;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Sort By',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  DropdownButton<String>(
                    value: _sortBy,
                    isExpanded: true,
                    items: const [
                      DropdownMenuItem<String>(
                        value: 'relevance',
                        child: Text('Relevance'),
                      ),
                      DropdownMenuItem<String>(
                        value: 'price_low_to_high',
                        child: Text('Price: Low to High'),
                      ),
                      DropdownMenuItem<String>(
                        value: 'price_high_to_low',
                        child: Text('Price: High to Low'),
                      ),
                      DropdownMenuItem<String>(
                        value: 'name_a_to_z',
                        child: Text('Name: A to Z'),
                      ),
                      DropdownMenuItem<String>(
                        value: 'name_z_to_a',
                        child: Text('Name: Z to A'),
                      ),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _sortBy = value!;
                      });
                    },
                  ),
                  const Spacer(),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            setState(() {
                              _selectedPriceRange =
                                  const RangeValues(0, 250000);
                              _selectedCategory = null;
                              _sortBy = 'relevance';
                            });
                          },
                          child: const Text('Reset'),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                            _filterProducts();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: acerPrimaryColor,
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('Apply'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('All Products'),
        backgroundColor: acerPrimaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDrawer,
          ),
        ],
      ),
      body: Column(
        children: [
          // Active filters display
          if (_selectedCategory != null ||
              _selectedPriceRange.start > 0 ||
              _selectedPriceRange.end < 250000 ||
              _sortBy != 'relevance')
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    if (_selectedCategory != null)
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: Chip(
                          label: Text('Category: $_selectedCategory'),
                          deleteIcon: const Icon(Icons.close, size: 16),
                          onDeleted: () {
                            setState(() {
                              _selectedCategory = null;
                              _filterProducts();
                            });
                          },
                        ),
                      ),
                    if (_selectedPriceRange.start > 0 ||
                        _selectedPriceRange.end < 250000)
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: Chip(
                          label: Text(
                            'Price: ₹${_selectedPriceRange.start.round()} - ₹${_selectedPriceRange.end.round()}',
                          ),
                          deleteIcon: const Icon(Icons.close, size: 16),
                          onDeleted: () {
                            setState(() {
                              _selectedPriceRange =
                                  const RangeValues(0, 250000);
                              _filterProducts();
                            });
                          },
                        ),
                      ),
                    if (_sortBy != 'relevance')
                      Chip(
                        label: Text(
                          'Sort: ${_sortBy.replaceAll('_', ' ').split(' ').map((word) => word[0].toUpperCase() + word.substring(1)).join(' ')}',
                        ),
                        deleteIcon: const Icon(Icons.close, size: 16),
                        onDeleted: () {
                          setState(() {
                            _sortBy = 'relevance';
                            _filterProducts();
                          });
                        },
                      ),
                  ],
                ),
              ),
            ),
          // Product grid
          Expanded(
            child: _filteredProducts.isEmpty
                ? const Center(
                    child: Text(
                      'No products found.\nTry adjusting your filters.',
                      textAlign: TextAlign.center,
                    ),
                  )
                : GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.7,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                    ),
                    itemCount: _filteredProducts.length,
                    itemBuilder: (context, index) {
                      return _buildProductCard(
                          context, _filteredProducts[index]);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductCard(BuildContext context, Product product) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => BeautifulProductDetails(product: product),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product image with colored header
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                  child: Container(
                    height: 100,
                    width: double.infinity,
                    color: acerPrimaryColor.withOpacity(0.1),
                    child: Image.network(
                      product.imageUrl,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: acerPrimaryColor.withOpacity(0.1),
                        child: const Icon(
                          Icons.image_not_supported,
                          size: 40,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  // const SizedBox(height: 4),
                  Text(
                    '₹${product.price.toStringAsFixed(2)}',
                    style: const TextStyle(
                      color: acerPrimaryColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Chip(
                    label: Text(
                      product.category,
                      style: const TextStyle(fontSize: 10),
                    ),
                    backgroundColor: acerPrimaryColor.withOpacity(0.1),
                    visualDensity: VisualDensity.compact,
                    padding: EdgeInsets.zero,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
