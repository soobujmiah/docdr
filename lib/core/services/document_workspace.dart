import 'dart:io';

import '../models/reader_state.dart';
import 'document_import_service.dart';

/// Coordinates imported documents and reader state without depending on UI.
class DocDrDocumentWorkspace {
  final DocDrDocumentImportService importer;
  DocDrReaderState readerState;

  DocDrImportedDocument? current;

  DocDrDocumentWorkspace({
    DocDrDocumentImportService? importer,
    this.readerState = const DocDrReaderState(),
  }) : importer = importer ?? DocDrDocumentImportService();

  Future<DocDrImportedDocument> open(File file) async {
    current = await importer.importFile(file);
    readerState = readerState.copyWith(pageIndex: 0);
    return current!;
  }

  void setPageCount(int count) {
    readerState = readerState.copyWith(
      pageCount: count < 0 ? 0 : count,
      pageIndex: 0,
    );
  }

  void nextPage() => readerState = readerState.nextPage();
  void previousPage() => readerState = readerState.previousPage();

  void setZoom(double zoom) {
    readerState = readerState.copyWith(zoom: zoom.clamp(0.25, 8.0));
  }

  void fitWidth() {
    readerState = readerState.copyWith(fitWidth: true);
  }
}
