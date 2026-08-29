# Editor Interaction Contract

The editor is canvas-first: the document stays readable while controls remain available.

## Element interactions

- Tap/click selects an element.
- Drag moves the selected element.
- Resize handles change width and height.
- Rotation control changes element rotation.
- Flip actions mirror the selected element horizontally or vertically.
- Every mutation is routed through the editor controller so undo/redo can capture it.
- Selection is explicit and can be cleared without changing document content.

## Viewport interactions

- Pinch or wheel controls zoom.
- Pan is available while zoomed.
- Fit-to-page remains one action away.
- Viewport transforms must not mutate the document model.

## Safety

- Minimum element size is enforced by geometry operations.
- Coordinates and dimensions remain numeric and serializable.
- UI code must not directly mutate persisted template JSON.
