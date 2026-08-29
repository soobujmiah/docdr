/// Persistent-independent state for the document editor viewport.
class DocumentViewState {
  final double zoom;
  final double panX;
  final double panY;
  final int rotationQuarterTurns;
  final bool flipHorizontal;
  final bool flipVertical;

  const DocumentViewState({
    this.zoom = 1.0,
    this.panX = 0,
    this.panY = 0,
    this.rotationQuarterTurns = 0,
    this.flipHorizontal = false,
    this.flipVertical = false,
  });

  DocumentViewState copyWith({
    double? zoom,
    double? panX,
    double? panY,
    int? rotationQuarterTurns,
    bool? flipHorizontal,
    bool? flipVertical,
  }) {
    return DocumentViewState(
      zoom: zoom ?? this.zoom,
      panX: panX ?? this.panX,
      panY: panY ?? this.panY,
      rotationQuarterTurns: rotationQuarterTurns ?? this.rotationQuarterTurns,
      flipHorizontal: flipHorizontal ?? this.flipHorizontal,
      flipVertical: flipVertical ?? this.flipVertical,
    );
  }

  DocumentViewState zoomBy(double factor) => copyWith(
        zoom: (zoom * factor).clamp(0.25, 8.0),
      );

  DocumentViewState rotateClockwise() => copyWith(
        rotationQuarterTurns: (rotationQuarterTurns + 1) % 4,
      );

  DocumentViewState rotateCounterClockwise() => copyWith(
        rotationQuarterTurns: (rotationQuarterTurns + 3) % 4,
      );

  DocumentViewState toggleFlipHorizontal() => copyWith(
        flipHorizontal: !flipHorizontal,
      );

  DocumentViewState toggleFlipVertical() => copyWith(
        flipVertical: !flipVertical,
      );

  DocumentViewState resetViewport() => const DocumentViewState();
}
