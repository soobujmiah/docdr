class DocDrReaderState {
  final int pageIndex;
  final int pageCount;
  final double zoom;
  final bool fitWidth;

  const DocDrReaderState({
    this.pageIndex = 0,
    this.pageCount = 0,
    this.zoom = 1,
    this.fitWidth = true,
  });

  DocDrReaderState copyWith({
    int? pageIndex,
    int? pageCount,
    double? zoom,
    bool? fitWidth,
  }) => DocDrReaderState(
        pageIndex: pageIndex ?? this.pageIndex,
        pageCount: pageCount ?? this.pageCount,
        zoom: zoom ?? this.zoom,
        fitWidth: fitWidth ?? this.fitWidth,
      );

  DocDrReaderState nextPage() => copyWith(
        pageIndex: pageIndex < pageCount - 1 ? pageIndex + 1 : pageIndex,
      );

  DocDrReaderState previousPage() => copyWith(
        pageIndex: pageIndex > 0 ? pageIndex - 1 : 0,
      );
}
