// Regression suite for the migrated template model.
//
// PROVENANCE: these tests port the *behavioural contract* of
// `rgen` @ 9cd0e0263c80e41b19229932e1f0f57a3f2ed231
// (android_app/test/custom_template_test.dart), adapted to DocDr identifiers.
//
// They exist because the migration condensed the 501-line RGEN model into a
// 50-line DocDr model with no tests at all. Under docs/ENGINEERING_RULES.md
// ("prefer regression tests before refactoring proven behavior") that
// refactor was unevidenced. This file is the evidence.
//
// DELIBERATELY NOT PORTED: RGEN's fourth test exercised
// CustomPdfService.render() through Syncfusion Flutter PDF. DocDr has no
// renderer yet and has not licensed Syncfusion, so that behaviour belongs to
// the renderer migration slice, not this one.

import 'package:docdr/core/models/custom_template.dart';
import 'package:test/test.dart';

void main() {
  group('serial fields', () {
    test('preserve prefix and pad to configured width', () {
      final serial = DocDrElement.create(DocDrElementType.serial, 1)
        ..serialPrefix = 'SL- '
        ..serialDigits = 4
        ..serialStart = 1;

      expect(serial.resolveValue(const <String, String>{}), 'SL- 0001');
      expect(
        serial.resolveValue(const <String, String>{}, batchIndex: 13),
        'SL- 0014',
      );
      expect(
        serial.resolveValue(const <String, String>{'serial_1': '14'}),
        'SL- 0014',
      );
    });

    test('honour start, increment, digits and suffix', () {
      final serial = DocDrElement.create(DocDrElementType.serial, 1)
        ..serialStart = 5
        ..serialIncrement = 5
        ..serialDigits = 6
        ..serialPrefix = 'INV-'
        ..serialSuffix = '-BD';

      expect(serial.resolveValue(const <String, String>{}), 'INV-000005-BD');
      expect(
        serial.resolveValue(const <String, String>{}, batchIndex: 2),
        'INV-000015-BD',
      );
    });

    test('pass through non-numeric supplied values unpadded', () {
      final serial = DocDrElement.create(DocDrElementType.serial, 1)
        ..serialPrefix = ''
        ..serialDigits = 4;
      expect(
        serial.resolveValue(const <String, String>{'serial_1': 'ABC-1'}),
        'ABC-1',
      );
    });
  });

  group('pattern interpolation', () {
    test('interpolates other spreadsheet fields', () {
      final field = DocDrElement.create(DocDrElementType.text, 1)
        ..keyName = 'reference'
        ..pattern = 'Ref: {registration_no} / {roll}';

      expect(
        field.resolveValue(const <String, String>{
          'registration_no': '11503',
          'roll': '24901721',
        }),
        'Ref: 11503 / 24901721',
      );
    });

    test('leaves unknown placeholders verbatim', () {
      final field = DocDrElement.create(DocDrElementType.text, 1)
        ..keyName = 'reference'
        ..pattern = 'Ref: {missing}';

      expect(
        field.resolveValue(const <String, String>{}),
        'Ref: {missing}',
      );
    });

    test('falls back to defaultValue when the record is empty', () {
      final field = DocDrElement.create(DocDrElementType.text, 1)
        ..keyName = 'note'
        ..defaultValue = 'N/A';
      expect(field.resolveValue(const <String, String>{}), 'N/A');
    });
  });

  group('element creation defaults', () {
    test('names data keys by type and sequence', () {
      expect(
        DocDrElement.create(DocDrElementType.serial, 1).keyName,
        'serial_1',
      );
      expect(DocDrElement.create(DocDrElementType.text, 2).keyName, 'text_2');
      expect(
        DocDrElement.create(DocDrElementType.multilineText, 3).keyName,
        'paragraph_3',
      );
      expect(DocDrElement.create(DocDrElementType.qrCode, 4).keyName, 'qr_4');
      expect(
        DocDrElement.create(DocDrElementType.barcode, 5).keyName,
        'barcode_5',
      );
      expect(DocDrElement.create(DocDrElementType.date, 6).keyName, 'date_6');
    });

    test('applies human labels from the element type', () {
      expect(DocDrElement.create(DocDrElementType.text, 1).label, 'Text');
      expect(
        DocDrElement.create(DocDrElementType.serial, 1).label,
        'Serial number',
      );
      expect(
        DocDrElement.create(DocDrElementType.multilineText, 1).label,
        'Multi-line text',
      );
      expect(
        DocDrElement.create(DocDrElementType.signature, 1).label,
        'Signature / stamp',
      );
    });

    test('applies per-type default geometry', () {
      final line = DocDrElement.create(DocDrElementType.line, 1);
      expect(line.width, 0.50);
      expect(line.height, 0.01);

      final barcode = DocDrElement.create(DocDrElementType.barcode, 1);
      expect(barcode.width, 0.35);
      expect(barcode.height, 0.10);

      final paragraph = DocDrElement.create(DocDrElementType.multilineText, 1);
      expect(paragraph.height, 0.15);

      final text = DocDrElement.create(DocDrElementType.text, 1);
      expect(text.width, 0.55);
      expect(text.height, 0.065);
      expect(text.x, 0.2);
      expect(text.y, 0.2);
    });

    test('left-aligns serial and centres everything else', () {
      expect(
        DocDrElement.create(DocDrElementType.serial, 1).alignment,
        DocDrTextAlignment.left,
      );
      expect(
        DocDrElement.create(DocDrElementType.text, 1).alignment,
        DocDrTextAlignment.center,
      );
    });

    test('seeds sensible default values', () {
      expect(
        DocDrElement.create(DocDrElementType.text, 1).defaultValue,
        'Sample text',
      );
      expect(
        DocDrElement.create(DocDrElementType.barcode, 1).defaultValue,
        '000000000001',
      );
      expect(
        DocDrElement.create(DocDrElementType.checkbox, 1).defaultValue,
        'false',
      );
      expect(DocDrElement.create(DocDrElementType.date, 1).defaultValue, '');
    });

    test('sampleValue renders without record data', () {
      final serial = DocDrElement.create(DocDrElementType.serial, 1)
        ..serialStart = 7
        ..serialDigits = 3;
      expect(serial.sampleValue(), 'SL- 007');
    });

    test('copy returns an independent equal element', () {
      final original = DocDrElement.create(DocDrElementType.text, 1)
        ..keyName = 'name'
        ..bold = true;
      final duplicate = original.copy();

      expect(duplicate.keyName, original.keyName);
      expect(duplicate.bold, isTrue);

      duplicate.keyName = 'renamed';
      expect(original.keyName, 'name');
    });
  });

  group('constructor defaults', () {
    test('element defaults match the proven RGEN contract', () {
      final e = DocDrElement(
        id: 'a',
        type: DocDrElementType.text,
        keyName: 'k',
        label: 'K',
      );
      expect(e.x, 0.2);
      expect(e.y, 0.2);
      expect(e.width, 0.4);
      expect(e.height, 0.07);
      expect(e.fontFamily, 'sans');
      expect(e.fontSize, 14);
      expect(e.minFontSize, 7);
      expect(e.colorArgb, 0xFF000000);
      expect(e.fillColorArgb, 0x00FFFFFF);
      expect(e.opacity, 1);
      expect(e.autoFit, isTrue);
      expect(e.alignment, DocDrTextAlignment.left);
      expect(e.serialPrefix, 'SL- ');
      expect(e.serialDigits, 4);
      expect(e.serialStart, 1);
      expect(e.serialIncrement, 1);
    });

    test('page defaults to A4 portrait', () {
      final page = DocDrPage(id: 'p', backgroundType: DocDrBackgroundType.blank);
      expect(page.widthPoints, 595.28);
      expect(page.heightPoints, 841.89);
      expect(page.sourcePageIndex, 0);
      expect(page.backgroundOpacity, 1);
      expect(page.elements, isEmpty);
    });

    test('template defaults to grid snapping', () {
      final now = DateTime(2026, 8, 29);
      final template = DocDrTemplate(
        id: 't',
        name: 'T',
        createdAt: now,
        updatedAt: now,
        pages: const <DocDrPage>[],
      );
      expect(template.gridStep, 0.025);
      expect(template.snapToGrid, isTrue);
      expect(template.basePath, '');
      expect(DocDrTemplate.schemaVersion, 2);
    });
  });

  group('geometry clamping', () {
    test('keeps elements inside the page and sizes sane', () {
      final e = DocDrElement(
        id: 'a',
        type: DocDrElementType.text,
        keyName: 'k',
        label: 'K',
      )
        ..x = -0.5
        ..y = 2.0
        ..width = 5.0
        ..height = -3.0
        ..opacity = 9.0
        ..fontSize = 1000
        ..minFontSize = 500
        ..serialDigits = 99;

      e.clampGeometry();

      expect(e.x, greaterThanOrEqualTo(0));
      expect(e.y, lessThanOrEqualTo(1 - e.height));
      expect(e.width, inInclusiveRange(0.01, 1.0));
      expect(e.height, inInclusiveRange(0.005, 1.0));
      expect(e.opacity, 1);
      expect(e.fontSize, 200);
      expect(e.minFontSize, inInclusiveRange(4, 200));
      expect(e.serialDigits, 12);
    });
  });

  group('JSON round-trip', () {
    test('retains pages, layers and styling', () {
      final now = DateTime(2026, 8, 15);
      final text = DocDrElement.create(DocDrElementType.text, 1)
        ..keyName = 'student_name'
        ..fontFamily = 'bengali'
        ..bold = true
        ..rotation = 12;
      final template = DocDrTemplate(
        id: 'demo',
        name: 'Demo',
        createdAt: now,
        updatedAt: now,
        pages: <DocDrPage>[
          DocDrPage(
            id: 'page_1',
            backgroundType: DocDrBackgroundType.blank,
            elements: <DocDrElement>[text],
          ),
        ],
      );

      final restored =
          DocDrTemplate.fromJson(template.toJson());

      expect(restored.pages, hasLength(1));
      expect(restored.dataFields.single.keyName, 'student_name');
      expect(restored.pages.single.elements.single.fontFamily, 'bengali');
      expect(restored.pages.single.elements.single.bold, isTrue);
      expect(restored.pages.single.elements.single.rotation, 12);
      expect(restored.id, 'demo');
      expect(restored.name, 'Demo');
      expect(restored.gridStep, 0.025);
      expect(restored.snapToGrid, isTrue);
    });

    test('preserves multi-page element order', () {
      final now = DateTime(2026, 8, 15);
      final template = DocDrTemplate(
        id: 'multi',
        name: 'Multi',
        createdAt: now,
        updatedAt: now,
        pages: <DocDrPage>[
          DocDrPage(
            id: 'p1',
            backgroundType: DocDrBackgroundType.blank,
            elements: <DocDrElement>[
              DocDrElement.create(DocDrElementType.text, 1),
              DocDrElement.create(DocDrElementType.text, 2),
            ],
          ),
          DocDrPage(
            id: 'p2',
            backgroundType: DocDrBackgroundType.image,
            elements: <DocDrElement>[
              DocDrElement.create(DocDrElementType.image, 1),
            ],
          ),
        ],
      );

      final restored =
          DocDrTemplate.fromJson(template.toJson());

      expect(restored.pages, hasLength(2));
      expect(restored.pages.first.elements.first.keyName, 'text_1');
      expect(restored.pages.first.elements.last.keyName, 'text_2');
      expect(restored.pages.last.elements.single.type,
          DocDrElementType.image);
    });

    test('emits the current schema version', () {
      final now = DateTime(2026, 8, 15);
      final json = DocDrTemplate(
        id: 't',
        name: 'T',
        createdAt: now,
        updatedAt: now,
        pages: const <DocDrPage>[],
      ).toJson();
      expect(json['schemaVersion'], 2);
    });

    test('does not serialize basePath', () {
      final now = DateTime(2026, 8, 15);
      final template = DocDrTemplate(
        id: 't',
        name: 'T',
        createdAt: now,
        updatedAt: now,
        pages: const <DocDrPage>[],
        basePath: '/data/user/0/com.soobujmiah.docdr/templates/t',
      );
      expect(template.toJson().containsKey('basePath'), isFalse);
    });
  });

  group('dataFields', () {
    test('de-duplicates by key and excludes shapes', () {
      final now = DateTime(2026, 8, 15);
      final template = DocDrTemplate(
        id: 't',
        name: 'T',
        createdAt: now,
        updatedAt: now,
        pages: <DocDrPage>[
          DocDrPage(
            id: 'p1',
            backgroundType: DocDrBackgroundType.blank,
            elements: <DocDrElement>[
              DocDrElement.create(DocDrElementType.text, 1)..keyName = 'dup',
              DocDrElement.create(DocDrElementType.text, 2)..keyName = 'dup',
              DocDrElement.create(DocDrElementType.line, 3),
              DocDrElement.create(DocDrElementType.rectangle, 4),
              DocDrElement.create(DocDrElementType.ellipse, 5),
              DocDrElement.create(DocDrElementType.date, 6),
            ],
          ),
        ],
      );

      final keys = template.dataFields.map((e) => e.keyName).toList();
      expect(keys, <String>['dup', 'date_6']);
    });
  });
}
