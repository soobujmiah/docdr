import 'dart:math' as math;

import '../security/document_path.dart';
import '../services/clock.dart';

/// Schema version written by this build of DocDr.
///
/// Shared with the RGEN schema it was migrated from, so v2 documents produced
/// by RGEN remain readable. See `_readSchemaVersion` for the accept/reject
/// rules.
const int currentTemplateSchemaVersion = 2;

/// Schema versions this build reads directly, with no migration step.
const Set<int> supportedTemplateSchemaVersions = <int>{2};

/// Older schema versions that have a deterministic migration into
/// [currentTemplateSchemaVersion].
///
/// Empty today: no pre-v2 template schema is known to have been published, so
/// there is nothing to migrate. UNKNOWN is recorded honestly here rather than
/// inventing a v1 migration. When a v1 surface is ever discovered, add it to
/// this set and implement the migration in `_migrateSchema`.
const Set<int> migratableTemplateSchemaVersions = <int>{};

/// Smallest accepted page dimension, in PDF points (1 inch).
const double minPageDimensionPoints = 72.0;

/// Largest accepted page dimension, in PDF points (200 inches).
///
/// 14400 is the PDF specification's maximum page dimension; values beyond it
/// cannot be represented in a valid PDF document.
const double maxPageDimensionPoints = 14400.0;

/// Thrown when a template declares an unsupported or unreadable
/// `schemaVersion`.
class TemplateSchemaException implements Exception {
  /// Creates a schema exception with a human-readable [message].
  const TemplateSchemaException(this.message);

  /// Why the schema was rejected.
  final String message;

  @override
  String toString() => 'TemplateSchemaException: $message';
}

/// Thrown when a template contains structurally invalid geometry or values
/// that cannot be safely clamped.
class TemplateValidationException implements Exception {
  /// Creates a validation exception with a human-readable [message].
  const TemplateValidationException(this.message);

  /// Why the value was rejected.
  final String message;

  @override
  String toString() => 'TemplateValidationException: $message';
}

/// Element categories supported by the DocDr template canvas.
///
/// Mirrors the proven RGEN element set. Order is part of the serialized
/// contract (values are persisted by name, not index).
enum DocDrElementType {
  text,
  multilineText,
  date,
  serial,
  image,
  photo,
  signature,
  checkbox,
  qrCode,
  barcode,
  line,
  rectangle,
  ellipse,
}

/// What a page draws behind its elements.
enum DocDrBackgroundType { pdf, image, blank }

/// Horizontal text alignment inside an element box.
enum DocDrTextAlignment { left, center, right, justify }

/// Capability helpers for [DocDrElementType].
extension DocDrElementTypeX on DocDrElementType {
  /// Whether the element can carry a data key.
  bool get acceptsData => !{
        DocDrElementType.line,
        DocDrElementType.rectangle,
        DocDrElementType.ellipse,
      }.contains(this);

  /// Whether the element renders text.
  bool get isTextLike => {
        DocDrElementType.text,
        DocDrElementType.multilineText,
        DocDrElementType.date,
        DocDrElementType.serial,
      }.contains(this);

  /// Whether the element renders raster content.
  bool get isImageLike => {
        DocDrElementType.image,
        DocDrElementType.photo,
        DocDrElementType.signature,
      }.contains(this);

  /// Default English label for the element type.
  ///
  /// Restored from RGEN's migration baseline: the condensed DocDr model had
  /// dropped this, and with it the editor's default field naming. It is
  /// generic product vocabulary, not office-specific content, so it satisfies
  /// the clean-room rule in README.md.
  String get label => switch (this) {
        DocDrElementType.text => 'Text',
        DocDrElementType.multilineText => 'Multi-line text',
        DocDrElementType.date => 'Date',
        DocDrElementType.serial => 'Serial number',
        DocDrElementType.image => 'Image / logo',
        DocDrElementType.photo => 'Photo',
        DocDrElementType.signature => 'Signature / stamp',
        DocDrElementType.checkbox => 'Checkbox',
        DocDrElementType.qrCode => 'QR code',
        DocDrElementType.barcode => 'Barcode',
        DocDrElementType.line => 'Line',
        DocDrElementType.rectangle => 'Rectangle',
        DocDrElementType.ellipse => 'Ellipse',
      };
}

/// One placeable, styleable object on a template page.
///
/// Geometry is stored as fractions of the page (0..1) so a layout survives
/// the editor preview, raster export at any DPI, and vector PDF output.
class DocDrElement {
  /// Creates an element.
  ///
  /// Defaults preserve the behaviour proven in RGEN.
  DocDrElement({
    required this.id,
    required this.type,
    required this.keyName,
    required this.label,
    this.defaultValue = '',
    this.pattern = '',
    this.x = .2,
    this.y = .2,
    this.width = .4,
    this.height = .07,
    this.rotation = 0,
    this.locked = false,
    this.hidden = false,
    this.required = false,
    this.fontFamily = 'sans',
    this.fontPath = '',
    this.fontSize = 14,
    this.minFontSize = 7,
    this.colorArgb = 0xFF000000,
    this.opacity = 1,
    this.bold = false,
    this.italic = false,
    this.underline = false,
    this.autoFit = true,
    this.alignment = DocDrTextAlignment.left,
    this.borderColorArgb = 0xFF000000,
    this.fillColorArgb = 0x00FFFFFF,
    this.borderWidth = 1,
    this.assetPath = '',
    this.serialPrefix = 'SL- ',
    this.serialSuffix = '',
    this.serialDigits = 4,
    this.serialStart = 1,
    this.serialIncrement = 1,
  });

  /// Stable element identifier.
  String id;

  /// Element category.
  DocDrElementType type;

  /// Data key this element reads from a record map.
  String keyName;

  /// Human-readable field label shown in the editor and mapping UI.
  String label;

  /// Value used when the record supplies nothing.
  String defaultValue;

  /// Optional interpolation pattern, for example `Ref: {roll}`.
  String pattern;

  /// Normalized left edge (0..1).
  double x;

  /// Normalized top edge (0..1).
  double y;

  /// Normalized width (0..1).
  double width;

  /// Normalized height (0..1).
  double height;

  /// Rotation in degrees.
  double rotation;

  /// Whether the element resists editing.
  bool locked;

  /// Whether the element is excluded from output.
  bool hidden;

  /// Whether generation requires a value for this element.
  bool required;

  /// Font family identifier.
  String fontFamily;

  /// Relative path to a custom font asset, validated on load.
  String fontPath;

  /// Font size in points.
  double fontSize;

  /// Smallest font size auto-fit may shrink to.
  double minFontSize;

  /// Text colour as ARGB.
  int colorArgb;

  /// Element opacity (0..1).
  double opacity;

  /// Bold text style.
  bool bold;

  /// Italic text style.
  bool italic;

  /// Underlined text style.
  bool underline;

  /// Whether text auto-shrinks to fit its box.
  bool autoFit;

  /// Horizontal text alignment.
  DocDrTextAlignment alignment;

  /// Border colour as ARGB.
  int borderColorArgb;

  /// Fill colour as ARGB.
  int fillColorArgb;

  /// Border width in points.
  double borderWidth;

  /// Relative path to an image asset, validated on load.
  String assetPath;

  /// Prefix prepended to serial values.
  String serialPrefix;

  /// Suffix appended to serial values.
  String serialSuffix;

  /// Zero-padding width for serial values.
  int serialDigits;

  /// First serial number.
  int serialStart;

  /// Step between serial numbers across a batch.
  int serialIncrement;

  /// Resolves the value this element renders for [data].
  ///
  /// [batchIndex] is the zero-based position of the record within a batch and
  /// drives [DocDrElementType.serial].
  ///
  /// [now] is the instant used when a [DocDrElementType.date] element has no
  /// supplied value. **Generation entry points must pass it** so output is
  /// reproducible; when omitted it falls back to [docDrClock].
  String resolveValue(
    Map<String, String> data, {
    int batchIndex = 0,
    DateTime? now,
  }) {
    var value = (data[keyName] ?? '').trim();

    if (type == DocDrElementType.serial) {
      if (value.isEmpty) {
        value = (serialStart + batchIndex * serialIncrement).toString();
      }
      final n = int.tryParse(value);
      if (n != null) {
        value = n.toString().padLeft(serialDigits, '0');
      }
      return '$serialPrefix$value$serialSuffix';
    }

    if (type == DocDrElementType.date && value.isEmpty) {
      final n = now ?? docDrNow();
      value =
          '${n.day.toString().padLeft(2, '0')}/${n.month.toString().padLeft(2, '0')}/${n.year}';
    }

    value = value.isEmpty ? defaultValue : value;
    return pattern.isEmpty
        ? value
        : interpolate(pattern, <String, String>{...data, keyName: value});
  }

  /// Replaces `{name}` placeholders in [source] with values from [data].
  ///
  /// Unknown keys are left verbatim rather than silently blanked.
  static String interpolate(String source, Map<String, String> data) =>
      source.replaceAllMapped(
        RegExp(r'\{([A-Za-z0-9_]+)\}'),
        (m) => data[m.group(1)] ?? m.group(0)!,
      );

  /// Creates a new element of [type] with the proven default geometry,
  /// data-key naming and alignment for that type.
  ///
  /// Restored from the RGEN migration baseline, which defined the key naming
  /// convention (`serial_1`, `text_2`, ...) that the Template Studio editor
  /// and the CSV/XLSX mapping UI both rely on. The condensed DocDr model had
  /// dropped this factory; without it the P1 editor backlog item "Add text
  /// and data fields" has no defined element-construction behaviour.
  ///
  /// [sequence] is the per-type ordinal used to build a unique data key.
  factory DocDrElement.create(DocDrElementType type, int sequence) {
    final key = switch (type) {
      DocDrElementType.multilineText => 'paragraph_$sequence',
      DocDrElementType.date => 'date_$sequence',
      DocDrElementType.serial => 'serial_$sequence',
      DocDrElementType.image => 'image_$sequence',
      DocDrElementType.photo => 'photo_$sequence',
      DocDrElementType.signature => 'signature_$sequence',
      DocDrElementType.checkbox => 'checkbox_$sequence',
      DocDrElementType.qrCode => 'qr_$sequence',
      DocDrElementType.barcode => 'barcode_$sequence',
      DocDrElementType.line => 'line_$sequence',
      DocDrElementType.rectangle => 'rectangle_$sequence',
      DocDrElementType.ellipse => 'ellipse_$sequence',
      DocDrElementType.text => 'text_$sequence',
    };
    final isImage = type.isImageLike ||
        type == DocDrElementType.qrCode ||
        type == DocDrElementType.checkbox;
    return DocDrElement(
      id: '${DateTime.now().microsecondsSinceEpoch}_$sequence',
      type: type,
      keyName: key,
      label: type.label,
      defaultValue: switch (type) {
        DocDrElementType.text => 'Sample text',
        DocDrElementType.multilineText => 'Enter a paragraph or address',
        DocDrElementType.date => '',
        DocDrElementType.qrCode => 'https://example.com',
        DocDrElementType.barcode => '000000000001',
        DocDrElementType.checkbox => 'false',
        _ => '',
      },
      // x/y intentionally use the 0.2 constructor default.
      width: switch (type) {
        DocDrElementType.line => 0.50,
        DocDrElementType.rectangle => 0.30,
        DocDrElementType.ellipse => 0.25,
        DocDrElementType.barcode => 0.35,
        _ => isImage ? 0.20 : 0.55,
      },
      height: switch (type) {
        DocDrElementType.multilineText => 0.15,
        DocDrElementType.line => 0.01,
        DocDrElementType.rectangle => 0.16,
        DocDrElementType.ellipse => 0.16,
        DocDrElementType.barcode => 0.10,
        _ => isImage ? 0.16 : 0.065,
      },
      alignment: type == DocDrElementType.serial
          ? DocDrTextAlignment.left
          : DocDrTextAlignment.center,
    );
  }

  /// Returns an independent copy of this element.
  DocDrElement copy() => DocDrElement.fromJson(toJson());

  /// The value this element renders with no record data.
  ///
  /// Used by the editor preview. Pass [now] to keep the result reproducible
  /// for [DocDrElementType.date] elements.
  String sampleValue({DateTime? now}) =>
      resolveValue(const <String, String>{}, now: now);

  /// Clamps geometry and style values into their valid ranges.
  void clampGeometry() {
    width = width.clamp(.01, 1).toDouble();
    height = height.clamp(.005, 1).toDouble();
    x = x.clamp(0, math.max(0, 1 - width)).toDouble();
    y = y.clamp(0, math.max(0, 1 - height)).toDouble();
    opacity = opacity.clamp(0, 1).toDouble();
    fontSize = fontSize.clamp(4, 200).toDouble();
    minFontSize = minFontSize.clamp(4, fontSize).toDouble();
    serialDigits = serialDigits.clamp(1, 12).toInt();
  }

  /// Serializes the element.
  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'type': type.name,
        'keyName': keyName,
        'label': label,
        'defaultValue': defaultValue,
        'pattern': pattern,
        'x': x,
        'y': y,
        'width': width,
        'height': height,
        'rotation': rotation,
        'locked': locked,
        'hidden': hidden,
        'required': required,
        'fontFamily': fontFamily,
        'fontPath': fontPath,
        'fontSize': fontSize,
        'minFontSize': minFontSize,
        'colorArgb': colorArgb,
        'opacity': opacity,
        'bold': bold,
        'italic': italic,
        'underline': underline,
        'autoFit': autoFit,
        'alignment': alignment.name,
        'borderColorArgb': borderColorArgb,
        'fillColorArgb': fillColorArgb,
        'borderWidth': borderWidth,
        'assetPath': assetPath,
        'serialPrefix': serialPrefix,
        'serialSuffix': serialSuffix,
        'serialDigits': serialDigits,
        'serialStart': serialStart,
        'serialIncrement': serialIncrement,
      };

  /// Deserializes an element from untrusted JSON.
  ///
  /// Throws [UnsafeDocumentPathException] if `fontPath` or `assetPath`
  /// attempts to escape the template storage root, and
  /// [TemplateValidationException] for unreadable values.
  factory DocDrElement.fromJson(Map<String, dynamic> j) {
    T ev<T extends Enum>(List<T> v, Object? r, T f) =>
        v.firstWhere((x) => x.name == r?.toString(), orElse: () => f);
    double d(String k, double f) => (j[k] as num?)?.toDouble() ?? f;
    int i(String k, int f) => (j[k] as num?)?.toInt() ?? f;
    bool b(String k, bool f) => j[k] is bool ? j[k] as bool : f;
    String s(String k, String f) => j[k]?.toString() ?? f;

    final e = DocDrElement(
      id: s('id', DateTime.now().microsecondsSinceEpoch.toString()),
      type: ev(DocDrElementType.values, j['type'], DocDrElementType.text),
      keyName: s('keyName', 'field'),
      label: s('label', 'Field'),
      defaultValue: s('defaultValue', ''),
      pattern: s('pattern', ''),
      x: d('x', .2),
      y: d('y', .2),
      width: d('width', .4),
      height: d('height', .07),
      rotation: d('rotation', 0),
      locked: b('locked', false),
      hidden: b('hidden', false),
      required: b('required', false),
      fontFamily: s('fontFamily', 'sans'),
      fontPath: documentPathPolicy.requireRelativeAssetPath(
        j['fontPath']?.toString(),
        fieldName: 'element.fontPath',
      ),
      fontSize: d('fontSize', 14),
      minFontSize: d('minFontSize', 7),
      colorArgb: i('colorArgb', 0xFF000000),
      opacity: d('opacity', 1),
      bold: b('bold', false),
      italic: b('italic', false),
      underline: b('underline', false),
      autoFit: b('autoFit', true),
      alignment: ev(DocDrTextAlignment.values, j['alignment'],
          DocDrTextAlignment.left),
      borderColorArgb: i('borderColorArgb', 0xFF000000),
      fillColorArgb: i('fillColorArgb', 0x00FFFFFF),
      borderWidth: d('borderWidth', 1),
      assetPath: documentPathPolicy.requireRelativeAssetPath(
        j['assetPath']?.toString(),
        fieldName: 'element.assetPath',
      ),
      serialPrefix: s('serialPrefix', 'SL- '),
      serialSuffix: s('serialSuffix', ''),
      serialDigits: i('serialDigits', 4),
      serialStart: i('serialStart', 1),
      serialIncrement: i('serialIncrement', 1),
    );
    e.clampGeometry();
    return e;
  }
}

/// One page of a template.
class DocDrPage {
  /// Creates a page.
  DocDrPage({
    required this.id,
    required this.backgroundType,
    this.backgroundPath = '',
    this.previewPath = '',
    this.sourcePageIndex = 0,
    this.widthPoints = defaultWidthPoints,
    this.heightPoints = defaultHeightPoints,
    List<DocDrElement>? elements,
    this.hideBackground = false,
    this.hideOriginalText = false,
    this.backgroundOpacity = 1,
  }) : elements = elements ?? <DocDrElement>[];

  /// A4 portrait width in PDF points.
  static const double defaultWidthPoints = 595.28;

  /// A4 portrait height in PDF points.
  static const double defaultHeightPoints = 841.89;

  /// Stable page identifier.
  String id;

  /// What is drawn behind the elements.
  DocDrBackgroundType backgroundType;

  /// Relative path to the page background asset, validated on load.
  String backgroundPath;

  /// Relative path to a cached preview image, validated on load.
  String previewPath;

  /// Index of this page within its source document.
  int sourcePageIndex;

  /// Page width in PDF points.
  double widthPoints;

  /// Page height in PDF points.
  double heightPoints;

  /// Elements on this page, in paint order.
  List<DocDrElement> elements;

  /// Whether the background is suppressed in output.
  bool hideBackground;

  /// Whether original background text is suppressed in output.
  bool hideOriginalText;

  /// Background opacity (0..1).
  double backgroundOpacity;

  /// Serializes the page.
  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'backgroundType': backgroundType.name,
        'backgroundPath': backgroundPath,
        'previewPath': previewPath,
        'sourcePageIndex': sourcePageIndex,
        'widthPoints': widthPoints,
        'heightPoints': heightPoints,
        'elements': elements.map((e) => e.toJson()).toList(),
        'hideBackground': hideBackground,
        'hideOriginalText': hideOriginalText,
        'backgroundOpacity': backgroundOpacity,
      };

  /// Deserializes a page from untrusted JSON.
  ///
  /// Throws [UnsafeDocumentPathException] if `backgroundPath` or
  /// `previewPath` attempts to escape the template storage root.
  ///
  /// Page geometry is validated by [_readPageDimension]: non-finite and
  /// non-positive values are rejected, and extreme-but-valid values are
  /// clamped into the PDF-representable range.
  factory DocDrPage.fromJson(Map<String, dynamic> j) {
    final bt = DocDrBackgroundType.values.firstWhere(
      (v) => v.name == j['backgroundType']?.toString(),
      orElse: () => DocDrBackgroundType.blank,
    );
    final rawElements = j['elements'];
    return DocDrPage(
      id: j['id']?.toString() ??
          DateTime.now().microsecondsSinceEpoch.toString(),
      backgroundType: bt,
      backgroundPath: documentPathPolicy.requireRelativeAssetPath(
        j['backgroundPath']?.toString(),
        fieldName: 'page.backgroundPath',
      ),
      previewPath: documentPathPolicy.requireRelativeAssetPath(
        j['previewPath']?.toString(),
        fieldName: 'page.previewPath',
      ),
      sourcePageIndex: _readSourcePageIndex(j['sourcePageIndex']),
      widthPoints: _readPageDimension(
        j['widthPoints'],
        DocDrPage.defaultWidthPoints,
        'widthPoints',
      ),
      heightPoints: _readPageDimension(
        j['heightPoints'],
        DocDrPage.defaultHeightPoints,
        'heightPoints',
      ),
      elements: rawElements is List
          ? rawElements
              .map((e) => DocDrElement.fromJson(
                  Map<String, dynamic>.from(e as Map<dynamic, dynamic>)))
              .toList()
          : <DocDrElement>[],
      hideBackground: j['hideBackground'] is bool
          ? j['hideBackground'] as bool
          : false,
      hideOriginalText: j['hideOriginalText'] is bool
          ? j['hideOriginalText'] as bool
          : false,
      backgroundOpacity: (j['backgroundOpacity'] as num?)?.toDouble() ?? 1,
    );
  }

  /// Reads and validates a page dimension in PDF points.
  static double _readPageDimension(
    Object? raw,
    double fallback,
    String field,
  ) {
    if (raw == null) {
      return fallback;
    }
    final value = raw is num ? raw.toDouble() : double.tryParse(raw.toString());
    if (value == null || value.isNaN || value.isInfinite) {
      throw TemplateValidationException(
        'page.$field is not a finite number: $raw',
      );
    }
    if (value <= 0) {
      throw TemplateValidationException(
        'page.$field must be greater than zero, got $value',
      );
    }
    if (value > maxPageDimensionPoints) {
      return maxPageDimensionPoints;
    }
    if (value < minPageDimensionPoints) {
      return minPageDimensionPoints;
    }
    return value;
  }

  /// Reads and validates a source page index.
  static int _readSourcePageIndex(Object? raw) {
    if (raw == null) {
      return 0;
    }
    final value = raw is int ? raw : int.tryParse(raw.toString());
    if (value == null) {
      throw TemplateValidationException(
        'page.sourcePageIndex is not an integer: $raw',
      );
    }
    if (value < 0) {
      throw TemplateValidationException(
        'page.sourcePageIndex must not be negative, got $value',
      );
    }
    return value;
  }
}

/// A reusable, user-owned document layout.
class DocDrTemplate {
  /// Creates a template.
  DocDrTemplate({
    required this.id,
    required this.name,
    this.description = '',
    required this.createdAt,
    required this.updatedAt,
    required this.pages,
    this.gridStep = .025,
    this.snapToGrid = true,
    this.basePath = '',
  });

  /// Schema version emitted by [toJson].
  static const int schemaVersion = 2;

  /// Stable template identifier.
  String id;

  /// User-visible template name.
  String name;

  /// Optional user description.
  String description;

  /// Creation timestamp.
  DateTime createdAt;

  /// Last modification timestamp.
  DateTime updatedAt;

  /// Pages in order.
  List<DocDrPage> pages;

  /// Editor grid spacing as a fraction of the page.
  double gridStep;

  /// Whether the editor snaps elements to the grid.
  bool snapToGrid;

  /// Storage root this template's relative asset paths resolve against.
  ///
  /// **This field is intentionally not serialized.** It is runtime state
  /// owned by the storage layer, not part of the portable template identity:
  /// a template that moves between devices must keep working, and persisting
  /// a device-specific root would both break portability and reopen the
  /// traversal class of bug recorded as RGEN-02.
  ///
  /// The storage layer sets it after loading and uses it to resolve the
  /// already-validated relative paths in [DocDrPage.backgroundPath],
  /// [DocDrPage.previewPath], [DocDrElement.fontPath] and
  /// [DocDrElement.assetPath]. Because those paths are validated on
  /// deserialization, resolving them under [basePath] cannot escape it.
  String basePath;

  /// Every element across every page.
  Iterable<DocDrElement> get allElements sync* {
    for (final p in pages) {
      yield* p.elements;
    }
  }

  /// Elements that accept data, de-duplicated by [DocDrElement.keyName].
  List<DocDrElement> get dataFields {
    final seen = <String>{};
    return allElements
        .where((e) => e.type.acceptsData && e.keyName.isNotEmpty && seen.add(e.keyName))
        .toList();
  }

  /// Serializes the template.
  ///
  /// [basePath] is deliberately excluded; see its documentation.
  Map<String, dynamic> toJson() => <String, dynamic>{
        'schemaVersion': schemaVersion,
        'id': id,
        'name': name,
        'description': description,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
        'pages': pages.map((p) => p.toJson()).toList(),
        'gridStep': gridStep,
        'snapToGrid': snapToGrid,
      };

  /// Deserializes a template from untrusted JSON.
  ///
  /// Throws [TemplateSchemaException] when `schemaVersion` is missing,
  /// unreadable, newer than this build, or older than any supported
  /// migration path. Throws [UnsafeDocumentPathException] or
  /// [TemplateValidationException] for unsafe paths and invalid geometry.
  factory DocDrTemplate.fromJson(Map<String, dynamic> j) {
    _readSchemaVersion(j['schemaVersion']);

    final rawPages = j['pages'];
    return DocDrTemplate(
      id: j['id']?.toString() ??
          DateTime.now().microsecondsSinceEpoch.toString(),
      name: j['name']?.toString() ?? 'Untitled',
      description: j['description']?.toString() ?? '',
      createdAt:
          DateTime.tryParse(j['createdAt']?.toString() ?? '') ?? DateTime.now(),
      updatedAt:
          DateTime.tryParse(j['updatedAt']?.toString() ?? '') ?? DateTime.now(),
      pages: rawPages is List
          ? rawPages
              .map((p) => DocDrPage.fromJson(
                  Map<String, dynamic>.from(p as Map<dynamic, dynamic>)))
              .toList()
          : <DocDrPage>[],
      gridStep: (j['gridStep'] as num?)?.toDouble() ?? .025,
      snapToGrid: j['snapToGrid'] is bool ? j['snapToGrid'] as bool : true,
    );
  }

  /// Deserializes a template, returning `null` instead of throwing on a
  /// schema rejection.
  ///
  /// Intended for import UI, which needs to tell the user "this template was
  /// created by a newer version of DocDr" rather than crash. Path and
  /// geometry errors still throw, because they indicate a corrupt or hostile
  /// file rather than a version mismatch.
  static DocDrTemplate? tryFromJson(Map<String, dynamic> j) {
    try {
      _readSchemaVersion(j['schemaVersion']);
    } on TemplateSchemaException {
      return null;
    }
    return DocDrTemplate.fromJson(j);
  }

  /// Validates a declared schema version.
  ///
  /// Rules, in order:
  /// 1. missing  -> rejected (a template must declare itself);
  /// 2. unreadable -> rejected;
  /// 3. newer than [currentTemplateSchemaVersion] -> rejected;
  /// 4. listed in [supportedTemplateSchemaVersions] -> accepted;
  /// 5. listed in [migratableTemplateSchemaVersions] -> migrated;
  /// 6. anything else -> rejected.
  static int _readSchemaVersion(Object? raw) {
    if (raw == null) {
      throw const TemplateSchemaException(
        'template is missing the required "schemaVersion" field',
      );
    }
    final version = raw is int ? raw : int.tryParse(raw.toString());
    if (version == null) {
      throw TemplateSchemaException(
        'template "schemaVersion" is not an integer: $raw',
      );
    }
    if (version > currentTemplateSchemaVersion) {
      throw TemplateSchemaException(
        'template schema version $version is newer than this build '
        '($currentTemplateSchemaVersion); update DocDr to open it',
      );
    }
    if (supportedTemplateSchemaVersions.contains(version)) {
      return version;
    }
    if (migratableTemplateSchemaVersions.contains(version)) {
      return _migrateSchema(version);
    }
    throw TemplateSchemaException(
      'template schema version $version has no supported migration path to '
      '$currentTemplateSchemaVersion',
    );
  }

  /// Applies the deterministic migration for [fromVersion].
  ///
  /// Unreachable while [migratableTemplateSchemaVersions] is empty; kept so
  /// adding a migration is a one-place change with a tested seam.
  static int _migrateSchema(int fromVersion) {
    throw TemplateSchemaException(
      'no migration implemented for schema version $fromVersion',
    );
  }
}
