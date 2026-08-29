# DocDr Editor UX Specification

## Principle

Document content and editing controls must remain visible together. Editing must never force the user to lose sight of the page.

## Canvas requirements

- Pinch-to-zoom and double-tap zoom on touch devices.
- Mouse/trackpad zoom where supported.
- Fit-to-width and fit-to-page commands.
- Pan while zoomed without accidentally editing content.
- Visible zoom percentage/state.
- Reset zoom.
- Rotate clockwise/counter-clockwise in 90-degree steps.
- Free rotation where technically appropriate for selected elements.
- Horizontal and vertical flip.
- The document canvas remains the primary visual surface at all times.

## Editing layout

Use a responsive editor rather than separate editor and preview screens:

```text
+------------------------------------------------+
| Back | Document | Undo Redo | Zoom | Save     |
+------------------------------------------------+
|                                                |
|             LIVE DOCUMENT CANVAS              |
|                                                |
|      select / move / resize / edit            |
|                                                |
+----------------------+-------------------------+
| Tool rail / toolbar  | Context properties      |
| Text                 | selected element        |
| Image                | typography             |
| Shape                | position / size       |
| Signature            | rotation / flip       |
| QR / Barcode         | data key              |
| OCR                  | alignment             |
+----------------------+-------------------------+
```

On narrow screens the property panel may become a bottom sheet, but the canvas must remain visible behind/above it where practical.

## Selection behavior

- Selected objects have a clear bounding box and handles.
- Move, resize and rotate controls must be discoverable.
- Properties update live.
- Changes support undo/redo.
- Multi-select should be considered for a later release.

## Document operations

The editor should expose, without leaving the current document:

- Save
- Undo / redo
- Zoom / fit
- Rotate page
- Flip page
- Add/remove/reorder pages
- Crop/straighten for scanned pages
- Text/image/shape insertion
- OCR
- Data-field insertion
- Export/share

## Accessibility and mobile usability

- Touch targets must be comfortably tappable.
- Toolbar actions should use icons plus accessible labels/tooltips.
- Avoid hidden gestures for critical operations.
- Preserve document visibility when tool panels open.
- Prevent accidental canvas movement while manipulating handles.

## Acceptance criteria

A user can open a document and simultaneously see the document and the tools needed to edit it; zoom from fit-to-page to a close inspection; pan at high zoom; rotate/flip as needed; make edits; undo/redo; and save without navigating through disconnected preview/edit screens.
