import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:docdr/core/models/docdr_template.dart';
import 'package:docdr/core/services/template_store.dart';

void main() {
  test('template store saves, lists, loads and deletes templates', () async {
    final directory = await Directory.systemTemp.createTemp('docdr_store_test_');
    addTearDown(() => directory.delete(recursive: true));

    final store = DocDrTemplateStore(directory);
    const template = DocDrTemplate(
      id: 'invoice-1',
      name: 'Invoice',
      pageWidth: 595,
      pageHeight: 842,
      elements: [
        DocDrElement(
          id: 'customer',
          type: DocDrElementType.text,
          x: 10,
          y: 20,
          width: 200,
          height: 30,
          dataKey: 'customer_name',
        ),
      ],
    );

    await store.save(template);
    expect(await store.get('invoice-1'), isNotNull);
    expect((await store.list()).map((e) => e.id), contains('invoice-1'));
    expect(await store.delete('invoice-1'), isTrue);
    expect(await store.get('invoice-1'), isNull);
  });
}
