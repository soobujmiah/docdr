import 'package:docdr/core/documents/document.dart';
import 'package:docdr/core/documents/document_renderer.dart';
import 'package:docdr/core/rendering/pdfium/pdfium_renderer_adapter.dart';
import 'package:test/test.dart';

void main() {
  group('DocumentRenderer — vendor-neutral contract (real PDFium adapter)', () {
    final now = DateTime.utc(2026, 8, 29);
    final pdfDoc = DocDrDocument(
      id: 'doc-1',
      name: 'Sample PDF',
      source: DocDrDocumentSource.imported,
      filePath: 'documents/sample.pdf',
      createdAt: now,
      updatedAt: now,
      pageCount: 2,
    );

    final imageDoc = DocDrDocument(
      id: 'doc-2',
      name: 'Photo',
      source: DocDrDocumentSource.scanned,
      filePath: 'documents/photo.jpg',
      createdAt: now,
      updatedAt: now,
    );

    test('PdfiumRendererAdapter implements DocumentRenderer without vendor types', () {
      const renderer = PdfiumRendererAdapter();
      expect(renderer, isA<DocumentRenderer>());
      expect(renderer.engineName, isNotEmpty);
      // engineName must be generic, not a vendor class leak
      expect(renderer.engineName, isNot(contains('PdfDocument')));
      expect(renderer.engineName, isNot(contains('pdfrx_engine')));
      // No vendor types should leak into capabilities — only bool flags.
      expect(renderer.capabilities, isA<RendererCapabilities>());
    });

    test('capabilities are queryable and true after licence gate', () {
      const renderer = PdfiumRendererAdapter();
      final caps = renderer.capabilities;
      // After licence gate closed, adapter reports true for PDF capabilities
      expect(caps.canRenderPdf, isTrue);
      expect(caps.supportsBengaliText, isTrue);
      expect(caps.canExtractText, isTrue);
      expect(caps.toString(), contains('pdf'));
    });

    test('canRender returns true for PDF, false for image (graceful)', () {
      const renderer = PdfiumRendererAdapter();
      expect(renderer.canRender(pdfDoc), isTrue);
      expect(renderer.canRender(imageDoc), isFalse);
    });

    test('getPageCount throws DocumentRenderException when file missing', () async {
      const renderer = PdfiumRendererAdapter();
      // File does not exist, should throw file not found, not licence gate
      await expectLater(
        renderer.getPageCount(pdfDoc),
        throwsA(
          isA<DocumentRenderException>().having(
            (e) => e.message,
            'message',
            contains('file not found'),
          ),
        ),
      );
    });

    test('renderPage validates arguments before file check', () async {
      const renderer = PdfiumRendererAdapter();
      await expectLater(
        renderer.renderPage(pdfDoc, -1),
        throwsA(isA<DocumentRenderException>()),
      );
      await expectLater(
        renderer.renderPage(pdfDoc, 0, scale: 0),
        throwsA(isA<DocumentRenderException>()),
      );
      await expectLater(
        renderer.renderPage(pdfDoc, 0, scale: -1),
        throwsA(isA<DocumentRenderException>()),
      );
    });

    test('renderPage throws file not found when file missing', () async {
      const renderer = PdfiumRendererAdapter();
      await expectLater(
        renderer.renderPage(pdfDoc, 0),
        throwsA(
          isA<DocumentRenderException>().having(
            (e) => e.message,
            'message',
            contains('file not found'),
          ),
        ),
      );
    });

    test('extractText throws file not found when file missing', () async {
      const renderer = PdfiumRendererAdapter();
      expect(renderer.capabilities.canExtractText, isTrue);
      await expectLater(
        renderer.extractText(pdfDoc, 0),
        throwsA(isA<DocumentRenderException>()),
      );
    });

    test('dispose is no-op', () async {
      const renderer = PdfiumRendererAdapter();
      await expectLater(renderer.dispose(), completes);
    });

    test('engineName does not expose vendor types and is pdfium', () {
      const renderer = PdfiumRendererAdapter();
      expect(renderer.engineName, isNot(contains('PdfDocument')));
      expect(renderer.engineName, isNot(contains('pdfrx'))); // vendor package name not in engineName
      expect(renderer.engineName, equals('pdfium'));
    });
  });
}
