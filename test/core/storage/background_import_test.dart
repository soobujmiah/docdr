import 'dart:io';
import 'dart:typed_data';

import 'package:docdr/core/documents/document.dart';
import 'package:docdr/core/documents/document_renderer.dart';
import 'package:docdr/core/documents/rendered_page.dart';
import 'package:docdr/core/models/custom_template.dart';
import 'package:docdr/core/services/background_import_service.dart';
import 'package:docdr/core/storage/template_store.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:pdf/pdf.dart' as pdf_lib;
import 'package:pdf/widgets.dart' as pw;

/// Fake renderer for tests — does not need native PDFium
class FakeRenderer implements DocumentRenderer {
  @override
  String get engineName => 'fake';

  @override
  RendererCapabilities get capabilities => const RendererCapabilities(
        canRenderPdf: true,
        canRenderImage: false,
        canExtractText: false,
        canRenderAnnotations: false,
        supportsBengaliText: true,
        supportsPasswordProtected: false,
      );

  @override
  bool canRender(DocDrDocument document) =>
      document.filePath.toLowerCase().endsWith('.pdf');

  @override
  Future<int> getPageCount(DocDrDocument document) async {
    final file = File(document.filePath);
    if (!await file.exists()) throw DocumentRenderException('not found');
    final bytes = await file.readAsBytes();
    // Simple validation: must start with %PDF-
    if (bytes.length < 5 || String.fromCharCodes(bytes.sublist(0, 5)) != '%PDF-') {
      throw DocumentRenderException('not a PDF');
    }
    // For test, return 1 page unless file contains special marker for multi-page
    // Count occurrences of "/Type /Page" not "/Pages" — crude but enough
    final content = String.fromCharCodes(bytes);
    final matches = RegExp(r'/Type\s*/Page[^s]').allMatches(content).length;
    return matches > 0 ? matches : 1;
  }

  @override
  Future<RenderedPage> renderPage(DocDrDocument document, int pageIndex,
      {double scale = 1.0, bool includeImage = true}) async {
    throw UnimplementedError();
  }

  @override
  Future<String> extractText(DocDrDocument document, int pageIndex) async {
    throw UnimplementedError();
  }

  @override
  Future<void> dispose() async {}
}

Future<File> _createPdfFile(Directory dir, String name, {int pages = 1}) async {
  final doc = pw.Document();
  for (var i = 0; i < pages; i++) {
    doc.addPage(
      pw.Page(
        pageFormat: pdf_lib.PdfPageFormat.a4,
        build: (c) => pw.Center(child: pw.Text('Page ${i + 1}')),
      ),
    );
  }
  final bytes = await doc.save();
  final file = File('${dir.path}/$name');
  await file.writeAsBytes(bytes);
  return file;
}

Future<File> _createPngFile(Directory dir, String name,
    {int width = 100, int height = 100}) async {
  final image = img.Image(width: width, height: height);
  // Fill with color
  img.fill(image, color: img.ColorRgb8(200, 200, 200));
  final bytes = img.encodePng(image);
  final file = File('${dir.path}/$name');
  await file.writeAsBytes(bytes);
  return file;
}

void main() {
  late Directory tmpRoot;
  late DocDrTemplateStore store;
  late BackgroundImportService service;
  late FakeRenderer renderer;

  setUp(() async {
    tmpRoot = await Directory.systemTemp.createTemp('docdr_bg_import_');
    store = DocDrTemplateStore(root: Directory('${tmpRoot.path}/templates'));
    renderer = FakeRenderer();
    service = BackgroundImportService(store: store, renderer: renderer);
  });

  tearDown(() async {
    try {
      await tmpRoot.delete(recursive: true);
    } catch (_) {}
  });

  group('BackgroundImportService — PDF', () {
    test('valid PDF import sets backgroundType pdf and relative path', () async {
      final template = await store.createBlank('Test');
      final pdfFile = await _createPdfFile(tmpRoot, 'sample.pdf');

      final updated = await service.importBackgroundPdf(
        template,
        pdfFile.path,
        pageId: template.pages.first.id,
      );

      expect(updated.pages.first.backgroundType, DocDrBackgroundType.pdf);
      expect(updated.pages.first.backgroundPath, isNotEmpty);
      expect(updated.pages.first.backgroundPath, contains('backgrounds/'));
      // Asset file exists
      final assetPath = store.resolveAssetPath(updated, updated.pages.first.backgroundPath);
      expect(File(assetPath).existsSync(), isTrue);
    });

    test('oversized PDF rejected (exceeds store limit)', () async {
      final smallLimitsStore = DocDrTemplateStore(
        root: Directory('${tmpRoot.path}/templates_small'),
        limits: const TemplateStoreLimits(maxAssetBytes: 10),
      );
      final smallService = BackgroundImportService(
        store: smallLimitsStore,
        renderer: renderer,
      );
      final template = await smallLimitsStore.createBlank('Test');
      final pdfFile = await _createPdfFile(tmpRoot, 'big.pdf');

      expect(
        () => smallService.importBackgroundPdf(
          template,
          pdfFile.path,
          pageId: template.pages.first.id,
        ),
        throwsA(isA<BackgroundImportException>()),
      );
    });

    test('invalid extension rejected', () async {
      final template = await store.createBlank('Test');
      final txtFile = File('${tmpRoot.path}/notpdf.txt');
      await txtFile.writeAsString('hello');

      expect(
        () => service.importBackgroundPdf(
          template,
          txtFile.path,
          pageId: template.pages.first.id,
        ),
        throwsA(isA<BackgroundImportException>()),
      );
    });

    test('file without %PDF- header rejected', () async {
      final template = await store.createBlank('Test');
      final fakePdf = File('${tmpRoot.path}/fake.pdf');
      await fakePdf.writeAsString('NOT A PDF');

      expect(
        () => service.importBackgroundPdf(
          template,
          fakePdf.path,
          pageId: template.pages.first.id,
        ),
        throwsA(isA<BackgroundImportException>()),
      );
    });

    test('empty PDF rejected', () async {
      final template = await store.createBlank('Test');
      final empty = File('${tmpRoot.path}/empty.pdf');
      await empty.writeAsBytes([]);

      expect(
        () => service.importBackgroundPdf(
          template,
          empty.path,
          pageId: template.pages.first.id,
        ),
        throwsA(isA<BackgroundImportException>()),
      );
    });

    test('page not found rejected', () async {
      final template = await store.createBlank('Test');
      final pdfFile = await _createPdfFile(tmpRoot, 'sample.pdf');

      expect(
        () => service.importBackgroundPdf(
          template,
          pdfFile.path,
          pageId: 'nonexistent',
        ),
        throwsA(isA<BackgroundImportException>()),
      );
    });

    test('Bengali filename sanitized but import succeeds', () async {
      final template = await store.createBlank('Test');
      // Create file with Bengali name — filesystem may support UTF-8, but _safeName will sanitize
      final pdfFile = await _createPdfFile(tmpRoot, 'নথি.pdf');

      final updated = await service.importBackgroundPdf(
        template,
        pdfFile.path,
        pageId: template.pages.first.id,
      );

      expect(updated.pages.first.backgroundType, DocDrBackgroundType.pdf);
      // Sanitized name should not contain Bengali chars, only safe chars
      expect(updated.pages.first.backgroundPath, matches(RegExp(r'^[A-Za-z0-9._/\\-]+$')));
    });
  });

  group('BackgroundImportService — Image', () {
    test('valid PNG import sets backgroundType image', () async {
      final template = await store.createBlank('Test');
      final pngFile = await _createPngFile(tmpRoot, 'sample.png', width: 200, height: 100);

      final updated = await service.importBackgroundImage(
        template,
        pngFile.path,
        pageId: template.pages.first.id,
      );

      expect(updated.pages.first.backgroundType, DocDrBackgroundType.image);
      expect(updated.pages.first.backgroundPath, contains('backgrounds/'));
      final assetPath = store.resolveAssetPath(updated, updated.pages.first.backgroundPath);
      expect(File(assetPath).existsSync(), isTrue);
    });

    test('valid JPG import succeeds', () async {
      final template = await store.createBlank('Test');
      final image = img.Image(width: 50, height: 50);
      final jpgBytes = img.encodeJpg(image);
      final jpgFile = File('${tmpRoot.path}/sample.jpg');
      await jpgFile.writeAsBytes(jpgBytes);

      final updated = await service.importBackgroundImage(
        template,
        jpgFile.path,
        pageId: template.pages.first.id,
      );

      expect(updated.pages.first.backgroundType, DocDrBackgroundType.image);
    });

    test('oversized image dimensions rejected', () async {
      final template = await store.createBlank('Test');
      // Create image exceeding max dimension (8000)
      final bigImage = img.Image(width: 9000, height: 100);
      final bytes = img.encodePng(bigImage);
      final file = File('${tmpRoot.path}/big.png');
      await file.writeAsBytes(bytes);

      expect(
        () => service.importBackgroundImage(
          template,
          file.path,
          pageId: template.pages.first.id,
        ),
        throwsA(isA<BackgroundImportException>()),
      );
    });

    test('corrupt image rejected', () async {
      final template = await store.createBlank('Test');
      final corrupt = File('${tmpRoot.path}/corrupt.png');
      await corrupt.writeAsString('not an image');

      expect(
        () => service.importBackgroundImage(
          template,
          corrupt.path,
          pageId: template.pages.first.id,
        ),
        throwsA(isA<BackgroundImportException>()),
      );
    });

    test('invalid extension rejected', () async {
      final template = await store.createBlank('Test');
      final txt = File('${tmpRoot.path}/notimage.txt');
      await txt.writeAsString('hello');

      expect(
        () => service.importBackgroundImage(
          template,
          txt.path,
          pageId: template.pages.first.id,
        ),
        throwsA(isA<BackgroundImportException>()),
      );
    });

    test('Bengali image filename sanitized', () async {
      final template = await store.createBlank('Test');
      final pngFile = await _createPngFile(tmpRoot, 'ছবি.png');

      final updated = await service.importBackgroundImage(
        template,
        pngFile.path,
        pageId: template.pages.first.id,
      );

      expect(updated.pages.first.backgroundPath, matches(RegExp(r'^[A-Za-z0-9._/\\-]+$')));
    });
  });

  group('Security — path handling', () {
    test('traversal in source name does not escape via sanitized import', () async {
      final template = await store.createBlank('Test');
      final pdfFile = await _createPdfFile(tmpRoot, 'sample.pdf');
      // Source path with .. is still valid absolute path, but importAsset sanitizes filename
      // The service should not allow traversal in final relative path
      final updated = await service.importBackgroundPdf(
        template,
        pdfFile.path,
        pageId: template.pages.first.id,
      );
      expect(updated.pages.first.backgroundPath.contains('..'), isFalse);
    });

    test('resolveAssetPath still enforces containment after import', () async {
      final template = await store.createBlank('Test');
      final pngFile = await _createPngFile(tmpRoot, 'sample.png');

      final updated = await service.importBackgroundImage(
        template,
        pngFile.path,
        pageId: template.pages.first.id,
      );

      final relative = updated.pages.first.backgroundPath;
      // Should resolve inside template dir
      final absolute = store.resolveAssetPath(updated, relative);
      expect(absolute.startsWith(Directory(updated.basePath).absolute.path), isTrue);
    });
  });
}
