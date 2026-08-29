import 'dart:typed_data';

import '../models/custom_template.dart';

/// Thrown when generation fails due to invalid input or engine error.
class DocumentGenerationException implements Exception {
  const DocumentGenerationException(this.message, {this.cause});
  final String message;
  final Object? cause;
  @override
  String toString() => 'DocumentGenerationException: $message'
      '${cause != null ? ' (cause: $cause)' : ''}';
}

/// Capability set for a [DocumentGenerator].
class GeneratorCapabilities {
  const GeneratorCapabilities({
    this.canGeneratePdf = false,
    this.canGenerateImage = false,
    this.supportsBengaliText = false,
    this.supportsBarcode = false,
    this.supportsQr = false,
    this.supportsImages = false,
    this.supportsMultiPage = false,
  });

  final bool canGeneratePdf;
  final bool canGenerateImage;
  final bool supportsBengaliText;
  final bool supportsBarcode;
  final bool supportsQr;
  final bool supportsImages;
  final bool supportsMultiPage;

  @override
  String toString() =>
      'GeneratorCapabilities(pdf: $canGeneratePdf, bn: $supportsBengaliText, multi: $supportsMultiPage)';
}

/// Abstract vendor-neutral document generator.
///
/// Rules:
/// - No vendor types (pdf package) in public API.
/// - Geometry is validated and bounded.
/// - Generation is deterministic given same template, data, batchIndex, and clock.
/// - No logging of user data.
/// - Security: bound page/element count, image size, etc.
abstract class DocumentGenerator {
  String get engineName;
  GeneratorCapabilities get capabilities;

  /// Generates a single PDF document from [template] + [data].
  ///
  /// [data] is a map from element keyName to value.
  /// [batchIndex] drives serial numbers (0-based).
  /// [now] is the clock for date elements — must be passed for determinism.
  ///
  /// Returns PDF bytes.
  Future<Uint8List> generateSingle({
    required DocDrTemplate template,
    required Map<String, String> data,
    int batchIndex = 0,
    DateTime? now,
  });

  /// Generates multiple PDFs from [template] + [records].
  ///
  /// Each record is a Map<String,String>. Returns list of PDF bytes, one per record.
  /// Must bound batch size.
  Future<List<Uint8List>> generateBatch({
    required DocDrTemplate template,
    required List<Map<String, String>> records,
    DateTime? now,
  });

  Future<void> dispose() async {}
}
