import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart'; // Ensure this path is correct
import 'edit_profile_page.dart'; // Ensure this path is correct

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
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EditProfilePage(user: user!),
                  ),
                );
              },
            ),
            // Add other settings options here
          ],
        ),
      ),
    );
  }
}
