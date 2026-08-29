import '../../core/models/docdr_template.dart';
import '../../core/models/document_view_state.dart';
import '../../core/services/undo_redo_stack.dart';

/// UI-independent editing controller for template documents.
class DocDrEditorController {
  DocDrTemplate template;
  DocumentViewState viewState;
  final UndoRedoStack<DocDrTemplate> history;

  DocDrEditorController({required this.template})
      : viewState = const DocumentViewState(),
        history = UndoRedoStack<DocDrTemplate>();

  void selectViewState(DocumentViewState state) => viewState = state;

  void updateTemplate(DocDrTemplate next) {
    history.push(template);
    template = next;
  }

  void undo() {
    final previous = history.undo(template);
    if (previous != null) template = previous;
  }

  void redo() {
    final next = history.redo(template);
    if (next != null) template = next;
  }

  void zoomIn() => viewState = viewState.zoomBy(1.25);
  void zoomOut() => viewState = viewState.zoomBy(0.8);
  void rotateClockwise() => viewState = viewState.rotateClockwise();
  void rotateCounterClockwise() => viewState = viewState.rotateCounterClockwise();
  void flipHorizontal() => viewState = viewState.toggleFlipHorizontal();
  void flipVertical() => viewState = viewState.toggleFlipVertical();
  void resetView() => viewState = viewState.resetViewport();
}
