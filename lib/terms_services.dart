import 'package:flutter/material.dart';
import 'main.dart';

class TermsServices extends StatelessWidget {
  const TermsServices({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Terms & Services'),
        backgroundColor: acerPrimaryColor,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            _buildHeading('Terms and Conditions for Acer Store'),
            const SizedBox(height: 16),
            _buildParagraph(
              'Welcome to Acer Store! These terms and conditions outline the rules and regulations for the use of the Acer Store mobile application.',
            ),
            const SizedBox(height: 16),
            _buildSection(
              'Acceptance of Terms',
              'By accessing and using this application, you accept and agree to be bound by these Terms and Conditions. If you disagree with any part of these terms, you may not use our application.',
            ),
            _buildSection(
              'Account Registration',
              'To use certain features of the Acer Store app, you may be required to register for an account. You agree to provide accurate, current, and complete information during the registration process. You are responsible for maintaining the confidentiality of your account credentials and for all activities that occur under your account.',
            ),
            _buildSection(
              'Intellectual Property',
              'The content, features, and functionality, including but not limited to text, graphics, logos, and software, are owned by Acer and are protected by international copyright, trademark, and other intellectual property laws.',
            ),
            _buildSection(
              'Product Information',
              'We strive to provide accurate product descriptions, specifications, and pricing. However, we do not warrant that product descriptions or other content on the app is accurate, complete, reliable, current, or error-free. Prices are subject to change without notice.',
            ),
            _buildSection(
              'Ordering and Payment',
              'When you place an order, we will send you a confirmation email. Your order represents an offer to purchase a product, which is accepted when we send you a shipment confirmation. Payment must be made at the time of placing your order through the available payment methods provided in the app.',
            ),
            _buildSection(
              'Shipping and Delivery',
              'We will make reasonable efforts to deliver products within the estimated delivery timeframes. However, delivery times are not guaranteed and may vary based on location and other factors. Risk of loss and title for items purchased pass to you upon our delivery to the carrier.',
            ),
            _buildSection(
              'Returns and Refunds',
              'Products may be returned within 7 days of delivery for a full refund, provided they are in their original condition with all packaging and accessories. Refunds will be processed within 5-7 business days after we receive the returned items.',
            ),
            _buildSection(
              'User Conduct',
              'You agree not to use the app to:\n• Violate any applicable laws or regulations\n• Infringe the rights of others\n• Transmit any harmful code or interfere with the operation of the app\n• Collect or store personal data about other users without their consent',
            ),
            _buildSection(
              'Limitation of Liability',
              'To the fullest extent permitted by law, Acer shall not be liable for any indirect, incidental, special, consequential, or punitive damages, including but not limited to loss of profits, data, or use, arising out of or in connection with your use of the app.',
            ),
            _buildSection(
              'Privacy Policy',
              'Your use of the app is also governed by our Privacy Policy, which is incorporated into these Terms by reference. Please review our Privacy Policy to understand our practices regarding the collection and use of your information.',
            ),
            _buildSection(
              'Changes to Terms',
              'We reserve the right to modify these Terms at any time. Changes will be effective immediately upon posting on the app. Your continued use of the app after changes are posted constitutes your acceptance of the modified Terms.',
            ),
            _buildSection(
              'Governing Law',
              'These Terms shall be governed by and construed in accordance with the laws of India, without regard to its conflict of law provisions.',
            ),
            _buildSection(
              'Contact Information',
              'For questions about these Terms, please contact us at legal@acer.com or through the Support section in the app.',
            ),
            const SizedBox(height: 16),
            _buildLastUpdated('Last Updated: February 15, 2023'),
            const SizedBox(height: 24),
            _buildAcceptButton(context),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildHeading(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: acerPrimaryColor,
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          content,
          style: const TextStyle(
            fontSize: 14,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 8),
        const Divider(),
      ],
    );
  }

  Widget _buildParagraph(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 14,
        height: 1.5,
      ),
    );
  }

  Widget _buildLastUpdated(String text) {
    return Align(
      alignment: Alignment.center,
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 12,
          color: Colors.grey,
          fontStyle: FontStyle.italic,
        ),
      ),
    );
  }

  Widget _buildAcceptButton(BuildContext context) {
    return Center(
      child: SizedBox(
        width: double.infinity,
        height: 50,
        child: ElevatedButton(
          onPressed: () {
            // In a real app, you might want to store acceptance status
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('You have accepted the Terms & Services'),
                backgroundColor: acerPrimaryColor,
              ),
            );
            Navigator.pop(context);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: acerPrimaryColor,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: const Text(
            'I Accept',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
