import 'package:flutter/material.dart';
import '../print_status/print_status_screen.dart';

class PrinterSelectionScreen extends StatelessWidget {
  const PrinterSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Select Printer')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Step 2: Choose a printer', style: TextStyle(fontSize: 20)),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const PrintStatusScreen()),
                );
              },
              child: const Text('Select printer (stub)'),
            ),
          ],
        ),
      ),
    );
  }
}
