import 'dart:io';

import '../models/docdr_template.dart';
import 'document_renderer.dart';
import 'template_data_resolver.dart';

/// Orchestrates the generic template -> data -> PDF workflow.
class DocDrDocumentService {
  final DocDrDocumentRenderer renderer;
  final DocDrTemplateDataResolver resolver;

  const DocDrDocumentService({
    this.renderer = const DocDrDocumentRenderer(),
    this.resolver = const DocDrTemplateDataResolver(),
  });

  Future<File> generate({
    required DocDrTemplate template,
    required Directory outputDirectory,
    Map<String, String> data = const {},
  }) {
    final resolved = resolver.resolve(template, data);
    return renderer.renderToPdf(
      template: resolved,
      outputDirectory: outputDirectory,
    );
  }
}
