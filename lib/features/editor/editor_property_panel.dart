import 'package:flutter/material.dart';

import '../../core/models/docdr_template.dart';

class DocDrEditorPropertyPanel extends StatelessWidget {
  final DocDrElement? element;
  final ValueChanged<String>? onValueChanged;
  final ValueChanged<String>? onDataKeyChanged;
  final ValueChanged<double>? onRotationChanged;
  final VoidCallback? onFlipHorizontal;
  final VoidCallback? onFlipVertical;

  const DocDrEditorPropertyPanel({
    super.key,
    required this.element,
    this.onValueChanged,
    this.onDataKeyChanged,
    this.onRotationChanged,
    this.onFlipHorizontal,
    this.onFlipVertical,
  });

  @override
  Widget build(BuildContext context) {
    final current = element;
    if (current == null) {
      return const Center(child: Text('Select an element to edit'));
    }
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text('Element: ${current.type.name}', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 16),
        TextFormField(
          initialValue: current.value ?? '',
          decoration: const InputDecoration(labelText: 'Value'),
          onChanged: onValueChanged,
        ),
        const SizedBox(height: 12),
        TextFormField(
          initialValue: current.dataKey ?? '',
          decoration: const InputDecoration(labelText: 'Data key'),
          onChanged: onDataKeyChanged,
        ),
        const SizedBox(height: 16),
        Text('Rotation: ${((current.style['rotation'] as num?)?.toDouble() ?? 0).round()}°'),
        Slider(
          min: -180,
          max: 180,
          value: ((current.style['rotation'] as num?)?.toDouble() ?? 0).clamp(-180, 180),
          onChanged: onRotationChanged,
        ),
        Row(
          children: [
            Expanded(child: OutlinedButton.icon(onPressed: onFlipHorizontal, icon: const Icon(Icons.flip), label: const Text('Flip H'))),
            const SizedBox(width: 8),
            Expanded(child: OutlinedButton.icon(onPressed: onFlipVertical, icon: const Icon(Icons.flip_camera_android), label: const Text('Flip V'))),
          ],
        ),
      ],
    );
  }
}
