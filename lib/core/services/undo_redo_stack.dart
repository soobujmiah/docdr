/// Small generic command history used by document editing features.
class UndoRedoStack<T> {
  final int maxDepth;
  final List<T> _undo = [];
  final List<T> _redo = [];

  UndoRedoStack({this.maxDepth = 100});

  bool get canUndo => _undo.isNotEmpty;
  bool get canRedo => _redo.isNotEmpty;

  void push(T state) {
    _undo.add(state);
    if (_undo.length > maxDepth) _undo.removeAt(0);
    _redo.clear();
  }

  T? undo(T current) {
    if (!canUndo) return null;
    _redo.add(current);
    return _undo.removeLast();
  }

  T? redo(T current) {
    if (!canRedo) return null;
    _undo.add(current);
    return _redo.removeLast();
  }

  void clear() {
    _undo.clear();
    _redo.clear();
  }
}
