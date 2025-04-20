import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart'; // Ensure this path is correct
import 'edit_profile_page.dart'; // Ensure this path is correct
import '../models/version_info.dart'; // Import the new model
import 'about_acer_store_page.dart'; // Add this import

class SettingsPage extends StatelessWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context).currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ListTile(
              title: const Text('Personal Information'),
              subtitle: user != null
                  ? Text('${user.name} - ${user.email}')
                  : const Text('No user information available'),
              trailing: const Icon(Icons.edit),
              onTap: () {
                // Navigate to EditProfilePage
                if (user != null) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EditProfilePage(user: user),
                    ),
                  );
                }
              },
            ),
            const Divider(),
            // About Acer Store Section
            ListTile(
              title: const Text('About Acer Store'),
              subtitle: const Text('Learn about our company'),
              trailing: const Icon(Icons.business),
              onTap: () {
                _showAboutAcerStoreDialog(context);
              },
            ),
            const Divider(),
            // About Version Section
            ListTile(
              title: const Text('About Version'),
              subtitle: const Text('View app version and updates'),
              trailing: const Icon(Icons.info_outline),
              onTap: () {
                _showAboutVersionDialog(context);
              },
            ),
            // Add other settings options here
          ],
        ),
      ),
    );
  }

  void _showAboutAcerStoreDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Column(
            children: [
              Image.asset(
                'assets/logos/acer_logo.png',
                height: 50,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(Icons.computer,
                      size: 50, color: Colors.green);
                },
              ),
              const SizedBox(height: 8),
              const Text(
                'About Acer Store',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: const SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Acer Store India',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                SizedBox(height: 12),
                Text(
                  'Acer is one of the world\'s top ICT companies with a presence in more than 160 countries. As Acer evolves with the industry and changing lifestyles, it is focused on enabling a world where hardware, software and services will fuse with one another, creating ecosystems and opening up new possibilities for consumers and businesses alike.',
                ),
                SizedBox(height: 16),
                Text(
                  'Our Mission',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Breaking barriers between people and technology',
                ),
                SizedBox(height: 16),
                Text(
                  'Founded in 1976, Acer is a hardware + software + services company dedicated to the research, design, marketing, sale, and support of innovative products that enhance people\'s lives.',
                ),
                SizedBox(height: 16),
                Text(
                  'Acer\'s product offerings include PCs, displays, projectors, servers, tablets, smartphones and wearables. The company is also developing cloud solutions to bring together the Internet of Things.',
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Close'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                // Navigate to a more detailed About page if needed
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AboutAcerStorePage(),
                  ),
                );
              },
              child: const Text('More Details'),
            ),
          ],
        );
      },
    );
  }

  void _showAboutVersionDialog(BuildContext context) {
    try {
      // Get version info from our model directly
      final versionInfo = VersionInfo.getCurrentVersionInfo();

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Column(
              children: [
                Text(
                  'Acer Store',
                  style: TextStyle(
                    color: Colors.green[700],
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                  ),
                ),
                Text(
                  'v${versionInfo.version}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Last Updated: ${versionInfo.releaseDate}',
                      style: TextStyle(
                        color: Colors.grey[800],
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildSectionHeader('What\'s New'),
                  const SizedBox(height: 8),
                  ...versionInfo.newFeatures
                      .map((feature) => _buildBulletPoint(feature)),
                  const SizedBox(height: 16),
                  _buildSectionHeader('Bug Fixes'),
                  const SizedBox(height: 8),
                  ...versionInfo.bugFixes.map((fix) => _buildBulletPoint(fix)),
                  const SizedBox(height: 16),
                  _buildSectionHeader('Improvements'),
                  const SizedBox(height: 8),
                  ...versionInfo.improvements
                      .map((improvement) => _buildBulletPoint(improvement)),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _showVersionHistoryDialog(context);
                },
                child: const Text('Version History'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('Close'),
              ),
            ],
          );
        },
      );
    } catch (e) {
      // Show a simple error dialog if something goes wrong
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Error'),
            content: Text('Could not load version information: $e'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('Close'),
              ),
            ],
          );
        },
      );
    }
  }

  Widget _buildSectionHeader(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.green[700],
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildBulletPoint(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 8.0, bottom: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ', style: TextStyle(fontWeight: FontWeight.bold)),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }

  void _showVersionHistoryDialog(BuildContext context) {
    final versionHistory = VersionInfo.getVersionHistory();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Version History',
            style: TextStyle(
              color: Colors.green[700],
              fontWeight: FontWeight.bold,
            ),
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: versionHistory.length,
              itemBuilder: (context, index) {
                final version = versionHistory[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  elevation: 2,
                  child: ExpansionTile(
                    title: Text(
                      'v${version.version}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(
                      version.releaseDate,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                    expandedCrossAxisAlignment: CrossAxisAlignment.start,
                    childrenPadding: const EdgeInsets.only(bottom: 12),
                    children: [
                      if (version.newFeatures.isNotEmpty) ...[
                        Padding(
                          padding: const EdgeInsets.only(
                              left: 16.0, right: 16.0, top: 8.0, bottom: 4.0),
                          child: _buildSectionHeader('New Features'),
                        ),
                        ...version.newFeatures.map((feature) => Padding(
                              padding: const EdgeInsets.only(
                                  left: 24.0, right: 16.0, bottom: 4.0),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('• ',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold)),
                                  Expanded(child: Text(feature)),
                                ],
                              ),
                            )),
                      ],
                      if (version.bugFixes.isNotEmpty) ...[
                        Padding(
                          padding: const EdgeInsets.only(
                              left: 16.0, right: 16.0, top: 8.0, bottom: 4.0),
                          child: _buildSectionHeader('Bug Fixes'),
                        ),
                        ...version.bugFixes.map((fix) => Padding(
                              padding: const EdgeInsets.only(
                                  left: 24.0, right: 16.0, bottom: 4.0),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('• ',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold)),
                                  Expanded(child: Text(fix)),
                                ],
                              ),
                            )),
                      ],
                      if (version.improvements.isNotEmpty) ...[
                        Padding(
                          padding: const EdgeInsets.only(
                              left: 16.0, right: 16.0, top: 8.0, bottom: 4.0),
                          child: _buildSectionHeader('Improvements'),
                        ),
                        ...version.improvements.map((improvement) => Padding(
                              padding: const EdgeInsets.only(
                                  left: 24.0, right: 16.0, bottom: 4.0),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('• ',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold)),
                                  Expanded(child: Text(improvement)),
                                ],
                              ),
                            )),
                      ],
                    ],
                  ),
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }
}
