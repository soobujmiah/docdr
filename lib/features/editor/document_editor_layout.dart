import 'package:flutter/material.dart';

/// Responsive editor shell: keeps the document canvas large while exposing
/// editing tools and properties in the same workspace.
class DocumentEditorLayout extends StatelessWidget {
  final Widget canvas;
  final Widget toolbar;
  final Widget properties;

  const DocumentEditorLayout({
    super.key,
    required this.canvas,
    required this.toolbar,
    required this.properties,
  });

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final compact = width < 760;

    if (compact) {
      return Column(
        children: [
          toolbar,
          Expanded(child: Padding(padding: const EdgeInsets.all(8), child: canvas)),
          SafeArea(
            top: false,
            child: SizedBox(
              height: 190,
              child: Material(elevation: 8, child: properties),
            ),
          ),
        ],
      );
    }

    return Row(
      children: [
        SizedBox(width: 64, child: toolbar),
        Expanded(
          flex: 7,
          child: Padding(padding: const EdgeInsets.all(16), child: canvas),
        ),
        SizedBox(width: 280, child: properties),
      ],
    );
  }
}
