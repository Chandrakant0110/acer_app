import 'package:flutter/material.dart';
import 'main.dart';
import 'package:package_info_plus/package_info_plus.dart';

class AboutAcerStore extends StatefulWidget {
  const AboutAcerStore({Key? key}) : super(key: key);

  @override
  State<AboutAcerStore> createState() => _AboutAcerStoreState();
}

class _AboutAcerStoreState extends State<AboutAcerStore> {
  String appVersion = '';
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _getAppVersion();
  }

  Future<void> _getAppVersion() async {
    final packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      appVersion = '${packageInfo.version}+${packageInfo.buildNumber}';
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About Acer Store'),
        backgroundColor: acerPrimaryColor,
        foregroundColor: Colors.white,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 24.0),
                      child: Image.asset(
                        'assets/logos/acer_logo.png',
                        height: 60,
                      ),
                    ),
                  ),
                  const Text(
                    'Acer Store India - Official App',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Version: 1.9.8',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'About the App',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'The official Acer Store app for India provides a seamless shopping experience for Acer products. Browse, purchase, and track your orders with ease, all from the convenience of your mobile device.',
                    style: TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Version History',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildVersionCard(
                    'Version 2.1.9 (Current)',
                    'June 24 2025',
                    [
                      'Improved UI/UX of the app',
                      'Added review and rating system',
                      'Added reply to review system',
                      'Dark Mode support',
                      'Profile photo can be uploaded by Gallery or Camera',
                      'Added Notification system',
                      
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildVersionCard(
                    'Version 1.9.2 (Initial Release)',
                    'January 24 2025',
                    [
                      'Basic product browsing functionality',
                      'User registration and login',
                      'Simple cart system',
                      'Basic order history',
                      'Store information page',
                    ],
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Coming Soon',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildFeatureList([
                    'Product comparison tool',
                    'Wishlist functionality',
                    'Customer reviews and ratings',
                    'AR product visualization',
                    'Performance optimizations',
                  ]),
                  const SizedBox(height: 24),
                  const Text(
                    'Contact Information',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const ListTile(
                    leading: Icon(Icons.email, color: acerPrimaryColor),
                    title: Text('Email'),
                    subtitle: Text('ail.easycare@acer.com'),
                  ),
                  const ListTile(
                    leading: Icon(Icons.phone, color: acerPrimaryColor),
                    title: Text('Customer Support'),
                    subtitle: Text('1800-11-ACER (2237)'),
                  ),
                  const ListTile(
                    leading: Icon(Icons.language, color: acerPrimaryColor),
                    title: Text('Website'),
                    subtitle: Text('www.acer.com'),
                  ),
                  const SizedBox(height: 36),
                  const Center(
                    child: Text(
                      '© 2025 Acer India Pvt. Ltd. All rights reserved.',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
    );
  }

  Widget _buildVersionCard(String version, String date, List<String> features) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              version,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              date,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 8),
            ...features.map((feature) => Padding(
                  padding: const EdgeInsets.only(bottom: 4.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('• ', style: TextStyle(fontSize: 16)),
                      Expanded(
                        child: Text(
                          feature,
                          style: const TextStyle(fontSize: 15),
                        ),
                      ),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureList(List<String> features) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: features
          .map((feature) => Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.arrow_forward,
                      size: 16,
                      color: acerPrimaryColor,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        feature,
                        style: const TextStyle(fontSize: 15),
                      ),
                    ),
                  ],
                ),
              ))
          .toList(),
    );
  }
}
