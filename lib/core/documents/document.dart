import '../security/document_path.dart';

/// Source/type of a document managed by DocDr.
///
/// Mirrors the contract in `docs/DATA_MODEL.md` — Document represents an
/// imported, scanned, generated, or otherwise managed document.
enum DocDrDocumentSource {
  /// Imported from PDF, image, or other supported file.
  imported,

  /// Created via camera scanner (multi-page scan).
  scanned,

  /// Generated from a reusable template + structured data.
  generated,

  /// Blank document created inside the app.
  blank,

  /// Unknown or legacy source — preserved for forward compatibility.
  unknown,
}

/// Thrown when a document declares invalid metadata.
class DocumentValidationException implements Exception {
  const DocumentValidationException(this.message);
  final String message;
  @override
  String toString() => 'DocumentValidationException: $message';
}

/// Represents a user-owned document in DocDr.
///
/// This is the **domain** model — it contains no PDF-engine types, no Flutter
/// widget types, and no platform-specific types. It is the single source of
/// truth for document identity and metadata; rendering is delegated to
/// [DocumentRenderer] implementations via adapters.
///
/// Privacy: document contents, file paths, and template IDs are user data and
/// must never be logged verbatim. See `docs/SECURITY_PRIVACY.md`.
class DocDrDocument {
  /// Creates a document.
  ///
  /// [id] must be stable and non-empty (e.g. timestamp + random hex, as used
  /// by `TemplateStore`).
  /// [name] is user-visible and must be non-empty.
  /// [filePath] is a local file reference — validated for traversal, null
  /// bytes, and empty segments via [DocumentPathPolicy] when relative, and
  /// checked for obvious escapes when absolute.
  /// [pageCount] is optional at creation time and may be populated after the
  /// renderer inspects the file.
  DocDrDocument({
    required this.id,
    required this.name,
    required this.source,
    required this.filePath,
    required this.createdAt,
    required this.updatedAt,
    this.pageCount,
    this.ocrTextIndexPath = '',
    this.originatingTemplateId = '',
  }) {
    if (id.trim().isEmpty) {
      throw const DocumentValidationException('id must not be empty');
    }
    if (name.trim().isEmpty) {
      throw const DocumentValidationException('name must not be empty');
    }
    if (filePath.trim().isEmpty) {
      throw const DocumentValidationException('filePath must not be empty');
    }
    // Reuse the centralized path policy for relative paths; for absolute
    // paths, apply a minimal safety check (no null bytes, no traversal).
    if (filePath.startsWith('/')) {
      _validateAbsolutePath(filePath);
    } else {
      // Relative asset-style path — must pass the strict policy.
      // Empty is not allowed here because filePath is required.
      documentPathPolicy.requireRelativeAssetPath(
        filePath,
        fieldName: 'filePath',
        allowEmpty: false,
      );
    }
    if (ocrTextIndexPath.isNotEmpty) {
      if (ocrTextIndexPath.startsWith('/')) {
        _validateAbsolutePath(ocrTextIndexPath);
      } else {
        documentPathPolicy.requireRelativeAssetPath(
          ocrTextIndexPath,
          fieldName: 'ocrTextIndexPath',
          allowEmpty: true,
        );
      }
    }
    if (originatingTemplateId.isNotEmpty && originatingTemplateId.length > 256) {
      throw const DocumentValidationException(
        'originatingTemplateId exceeds 256 characters',
      );
    }
    if (pageCount != null && pageCount! < 0) {
      throw const DocumentValidationException('pageCount must not be negative');
    }
  }

  /// Stable local ID — e.g. timestamp + random hex.
  final String id;

  /// User-visible display name.
  final String name;

  /// How the document was created.
  final DocDrDocumentSource source;

  /// Local file reference — relative to app documents root or absolute inside
  /// sandbox. Validated at construction.
  final String filePath;

  /// Number of pages where known, null if not yet inspected.
  final int? pageCount;

  /// When the document was first created.
  final DateTime createdAt;

  /// When the document was last updated.
  final DateTime updatedAt;

  /// Optional OCR/text index reference — may be relative or absolute.
  final String ocrTextIndexPath;

  /// Optional originating template ID if this document was generated from a
  /// reusable template.
  final String originatingTemplateId;

  /// Creates a copy with updated fields.
  DocDrDocument copyWith({
    String? name,
    DocDrDocumentSource? source,
    String? filePath,
    int? pageCount,
    DateTime? updatedAt,
    String? ocrTextIndexPath,
    String? originatingTemplateId,
  }) {
    return DocDrDocument(
      id: id,
      name: name ?? this.name,
      source: source ?? this.source,
      filePath: filePath ?? this.filePath,
      pageCount: pageCount ?? this.pageCount,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      ocrTextIndexPath: ocrTextIndexPath ?? this.ocrTextIndexPath,
      originatingTemplateId:
          originatingTemplateId ?? this.originatingTemplateId,
    );
  }

  /// Minimal safety check for absolute paths.
  ///
  /// Absolute paths are allowed only inside the app sandbox, but this domain
  /// layer cannot know the sandbox root. It enforces only that the path does
  /// not contain null bytes, backslashes, traversal segments, or empty
  /// segments — the storage layer must still enforce containment.
  static void _validateAbsolutePath(String path) {
    if (path.contains('\u0000')) {
      throw DocumentValidationException(
        'absolute path contains NUL byte: $path',
      );
    }
    if (path.contains('\\')) {
      throw const DocumentValidationException(
        'absolute path contains backslash',
      );
    }
    if (path.contains('//')) {
      throw const DocumentValidationException(
        'absolute path contains empty segment //',
      );
    }
    final segments = path.split('/');
    for (final segment in segments) {
      if (segment == '..') {
        throw const DocumentValidationException(
          'absolute path contains traversal ..',
        );
      }
    }
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DocDrDocument &&
        other.id == id &&
        other.name == name &&
        other.source == source &&
        other.filePath == filePath &&
        other.pageCount == pageCount &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt &&
        other.ocrTextIndexPath == ocrTextIndexPath &&
        other.originatingTemplateId == originatingTemplateId;
  }

  @override
  int get hashCode => Object.hash(
        id,
        name,
        source,
        filePath,
        pageCount,
        createdAt,
        updatedAt,
        ocrTextIndexPath,
        originatingTemplateId,
      );

  @override
  String toString() =>
      'DocDrDocument(id: $id, name: $name, source: $source, pages: $pageCount)';
}
