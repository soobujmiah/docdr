import '../../documents/document.dart';
import '../../documents/document_renderer.dart';
import '../../documents/rendered_page.dart';

/// PDFium-based renderer adapter — **stub, no PDF engine bundled yet**.
///
/// This file establishes the vendor-neutral boundary required by handoff
/// section 13:
///
/// ```
/// DocDr Domain Document
///         ↓
/// DocumentRenderer
///         ↓
/// PdfRendererAdapter
///         ↓
/// Selected PDF Engine (PDFium via pdfrx)
/// ```
///
/// **Licensing gate (handoff section 11 & 12):**
/// - Preferred reader/rendering engine: PDFium via `pdfrx`
/// - Preferred generation engine: `pdf` package
/// - Neither dependency is added until:
///   1. exact licence verified
///   2. transitive deps inspected (no GPL/AGPL)
///   3. NOTICE requirements recorded in THIRD_PARTY_NOTICES.md
///   4. Bengali text rendering verified
///   5. font handling verified
///   6. golden tests established
///
/// This stub implements [DocumentRenderer] but throws [DocumentRenderException]
/// for all operations until the dependency is cleared. This allows the rest
/// of the app (workspace, reader UI, data model) to be built and tested
/// against the interface without bundling an unverified engine.
///
/// When the licence is cleared:
/// 1. Add `pdfrx` to pubspec.yaml after recording it in THIRD_PARTY_NOTICES.md
/// 2. Implement `canRender`, `getPageCount`, `renderPage` using PDFium APIs
/// 3. Keep all `pdfrx` types **inside this file** — never leak them to domain
///    or UI layers.
/// 4. Add Bengali fixture tests (see docs/PRODUCT_BACKLOG.md)
/// 5. Add golden tests for rendering
class PdfiumRendererAdapter implements DocumentRenderer {
  /// Creates a PDFium renderer adapter.
  ///
  /// [enableBengaliCheck] is reserved for future font/Bengali verification.
  const PdfiumRendererAdapter({this.enableBengaliCheck = false});

  /// Whether Bengali verification mode is enabled (future use).
  final bool enableBengaliCheck;

  @override
  String get engineName => 'pdfium-stub';

  @override
  RendererCapabilities get capabilities => const RendererCapabilities(
        canRenderPdf: false, // false until pdfrx is bundled and verified
        canRenderImage: false,
        canExtractText: false,
        canRenderAnnotations: false,
        supportsBengaliText: false, // must be verified per handoff section 12
        supportsPasswordProtected: false,
      );

  @override
  bool canRender(DocDrDocument document) {
    // Stub: no engine, so cannot render anything yet.
    // Real implementation will check extension .pdf and capabilities.
    // Must not throw — return false for graceful degradation.
    final lower = document.filePath.toLowerCase();
    if (lower.endsWith('.pdf')) {
      // Even for PDFs, return false until engine is verified and bundled.
      return false;
    }
    return false;
  }

  @override
  Future<int> getPageCount(DocDrDocument document) async {
    throw const DocumentRenderException(
      'PDFium engine not bundled — licence gate open. '
      'See THIRD_PARTY_NOTICES.md and handoff section 12.',
    );
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
    throw const DocumentRenderException(
      'PDFium engine not bundled — licence gate open. '
      'See THIRD_PARTY_NOTICES.md and handoff section 12.',
    );
  }

  @override
  Future<String> extractText(DocDrDocument document, int pageIndex) async {
    throw const DocumentRenderException(
      'text extraction not supported — PDFium stub, no engine bundled',
    );
  }

  @override
  Future<void> dispose() async {
    // No native resources in stub.
  }
}
