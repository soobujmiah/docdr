import 'dart:typed_data';

/// A rendered representation of a single document page.
///
/// This is a **domain** type — it contains no PDF-engine types. The renderer
/// adapter is responsible for producing this from a vendor-specific page
/// object. UI layers may display [imageBytes] or use [width]/[height] for
/// layout.
///
/// Design notes per handoff section 13:
/// - No vendor types in domain models.
/// - Capability-oriented, graceful degradation.
/// - Bounded memory: [imageBytes] may be null if the caller requested
///   dimensions only, or if the renderer is configured for streaming.
class RenderedPage {
  /// Creates a rendered page.
  ///
  /// [pageIndex] is zero-based.
  /// [width] and [height] are in logical pixels or PDF points depending on
  /// the renderer's contract — documented by the adapter.
  /// [imageBytes] is optional raster data (e.g. PNG) for immediate display.
  const RenderedPage({
    required this.pageIndex,
    required this.width,
    required this.height,
    this.imageBytes,
  }) : assert(pageIndex >= 0, 'pageIndex must not be negative'),
       assert(width > 0, 'width must be positive'),
       assert(height > 0, 'height must be positive');

  /// Zero-based page index.
  final int pageIndex;

  /// Rendered width.
  final double width;

  /// Rendered height.
  final double height;

  /// Optional raster bytes for the page (e.g. PNG). Null means dimensions-only
  /// or streaming mode.
  final Uint8List? imageBytes;

  /// Whether this page carries raster data.
  bool get hasImage => imageBytes != null && imageBytes!.isNotEmpty;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is RenderedPage &&
        other.pageIndex == pageIndex &&
        other.width == width &&
        other.height == height &&
        other.imageBytes == imageBytes;
  }

  @override
  int get hashCode => Object.hash(pageIndex, width, height, imageBytes);

  @override
  String toString() =>
      'RenderedPage(index: $pageIndex, ${width.toStringAsFixed(1)}x${height.toStringAsFixed(1)}, hasImage: $hasImage)';
}
