import 'dart:io';

/// Small, UI-independent document-library operations used by Documents/Recent.
class DocDrDocumentLibraryService {
  const DocDrDocumentLibraryService();

  Future<List<File>> listDocuments(Directory root) async {
    if (!await root.exists()) return const [];
    final files = <File>[];
    await for (final entity in root.list(recursive: true, followLinks: false)) {
      if (entity is! File) continue;
      final ext = _extension(entity.path);
      if ({'pdf', 'png', 'jpg', 'jpeg', 'docx', 'xlsx', 'csv'}.contains(ext)) {
        files.add(entity);
      }
    }
    files.sort((a, b) => b.statSync().modified.compareTo(a.statSync().modified));
    return files;
  }

  String _extension(String path) {
    final name = path.split(Platform.pathSeparator).last.toLowerCase();
    final dot = name.lastIndexOf('.');
    return dot < 0 ? '' : name.substring(dot + 1);
  }
}
