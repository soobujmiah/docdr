import '../models/docdr_template.dart';

/// Resolves user data against template elements without coupling the model to UI.
class DocDrTemplateDataResolver {
  const DocDrTemplateDataResolver();

  DocDrElement resolveElement(
    DocDrElement element,
    Map<String, String> data,
  ) {
    if (element.dataKey == null) return element;
    return DocDrElement(
      id: element.id,
      type: element.type,
      x: element.x,
      y: element.y,
      width: element.width,
      height: element.height,
      dataKey: element.dataKey,
      value: data[element.dataKey] ?? '',
      style: element.style,
    );
  }

  DocDrTemplate resolve(
    DocDrTemplate template,
    Map<String, String> data,
  ) {
    return DocDrTemplate(
      id: template.id,
      name: template.name,
      pageWidth: template.pageWidth,
      pageHeight: template.pageHeight,
      elements: template.elements
          .map((element) => resolveElement(element, data))
          .toList(growable: false),
    );
  }
}
