import 'package:flutter/material.dart';
import 'order_tracker_page.dart'; // Ensure this path is correct
import '../predator_series.dart';
import '../aspire_series.dart';
import '../swift_series.dart';
import 'dart:math' as math;

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Banner section
            const SizedBox(height: 20),
            const Text(
              'Explore Acer Series',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),

            // Predator Series Banner
            _buildSeriesBanner(
              context,
              'Predator Series',
              'High-performance gaming laptops',
              Colors.red.shade800,
              () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PredatorSeries(),
                  ),
                );
              },
              assetImage: 'assets/images/nitro v.png',
              logoIconData: Icons.sports_esports,
            ),

            // Aspire Series Banner
            _buildSeriesBanner(
              context,
              'Aspire Series',
              'Everyday computing solutions',
              Colors.blue.shade700,
              () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AspireSeries(),
                  ),
                );
              },
              logoIconData: Icons.laptop_mac,
            ),

            // Swift Series Banner
            _buildSeriesBanner(
              context,
              'Swift Series',
              'Ultra-thin, lightweight laptops',
              Colors.green.shade600,
              () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SwiftSeries(),
                  ),
                );
              },
              logoIconData: Icons.laptop,
            ),

            const SizedBox(height: 30),

            // Order tracking button
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const OrderTrackerPage(),
                  ),
                );
              },
              child: const Text('Track My Orders'),
            ),
          ],
        ),
      ),
    );
  }

  // Helper method to build series banners
  Widget _buildSeriesBanner(
    BuildContext context,
    String title,
    String subtitle,
    Color color,
    VoidCallback onTap, {
    String? assetImage,
    IconData? logoIconData,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 130, // Fixed height for consistent banners
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 5,
              offset: Offset(0, 3),
            ),
          ],
        ),
        clipBehavior:
            Clip.antiAlias, // This is important for proper image rendering
        child: Stack(
          children: [
            // Background
            Positioned.fill(
              child: assetImage != null
                  ? Image.asset(
                      assetImage,
                      fit: BoxFit.cover,
                    )
                  : Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            color,
                            color.withOpacity(0.7),
                          ],
                        ),
                      ),
                      child: CustomPaint(
                        painter: BannerPatternPainter(color: color),
                      ),
                    ),
            ),

            // Overlay to ensure text readability
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [
                      Colors.black.withOpacity(0.7),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),

            // Logo icon in background (if no asset image)
            if (logoIconData != null && assetImage == null)
              Positioned(
                right: -15,
                bottom: -15,
                child: Icon(
                  logoIconData,
                  size: 120,
                  color: Colors.white.withOpacity(0.1),
                ),
              ),

            // Content
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            shadows: [
                              Shadow(
                                color: Colors.black54,
                                offset: Offset(1, 1),
                                blurRadius: 3,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          subtitle,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.white,
                            shadows: [
                              Shadow(
                                color: Colors.black54,
                                offset: Offset(0.5, 0.5),
                                blurRadius: 1,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.arrow_forward,
                      color: Colors.white,
                      size: 20,
                    ),
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

// Custom painter for banner pattern
class BannerPatternPainter extends CustomPainter {
  final Color color;

  BannerPatternPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.05)
      ..style = PaintingStyle.fill;

    // Use a fixed random seed for consistent pattern
    final random = math.Random(42);

    // Draw subtle diagonal lines
    for (int i = 0; i < 10; i++) {
      final lineWidth = random.nextDouble() * 20 + 10;
      final startX = random.nextDouble() * size.width;
      final startY = random.nextDouble() * size.height;

      final path = Path();
      path.moveTo(startX, startY);
      path.lineTo(startX + lineWidth, startY + lineWidth);

      canvas.drawPath(
        path,
        Paint()
          ..color = Colors.white.withOpacity(0.08)
          ..style = PaintingStyle.stroke
          ..strokeWidth = random.nextDouble() * 10 + 5,
      );
    }

    // Draw some circles
    for (int i = 0; i < 5; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      final radius = random.nextDouble() * 20 + 10;

      canvas.drawCircle(
        Offset(x, y),
        radius,
        Paint()
          ..color = Colors.white.withOpacity(0.05)
          ..style = PaintingStyle.fill,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
