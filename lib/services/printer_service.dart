import 'dart:io';
import 'package:printing/printing.dart';

class PrinterService {
  Future<List<Printer>> listPrinters() async {
    return Printing.listPrinters();
  }

  Future<bool> printPdf(Printer printer, String filePath, String jobName) async {
    final bytes = await File(filePath).readAsBytes();
    return Printing.directPrintPdf(
      printer: printer,
      onLayout: (_) async => bytes,
      name: jobName,
    );
  }
}
