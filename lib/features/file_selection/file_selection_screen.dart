import 'package:flutter/material.dart';
import '../printer_selection/printer_selection_screen.dart';

class FileSelectionScreen extends StatelessWidget {
  const FileSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Step 1: Select a document', style: TextStyle(fontSize: 20)),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const PrinterSelectionScreen()),
                );
              },
              child: const Text('Select PDF (stub)'),
            ),
          ],
        ),
      ),
    );
  }
}
