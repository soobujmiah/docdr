// Deserialization hardening suite.
//
// Covers the audit findings DOC-03 (schemaVersion written but never read),
// DOC-04 (unvalidated page geometry) and DOC-05 (path traversal). Every case
// here is an *untrusted input* case: templates arrive from imported portable
// packages and must never crash the app, escape their storage root, or be
// silently accepted as something they are not.

import 'package:docdr/core/models/custom_template.dart';
import 'package:docdr/core/security/document_path.dart';
import 'package:test/test.dart';

Map<String, dynamic> _templateJson([Map<String, dynamic>? overrides]) =>
    <String, dynamic>{
      'schemaVersion': 2,
      'id': 't',
      'name': 'T',
      'createdAt': '2026-08-29T00:00:00.000Z',
      'updatedAt': '2026-08-29T00:00:00.000Z',
      'pages': <dynamic>[],
      ...?overrides,
    };

Map<String, dynamic> _pageJson(Map<String, dynamic> overrides) =>
    _templateJson(<String, dynamic>{
      'pages': <dynamic>[
        <String, dynamic>{
          'id': 'p1',
          'backgroundType': 'blank',
          ...overrides,
        },
      ],
    });

void main() {
  group('schemaVersion (DOC-03)', () {
    test('accepts the current version', () {
      final t = DocDrTemplate.fromJson(_templateJson());
      expect(t.id, 't');
    });

    test('accepts a numeric string version', () {
      final t = DocDrTemplate.fromJson(_templateJson(<String, dynamic>{
        'schemaVersion': '2',
      }));
      expect(t.id, 't');
    });

    test('rejects a missing schemaVersion', () {
      final json = _templateJson()..remove('schemaVersion');
      expect(
        () => DocDrTemplate.fromJson(json),
        throwsA(isA<TemplateSchemaException>()),
      );
    });

    test('rejects a null schemaVersion', () {
      expect(
        () => DocDrTemplate.fromJson(_templateJson(<String, dynamic>{
          'schemaVersion': null,
        })),
        throwsA(isA<TemplateSchemaException>()),
      );
    });

    test('rejects a newer schemaVersion from a future DocDr build', () {
      expect(
        () => DocDrTemplate.fromJson(_templateJson(<String, dynamic>{
          'schemaVersion': 3,
        })),
        throwsA(
          isA<TemplateSchemaException>().having(
            (e) => e.message,
            'message',
            contains('newer than this build'),
          ),
        ),
      );
    });

    test('rejects an older version with no migration path', () {
      expect(
        () => DocDrTemplate.fromJson(_templateJson(<String, dynamic>{
          'schemaVersion': 1,
        })),
        throwsA(
          isA<TemplateSchemaException>().having(
            (e) => e.message,
            'message',
            contains('no supported migration path'),
          ),
        ),
      );
    });

    test('rejects an unreadable schemaVersion', () {
      expect(
        () => DocDrTemplate.fromJson(_templateJson(<String, dynamic>{
          'schemaVersion': 'not-a-number',
        })),
        throwsA(isA<TemplateSchemaException>()),
      );
    });

    test('tryFromJson returns null on a schema rejection', () {
      expect(
        DocDrTemplate.tryFromJson(_templateJson(<String, dynamic>{
          'schemaVersion': 99,
        })),
        isNull,
      );
    });

    test('tryFromJson returns a template for a supported schema', () {
      expect(DocDrTemplate.tryFromJson(_templateJson()), isNotNull);
    });
  });

  group('page geometry (DOC-04)', () {
    test('defaults to A4 when dimensions are absent', () {
      final t = DocDrTemplate.fromJson(_pageJson(<String, dynamic>{}));
      expect(t.pages.single.widthPoints, 595.28);
      expect(t.pages.single.heightPoints, 841.89);
      expect(t.pages.single.sourcePageIndex, 0);
    });

    test('accepts ordinary dimensions unchanged', () {
      final t = DocDrTemplate.fromJson(_pageJson(<String, dynamic>{
        'widthPoints': 600,
        'heightPoints': 900,
      }));
      expect(t.pages.single.widthPoints, 600);
      expect(t.pages.single.heightPoints, 900);
    });

    test('rejects negative dimensions', () {
      expect(
        () => DocDrTemplate.fromJson(_pageJson(<String, dynamic>{
          'widthPoints': -10,
        })),
        throwsA(isA<TemplateValidationException>()),
      );
      expect(
        () => DocDrTemplate.fromJson(_pageJson(<String, dynamic>{
          'heightPoints': -1,
        })),
        throwsA(isA<TemplateValidationException>()),
      );
    });

    test('rejects zero dimensions', () {
      expect(
        () => DocDrTemplate.fromJson(_pageJson(<String, dynamic>{
          'widthPoints': 0,
        })),
        throwsA(isA<TemplateValidationException>()),
      );
      expect(
        () => DocDrTemplate.fromJson(_pageJson(<String, dynamic>{
          'heightPoints': 0.0,
        })),
        throwsA(isA<TemplateValidationException>()),
      );
    });

    test('rejects non-numeric and non-finite dimensions', () {
      for (final bad in <Object>['abc', double.infinity, double.nan]) {
        expect(
          () => DocDrTemplate.fromJson(_pageJson(<String, dynamic>{
            'widthPoints': bad,
          })),
          throwsA(isA<TemplateValidationException>()),
          reason: 'widthPoints=$bad must be rejected',
        );
      }
    });

    test('clamps absurd dimensions into the PDF-representable range', () {
      final huge = DocDrTemplate.fromJson(_pageJson(<String, dynamic>{
        'widthPoints': 1e9,
        'heightPoints': 1e9,
      }));
      expect(huge.pages.single.widthPoints, maxPageDimensionPoints);
      expect(huge.pages.single.heightPoints, maxPageDimensionPoints);

      final tiny = DocDrTemplate.fromJson(_pageJson(<String, dynamic>{
        'widthPoints': 1,
        'heightPoints': 2,
      }));
      expect(tiny.pages.single.widthPoints, minPageDimensionPoints);
      expect(tiny.pages.single.heightPoints, minPageDimensionPoints);
    });

    test('rejects a negative source page index', () {
      expect(
        () => DocDrTemplate.fromJson(_pageJson(<String, dynamic>{
          'sourcePageIndex': -1,
        })),
        throwsA(isA<TemplateValidationException>()),
      );
    });

    test('accepts a positive source page index', () {
      final t = DocDrTemplate.fromJson(_pageJson(<String, dynamic>{
        'sourcePageIndex': 7,
      }));
      expect(t.pages.single.sourcePageIndex, 7);
    });

    test('tolerates a missing or malformed element list', () {
      expect(
        DocDrTemplate.fromJson(_pageJson(<String, dynamic>{}))
            .pages
            .single
            .elements,
        isEmpty,
      );
      expect(
        DocDrTemplate.fromJson(_templateJson(<String, dynamic>{
          'pages': 'not-a-list',
        })).pages,
        isEmpty,
      );
    });
  });

  group('asset path security (DOC-05)', () {
    const unsafe = <String>[
      '/etc/passwd',
      '../../secrets.pdf',
      'pages/../../secrets.pdf',
      '..',
      '.',
      'C:\\Windows\\win.ini',
      'assets\\fonts\\x.ttf',
      'file:///etc/passwd',
      'content://media/external/file/1',
      'http://evil.example/x.pdf',
      'pages//bg.pdf',
      'pages/',
      '%2e%2e%2fsecrets.pdf',
      'bg\u0000.pdf',
      'bg\n.pdf',
    ];

    test('rejects every unsafe path form', () {
      for (final path in unsafe) {
        expect(
          documentPathPolicy.isSafeRelativeAssetPath(path),
          isFalse,
          reason: 'path must be rejected: ${path.replaceAll('\n', '\\n')}',
        );
      }
    });

    test('rejects unsafe page background and preview paths', () {
      for (final field in <String>['backgroundPath', 'previewPath']) {
        expect(
          () => DocDrTemplate.fromJson(_pageJson(<String, dynamic>{
            field: '/etc/passwd',
          })),
          throwsA(isA<UnsafeDocumentPathException>()),
          reason: '$field must reject absolute paths',
        );
        expect(
          () => DocDrTemplate.fromJson(_pageJson(<String, dynamic>{
            field: '../../secrets.pdf',
          })),
          throwsA(isA<UnsafeDocumentPathException>()),
          reason: '$field must reject traversal',
        );
      }
    });

    test('rejects unsafe element font and asset paths', () {
      for (final field in <String>['fontPath', 'assetPath']) {
        final json = _pageJson(<String, dynamic>{
          'elements': <dynamic>[
            <String, dynamic>{
              'id': 'e1',
              'type': 'text',
              'keyName': 'k',
              'label': 'K',
              field: '../../etc/passwd',
            },
          ],
        });
        expect(
          () => DocDrTemplate.fromJson(json),
          throwsA(isA<UnsafeDocumentPathException>()),
          reason: '$field must reject traversal',
        );
      }
    });

    test('accepts ordinary relative asset paths', () {
      final t = DocDrTemplate.fromJson(_pageJson(<String, dynamic>{
        'backgroundPath': 'pages/bg-001.pdf',
        'previewPath': 'previews/page-1.png',
        'elements': <dynamic>[
          <String, dynamic>{
            'id': 'e1',
            'type': 'text',
            'keyName': 'k',
            'label': 'K',
            'fontPath': 'fonts/bengali.ttf',
            'assetPath': 'assets/logo.png',
          },
        ],
      }));
      expect(t.pages.single.backgroundPath, 'pages/bg-001.pdf');
      expect(t.pages.single.previewPath, 'previews/page-1.png');
      expect(t.pages.single.elements.single.fontPath, 'fonts/bengali.ttf');
      expect(t.pages.single.elements.single.assetPath, 'assets/logo.png');
    });

    test('allows empty paths to mean "no asset"', () {
      expect(documentPathPolicy.isSafeRelativeAssetPath(''), isTrue);
      expect(documentPathPolicy.isSafeRelativeAssetPath(null), isTrue);
      expect(
        documentPathPolicy.isSafeRelativeAssetPath('', allowEmpty: false),
        isFalse,
      );
    });

    test('enforces the configured maximum length', () {
      final long = '${'a' * 600}/file.pdf';
      expect(
        () => documentPathPolicy.requireRelativeAssetPath(
          long,
          fieldName: 'test.path',
        ),
        throwsA(isA<UnsafeDocumentPathException>()),
      );
      expect(
        documentPathPolicy.isSafeRelativeAssetPath('a' * 600),
        isFalse,
      );
    });

    test('records the offending field name on rejection', () {
      try {
        documentPathPolicy.requireRelativeAssetPath(
          '/etc/passwd',
          fieldName: 'page.backgroundPath',
        );
        fail('expected UnsafeDocumentPathException');
      } on UnsafeDocumentPathException catch (e) {
        expect(e.field, 'page.backgroundPath');
      }
    });

    test('a hostile template cannot escape through any path field', () {
      final hostile = _templateJson(<String, dynamic>{
        'pages': <dynamic>[
          <String, dynamic>{
            'id': 'p1',
            'backgroundType': 'pdf',
            'backgroundPath': '../../../sdcard/DCIM/private.jpg',
            'previewPath': '/data/data/com.soobujmiah.docdr/databases/app.db',
            'elements': <dynamic>[
              <String, dynamic>{
                'id': 'e1',
                'type': 'image',
                'keyName': 'logo',
                'label': 'Logo',
                'assetPath': '..%2f..%2fsecrets.png',
                'fontPath': 'file:///system/fonts/NotoSans.ttf',
              },
            ],
          },
        ],
      });
      expect(
        () => DocDrTemplate.fromJson(hostile),
        throwsA(isA<UnsafeDocumentPathException>()),
      );
    });
  });
}
