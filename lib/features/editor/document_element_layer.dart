import 'package:flutter/material.dart';

import '../../core/models/docdr_template.dart';

/// Renders template elements as interactive, selectable editor objects.
/// Rendering remains deliberately UI-only; persistence is handled by the core model.
class DocumentElementLayer extends StatelessWidget {
  final DocDrTemplate template;
  final String? selectedId;
  final ValueChanged<String> onSelect;
  final void Function(DocDrElement element, Offset delta) onMove;
  final void Function(DocDrElement element, Size size) onResize;

  const DocumentElementLayer({
    super.key,
    required this.template,
    required this.selectedId,
    required this.onSelect,
    required this.onMove,
    required this.onResize,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        for (final element in template.elements)
          Positioned(
            left: element.x,
            top: element.y,
            width: element.width,
            height: element.height,
            child: _EditorElement(
              element: element,
              selected: element.id == selectedId,
              onSelect: () => onSelect(element.id),
              onMove: (delta) => onMove(element, delta),
              onResize: (size) => onResize(element, size),
            ),
          ),
      ],
    );
  }
}

class _EditorElement extends StatelessWidget {
  final DocDrElement element;
  final bool selected;
  final VoidCallback onSelect;
  final ValueChanged<Offset> onMove;
  final ValueChanged<Size> onResize;

  const _EditorElement({
    required this.element,
    required this.selected,
    required this.onSelect,
    required this.onMove,
    required this.onResize,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onSelect,
      onPanUpdate: (details) {
        onSelect();
        onMove(details.delta);
      },
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              border: selected
                  ? Border.all(color: Theme.of(context).colorScheme.primary, width: 2)
                  : Border.all(color: Colors.transparent, width: 1),
            ),
            child: _content(),
          ),
          if (selected)
            Positioned(
              right: -7,
              bottom: -7,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onPanUpdate: (details) => onResize(Size(
                  (element.width + details.delta.dx).clamp(8, double.infinity),
                  (element.height + details.delta.dy).clamp(8, double.infinity),
                )),
                child: const SizedBox(width: 18, height: 18, child: Icon(Icons.open_in_full, size: 14)),
              ),
            ),
        ],
      ),
    );
  }

  Widget _content() {
    switch (element.type) {
      case DocDrElementType.rectangle:
        return Container(decoration: BoxDecoration(border: Border.all()));
      case DocDrElementType.circle:
        return Container(decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all()));
      case DocDrElementType.line:
        return const Align(alignment: Alignment.center, child: Divider());
      default:
        return Padding(
          padding: const EdgeInsets.all(4),
          child: Text(element.value ?? element.dataKey ?? element.type.name),
        );
    }
  }
}
