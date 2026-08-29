import 'dart:convert';

enum DocDrElementType {
  text,
  image,
  shape,
  line,
  rectangle,
  circle,
  checkbox,
  qr,
  barcode,
  photo,
  signature,
  date,
  serial,
}

class DocDrElement {
  final String id;
  final DocDrElementType type;
  final double x;
  final double y;
  final double width;
  final double height;
  final String? dataKey;
  final String? value;
  final Map<String, dynamic> style;

  const DocDrElement({
    required this.id,
    required this.type,
    required this.x,
    required this.y,
    required this.width,
    required this.height,
    this.dataKey,
    this.value,
    this.style = const {},
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type.name,
        'x': x,
        'y': y,
        'width': width,
        'height': height,
        if (dataKey != null) 'dataKey': dataKey,
        if (value != null) 'value': value,
        'style': style,
      };

  factory DocDrElement.fromJson(Map<String, dynamic> json) => DocDrElement(
        id: json['id'] as String,
        type: DocDrElementType.values.byName(json['type'] as String),
        x: (json['x'] as num).toDouble(),
        y: (json['y'] as num).toDouble(),
        width: (json['width'] as num).toDouble(),
        height: (json['height'] as num).toDouble(),
        dataKey: json['dataKey'] as String?,
        value: json['value'] as String?,
        style: Map<String, dynamic>.from(json['style'] as Map? ?? const {}),
      );
}

class DocDrTemplate {
  final String id;
  final String name;
  final double pageWidth;
  final double pageHeight;
  final List<DocDrElement> elements;

  const DocDrTemplate({
    required this.id,
    required this.name,
    required this.pageWidth,
    required this.pageHeight,
    this.elements = const [],
  });

  Map<String, dynamic> toJson() => {
        'schemaVersion': 1,
        'id': id,
        'name': name,
        'pageWidth': pageWidth,
        'pageHeight': pageHeight,
        'elements': elements.map((e) => e.toJson()).toList(),
      };

  factory DocDrTemplate.fromJson(Map<String, dynamic> json) => DocDrTemplate(
        id: json['id'] as String,
        name: json['name'] as String,
        pageWidth: (json['pageWidth'] as num).toDouble(),
        pageHeight: (json['pageHeight'] as num).toDouble(),
        elements: (json['elements'] as List? ?? const [])
            .map((e) => DocDrElement.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList(),
      );

  String encode() => jsonEncode(toJson());
  factory DocDrTemplate.decode(String source) =>
      DocDrTemplate.fromJson(Map<String, dynamic>.from(jsonDecode(source) as Map));
}
