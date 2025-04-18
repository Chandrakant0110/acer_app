import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutAcerStorePage extends StatelessWidget {
  const AboutAcerStorePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About Acer Store'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with logo
              Center(
                child: Column(
                  children: [
                    Image.asset(
                      'assets/logos/acer_logo.png',
                      height: 80,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(Icons.computer, size: 80, color: Colors.green);
                      },
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Acer Store India',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Your official destination for Acer products',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
              
              // About Acer
              _buildSectionTitle('About Acer'),
              const Text(
                'Acer Inc. is a Taiwanese multinational hardware and electronics corporation specializing in advanced electronics technology. It is one of the world\'s largest PC vendors, and its product offerings include desktop and mobile PCs, laptops, tablets, servers, storage devices, displays, peripherals, and solutions for businesses, governments, education, and home users.',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 16),
              const Text(
                'Established in 1976, Acer has continually evolved with the industry to deliver innovative, high-quality products and services that help people achieve their goals and improve their lives through technology.',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 24),
              
              // Our Vision and Mission
              _buildSectionTitle('Our Vision and Mission'),
              _buildSubsectionTitle('Vision'),
              const Text(
                'To break the barriers between people and technology.',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 16),
              _buildSubsectionTitle('Mission'),
              const Text(
                'We are fueled by the innate human desire to explore beyond limits. We dedicate ourselves to designing products that weave seamlessly into users\' daily lives. We go where others haven\'t, creating experiences that make life better.',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 24),
              
              // Our Values
              _buildSectionTitle('Our Values'),
              _buildValueItem('Innovation', 'Pushing boundaries to create cutting-edge technology that enhances lives'),
              _buildValueItem('Quality', 'Commitment to excellence in every product and service we offer'),
              _buildValueItem('Sustainability', 'Environmental responsibility in our operations and products'),
              _buildValueItem('Customer-First', 'Putting our customers at the center of everything we do'),
              _buildValueItem('Integrity', 'Operating with honesty, transparency, and ethical standards'),
              const SizedBox(height: 24),
              
              // Our Products
              _buildSectionTitle('Our Products'),
              const Wrap(
                spacing: 16,
                runSpacing: 16,
                children: [
                  ProductCategoryCard(title: 'Laptops', icon: Icons.laptop),
                  ProductCategoryCard(title: 'Desktops', icon: Icons.desktop_windows),
                  ProductCategoryCard(title: 'Monitors', icon: Icons.desktop_mac),
                  ProductCategoryCard(title: 'Projectors', icon: Icons.videocam),
                  ProductCategoryCard(title: 'Tablets', icon: Icons.tablet),
                  ProductCategoryCard(title: 'Accessories', icon: Icons.headset),
                ],
              ),
              const SizedBox(height: 24),
              
              // Contact Information
              _buildSectionTitle('Contact Us'),
              _buildContactItem(Icons.location_on, 'Headquarters', 'Acer India (Pvt) Ltd.\nNational Highway 8, Ward No. 1\nAhmedabad 382110, Gujarat, India'),
              _buildContactItem(Icons.phone, 'Customer Support', '+91 1800 11 6677'),
              _buildContactItem(Icons.email, 'Email', 'support@acer-india.com'),
              _buildContactItem(Icons.language, 'Website', 'www.acer.com/in-en'),
              const SizedBox(height: 24),
              
              // Social Media
              _buildSectionTitle('Connect With Us'),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildSocialButton(Icons.facebook, 'Facebook', 'https://www.facebook.com/AcerIndia'),
                  _buildSocialButton(Icons.camera_alt, 'Instagram', 'https://www.instagram.com/acer_india'),
                  _buildSocialButton(Icons.message, 'Twitter', 'https://twitter.com/Acer_India'),
                  _buildSocialButton(Icons.video_library, 'YouTube', 'https://www.youtube.com/user/acercomputers'),
                ],
              ),
              const SizedBox(height: 32),
              
              // Copyright
              const Center(
                child: Text(
                  '© 2023 Acer Inc. All Rights Reserved.',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.green,
        ),
      ),
    );
  }
  
  Widget _buildSubsectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
  
  Widget _buildValueItem(String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.check_circle, color: Colors.green[700], size: 22),
          const SizedBox(width: 12),
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
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(fontSize: 14),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildContactItem(IconData icon, String title, String details) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.green[700], size: 22),
          const SizedBox(width: 12),
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
                const SizedBox(height: 4),
                Text(
                  details,
                  style: const TextStyle(fontSize: 14),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildSocialButton(IconData icon, String platform, String url) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      child: IconButton(
        icon: Icon(icon, size: 28),
        color: Colors.green[700],
        onPressed: () async {
          final Uri uri = Uri.parse(url);
          if (await canLaunchUrl(uri)) {
            await launchUrl(uri);
          }
        },
      ),
    );
  }
}

class ProductCategoryCard extends StatelessWidget {
  final String title;
  final IconData icon;
  
  const ProductCategoryCard({
    Key? key,
    required this.title,
    required this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 150,
      height: 120,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
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
            color: Colors.green[700],
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
} 