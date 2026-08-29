import 'dart:io';

class DocDrScanResult {
  final List<File> pages;
  const DocDrScanResult(this.pages);
}

abstract interface class DocDrScannerService {
  Future<DocDrScanResult> scan();
}

/// Keeps camera/scanner SDK details outside the document core.
class UnsupportedDocDrScannerService implements DocDrScannerService {
  const UnsupportedDocDrScannerService();

  @override
  Future<DocDrScanResult> scan() =>
      Future.error(UnsupportedError('No scanner implementation is configured for this platform'));
}
