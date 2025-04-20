import 'package:flutter/material.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Get the app's primary color
    final acerPrimaryColor = Theme.of(context).primaryColor;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacy Policy'),
        backgroundColor: acerPrimaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: Row(
                  children: [
                    Icon(
                      Icons.security,
                      color: acerPrimaryColor,
                      size: 32,
                    ),
                    const SizedBox(width: 16),
                    const Text(
                      'Privacy Policy',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Last Updated Date
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: acerPrimaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'Last Updated: January 29, 2025',
                  style: TextStyle(
                    fontStyle: FontStyle.italic,
                    fontSize: 14,
                    color: Colors.black87,
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Introduction
              _buildSectionTitle('Introduction'),
              _buildParagraph(
                'Welcome to the Acer Store App. We respect your privacy and are committed to protecting your personal data. This Privacy Policy will inform you about how we look after your personal data when you use our application and tell you about your privacy rights and how the law protects you.',
              ),

              const SizedBox(height: 16),

              // Information We Collect
              _buildSectionTitle('Information We Collect'),
              _buildParagraph(
                'We may collect various types of information including:',
              ),
              _buildBulletPoint(
                  'Personal identification information (Name, email address, phone number, etc.)'),
              _buildBulletPoint(
                  'Technical data (IP address, device information, browsing actions)'),
              _buildBulletPoint(
                  'Profile data (your purchases, preferences, feedback)'),
              _buildBulletPoint('Usage data (how you use our application)'),

              const SizedBox(height: 16),

              // How We Use Your Information
              _buildSectionTitle('How We Use Your Information'),
              _buildParagraph(
                'We use the information we collect in various ways, including:',
              ),
              _buildBulletPoint(
                  'To provide, operate, and maintain our application'),
              _buildBulletPoint(
                  'To improve, personalize, and expand our application'),
              _buildBulletPoint(
                  'To understand and analyze how you use our application'),
              _buildBulletPoint(
                  'To develop new products, services, features, and functionality'),
              _buildBulletPoint(
                  'To communicate with you for customer service, updates, and other information'),
              _buildBulletPoint(
                  'To process transactions and manage your account'),
              _buildBulletPoint('To find and prevent fraud'),

              const SizedBox(height: 16),

              // Data Security
              _buildSectionTitle('Data Security'),
              _buildParagraph(
                'We have implemented appropriate technical and organizational security measures designed to protect the security of any personal information we process. However, please also remember that we cannot guarantee that the internet itself is 100% secure.',
              ),

              const SizedBox(height: 16),

              // Your Rights
              _buildSectionTitle('Your Rights'),
              _buildParagraph(
                'You have the right to:',
              ),
              _buildBulletPoint(
                  'Access and receive a copy of your personal data'),
              _buildBulletPoint(
                  'Rectify any personal information held about you that is inaccurate'),
              _buildBulletPoint('Request erasure of your personal information'),
              _buildBulletPoint(
                  'Object to processing of your personal information'),
              _buildBulletPoint(
                  'Request restriction of processing of your personal information'),
              _buildBulletPoint(
                  'Request the transfer of your personal information'),
              _buildBulletPoint(
                  'Withdraw consent at any time where we are relying on consent to process your personal information'),

              const SizedBox(height: 16),

              // Changes to This Privacy Policy
              _buildSectionTitle('Changes to This Privacy Policy'),
              _buildParagraph(
                'We may update our Privacy Policy from time to time. We will notify you of any changes by posting the new Privacy Policy on this page and updating the "Last Updated" date at the top of this Privacy Policy.',
              ),
              _buildParagraph(
                'You are advised to review this Privacy Policy periodically for any changes. Changes to this Privacy Policy are effective when they are posted on this page.',
              ),

              const SizedBox(height: 16),

              // Contact Us
              _buildSectionTitle('Contact Us'),
              _buildParagraph(
                'If you have any questions about this Privacy Policy, please contact us:',
              ),
              _buildBulletPoint('By email: ail.easycare@acer.com'),
              _buildBulletPoint('By phone: 1800-11-ACER (2237)'),
              _buildBulletPoint('By mail: 123 Acer Way, Tech City, TC 12345'),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildParagraph(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 16,
          height: 1.5,
        ),
        textAlign: TextAlign.justify,
      ),
    );
  }

  Widget _buildBulletPoint(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 16.0, bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '•',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 16,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
