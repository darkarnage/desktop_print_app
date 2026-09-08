import 'package:flutter/material.dart';

class PrintStatusScreen extends StatelessWidget {
  const PrintStatusScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Print Status')),
      body: const Center(
        child: Text('Step 3: Print result will appear here', style: TextStyle(fontSize: 20)),
      ),
    );
  }
}
