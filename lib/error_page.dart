import 'package:flutter/material.dart';

class ErrorPage extends StatelessWidget {
  const ErrorPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Error'),
        backgroundColor: Colors.red,
      ),
      body: const Center(
        child: Text(
          'User not found. Please log in.',
          style: TextStyle(fontSize: 20, color: Colors.red),
        ),
      ),
    );
  }
}
