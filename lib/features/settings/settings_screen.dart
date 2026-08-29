import 'package:flutter/material.dart';

import '../../core/models/app_settings.dart';

class DocDrSettingsScreen extends StatefulWidget {
  final DocDrAppSettings initialSettings;
  final ValueChanged<DocDrAppSettings>? onChanged;

  const DocDrSettingsScreen({
    super.key,
    this.initialSettings = const DocDrAppSettings(),
    this.onChanged,
  });

  @override
  State<DocDrSettingsScreen> createState() => _DocDrSettingsScreenState();
}

class _DocDrSettingsScreenState extends State<DocDrSettingsScreen> {
  late DocDrAppSettings settings = widget.initialSettings;

  void update(DocDrAppSettings next) {
    setState(() => settings = next);
    widget.onChanged?.call(next);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Settings')),
        body: ListView(
          children: [
            const _SectionTitle('Appearance'),
            ListTile(
              leading: const Icon(Icons.brightness_6_outlined),
              title: const Text('Theme'),
              subtitle: Text(settings.themeMode.name),
              onTap: () => _chooseTheme(context),
            ),
            const _SectionTitle('Documents'),
            SwitchListTile(
              secondary: const Icon(Icons.autorenew),
              title: const Text('Auto-save'),
              value: settings.autoSave,
              onChanged: (v) => update(settings.copyWith(autoSave: v)),
            ),
            SwitchListTile(
              secondary: const Icon(Icons.history),
              title: const Text('Remember last document'),
              value: settings.rememberLastDocument,
              onChanged: (v) => update(settings.copyWith(rememberLastDocument: v)),
            ),
            SwitchListTile(
              secondary: const Icon(Icons.delete_outline),
              title: const Text('Confirm before deleting'),
              value: settings.confirmBeforeDelete,
              onChanged: (v) => update(settings.copyWith(confirmBeforeDelete: v)),
            ),
            SwitchListTile(
              secondary: const Icon(Icons.screen_lock_portrait_outlined),
              title: const Text('Keep screen awake while editing'),
              value: settings.keepScreenAwakeWhileEditing,
              onChanged: (v) => update(settings.copyWith(keepScreenAwakeWhileEditing: v)),
            ),
            const _SectionTitle('Interaction'),
            SwitchListTile(
              secondary: const Icon(Icons.vibration),
              title: const Text('Haptic feedback'),
              value: settings.hapticFeedback,
              onChanged: (v) => update(settings.copyWith(hapticFeedback: v)),
            ),
            const _SectionTitle('About'),
            const ListTile(
              leading: Icon(Icons.info_outline),
              title: Text('DocDr'),
              subtitle: Text('Your documents, taken care of.'),
            ),
          ],
        ),
      );

  Future<void> _chooseTheme(BuildContext context) async {
    final selected = await showModalBottomSheet<DocDrThemeMode>(
      context: context,
      builder: (_) => SafeArea(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          for (final mode in DocDrThemeMode.values)
            ListTile(
              title: Text(mode.name),
              trailing: mode == settings.themeMode ? const Icon(Icons.check) : null,
              onTap: () => Navigator.pop(context, mode),
            ),
        ]),
      ),
    );
    if (selected != null) update(settings.copyWith(themeMode: selected));
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 6),
        child: Text(text, style: Theme.of(context).textTheme.labelLarge),
      );
}
