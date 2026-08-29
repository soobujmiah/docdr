// Storage slice: template persistence, asset containment and duplicate.
//
// Uses real dart:io against a temporary directory, so the tests run on a plain
// Dart VM and in `flutter test` without any Android emulator.

import 'dart:convert';
import 'dart:io';

import 'package:docdr/core/models/custom_template.dart';
import 'package:docdr/core/security/document_path.dart';
import 'package:docdr/core/services/clock.dart';
import 'package:docdr/core/storage/template_store.dart';
import 'package:test/test.dart';

Directory? _tmp;
Directory? _outside;

Directory get tmp => _tmp!;
Directory get outside => _outside!;

set tmp(Directory value) => _tmp = value;

final DateTime fixedNow = DateTime(2026, 8, 29, 12);

DocDrTemplateStore makeStore({
  TemplateStoreLimits limits = const TemplateStoreLimits(),
}) =>
    DocDrTemplateStore(
      root: Directory('${tmp.path}/templates'),
      limits: limits,
      clock: FixedDocumentClock(fixedNow),
    );

DocDrTemplate simpleTemplate([String name = 'Demo']) => DocDrTemplate(
      id: 't1',
      name: name,
      description: 'a demo',
      createdAt: fixedNow,
      updatedAt: fixedNow,
      pages: <DocDrPage>[
        DocDrPage(
          id: 'page_1',
          backgroundType: DocDrBackgroundType.blank,
          elements: <DocDrElement>[
            DocDrElement.create(DocDrElementType.text, 1)..keyName = 'name',
          ],
        ),
      ],
    );

void main() {
  setUp(() {
    final base = Directory.systemTemp.createTempSync('docdr_store_test_');
    _tmp = base;
    _outside = Directory('${base.path}_outside')..createSync(recursive: true);
  });

  tearDown(() {
    try {
      tmp.deleteSync(recursive: true);
    } on Object {
      // best effort
    }
    try {
      outside.deleteSync(recursive: true);
    } on Object {
      // best effort
    }
    _tmp = null;
    _outside = null;
  });

  group('save and load', () {
    test('writes a manifest that round-trips', () async {
      final store = makeStore();
      final saved = await store.save(simpleTemplate());

      expect(saved.basePath, isNotEmpty);
      final manifest = File('${saved.basePath}/template.json');
      expect(await manifest.exists(), isTrue);

      final raw = await manifest.readAsString();
      expect(jsonDecode(raw), containsPair('schemaVersion', 2));

      final loaded = await store.load('t1');
      expect(loaded.name, 'Demo');
      expect(loaded.description, 'a demo');
      expect(loaded.pages.single.elements.single.keyName, 'name');
    });

    test('pretty-prints the manifest for readable diffs', () async {
      final store = makeStore();
      final saved = await store.save(simpleTemplate());
      final raw = await File('${saved.basePath}/template.json').readAsString();
      expect(raw, contains('\n  "schemaVersion"'));
    });

    test('uses the injected clock for updatedAt', () async {
      final store = makeStore();
      final template = simpleTemplate()..updatedAt = DateTime(2000);
      final saved = await store.save(template, now: fixedNow);
      expect(saved.updatedAt, fixedNow);
    });

    test('tryLoad returns null for a missing template', () async {
      final store = makeStore();
      expect(await store.tryLoad('nope'), isNull);
    });

    test('load throws for a missing template', () async {
      final store = makeStore();
      expect(store.load('nope'), throwsA(isA<TemplateStoreException>()));
    });

    test('rejects a manifest larger than the configured limit', () async {
      final store = makeStore(
        limits: const TemplateStoreLimits(maxManifestBytes: 10),
      );
      expect(
        store.save(simpleTemplate()),
        throwsA(isA<TemplateStoreException>()),
      );
    });
  });

  group('listTemplates', () {
    test('returns templates newest-first', () async {
      final store = makeStore();
      final older = simpleTemplate('Older')..id = 'older';
      final newer = simpleTemplate('Newer')..id = 'newer';
      await store.save(older, now: DateTime(2026, 1, 1));
      await store.save(newer, now: DateTime(2026, 8, 1));

      final names = (await store.listTemplates()).map((t) => t.name).toList();
      expect(names, <String>['Newer', 'Older']);
    });

    test('skips a damaged package without hiding the others', () async {
      final store = makeStore();
      await store.save(simpleTemplate('Good')..id = 'good');

      final broken = Directory('${tmp.path}/templates/broken')
        ..createSync(recursive: true);
      File('${broken.path}/template.json').writeAsStringSync('{not json');

      final templates = await store.listTemplates();
      expect(templates.map((t) => t.name), <String>['Good']);
    });

    test('returns an empty list for an empty store', () async {
      expect(await makeStore().listTemplates(), isEmpty);
    });
  });

  group('createBlank', () {
    test('creates one A4 blank page', () async {
      final store = makeStore();
      final blank = await store.createBlank('   ');
      expect(blank.name, 'Blank template');
      expect(blank.pages, hasLength(1));
      expect(blank.pages.single.backgroundType, DocDrBackgroundType.blank);
      expect(blank.pages.single.widthPoints, 595.28);
      expect(blank.pages.single.heightPoints, 841.89);
      expect(blank.pages.single.elements, isEmpty);
    });

    test('honours an explicit page size and name', () async {
      final store = makeStore();
      final blank = await store.createBlank(
        ' Receipt ',
        widthPoints: 300,
        heightPoints: 600,
      );
      expect(blank.name, 'Receipt');
      expect(blank.pages.single.widthPoints, 300);
      expect(blank.pages.single.heightPoints, 600);
    });
  });

  group('assets', () {
    test('importAsset copies the file and returns a relative path', () async {
      final store = makeStore();
      final saved = await store.save(simpleTemplate());

      final source = File('${outside.path}/logo.png')
        ..writeAsBytesSync(<int>[1, 2, 3, 4]);
      final relative = await store.importAsset(saved, source.path);

      expect(relative, startsWith('assets/'));
      expect(relative, endsWith('_logo.png'));
      expect(await store.readAsset(saved, relative), <int>[1, 2, 3, 4]);
    });

    test('sanitizes a hostile file name', () async {
      final store = makeStore();
      final saved = await store.save(simpleTemplate());

      final source = File('${outside.path}/..\\\\..evil name!.png')
        ..writeAsBytesSync(<int>[9]);
      final relative = await store.importAsset(saved, source.path);

      // The security property is that no path SEGMENT is a traversal marker -
      // a filename may legitimately contain ".." (for example "a..b.png").
      expect(relative.split('/'), everyElement(isNot('..')));
      expect(relative.split('/').last, isNot(startsWith('.')));
      expect(relative, isNot(contains('\\')));
      expect(relative.split('/').last, endsWith('.png'));
      // And the sanitized name must still resolve safely inside the template.
      expect(await store.readAsset(saved, relative), <int>[9]);
    });

    test('rejects a missing asset', () async {
      final store = makeStore();
      final saved = await store.save(simpleTemplate());
      expect(
        store.importAsset(saved, '${outside.path}/nope.png'),
        throwsA(isA<TemplateStoreException>()),
      );
    });

    test('rejects an asset over the size limit', () async {
      final store = makeStore(
        limits: const TemplateStoreLimits(maxAssetBytes: 4),
      );
      final saved = await store.save(simpleTemplate());
      final source = File('${outside.path}/big.png')
        ..writeAsBytesSync(List<int>.filled(64, 7));
      expect(
        store.importAsset(saved, source.path),
        throwsA(isA<TemplateStoreException>()),
      );
    });
  });

  group('asset path containment (DOC-05 storage half)', () {
    test('resolves a normal relative asset inside the template', () async {
      final store = makeStore();
      final saved = await store.save(simpleTemplate());
      final resolved = store.resolveAssetPath(saved, 'background/page_1.pdf');
      expect(resolved, startsWith(saved.basePath));
      expect(resolved, endsWith('background/page_1.pdf'));
    });

    test('rejects traversal, absolute and empty paths', () async {
      final store = makeStore();
      final saved = await store.save(simpleTemplate());
      for (final bad in <String>['../../secrets.pdf', '/etc/passwd', '']) {
        expect(
          () => store.resolveAssetPath(saved, bad),
          throwsA(isA<UnsafeDocumentPathException>()),
          reason: 'must reject "$bad"',
        );
      }
    });

    test('rejects a path that escapes through a symbolic link', () async {
      final store = makeStore();
      final saved = await store.save(simpleTemplate());

      // "assets" inside the template points at a directory outside it.
      Link('${saved.basePath}/assets').createSync(outside.path,
          recursive: true);

      expect(
        () => store.resolveAssetPath(saved, 'assets/secret.png'),
        throwsA(isA<UnsafeDocumentPathException>()),
      );
    });

    test('readAsset cannot read outside the template directory', () async {
      final store = makeStore();
      final saved = await store.save(simpleTemplate());
      File('${outside.path}/secret.txt').writeAsStringSync('classified');
      expect(
        store.readAsset(saved, '../secret.txt'),
        throwsA(isA<UnsafeDocumentPathException>()),
      );
    });

    test('refuses to store a template whose basePath is outside the root',
        () async {
      final store = makeStore();
      final escaped = simpleTemplate()..basePath = '${outside.path}/escape';
      expect(
        store.save(escaped),
        throwsA(isA<TemplateStoreException>()),
      );
    });
  });

  group('complexity limits', () {
    test('rejects too many pages', () async {
      final store = makeStore(limits: const TemplateStoreLimits(maxPages: 2));
      final template = simpleTemplate()
        ..pages = List<DocDrPage>.generate(
          5,
          (i) => DocDrPage(
            id: 'p$i',
            backgroundType: DocDrBackgroundType.blank,
          ),
        );
      expect(
        store.save(template),
        throwsA(isA<TemplateStoreException>()),
      );
    });

    test('rejects too many elements on one page', () async {
      final store = makeStore(
        limits: const TemplateStoreLimits(maxElementsPerPage: 3),
      );
      final template = simpleTemplate()
        ..pages = <DocDrPage>[
          DocDrPage(
            id: 'p1',
            backgroundType: DocDrBackgroundType.blank,
            elements: List<DocDrElement>.generate(
              10,
              (i) => DocDrElement.create(DocDrElementType.text, i),
            ),
          ),
        ];
      expect(
        store.save(template),
        throwsA(isA<TemplateStoreException>()),
      );
    });
  });

  group('delete and duplicate', () {
    test('delete removes the template directory', () async {
      final store = makeStore();
      final saved = await store.save(simpleTemplate());
      expect(Directory(saved.basePath).existsSync(), isTrue);

      await store.delete(saved);
      expect(Directory(saved.basePath).existsSync(), isFalse);
      expect(await store.tryLoad('t1'), isNull);
    });

    test('delete is safe on an already removed template', () async {
      final store = makeStore();
      final saved = await store.save(simpleTemplate());
      await store.delete(saved);
      await store.delete(saved);
    });

    test('duplicate copies assets and is independent of the original',
        () async {
      final store = makeStore();
      final original = await store.save(simpleTemplate('Original'));

      final source = File('${outside.path}/logo.png')
        ..writeAsBytesSync(<int>[5, 6, 7]);
      final relative = await store.importAsset(original, source.path);

      final copy = await store.duplicate(original);

      expect(copy.id, isNot(original.id));
      expect(copy.name, 'Original Copy');
      expect(copy.basePath, isNot(original.basePath));
      expect(await store.readAsset(copy, relative), <int>[5, 6, 7]);

      // Independence: deleting the original leaves the copy intact.
      await store.delete(original);
      expect(await store.tryLoad(copy.id), isNotNull);
      expect(await store.readAsset(copy, relative), <int>[5, 6, 7]);
    });

    test('duplicate accepts an explicit name', () async {
      final store = makeStore();
      final original = await store.save(simpleTemplate('Original'));
      final copy = await store.duplicate(original, name: 'Renamed');
      expect(copy.name, 'Renamed');
    });

    test('both templates appear after duplication', () async {
      final store = makeStore();
      final original = await store.save(simpleTemplate('Original'));
      await store.duplicate(original);
      expect(await store.listTemplates(), hasLength(2));
    });
  });
}
