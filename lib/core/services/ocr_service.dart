import 'dart:io';

class DocDrOcrResult {
  final String text;
  final double confidence;
  final String language;

  const DocDrOcrResult({required this.text, required this.confidence, required this.language});
}

abstract interface class DocDrOcrService {
  Future<DocDrOcrResult> recognize(File image, {String language = 'auto'});
}

/// Platform-neutral OCR boundary. Native OCR engines can implement this
/// without coupling the document core to a particular vendor or SDK.
class UnsupportedDocDrOcrService implements DocDrOcrService {
  const UnsupportedDocDrOcrService();

  @override
  Future<DocDrOcrResult> recognize(File image, {String language = 'auto'}) {
    return Future.error(UnsupportedError('No OCR engine is configured for this platform'));
  }
}
