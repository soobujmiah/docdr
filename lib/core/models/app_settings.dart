enum DocDrThemeMode { system, light, dark, technology, classic, colorful }

enum DocDrDefaultView { grid, list }

class DocDrAppSettings {
  final DocDrThemeMode themeMode;
  final DocDrDefaultView defaultView;
  final bool rememberLastDocument;
  final bool autoSave;
  final bool confirmBeforeDelete;
  final bool keepScreenAwakeWhileEditing;
  final bool hapticFeedback;
  final String defaultExportDirectory;

  const DocDrAppSettings({
    this.themeMode = DocDrThemeMode.system,
    this.defaultView = DocDrDefaultView.grid,
    this.rememberLastDocument = true,
    this.autoSave = true,
    this.confirmBeforeDelete = true,
    this.keepScreenAwakeWhileEditing = true,
    this.hapticFeedback = true,
    this.defaultExportDirectory = '',
  });

  DocDrAppSettings copyWith({
    DocDrThemeMode? themeMode,
    DocDrDefaultView? defaultView,
    bool? rememberLastDocument,
    bool? autoSave,
    bool? confirmBeforeDelete,
    bool? keepScreenAwakeWhileEditing,
    bool? hapticFeedback,
    String? defaultExportDirectory,
  }) => DocDrAppSettings(
        themeMode: themeMode ?? this.themeMode,
        defaultView: defaultView ?? this.defaultView,
        rememberLastDocument: rememberLastDocument ?? this.rememberLastDocument,
        autoSave: autoSave ?? this.autoSave,
        confirmBeforeDelete: confirmBeforeDelete ?? this.confirmBeforeDelete,
        keepScreenAwakeWhileEditing: keepScreenAwakeWhileEditing ?? this.keepScreenAwakeWhileEditing,
        hapticFeedback: hapticFeedback ?? this.hapticFeedback,
        defaultExportDirectory: defaultExportDirectory ?? this.defaultExportDirectory,
      );

  Map<String, dynamic> toJson() => {
        'themeMode': themeMode.name,
        'defaultView': defaultView.name,
        'rememberLastDocument': rememberLastDocument,
        'autoSave': autoSave,
        'confirmBeforeDelete': confirmBeforeDelete,
        'keepScreenAwakeWhileEditing': keepScreenAwakeWhileEditing,
        'hapticFeedback': hapticFeedback,
        'defaultExportDirectory': defaultExportDirectory,
      };
}
