import 'dart:convert';
import 'dart:io';

import '../models/app_settings.dart';

class DocDrAppSettingsStore {
  final File file;

  const DocDrAppSettingsStore(this.file);

  Future<DocDrAppSettings> load() async {
    if (!await file.exists()) return const DocDrAppSettings();
    try {
      final json = jsonDecode(await file.readAsString()) as Map;
      final mode = DocDrThemeMode.values.byName(json['themeMode'] as String? ?? 'system');
      final view = DocDrDefaultView.values.byName(json['defaultView'] as String? ?? 'grid');
      return DocDrAppSettings(
        themeMode: mode,
        defaultView: view,
        rememberLastDocument: json['rememberLastDocument'] as bool? ?? true,
        autoSave: json['autoSave'] as bool? ?? true,
        confirmBeforeDelete: json['confirmBeforeDelete'] as bool? ?? true,
        keepScreenAwakeWhileEditing: json['keepScreenAwakeWhileEditing'] as bool? ?? true,
        hapticFeedback: json['hapticFeedback'] as bool? ?? true,
        defaultExportDirectory: json['defaultExportDirectory'] as String? ?? '',
      );
    } catch (_) {
      return const DocDrAppSettings();
    }
  }

  Future<void> save(DocDrAppSettings settings) async {
    await file.parent.create(recursive: true);
    await file.writeAsString(jsonEncode(settings.toJson()), flush: true);
  }
}
