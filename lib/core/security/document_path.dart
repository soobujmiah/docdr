/// Centralized path validation for DocDr document and template assets.
///
/// ## Why this exists
///
/// RGEN audit finding **RGEN-02** (High) recorded that an imported template
/// could make the app read arbitrary files: `CustomTemplate.resolvePath()`
/// accepted absolute paths and concatenated any relative string, including
/// `..` segments. DocDr deliberately did **not** migrate `resolvePath()`.
///
/// This file is the replacement policy. It is the *single* place where a
/// path coming from untrusted document/template data is judged safe. Every
/// path-bearing field in the template model
/// ([backgroundPath], [previewPath], [fontPath], [assetPath]) is validated
/// through it during deserialization.
///
/// ## Contract
///
/// A valid asset path is a **relative, canonical, single-separator** path:
///
/// ```text
/// pages/bg-001.pdf        OK
/// fonts/bengali.ttf       OK
/// /etc/passwd             REJECTED (absolute)
/// ../../secrets.pdf       REJECTED (traversal)
/// C:\Windows\win.ini      REJECTED (drive + backslash)
/// file:///etc/passwd      REJECTED (URI scheme)
/// pages//bg.pdf           REJECTED (empty segment)
/// ```
///
/// An **empty** path is permitted and means "no asset" (for example a blank
/// page background). Every other rejected form throws
/// [UnsafeDocumentPathException].
///
/// The caller (storage/renderer layer) remains responsible for resolving the
/// validated relative path **inside** the template's own storage root. This
/// policy guarantees the path cannot point outside it; it does not decide
/// where that root is.
library;

/// Thrown when an untrusted document/template path escapes the permitted
/// storage boundary or is otherwise malformed.
class UnsafeDocumentPathException implements Exception {
  /// Creates an exception describing a rejected [path].
  ///
  /// [field] names the template field the path came from so an import failure
  /// can tell the user *which* field was rejected.
  const UnsafeDocumentPathException(
    this.path,
    this.reason, {
    this.field = 'unknown',
  });

  /// The rejected path, as supplied by untrusted data.
  final String path;

  /// Why the path was rejected.
  final String reason;

  /// Name of the template field the path came from.
  final String field;

  @override
  String toString() =>
      'UnsafeDocumentPathException: $reason '
      '(field: $field, path: <${path.length} chars>)';
}

/// Validates asset paths that originate from imported templates/documents.
///
/// This class is intentionally stateless and dependency-free so it can be
/// unit tested exhaustively and reused by any layer.
class DocumentPathPolicy {
  /// Creates a policy.
  ///
  /// [maxLength] bounds the length of a single path string.
  const DocumentPathPolicy({this.maxLength = 512});

  /// Maximum accepted path length in characters.
  final int maxLength;

  /// Returns `true` when [path] is a safe relative asset path.
  ///
  /// Returns `true` for the empty string ([allowEmpty] permitting), which
  /// means "no asset".
  bool isSafeRelativeAssetPath(
    String? path, {
    bool allowEmpty = true,
  }) {
    try {
      requireRelativeAssetPath(path, fieldName: 'path', allowEmpty: allowEmpty);
      return true;
    } on UnsafeDocumentPathException {
      return false;
    }
  }

  /// Validates [path] and returns it unchanged.
  ///
  /// Throws [UnsafeDocumentPathException] when the path is not a safe
  /// relative asset path. Use this at every deserialization boundary.
  ///
  /// [fieldName] identifies the template field in the thrown exception so an
  /// import failure can tell the user *which* field was rejected.
  String requireRelativeAssetPath(
    String? path, {
    required String fieldName,
    bool allowEmpty = true,
  }) {
    final value = path ?? '';

    if (value.isEmpty) {
      if (allowEmpty) {
        return value;
      }
      throw UnsafeDocumentPathException(
        value,
        'path must not be empty',
        field: fieldName,
      );
    }

    void reject(String reason) {
      throw UnsafeDocumentPathException(value, reason, field: fieldName);
    }

    if (value.length > maxLength) {
      reject('path exceeds maximum length of $maxLength characters');
    }

    // NUL truncates paths at the OS layer and is a classic validation bypass.
    if (value.contains('\u0000')) {
      reject('path contains a NUL byte');
    }

    // Backslash is a Windows separator; allowing it invites "..\" traversal.
    if (value.contains('\\')) {
      reject('path contains a backslash separator');
    }

    // Absolute paths (POSIX) and drive letters (Windows).
    if (value.startsWith('/') ||
        RegExp(r'^[A-Za-z]:').hasMatch(value)) {
      reject('path must be relative to the template storage root');
    }

    // URI schemes such as file:, content:, http: bypass the file system root.
    if (RegExp(r'^[A-Za-z][A-Za-z0-9+.\-]*:').hasMatch(value)) {
      reject('path must not contain a URI scheme');
    }

    // Defensive: reject percent-encoded traversal in case a later layer
    // decodes the path after validation.
    final lower = value.toLowerCase();
    if (lower.contains('%2e') || lower.contains('%2f') || lower.contains('%5c')) {
      reject('path contains percent-encoded traversal sequences');
    }

    final segments = value.split('/');
    for (final segment in segments) {
      if (segment.isEmpty) {
        reject('path contains an empty segment (// or trailing /)');
      }
      if (segment == '.' || segment == '..') {
        reject('path contains a traversal segment ("$segment")');
      }
      for (final unit in segment.codeUnits) {
        if (unit < 0x20 || unit == 0x7F) {
          reject('path contains a control character');
        }
      }
    }

    return value;
  }
}

/// Shared default policy instance.
///
/// Stateless and safe to reuse. Layers that need different limits can
/// construct their own [DocumentPathPolicy].
const DocumentPathPolicy documentPathPolicy = DocumentPathPolicy();
