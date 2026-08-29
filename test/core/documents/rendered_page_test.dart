import 'dart:typed_data';

import 'package:docdr/core/documents/rendered_page.dart';
import 'package:test/test.dart';

void main() {
  group('RenderedPage — domain model', () {
    test('creates valid rendered page', () {
      final page = RenderedPage(
        pageIndex: 0,
        width: 595.0,
        height: 842.0,
      );
      expect(page.pageIndex, 0);
      expect(page.width, 595.0);
      expect(page.height, 842.0);
      expect(page.hasImage, isFalse);
    });

    test('creates with image bytes', () {
      final bytes = Uint8List.fromList([1, 2, 3]);
      final page = RenderedPage(
        pageIndex: 1,
        width: 100,
        height: 100,
        imageBytes: bytes,
      );
      expect(page.hasImage, isTrue);
      expect(page.imageBytes, bytes);
    });

    test('rejects negative pageIndex via assert', () {
      expect(
        () => RenderedPage(pageIndex: -1, width: 100, height: 100),
        throwsA(isA<AssertionError>()),
      );
    });

    test('toString contains dimensions', () {
      const page = RenderedPage(pageIndex: 0, width: 595, height: 842);
      expect(page.toString(), contains('595'));
      expect(page.toString(), contains('842'));
    });
  });
}
