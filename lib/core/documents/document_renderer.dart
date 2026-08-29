import 'document.dart';
import 'rendered_page.dart';

/// Thrown when a renderer cannot handle a document or page.
class DocumentRenderException implements Exception {
  const DocumentRenderException(this.message, {this.cause});
  final String message;
  final Object? cause;
  @override
  String toString() => 'DocumentRenderException: $message'
      '${cause != null ? ' (cause: $cause)' : ''}';
}

/// Capability set for a [DocumentRenderer].
///
/// Capability-oriented design per handoff section 13:
/// - Optional capabilities must be queryable.
/// - Missing optional capabilities should degrade gracefully.
/// - Swapping engines means implementing another adapter, not rewriting the app.
class RendererCapabilities {
  const RendererCapabilities({
    this.canRenderPdf = false,
    this.canRenderImage = false,
    this.canExtractText = false,
    this.canRenderAnnotations = false,
    this.supportsBengaliText = false,
    this.supportsPasswordProtected = false,
  });

  /// Whether the renderer can render PDF documents.
  final bool canRenderPdf;

  /// Whether the renderer can render image documents (PNG/JPG).
  final bool canRenderImage;

  /// Whether text extraction (for search/OCR assist) is supported.
  final bool canExtractText;

  /// Whether annotations/highlights are supported.
  final bool canRenderAnnotations;

  /// Whether Bengali text rendering has been verified for this engine.
  /// See handoff section 12: verify Bengali text rendering and fonts.
  final bool supportsBengaliText;

  /// Whether password-protected PDFs can be opened (with user-supplied password).
  final bool supportsPasswordProtected;

  @override
  String toString() =>
      'RendererCapabilities(pdf: $canRenderPdf, image: $canRenderImage, text: $canExtractText, annot: $canRenderAnnotations, bn: $supportsBengaliText, pwd: $supportsPasswordProtected)';
}

/// Abstract, vendor-neutral document renderer.
///
/// **Rules (handoff section 13):**
/// 1. No vendor types in domain models.
/// 2. No vendor types in UI signatures.
/// 3. Interface must be capability-oriented.
/// 4. Optional capabilities must be queryable.
/// 5. Missing optional capabilities should degrade gracefully.
/// 6. Swapping PDF engines should mean implementing another adapter, not rewriting the app.
/// 7. Licensing/attribution boundaries should remain isolated.
///
/// Implementations live in `lib/core/rendering/` — e.g.
/// `pdfium/pdfium_renderer_adapter.dart` for PDFium via `pdfrx`.
///
/// The renderer must never log document contents. See `docs/SECURITY_PRIVACY.md`.
abstract class DocumentRenderer {
  /// Human-readable name of the engine (e.g. 'pdfium', 'pdf', 'image').
  String get engineName;

  /// Capability set for this renderer.
  RendererCapabilities get capabilities;

  /// Returns true if [document] can be rendered by this renderer.
  ///
  /// This should check [document.source], file extension, and [capabilities]
  /// without opening the file if possible. It must not throw for unsupported
  /// documents — return false instead.
  bool canRender(DocDrDocument document);

  /// Returns the number of pages in [document].
  ///
  /// Throws [DocumentRenderException] if the document cannot be opened or
  /// is malformed. Must handle invalid/negative dimensions gracefully.
  Future<int> getPageCount(DocDrDocument document);

  /// Renders a single page.
  ///
  /// [pageIndex] is zero-based. [scale] is a logical scale factor (e.g. 1.0 =
  /// 100%, 2.0 = 200% for high-DPI). Implementations should bound memory —
  /// never load unlimited pages or enormous dimensions into RAM.
  ///
  /// If [includeImage] is false, the returned [RenderedPage] may contain only
  /// dimensions (imageBytes null) for layout purposes.
  ///
  /// Throws [DocumentRenderException] for invalid pageIndex, malformed
  /// documents, or when the engine is not available.
  Future<RenderedPage> renderPage(
    DocDrDocument document,
    int pageIndex, {
    double scale = 1.0,
    bool includeImage = true,
  });

  /// Optional: extracts text from a page for search/indexing.
  ///
  /// If [capabilities.canExtractText] is false, this should throw
  /// [DocumentRenderException] with a clear message rather than returning
  /// garbled data. Callers should check capabilities first and degrade
  /// gracefully.
  Future<String> extractText(DocDrDocument document, int pageIndex) {
    throw const DocumentRenderException(
      'text extraction not supported by this renderer',
    );
  }

  /// Closes any native resources held by the renderer.
  ///
  /// Renderers that hold no resources may implement this as a no-op.
  Future<void> dispose() async {}
}
