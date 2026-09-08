import 'package:printing/printing.dart';

class PrintJob {
  final String filePath;
  final String fileName;
  final Printer printer;

  const PrintJob({
    required this.filePath,
    required this.fileName,
    required this.printer,
  });
}

enum PrintJobStatus { idle, submitting, success, failure }
