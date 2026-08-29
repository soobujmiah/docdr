import 'package:docdr/core/models/docdr_template.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('template round-trips through JSON', () {
    const original = DocDrTemplate(
      id: 'template-1',
      name: 'Invoice',
      pageWidth: 595,
      pageHeight: 842,
      elements: [
        DocDrElement(
          id: 'text-1',
          type: DocDrElementType.text,
          x: 20,
          y: 30,
          width: 200,
          height: 40,
          dataKey: 'customer_name',
          value: '{{customer_name}}',
          style: {'fontSize': 16},
        ),
      ],
    );

    final restored = DocDrTemplate.decode(original.encode());

    expect(restored.id, original.id);
    expect(restored.name, original.name);
    expect(restored.pageWidth, original.pageWidth);
    expect(restored.pageHeight, original.pageHeight);
    expect(restored.elements.single.type, DocDrElementType.text);
    expect(restored.elements.single.dataKey, 'customer_name');
    expect(restored.elements.single.style['fontSize'], 16);
  });
}
