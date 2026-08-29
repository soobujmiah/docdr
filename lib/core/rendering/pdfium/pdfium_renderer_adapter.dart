import 'dart:io';
import 'dart:typed_data';

import 'package:image/image.dart' as img;
import 'package:pdfrx_engine/pdfrx_engine.dart' as pdfrx;

import '../../documents/document.dart';
import '../../documents/document_renderer.dart';
import '../../documents/rendered_page.dart';

/// PDFium-based renderer adapter — **real implementation** after licence gate.
///
/// Architecture per handoff section 13:
/// ```
/// DocDr Domain Document
///         ↓
/// DocumentRenderer (vendor-neutral)
///         ↓
/// PdfiumRendererAdapter (this file, only place with pdfrx types)
///         ↓
/// pdfrx_engine + PDFium (BSD-3-Clause + MIT)
/// ```
///
/// **Licensing:** Verified in `THIRD_PARTY_NOTICES.md` and
/// `docs/PDF_TECHNOLOGY_EVALUATION.md`:
/// - pdfrx 2.4.7 MIT
/// - pdfrx_engine 0.5.0 MIT
/// - pdfium_dart 0.2.5 MIT
/// - pdfium_flutter 0.2.3 MIT
/// - PDFium binary BSD-3-Clause + permissive third-party (freetype, libjpeg, lcms2, etc.)
/// All permissive, compatible with PROPRIETARY closed-source with attribution.
///
/// **Vendor isolation:** All `pdfrx_engine` types are used only inside this file.
/// Public API exposes only domain types (`DocDrDocument`, `RenderedPage`,
/// `RendererCapabilities`, `DocumentRenderException`).
class PdfiumRendererAdapter implements DocumentRenderer {
  const PdfiumRendererAdapter({this.enableBengaliCheck = false});

  final bool enableBengaliCheck;

  static bool _initialized = false;
  static Future<void> _ensureInitialized() async {
    if (_initialized) return;
    // pdfrxInitialize loads PDFium native library.
    // In Flutter apps, pdfium_flutter handles packaging; in pure Dart,
    // pdfium_dart downloads native asset at build time.
    await pdfrx.pdfrxInitialize();
    _initialized = true;
  }

  @override
  String get engineName => 'pdfium';

  @override
  RendererCapabilities get capabilities => const RendererCapabilities(
        canRenderPdf: true,
        canRenderImage: false,
        canExtractText: true,
        canRenderAnnotations: true,
        supportsBengaliText: true, // PDFium supports Bengali if font embedded or system fallback
        supportsPasswordProtected: true,
      );

  @override
  bool canRender(DocDrDocument document) {
    final lower = document.filePath.toLowerCase();
    return lower.endsWith('.pdf');
  }

  void _validateFile(DocDrDocument document) {
    // Security: filePath already validated in DocDrDocument constructor
    // (no traversal, no NUL, no backslash, no //). Here we enforce existence
    // and size bounds.
    final path = document.filePath;
    final file = File(path);
    // Allow relative paths for tests that use temp dir; File will resolve.
    if (!file.existsSync()) {
      // For relative paths, try resolving against current directory; if still
      // missing, throw with clear message (no path leak in production logs
      // per SECURITY_PRIVACY.md, but for prototype we include path in exception
      // message for debugging — caller should not log verbatim in prod).
      throw DocumentRenderException('file not found: $path');
    }
    final length = file.lengthSync();
    // Bound: 100 MB max PDF size (prevent OOM / decompression bomb)
    const maxBytes = 100 * 1024 * 1024;
    if (length > maxBytes) {
      throw DocumentRenderException(
        'PDF too large: $length bytes > $maxBytes (bound)',
      );
    }
    if (length == 0) {
      throw const DocumentRenderException('PDF file is empty');
    }
  }

  @override
  Future<int> getPageCount(DocDrDocument document) async {
    _validateFile(document);
    await _ensureInitialized();
    pdfrx.PdfDocument? doc;
    try {
      doc = await pdfrx.PdfDocument.openFile(document.filePath);
      // Security: bound page count (prevent excessive page count)
      const maxPages = 2000;
      final count = doc.pages.length;
      if (count > maxPages) {
        throw DocumentRenderException(
          'PDF page count $count exceeds bound $maxPages',
        );
      }
      return count;
    } catch (e) {
      if (e is DocumentRenderException) rethrow;
      throw DocumentRenderException('failed to open PDF: $e', cause: e);
    } finally {
      doc?.dispose();
    }
  }

  @override
  Future<RenderedPage> renderPage(
    DocDrDocument document,
    int pageIndex, {
    double scale = 1.0,
    bool includeImage = true,
  }) async {
    if (pageIndex < 0) {
      throw const DocumentRenderException('pageIndex must not be negative');
    }
    if (scale <= 0) {
      throw const DocumentRenderException('scale must be positive');
    }
    // Bound scale to prevent enormous raster
    const minScale = 0.1;
    const maxScale = 4.0;
    final boundedScale = scale.clamp(minScale, maxScale).toDouble();

    _validateFile(document);
    await _ensureInitialized();

    pdfrx.PdfDocument? doc;
    try {
      doc = await pdfrx.PdfDocument.openFile(document.filePath);
      if (pageIndex >= doc.pages.length) {
        throw DocumentRenderException(
          'pageIndex $pageIndex out of range (0..${doc.pages.length - 1})',
        );
      }
      final page = doc.pages[pageIndex];
      // Use PDF points for dimensions; PDFium page width/height are in points (1/72 inch)
      final widthPoints = page.width;
      final heightPoints = page.height;

      // Validate dimensions
      if (widthPoints <= 0 || heightPoints <= 0) {
        throw DocumentRenderException(
          'invalid page dimensions: ${widthPoints}x$heightPoints',
        );
      }
      // Bound dimensions to PDF spec max 14400 points
      const maxDim = 14400.0;
      if (widthPoints > maxDim || heightPoints > maxDim) {
        throw DocumentRenderException(
          'page dimensions exceed PDF max: ${widthPoints}x$heightPoints',
        );
      }

      final renderWidthInt =
          (widthPoints * boundedScale).clamp(1, 4000).toInt();
      final renderHeightInt =
          (heightPoints * boundedScale).clamp(1, 4000).toInt();

      if (!includeImage) {
        return RenderedPage(
          pageIndex: pageIndex,
          width: renderWidthInt.toDouble(),
          height: renderHeightInt.toDouble(),
          imageBytes: null,
        );
      }

      final pageImage = await page.render(
        width: renderWidthInt,
        height: renderHeightInt,
      );
      if (pageImage == null) {
        throw const DocumentRenderException('failed to render page image');
      }
      try {
        // Convert PdfPageImage to image.Image then PNG
        final image = pageImage.createImageNF();
        // Bound image size: if image too large, downscale already bounded by 4000
        final pngBytes = Uint8List.fromList(img.encodePng(image));
        // Bound PNG bytes: 20 MB max
        const maxPngBytes = 20 * 1024 * 1024;
        if (pngBytes.length > maxPngBytes) {
          throw DocumentRenderException(
            'rendered image too large: ${pngBytes.length} > $maxPngBytes',
          );
        }
        return RenderedPage(
          pageIndex: pageIndex,
          width: renderWidthInt.toDouble(),
          height: renderHeightInt.toDouble(),
          imageBytes: pngBytes,
        );
      } finally {
        pageImage.dispose();
      }
    } catch (e) {
      if (e is DocumentRenderException) rethrow;
      throw DocumentRenderException('renderPage failed: $e', cause: e);
    } finally {
      doc?.dispose();
    }
  }

  @override
  Future<String> extractText(DocDrDocument document, int pageIndex) async {
    if (pageIndex < 0) {
      throw const DocumentRenderException('pageIndex must not be negative');
    }
    _validateFile(document);
    await _ensureInitialized();
    pdfrx.PdfDocument? doc;
    try {
      doc = await pdfrx.PdfDocument.openFile(document.filePath);
      if (pageIndex >= doc.pages.length) {
        throw DocumentRenderException(
          'pageIndex $pageIndex out of range (0..${doc.pages.length - 1})',
        );
      }
      final page = doc.pages[pageIndex];
      final text = await page.loadText();
      // text is PdfPageText — fullText may be nullable in newer API
      final all = text?.fullText ?? '';
      text?.dispose();
      return all;
    } catch (e) {
      if (e is DocumentRenderException) rethrow;
      throw DocumentRenderException('extractText failed: $e', cause: e);
    } finally {
      doc?.dispose();
    }
  }

  @override
  Future<void> dispose() async {
    // No persistent native resources held by adapter itself.
    // PdfDocument instances are disposed per call.
  }
}
