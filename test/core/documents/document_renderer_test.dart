import 'package:docdr/core/documents/document.dart';
import 'package:docdr/core/documents/document_renderer.dart';
import 'package:docdr/core/rendering/pdfium/pdfium_renderer_adapter.dart';
import 'package:test/test.dart';

void main() {
  group('DocumentRenderer — vendor-neutral contract', () {
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
      expect(renderer.engineName, isNot(contains('pdfrx')));
      // No vendor types should leak into capabilities — only bool flags.
      expect(renderer.capabilities, isA<RendererCapabilities>());
    });

    test('capabilities are queryable and default to false in stub', () {
      const renderer = PdfiumRendererAdapter();
      final caps = renderer.capabilities;
      // Stub must report false until licence is cleared and engine bundled.
      expect(caps.canRenderPdf, isFalse);
      expect(caps.supportsBengaliText, isFalse);
      expect(caps.toString(), contains('pdf'));
    });

    test('canRender returns false for graceful degradation (stub)', () {
      const renderer = PdfiumRendererAdapter();
      // Must not throw, must return false for graceful degradation.
      expect(renderer.canRender(pdfDoc), isFalse);
      expect(renderer.canRender(imageDoc), isFalse);
    });

    test('getPageCount throws DocumentRenderException in stub', () async {
      const renderer = PdfiumRendererAdapter();
      await expectLater(
        renderer.getPageCount(pdfDoc),
        throwsA(isA<DocumentRenderException>()),
      );
    });

    test('renderPage validates arguments before engine check', () async {
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

    test('renderPage throws DocumentRenderException in stub (licence gate)', () async {
      const renderer = PdfiumRendererAdapter();
      await expectLater(
        renderer.renderPage(pdfDoc, 0),
        throwsA(
          isA<DocumentRenderException>().having(
            (e) => e.message,
            'message',
            contains('licence gate'),
          ),
        ),
      );
    });

    test('extractText throws when capability false', () async {
      const renderer = PdfiumRendererAdapter();
      expect(renderer.capabilities.canExtractText, isFalse);
      await expectLater(
        renderer.extractText(pdfDoc, 0),
        throwsA(isA<DocumentRenderException>()),
      );
    });

    test('dispose is no-op in stub', () async {
      const renderer = PdfiumRendererAdapter();
      await expectLater(renderer.dispose(), completes);
    });

    test('engineName does not expose vendor types', () {
      const renderer = PdfiumRendererAdapter();
      // engineName must be generic, not a vendor class name.
      expect(renderer.engineName, isNot(contains('PdfDocument')));
      expect(renderer.engineName, isNot(contains('Pdfium')));
      // Our stub uses 'pdfium-stub' — generic identifier, not vendor type.
      expect(renderer.engineName, equals('pdfium-stub'));
    });
  });
}
