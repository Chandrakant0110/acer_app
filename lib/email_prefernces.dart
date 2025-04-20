import 'package:flutter/material.dart';
import 'main.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EmailPreferences extends StatefulWidget {
  const EmailPreferences({Key? key}) : super(key: key);

  @override
  State<EmailPreferences> createState() => _EmailPreferencesState();
}

class _EmailPreferencesState extends State<EmailPreferences> {
  // Email preferences
  bool _promotionalEmails = true;
  bool _orderUpdates = true;
  bool _productUpdates = true;
  bool _accountAlerts = true;
  bool _newsletterEmails = false;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _promotionalEmails = prefs.getBool('promotionalEmails') ?? true;
      _orderUpdates = prefs.getBool('orderUpdates') ?? true;
      _productUpdates = prefs.getBool('productUpdates') ?? true;
      _accountAlerts = prefs.getBool('accountAlerts') ?? true;
      _newsletterEmails = prefs.getBool('newsletterEmails') ?? false;
    });
  }

  Future<void> _savePreferences() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('promotionalEmails', _promotionalEmails);
    await prefs.setBool('orderUpdates', _orderUpdates);
    await prefs.setBool('productUpdates', _productUpdates);
    await prefs.setBool('accountAlerts', _accountAlerts);
    await prefs.setBool('newsletterEmails', _newsletterEmails);

    // Show save confirmation
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Email preferences saved'),
          backgroundColor: acerPrimaryColor,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  Widget _buildPreferenceSwitch({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: ListTile(
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
        trailing: Switch(
          value: value,
          activeColor: acerPrimaryColor,
          onChanged: onChanged,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Email Preferences'),
        backgroundColor: acerPrimaryColor,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'Manage Your Email Preferences',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: acerPrimaryColor,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                'Select which types of emails you would like to receive from Acer Store. You can change these preferences at any time.',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                  height: 1.5,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              margin: const EdgeInsets.all(16.0),
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  _buildPreferenceSwitch(
                    title: 'Promotional Emails',
                    subtitle:
                        'Receive special offers, discounts, and promotional content',
                    value: _promotionalEmails,
                    onChanged: (value) {
                      setState(() {
                        _promotionalEmails = value;
                      });
                    },
                  ),
                  const Divider(height: 1),
                  _buildPreferenceSwitch(
                    title: 'Order Updates',
                    subtitle:
                        'Receive notifications about your orders and purchases',
                    value: _orderUpdates,
                    onChanged: (value) {
                      setState(() {
                        _orderUpdates = value;
                      });
                    },
                  ),
                  const Divider(height: 1),
                  _buildPreferenceSwitch(
                    title: 'Product Updates',
                    subtitle: 'Get notified about new products and updates',
                    value: _productUpdates,
                    onChanged: (value) {
                      setState(() {
                        _productUpdates = value;
                      });
                    },
                  ),
                  const Divider(height: 1),
                  _buildPreferenceSwitch(
                    title: 'Account Alerts',
                    subtitle: 'Important notifications about your account',
                    value: _accountAlerts,
                    onChanged: (value) {
                      setState(() {
                        _accountAlerts = value;
                      });
                    },
                  ),
                  const Divider(height: 1),
                  _buildPreferenceSwitch(
                    title: 'Newsletter',
                    subtitle:
                        'Monthly newsletter with tips, tricks, and Acer news',
                    value: _newsletterEmails,
                    onChanged: (value) {
                      setState(() {
                        _newsletterEmails = value;
                      });
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _savePreferences,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: acerPrimaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Save Preferences',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                'Note: Even if you opt out of marketing emails, we will still send you important account-related notifications and information about your orders.',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontStyle: FontStyle.italic,
                  height: 1.4,
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
