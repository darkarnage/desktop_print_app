import 'dart:io';
import 'package:file_picker/file_picker.dart';

class FileService {
  Future<({String path, String name})?> pickPdf() async {
    final files = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );
    if (files.isEmpty) return null;
    final file = files.single;
    if (file.path == null) return null;
    return (path: file.path!, name: file.name);
  }

  // Returns null if valid, or an error message if not.
  String? validatePdf(String path) {
    final f = File(path);
    if (!f.existsSync()) return 'File not found.';
    final raf = f.openSync()..setPositionSync(0);
    final bytes = raf.readSync(5);
    raf.closeSync();
    if (bytes.length < 5 || String.fromCharCodes(bytes) != '%PDF-') {
      return 'File does not appear to be a valid PDF.';
    }
    return null;
  }
}
