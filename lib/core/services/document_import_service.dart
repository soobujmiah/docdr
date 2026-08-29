import 'dart:io';

/// Describes an imported document without coupling the core to a UI.
class DocDrImportedDocument {
  final File file;
  final String type;
  final int sizeBytes;

  const DocDrImportedDocument({
    required this.file,
    required this.type,
    required this.sizeBytes,
  });
}

/// Validates and classifies documents before they enter the reader/editor.
class DocDrDocumentImportService {
  static const _extensions = {'pdf', 'png', 'jpg', 'jpeg'};

  Future<DocDrImportedDocument> importFile(File file) async {
    if (!await file.exists()) {
      throw const FileSystemException('Document does not exist');
    }
    final extension = _extension(file.path);
    if (!_extensions.contains(extension)) {
      throw UnsupportedError('Unsupported document type: .$extension');
    }
    final size = await file.length();
    if (size == 0) {
      throw const FileSystemException('Document is empty');
    }
    return DocDrImportedDocument(
      file: file,
      type: extension == 'jpg' || extension == 'jpeg' ? 'image' : extension,
      sizeBytes: size,
    );
  }

  String _extension(String path) {
    final name = path.split(Platform.pathSeparator).last.toLowerCase();
    final index = name.lastIndexOf('.');
    return index < 0 ? '' : name.substring(index + 1);
  }
}
