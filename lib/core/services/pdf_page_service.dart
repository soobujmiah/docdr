import 'dart:io';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

/// Page-level PDF operations kept independent from Flutter UI.
class DocDrPdfPageService {
  Future<File> createPdfFromImages({
    required List<File> images,
    required Directory outputDirectory,
    String fileName = 'document.pdf',
  }) async {
    if (images.isEmpty) throw ArgumentError('At least one image is required');
    await outputDirectory.create(recursive: true);
    final pdf = pw.Document();

    for (final imageFile in images) {
      if (!await imageFile.exists()) {
        throw FileSystemException('Image does not exist', imageFile.path);
      }
      final image = pw.MemoryImage(await imageFile.readAsBytes());
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          margin: pw.EdgeInsets.zero,
          build: (_) => pw.Center(child: pw.Image(image, fit: pw.BoxFit.contain)),
        ),
      );
    }

    final safeName = fileName.replaceAll(RegExp(r'[^A-Za-z0-9._-]'), '_');
    final output = File('${outputDirectory.path}/$safeName');
    await output.writeAsBytes(await pdf.save(), flush: true);
    return output;
  }
}
