import 'package:flutter/material.dart';
import 'main.dart';

class AllCategoriesPage extends StatelessWidget {
  const AllCategoriesPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Define the category data with associated icons and colors
    final List<Map<String, dynamic>> categoryData = [
      {
        'title': 'Gaming',
        'icon': Icons.videogame_asset,
        'color': acerPrimaryColor
      },
      {'title': 'Business', 'icon': Icons.business, 'color': acerAccentColor},
      {
        'title': 'Monitors',
        'icon': Icons.desktop_windows,
        'color': Colors.purple
      },
      {'title': 'Accessories', 'icon': Icons.headset, 'color': Colors.orange},
      {
        'title': 'Entry Level Gaming',
        'icon': Icons.sports_esports,
        'color': Colors.green
      },
      {
        'title': 'Mid-Range Gaming',
        'icon': Icons.gamepad,
        'color': Colors.blue
      },
      {'title': 'High-End Gaming', 'icon': Icons.games, 'color': Colors.red},
      {
        'title': 'Business & Productivity',
        'icon': Icons.work,
        'color': Colors.teal
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('All Categories'),
        backgroundColor: acerPrimaryColor,
        foregroundColor: Colors.white,
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 1.2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: categoryData.length,
        itemBuilder: (context, index) {
          return _buildCategoryCard(
            context,
            categoryData[index]['title'],
            categoryData[index]['icon'],
            categoryData[index]['color'],
          );
        },
      ),
    );
  }

  Widget _buildCategoryCard(
      BuildContext context, String title, IconData icon, Color color) {
    // Map the display title to actual category values
    String categoryFilter;
    String categoryTitle;

    switch (title) {
      case 'Gaming':
        categoryFilter = 'Gaming';
        categoryTitle = 'Gaming Laptops';
        break;
      case 'Business':
        categoryFilter = 'Business';
        categoryTitle = 'Business Laptops';
        break;
      case 'Monitors':
        categoryFilter = 'Monitors';
        categoryTitle = 'Monitors';
        break;
      case 'Accessories':
        categoryFilter = 'Accessories';
        categoryTitle = 'Accessories';
        break;
      case 'Entry Level Gaming':
        categoryFilter = 'Entry Level Gaming';
        categoryTitle = 'Entry Level Gaming';
        break;
      case 'Mid-Range Gaming':
        categoryFilter = 'Mid-Range Gaming';
        categoryTitle = 'Mid-Range Gaming';
        break;
      case 'High-End Gaming':
        categoryFilter = 'High-End Gaming';
        categoryTitle = 'High-End Gaming';
        break;
      case 'Business & Productivity':
        categoryFilter = 'Business & Productivity';
        categoryTitle = 'Business & Productivity';
        break;
      default:
        categoryFilter = title;
        categoryTitle = title;
    }

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CategoryPage(
              category: categoryFilter,
              title: categoryTitle,
            ),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: color.withOpacity(0.2),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 40,
              color: color,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color.withOpacity(0.8),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
