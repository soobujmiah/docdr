import 'package:flutter_test/flutter_test.dart';
import 'package:docdr/core/models/docdr_template.dart';

void main() {
  test('template round-trips through JSON', () {
    const original = DocDrTemplate(
      id: 't1',
      name: 'Blank form',
      pageWidth: 595,
      pageHeight: 842,
      elements: [
        DocDrElement(
          id: 'e1',
          type: DocDrElementType.text,
          x: 10,
          y: 20,
          width: 200,
          height: 30,
          dataKey: 'name',
          value: '{{name}}',
          style: {'fontSize': 14},
        ),
      ],
    );

    final restored = DocDrTemplate.decode(original.encode());
    expect(restored.id, original.id);
    expect(restored.name, original.name);
    expect(restored.pageWidth, original.pageWidth);
    expect(restored.elements.single.type, DocDrElementType.text);
    expect(restored.elements.single.dataKey, 'name');
    expect(restored.elements.single.style['fontSize'], 14);
  });
}
