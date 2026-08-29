import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import '../models/custom_template.dart';
import '../security/document_path.dart';
import '../services/clock.dart';

/// Name of the manifest inside every template directory.
const String templateManifestName = 'template.json';

/// Resource limits enforced by [DocDrTemplateStore].
///
/// These exist because RGEN finding **RGEN-04** recorded that imported
/// template complexity was entirely unbounded, and **RGEN-03** recorded that
/// batch generation held every rendered PDF in memory. Bounding what is
/// written into a template is the cheapest place to start.
class TemplateStoreLimits {
  /// Creates a limits set.
  const TemplateStoreLimits({
    this.maxAssetBytes = 32 * 1024 * 1024,
    this.maxPages = 500,
    this.maxElementsPerPage = 2000,
    this.maxManifestBytes = 8 * 1024 * 1024,
  });

  /// Largest single asset that may be imported into a template.
  final int maxAssetBytes;

  /// Largest number of pages a template may contain.
  final int maxPages;

  /// Largest number of elements a single page may contain.
  final int maxElementsPerPage;

  /// Largest serialized manifest that may be written or read.
  final int maxManifestBytes;
}

/// Raised when a template storage operation fails.
class TemplateStoreException implements Exception {
  /// Creates a storage exception with a human-readable [message].
  const TemplateStoreException(this.message);

  /// Why the operation failed.
  final String message;

  @override
  String toString() => 'TemplateStoreException: $message';
}

/// Offline, on-device storage for DocDr templates.
///
/// ## Design notes
///
/// A template is a **self-contained directory**: one manifest plus its
/// backgrounds, previews, fonts and images. That keeps export/import lossless
/// and never mutates the user's source documents.
///
/// **No third-party dependencies.** The RGEN equivalent depended on
/// `archive`, `cryptography`, `image`, `printing`, `path_provider` and
/// Syncfusion Flutter PDF. Every one of those is still behind the licensing
/// gate in `THIRD_PARTY_NOTICES.md`, so this implementation uses only
/// `dart:io`. Consequences:
///
/// - Portable `.docdr` ZIP packages and password protection are **deferred**
///   to the slice that clears the `archive` and `cryptography` licences.
///   `duplicate()` therefore copies the directory tree directly instead of
///   round-tripping through a ZIP.
/// - The store receives its [root] directory from the caller rather than
///   resolving it via `path_provider`. The application layer supplies
///   `getApplicationDocumentsDirectory()/docdr/templates`; keeping that out of
///   the core makes the store testable on a plain Dart VM.
///
/// ## Security contract (closes the storage half of DOC-05)
///
/// Every path that comes from template data is already validated as a relative
/// asset path by [DocumentPathPolicy] during deserialization. [resolveAssetPath]
/// applies a second, independent check: the resolved absolute path must remain
/// inside the template directory, and no path component may escape it through a
/// symbolic link. `basePath` is likewise required to sit inside [root].
class DocDrTemplateStore {
  /// Creates a store rooted at [root].
  DocDrTemplateStore({
    required this.root,
    this.limits = const TemplateStoreLimits(),
    DocumentClock? clock,
  }) : _clock = clock ?? docDrClock;

  /// Directory that contains one sub-directory per template.
  final Directory root;

  /// Limits enforced on read and write.
  final TemplateStoreLimits limits;

  /// Returns the root, creating it if necessary.
  Future<Directory> ensureRoot() => root.create(recursive: true);

  final DocumentClock _clock;
  static final Random _random = Random.secure();

  /// Generates a collision-resistant template identifier.
  String newId() =>
      '${_clock.now().millisecondsSinceEpoch}_'
      '${_random.nextInt(0xFFFFFF).toRadixString(16).padLeft(6, '0')}';

  /// Lists every readable template, most recently updated first.
  ///
  /// A damaged template is skipped rather than propagated: one broken package
  /// must never hide the user's other templates.
  Future<List<DocDrTemplate>> listTemplates() async {
    final dir = await ensureRoot();
    final templates = <DocDrTemplate>[];
    await for (final entity in dir.list(followLinks: false)) {
      if (entity is! Directory) {
        continue;
      }
      final manifest = File('${entity.path}/$templateManifestName');
      if (!await manifest.exists()) {
        continue;
      }
      try {
        final template = _decodeManifest(await manifest.readAsString());
        template.basePath = entity.path;
        templates.add(template);
      } on Object {
        // Intentionally swallowed - see the note above.
      }
    }
    templates.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return templates;
  }

  /// Loads a template by id.
  ///
  /// Throws [TemplateStoreException] when the template does not exist.
  Future<DocDrTemplate> load(String id) async {
    final template = await tryLoad(id);
    if (template == null) {
      throw TemplateStoreException('no template with id "$id"');
    }
    return template;
  }

  /// Loads a template by id, returning `null` when it does not exist.
  Future<DocDrTemplate?> tryLoad(String id) async {
    final dir = await ensureRoot();
    final base = '${dir.path}/$id';
    final manifest = File('$base/$templateManifestName');
    if (!await manifest.exists()) {
      return null;
    }
    final template = _decodeManifest(await manifest.readAsString());
    template.basePath = base;
    return template;
  }

  /// Writes [template] to disk and returns it with `basePath` set.
  ///
  /// [now] fixes `updatedAt`; pass it to keep output reproducible.
  Future<DocDrTemplate> save(DocDrTemplate template, {DateTime? now}) async {
    _validateComplexity(template);
    final base = _baseFor(template);
    await Directory(base).create(recursive: true);

    template.basePath = base;
    template.updatedAt = now ?? _clock.now();

    final json = JsonEncoder.withIndent('  ').convert(template.toJson());
    if (json.length > limits.maxManifestBytes) {
      throw TemplateStoreException(
        'manifest is ${json.length} bytes, exceeding the '
        '${limits.maxManifestBytes} byte limit',
      );
    }
    await File('$base/$templateManifestName').writeAsString(json);
    return template;
  }

  /// Creates and saves a blank A4 template with one empty page.
  Future<DocDrTemplate> createBlank(
    String name, {
    double widthPoints = DocDrPage.defaultWidthPoints,
    double heightPoints = DocDrPage.defaultHeightPoints,
    DateTime? now,
  }) async {
    final stamp = now ?? _clock.now();
    final template = DocDrTemplate(
      id: newId(),
      name: name.trim().isEmpty ? 'Blank template' : name.trim(),
      createdAt: stamp,
      updatedAt: stamp,
      pages: <DocDrPage>[
        DocDrPage(
          id: 'page_1',
          backgroundType: DocDrBackgroundType.blank,
          widthPoints: widthPoints,
          heightPoints: heightPoints,
        ),
      ],
    );
    return save(template, now: stamp);
  }

  /// Copies an asset into [template] and returns its template-relative path.
  ///
  /// The file name is sanitized to `[A-Za-z0-9._-]` so a hostile source name
  /// cannot introduce separators or traversal segments.
  Future<String> importAsset(
    DocDrTemplate template,
    String sourcePath, {
    String folder = 'assets',
  }) async {
    final source = File(sourcePath);
    if (!await source.exists()) {
      throw TemplateStoreException('asset not found: $sourcePath');
    }
    final length = await source.length();
    if (length > limits.maxAssetBytes) {
      throw TemplateStoreException(
        'asset is $length bytes, exceeding the ${limits.maxAssetBytes} byte limit',
      );
    }
    final base = _baseFor(template);
    final relative = '$folder/${_stamp()}_${_safeName(sourcePath)}';
    final target = File('$base/$relative');
    await target.parent.create(recursive: true);
    await source.copy(target.path);
    return relative;
  }

  /// Reads the bytes of a template-relative asset.
  ///
  /// The path is resolved through [resolveAssetPath], so it cannot read
  /// outside the template directory.
  Future<Uint8List> readAsset(
    DocDrTemplate template,
    String relativePath,
  ) async {
    // Marked async so a rejected path surfaces as a failed Future rather than
    // a synchronous throw, which callers using await would not expect.
    return File(resolveAssetPath(template, relativePath)).readAsBytes();
  }

  /// Resolves a template-relative asset path to an absolute path, refusing
  /// anything that escapes the template directory.
  ///
  /// Two independent defences:
  /// 1. [DocumentPathPolicy] guarantees the path is relative, canonical and
  ///    free of `..`, drive letters, URI schemes and NUL bytes.
  /// 2. Every resolved component is checked for containment, including through
  ///    symbolic links, and the result must lie strictly inside the template
  ///    directory.
  String resolveAssetPath(DocDrTemplate template, String relativePath) {
    final validated = documentPathPolicy.requireRelativeAssetPath(
      relativePath,
      fieldName: 'template asset',
      allowEmpty: false,
    );
    final baseAbs = Directory(_baseFor(template)).absolute.path;
    String current = baseAbs;

    for (final segment in validated.split('/')) {
      final next = '$current${Platform.pathSeparator}$segment';
      if (FileSystemEntity.isLinkSync(next)) {
        final resolved = Link(next).resolveSymbolicLinksSync();
        if (!_isContained(baseAbs, resolved)) {
          throw UnsafeDocumentPathException(
            relativePath,
            'asset path escapes the template directory through a symbolic link',
            field: 'template asset',
          );
        }
      }
      current = next;
    }

    if (!_isContained(baseAbs, current)) {
      throw UnsafeDocumentPathException(
        relativePath,
        'asset path escapes the template directory',
        field: 'template asset',
      );
    }
    return current;
  }

  /// Deletes a template directory and everything inside it.
  Future<void> delete(DocDrTemplate template) async {
    final dir = Directory(_baseFor(template));
    if (await dir.exists()) {
      await dir.delete(recursive: true);
    }
  }

  /// Copies a template, its manifest and all of its assets to a new id.
  ///
  /// Implemented as a directory copy rather than the RGEN export/import round
  /// trip, because portable ZIP packages depend on the not-yet-cleared
  /// `archive` package.
  Future<DocDrTemplate> duplicate(
    DocDrTemplate template, {
    String? name,
    DateTime? now,
  }) async {
    final stamp = now ?? _clock.now();
    final source = Directory(_baseFor(template));
    final target = '${(await ensureRoot()).path}/${newId()}';
    await Directory(target).create(recursive: true);

    await for (final entity in source.list(recursive: true, followLinks: false)) {
      if (entity is! File) {
        continue;
      }
      final relative = entity.path.substring(source.path.length + 1);
      final destination = File('$target/$relative');
      await destination.parent.create(recursive: true);
      await entity.copy(destination.path);
    }

    final manifest = File('$target/$templateManifestName');
    final copy = _decodeManifest(await manifest.readAsString());
    copy.id = target.split(Platform.pathSeparator).last;
    copy.name = name ?? '${template.name} Copy';
    copy.createdAt = stamp;
    return save(copy, now: stamp);
  }

  // ---------------------------------------------------------------- internals

  /// Directory for [template], ensuring it lies inside [root].
  String _baseFor(DocDrTemplate template) {
    final candidate = template.basePath.isEmpty
        ? '${root.path}/${template.id}'
        : template.basePath;
    final rootAbs = Directory(root.path).absolute.path;
    final candidateAbs = Directory(candidate).absolute.path;
    if (!_isContained(rootAbs, candidateAbs) && candidateAbs != rootAbs) {
      throw TemplateStoreException(
        'template directory lies outside the store root: $candidate',
      );
    }
    return candidate;
  }

  DocDrTemplate _decodeManifest(String raw) {
    if (raw.length > limits.maxManifestBytes) {
      throw TemplateStoreException(
        'manifest is ${raw.length} bytes, exceeding the '
        '${limits.maxManifestBytes} byte limit',
      );
    }
    final decoded = jsonDecode(raw);
    if (decoded is! Map) {
      throw TemplateStoreException('manifest is not a JSON object');
    }
    return DocDrTemplate.fromJson(Map<String, dynamic>.from(decoded));
  }

  void _validateComplexity(DocDrTemplate template) {
    if (template.pages.length > limits.maxPages) {
      throw TemplateStoreException(
        'template has ${template.pages.length} pages, exceeding the '
        '${limits.maxPages} page limit',
      );
    }
    for (final page in template.pages) {
      if (page.elements.length > limits.maxElementsPerPage) {
        throw TemplateStoreException(
          'page "${page.id}" has ${page.elements.length} elements, exceeding '
          'the ${limits.maxElementsPerPage} element limit',
        );
      }
    }
  }

  String _stamp() => _clock.now().microsecondsSinceEpoch.toString();

  static String _safeName(String value) {
    final last = value.split(Platform.pathSeparator).last;
    var cleaned = last.replaceAll(RegExp(r'[^A-Za-z0-9._-]'), '_');
    if (cleaned.length > 120) {
      cleaned = cleaned.substring(cleaned.length - 120);
    }
    // Never let a sanitized name begin with a dot: a leading "." turns an
    // otherwise harmless filename into a hidden or traversal-shaped entry.
    cleaned = cleaned.replaceFirst(RegExp(r'^\.+'), '');
    return cleaned.isEmpty ? 'asset' : cleaned;
  }

  static bool _isContained(String baseAbs, String targetAbs) {
    final base = _normalize(baseAbs);
    final target = _normalize(targetAbs);
    if (target == base) {
      return false;
    }
    final prefix = base.endsWith('/') ? base : '$base/';
    return target.startsWith(prefix);
  }

  /// Lexically normalizes a path, collapsing `.` and `..`.
  static String _normalize(String path) {
    final absolute = path.startsWith('/');
    final segments = <String>[];
    for (final segment in path.replaceAll('\\', '/').split('/')) {
      if (segment.isEmpty || segment == '.') {
        continue;
      }
      if (segment == '..') {
        if (segments.isNotEmpty) {
          segments.removeLast();
        }
        continue;
      }
      segments.add(segment);
    }
    return '${absolute ? '/' : ''}${segments.join('/')}';
  }
}
