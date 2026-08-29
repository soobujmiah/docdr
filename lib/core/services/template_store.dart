import 'dart:convert';
import 'dart:io';

import '../models/docdr_template.dart';

/// Local-first persistence for user-owned DocDr templates.
class DocDrTemplateStore {
  final Directory root;

  const DocDrTemplateStore(this.root);

  Directory get templatesDirectory => Directory('${root.path}/templates');

  Future<void> init() => templatesDirectory.create(recursive: true);

  Future<void> save(DocDrTemplate template) async {
    await init();
    final file = File('${templatesDirectory.path}/${_safeId(template.id)}.json');
    await file.writeAsString(jsonEncode(template.toJson()), flush: true);
  }

  Future<DocDrTemplate?> get(String id) async {
    final file = File('${templatesDirectory.path}/${_safeId(id)}.json');
    if (!await file.exists()) return null;
    try {
      return DocDrTemplate.fromJson(
        Map<String, dynamic>.from(jsonDecode(await file.readAsString()) as Map),
      );
    } on FormatException {
      return null;
    }
  }

  Future<List<DocDrTemplate>> list() async {
    await init();
    final result = <DocDrTemplate>[];
    await for (final entity in templatesDirectory.list()) {
      if (entity is! File || !entity.path.endsWith('.json')) continue;
      try {
        result.add(DocDrTemplate.fromJson(
          Map<String, dynamic>.from(jsonDecode(await entity.readAsString()) as Map),
        ));
      } on FormatException {
        // Ignore malformed user files; a single bad file must not break the library.
      }
    }
    return result;
  }

  Future<bool> delete(String id) async {
    final file = File('${templatesDirectory.path}/${_safeId(id)}.json');
    if (!await file.exists()) return false;
    await file.delete();
    return true;
  }

  String _safeId(String value) => value.replaceAll(RegExp(r'[^A-Za-z0-9._-]'), '_');
}
