import 'package:flutter/material.dart';

/// Canvas viewport for the editor. Content stays readable while tools remain
/// outside the document surface.
class DocumentCanvas extends StatelessWidget {
  final Widget document;
  final double zoom;
  final VoidCallback? onResetZoom;

  const DocumentCanvas({
    super.key,
    required this.document,
    this.zoom = 1,
    this.onResetZoom,
  });

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          children: [
            InteractiveViewer(
              minScale: .25,
              maxScale: 8,
              boundaryMargin: const EdgeInsets.all(160),
              constrained: false,
              child: Transform.scale(scale: zoom, child: document),
            ),
            Positioned(
              right: 12,
              bottom: 12,
              child: Material(
                elevation: 3,
                borderRadius: BorderRadius.circular(24),
                child: InkWell(
                  onTap: onResetZoom,
                  borderRadius: BorderRadius.circular(24),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    child: Text('${(zoom * 100).round()}%'),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
