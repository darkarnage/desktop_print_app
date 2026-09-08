import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:printing/printing.dart';
import '../services/file_service.dart';
import '../services/printer_service.dart';

final fileServiceProvider = Provider((_) => FileService());
final printerServiceProvider = Provider((_) => PrinterService());

// --- Selected file ---

typedef SelectedFile = ({String path, String name, int sizeBytes})?;

class SelectedFileNotifier extends Notifier<SelectedFile> {
  @override
  SelectedFile build() => null;

  // Returns an error message on failure, null on success or cancellation.
  Future<String?> pick() async {
    final picked = await ref.read(fileServiceProvider).pickPdf();
    if (picked == null) return null;
    final error = ref.read(fileServiceProvider).validatePdf(picked.path);
    if (error != null) return error;
    final sizeBytes = File(picked.path).lengthSync();
    state = (path: picked.path, name: picked.name, sizeBytes: sizeBytes);
    return null;
  }

  void clear() => state = null;
}

final selectedFileProvider =
    NotifierProvider<SelectedFileNotifier, SelectedFile>(SelectedFileNotifier.new);

// --- Printer list ---

class PrintersNotifier extends AsyncNotifier<List<Printer>> {
  @override
  Future<List<Printer>> build() =>
      ref.read(printerServiceProvider).listPrinters();

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(printerServiceProvider).listPrinters(),
    );
  }
}

final printersProvider =
    AsyncNotifierProvider<PrintersNotifier, List<Printer>>(PrintersNotifier.new);

// Selected printer identified by name (Printer has no == override).
class SelectedPrinterNameNotifier extends Notifier<String?> {
  @override
  String? build() => null;
  void select(String name) => state = name;
}

final selectedPrinterNameProvider =
    NotifierProvider<SelectedPrinterNameNotifier, String?>(
        SelectedPrinterNameNotifier.new);

// --- Print job ---

enum PrintStatus { idle, printing, success, failure }

typedef PrintState = ({PrintStatus status, String? error});

class PrintJobNotifier extends Notifier<PrintState> {
  @override
  PrintState build() => (status: PrintStatus.idle, error: null);

  Future<void> submit(String filePath, String fileName, Printer printer) async {
    state = (status: PrintStatus.printing, error: null);
    try {
      final ok = await ref
          .read(printerServiceProvider)
          .printPdf(printer, filePath, fileName);
      state = ok
          ? (status: PrintStatus.success, error: null)
          : (status: PrintStatus.failure,
              error: 'The printer did not accept the job.');
    } catch (e) {
      state = (status: PrintStatus.failure, error: e.toString());
    }
  }

  void reset() => state = (status: PrintStatus.idle, error: null);
}

final printJobProvider =
    NotifierProvider<PrintJobNotifier, PrintState>(PrintJobNotifier.new);
