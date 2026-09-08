import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:printing/printing.dart';
import '../../providers/app_providers.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: cs.surfaceContainerLowest,
      appBar: AppBar(
        title: const Text('Print', style: TextStyle(fontWeight: FontWeight.w600)),
        backgroundColor: cs.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Divider(height: 1, color: cs.outlineVariant),
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: const [
                _SectionLabel('Document'),
                SizedBox(height: 8),
                _FilePickerCard(),
                SizedBox(height: 24),
                _SectionLabel('Printer'),
                SizedBox(height: 8),
                _PrinterListCard(),
                SizedBox(height: 32),
                _PrintButton(),
                SizedBox(height: 16),
                _StatusBanner(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Section label ───────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            letterSpacing: 1.2,
            fontWeight: FontWeight.w600,
          ),
    );
  }
}

// ─── File picker card ─────────────────────────────────────────────────────────

class _FilePickerCard extends ConsumerWidget {
  const _FilePickerCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final file = ref.watch(selectedFileProvider);
    final cs = Theme.of(context).colorScheme;

    if (file != null) {
      return _OutlinedCard(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Icon(Icons.picture_as_pdf_rounded, color: Colors.red.shade400, size: 40),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      file.name,
                      style: Theme.of(context)
                          .textTheme
                          .bodyLarge
                          ?.copyWith(fontWeight: FontWeight.w500),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _formatBytes(file.sizeBytes),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: cs.onSurfaceVariant,
                          ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () {
                  ref.read(selectedFileProvider.notifier).clear();
                  ref.read(printJobProvider.notifier).reset();
                },
                tooltip: 'Remove',
              ),
            ],
          ),
        ),
      );
    }

    return GestureDetector(
      onTap: () async {
        final error = await ref.read(selectedFileProvider.notifier).pick();
        if (error != null && context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(error),
              backgroundColor: cs.error,
            ),
          );
        }
      },
      child: CustomPaint(
        painter: _DashedBorderPainter(color: cs.primary),
        child: Container(
          height: 120,
          decoration: BoxDecoration(
            color: cs.primaryContainer.withValues(alpha: 0.25),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.upload_file_outlined, size: 40, color: cs.primary),
                const SizedBox(height: 8),
                Text(
                  'Click to select a PDF',
                  style: Theme.of(context)
                      .textTheme
                      .bodyLarge
                      ?.copyWith(color: cs.primary, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 2),
                Text(
                  'PDF files only',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: cs.onSurfaceVariant,
                      ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

String _formatBytes(int bytes) {
  if (bytes < 1024) return '$bytes B';
  if (bytes < 1048576) return '${(bytes / 1024).toStringAsFixed(1)} KB';
  return '${(bytes / 1048576).toStringAsFixed(1)} MB';
}

// ─── Printer list card ────────────────────────────────────────────────────────

class _PrinterListCard extends ConsumerWidget {
  const _PrinterListCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final printersAsync = ref.watch(printersProvider);
    final selectedName = ref.watch(selectedPrinterNameProvider);
    final cs = Theme.of(context).colorScheme;

    return _OutlinedCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 8, 10),
            child: Row(
              children: [
                Text(
                  'Available Printers',
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(fontWeight: FontWeight.w600),
                ),
                const Spacer(),
                TextButton.icon(
                  icon: const Icon(Icons.refresh, size: 16),
                  label: const Text('Refresh'),
                  style: TextButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                  ),
                  onPressed: () => ref.read(printersProvider.notifier).refresh(),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: cs.outlineVariant),
          printersAsync.when(
            loading: () => const Padding(
              padding: EdgeInsets.all(28),
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (e, _) => Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(Icons.error_outline, color: cs.error, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Could not load printers: $e',
                      style: TextStyle(color: cs.error),
                    ),
                  ),
                ],
              ),
            ),
            data: (printers) {
              if (printers.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.all(28),
                  child: Center(
                    child: Text(
                      'No printers found',
                      style: TextStyle(color: cs.onSurfaceVariant),
                    ),
                  ),
                );
              }
              return RadioGroup<String>(
                groupValue: selectedName,
                onChanged: (name) {
                  if (name == null) return;
                  ref.read(selectedPrinterNameProvider.notifier).select(name);
                  ref.read(printJobProvider.notifier).reset();
                },
                child: Column(
                  children: printers
                      .map(
                        (printer) => RadioListTile<String>(
                          value: printer.name,
                          title: Text(printer.name),
                          subtitle: printer.isDefault
                              ? Text(
                                  'Default',
                                  style: TextStyle(color: cs.primary, fontSize: 12),
                                )
                              : null,
                          secondary: printer.isAvailable
                              ? null
                              : const Tooltip(
                                  message: 'Printer may be offline',
                                  child: Icon(Icons.warning_amber_rounded,
                                      size: 18, color: Colors.orange),
                                ),
                          controlAffinity: ListTileControlAffinity.leading,
                          dense: true,
                        ),
                      )
                      .toList(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

// ─── Print button ─────────────────────────────────────────────────────────────

class _PrintButton extends ConsumerWidget {
  const _PrintButton();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final file = ref.watch(selectedFileProvider);
    final selectedName = ref.watch(selectedPrinterNameProvider);
    final printers = ref.watch(printersProvider).value ?? [];
    final printState = ref.watch(printJobProvider);
    final isPrinting = printState.status == PrintStatus.printing;

    final Printer? printer =
        selectedName != null && printers.isNotEmpty
            ? printers.where((p) => p.name == selectedName).firstOrNull
            : null;

    final canPrint = file != null && printer != null && !isPrinting;

    return FilledButton(
      onPressed: canPrint
          ? () => ref
              .read(printJobProvider.notifier)
              .submit(file.path, file.name, printer)
          : null,
      style: FilledButton.styleFrom(
        minimumSize: const Size.fromHeight(52),
        textStyle:
            const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
      child: isPrinting
          ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                  strokeWidth: 2.5, color: Colors.white),
            )
          : const Text('Print'),
    );
  }
}

// ─── Status banner ────────────────────────────────────────────────────────────

class _StatusBanner extends ConsumerWidget {
  const _StatusBanner();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final printState = ref.watch(printJobProvider);

    return switch (printState.status) {
      PrintStatus.idle || PrintStatus.printing => const SizedBox.shrink(),
      PrintStatus.success => const _StatusTile(
          icon: Icons.check_circle_outline_rounded,
          message: 'Sent to printer successfully.',
          isError: false,
        ),
      PrintStatus.failure => _StatusTile(
          icon: Icons.error_outline_rounded,
          message: printState.error ?? 'Print failed.',
          isError: true,
        ),
    };
  }
}

class _StatusTile extends StatelessWidget {
  const _StatusTile({
    required this.icon,
    required this.message,
    required this.isError,
  });

  final IconData icon;
  final String message;
  final bool isError;

  @override
  Widget build(BuildContext context) {
    final color = isError ? Colors.red.shade700 : Colors.green.shade700;
    final bg = isError ? Colors.red.shade50 : Colors.green.shade50;
    final border = isError ? Colors.red.shade200 : Colors.green.shade200;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: border),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: TextStyle(color: color, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Shared widgets ───────────────────────────────────────────────────────────

class _OutlinedCard extends StatelessWidget {
  const _OutlinedCard({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: cs.outlineVariant),
      ),
      child: child,
    );
  }
}

// Draws a rounded-rect dashed border.
class _DashedBorderPainter extends CustomPainter {
  const _DashedBorderPainter({required this.color});
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withValues(alpha: 0.5)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    final path = Path()
      ..addRRect(RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.width, size.height),
        const Radius.circular(12),
      ));

    final dashPath = Path();
    for (final metric in path.computeMetrics()) {
      double d = 0;
      while (d < metric.length) {
        dashPath.addPath(metric.extractPath(d, d + 6), Offset.zero);
        d += 10;
      }
    }
    canvas.drawPath(dashPath, paint);
  }

  @override
  bool shouldRepaint(_DashedBorderPainter old) => old.color != color;
}
