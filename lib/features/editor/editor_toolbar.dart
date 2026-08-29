import 'package:flutter/material.dart';

class DocDrEditorToolbar extends StatelessWidget {
  final VoidCallback? onUndo;
  final VoidCallback? onRedo;
  final VoidCallback? onZoomIn;
  final VoidCallback? onZoomOut;
  final VoidCallback? onResetView;
  final VoidCallback? onRotateLeft;
  final VoidCallback? onRotateRight;
  final VoidCallback? onFlipHorizontal;
  final VoidCallback? onFlipVertical;
  final VoidCallback? onSave;

  const DocDrEditorToolbar({
    super.key,
    this.onUndo,
    this.onRedo,
    this.onZoomIn,
    this.onZoomOut,
    this.onResetView,
    this.onRotateLeft,
    this.onRotateRight,
    this.onFlipHorizontal,
    this.onFlipVertical,
    this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    final actions = <Widget>[
      _button(Icons.undo, 'Undo', onUndo),
      _button(Icons.redo, 'Redo', onRedo),
      _button(Icons.zoom_out, 'Zoom out', onZoomOut),
      _button(Icons.zoom_in, 'Zoom in', onZoomIn),
      _button(Icons.fit_screen, 'Reset view', onResetView),
      _button(Icons.rotate_left, 'Rotate left', onRotateLeft),
      _button(Icons.rotate_right, 'Rotate right', onRotateRight),
      _button(Icons.flip, 'Flip horizontal', onFlipHorizontal),
      _button(Icons.flip_camera_android, 'Flip vertical', onFlipVertical),
      _button(Icons.save, 'Save', onSave),
    ];
    return Material(
      elevation: 2,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(mainAxisSize: MainAxisSize.min, children: actions),
      ),
    );
  }

  Widget _button(IconData icon, String tooltip, VoidCallback? onPressed) =>
      IconButton(tooltip: tooltip, onPressed: onPressed, icon: Icon(icon));
}
