import 'package:flutter/material.dart';
import 'main.dart';
import 'dart:math';

class HelpSupport extends StatefulWidget {
  const HelpSupport({Key? key}) : super(key: key);

  @override
  State<HelpSupport> createState() => _HelpSupportState();
}

class _HelpSupportState extends State<HelpSupport>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.of(context).pop();
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Help & Support'),
          foregroundColor: Colors.white,
          backgroundColor: acerPrimaryColor,
          bottom: TabBar(
            controller: _tabController,
            indicatorColor: Colors.white,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            tabs: const [
              Tab(text: 'FAQ', icon: Icon(Icons.help_outline)),
              Tab(text: 'Contact Us', icon: Icon(Icons.message_outlined)),
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildFAQsView(),
            _buildContactView(),
          ],
        ),
      ),
    );
  }

  Widget _buildFAQsView() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildSearchBar(),
        const SizedBox(height: 20),
        _buildFAQItem(
          'How do I create an account?',
          'To create an account, tap on the profile icon and select "Sign Up". Fill in your details and follow the on-screen instructions to complete registration.',
        ),
        _buildFAQItem(
          'How can I track my order?',
          'Go to "My Orders" in your profile and select the order you want to track. You\'ll see current status and tracking information.',
        ),
        _buildFAQItem(
          'What payment methods do you accept?',
          'We accept credit/debit cards, net banking, UPI, and wallet payments. All transactions are secure and protected.',
        ),
        _buildFAQItem(
          'How can I cancel my order?',
          'You can cancel an order before it ships by going to "My Orders" and selecting the order you wish to cancel. Then tap on "Cancel Order" and follow the prompts.',
        ),
        _buildFAQItem(
          'When will my order be delivered?',
          'Delivery time depends on your location. Typically, orders are delivered within 3-5 business days in major cities and 5-7 days in other areas.',
        ),
        _buildFAQItem(
          'What is the return policy?',
          'You can return most products within 7 days of delivery. The product must be in its original packaging with all accessories and without damage.',
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.search, color: Colors.grey),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Search for help...',
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
              onSubmitted: (value) {
                // Simple search function - would connect to backend in real app
                if (value.isNotEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Searching for: $value')),
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFAQItem(String question, String answer) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ExpansionTile(
        title: Text(
          question,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        children: [
          Text(
            answer,
            style: const TextStyle(
              fontSize: 15,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Contact options
          Row(
            children: [
              Expanded(
                child: _buildContactOption(
                  icon: Icons.phone,
                  title: 'Call Us',
                  subtitle: '9AM-6PM, Mon-Sat',
                  onTap: () => _showContactInfo(
                    'Customer Support',
                    [
                      {
                        'title': 'Technical Support',
                        'detail': '+91 1800-11-6677'
                      },
                      {'title': 'Order Support', 'detail': '+91 1800-11-8899'},
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildContactOption(
                  icon: Icons.email,
                  title: 'Email Us',
                  subtitle: 'Response within 24h',
                  onTap: () => _showContactInfo(
                    'Email Support',
                    [
                      {
                        'title': 'Technical Queries',
                        'detail': 'tech.support@acer.com'
                      },
                      {'title': 'Order Queries', 'detail': 'orders@acer.com'},
                    ],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),
          const Text(
            'Send us a Message',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),

          // Support ticket form
          Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Your Name',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter your name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email Address',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter your email';
                    }
                    if (!value.contains('@') || !value.contains('.')) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _messageController,
                  decoration: const InputDecoration(
                    labelText: 'Message',
                    border: OutlineInputBorder(),
                    alignLabelWithHint: true,
                  ),
                  maxLines: 5,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter your message';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _submitForm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: acerPrimaryColor,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text(
                      'Submit',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, size: 32, color: acerPrimaryColor),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            Text(
              subtitle,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _showContactInfo(String title, List<Map<String, String>> contacts) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: contacts.map((contact) {
            return ListTile(
              title: Text(contact['title'] ?? ''),
              subtitle: Text(
                contact['detail'] ?? '',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              leading: Icon(
                title.contains('Email') ? Icons.email : Icons.phone,
                color: acerPrimaryColor,
              ),
            );
          }).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      // In a real app, send data to backend
      final ticketId = 'TKT${Random().nextInt(90000) + 10000}';

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Thank You!'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.check_circle,
                color: acerPrimaryColor,
                size: 48,
              ),
              const SizedBox(height: 16),
              Text(
                'Your request #$ticketId has been submitted successfully.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const Text(
                'Our team will get back to you within 24 hours.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                // Clear form and close dialog
                _nameController.clear();
                _emailController.clear();
                _messageController.clear();
                Navigator.pop(context);
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }
}
