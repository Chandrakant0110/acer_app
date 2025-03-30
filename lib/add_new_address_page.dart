import 'package:flutter/material.dart';

class AddNewAddressPage extends StatelessWidget {
  const AddNewAddressPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Address'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const TextField(
              decoration: InputDecoration(labelText: 'Address'),
            ),
            const TextField(
              decoration: InputDecoration(labelText: 'City'),
            ),
            const TextField(
              decoration: InputDecoration(labelText: 'State'),
            ),
            const TextField(
              decoration: InputDecoration(labelText: 'Zip Code'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Handle address saving logic here
                Navigator.pop(context); // Go back after saving
              },
              child: const Text('Save Address'),
            ),
          ],
        ),
      ),
    );
  }
}
