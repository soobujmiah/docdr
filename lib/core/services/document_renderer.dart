import 'dart:io';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../models/docdr_template.dart';

/// Minimal vector-first renderer for the generic DocDr template model.
/// Complex elements can be added without changing the template contract.
class DocDrDocumentRenderer {
  Future<File> renderToPdf({
    required DocDrTemplate template,
    required Directory outputDirectory,
    Map<String, String> data = const {},
  }) async {
    await outputDirectory.create(recursive: true);
    final document = pw.Document();
    final pageFormat = PdfPageFormat(
      template.pageWidth,
      template.pageHeight,
      marginAll: 0,
    );

    document.addPage(
      pw.Page(
        pageFormat: pageFormat,
        margin: pw.EdgeInsets.zero,
        build: (_) => pw.Stack(
          children: template.elements.map((element) {
            return _buildElement(element, data);
          }).whereType<pw.Widget>().toList(),
        ),
      ),
    );

    final file = File('${outputDirectory.path}/${_safe(template.id)}.pdf');
    await file.writeAsBytes(await document.save(), flush: true);
    return file;
  }

  pw.Widget? _buildElement(DocDrElement element, Map<String, String> data) {
    final value = _resolve(element, data);
    final position = pw.Positioned(
      left: element.x,
      top: element.y,
      width: element.width,
      height: element.height,
      child: _content(element, value),
    );
    return position;
  }

  pw.Widget _content(DocDrElement element, String value) {
    switch (element.type) {
      case DocDrElementType.text:
      case DocDrElementType.date:
      case DocDrElementType.serial:
        return pw.Text(value, style: const pw.TextStyle(fontSize: 12));
      case DocDrElementType.rectangle:
        return pw.Container(decoration: pw.BoxDecoration(border: pw.Border.all()));
      case DocDrElementType.line:
        return pw.Container(height: 1, color: PdfColors.black);
      case DocDrElementType.circle:
        return pw.Container(decoration: const pw.BoxDecoration(shape: pw.BoxShape.circle, border: pw.Border.fromBorderSide(pw.BorderSide())));
      case DocDrElementType.checkbox:
        return pw.Center(child: pw.Text(value == 'true' ? '☑' : '☐'));
      case DocDrElementType.shape:
      case DocDrElementType.image:
      case DocDrElementType.qr:
      case DocDrElementType.barcode:
      case DocDrElementType.photo:
      case DocDrElementType.signature:
        return pw.Text(value);
    }
  }

  String _resolve(DocDrElement element, Map<String, String> data) {
    if (element.dataKey != null) return data[element.dataKey] ?? '';
    return element.value ?? '';
  }

  String _safe(String value) => value.replaceAll(RegExp(r'[^A-Za-z0-9._-]'), '_');
}
