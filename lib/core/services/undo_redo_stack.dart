/// Small generic command history used by document editing features.
///
/// States are snapshots, not deltas: [T] is expected to be an immutable
/// document/template value. Keep snapshots small; the stack holds at most
/// [maxDepth] of them in each direction.
///
/// ## Memory contract (audit finding DOC-09)
///
/// Both stacks are bounded. In the previous implementation only `_undo` was
/// capped while `_redo` grew without limit, so a long undo run followed by a
/// long redo run could grow one list without bound. Both directions are now
/// capped at [maxDepth].
class UndoRedoStack<T> {
  /// Creates a stack that retains at most [maxDepth] entries per direction.
  UndoRedoStack({this.maxDepth = 100}) {
    if (maxDepth < 1) {
      throw ArgumentError.value(maxDepth, 'maxDepth', 'must be at least 1');
    }
  }

  /// Maximum number of retained entries in each direction.
  final int maxDepth;

  final List<T> _undo = [];
  final List<T> _redo = [];

  /// Whether an undo is available.
  bool get canUndo => _undo.isNotEmpty;

  /// Whether a redo is available.
  bool get canRedo => _redo.isNotEmpty;

  /// Number of retained undo entries, for tests and diagnostics.
  int get undoDepth => _undo.length;

  /// Number of retained redo entries, for tests and diagnostics.
  int get redoDepth => _redo.length;

  /// Records [state] as the newest undo point and invalidates the redo
  /// history, matching standard editor behaviour.
  void push(T state) {
    _undo.add(state);
    _trimUndo();
    _redo.clear();
  }

  /// Moves [current] onto the redo stack and returns the previous state.
  ///
  /// Returns `null` when there is nothing to undo.
  T? undo(T current) {
    if (!canUndo) {
      return null;
    }
    _redo.add(current);
    _trimRedo();
    return _undo.removeLast();
  }

  /// Moves [current] onto the undo stack and returns the next state.
  ///
  /// Returns `null` when there is nothing to redo.
  T? redo(T current) {
    if (!canRedo) {
      return null;
    }
    _undo.add(current);
    _trimUndo();
    return _redo.removeLast();
  }

  /// Discards all history.
  void clear() {
    _undo.clear();
    _redo.clear();
  }

  void _trimUndo() {
    while (_undo.length > maxDepth) {
      _undo.removeAt(0);
    }
  }

  void _trimRedo() {
    while (_redo.length > maxDepth) {
      _redo.removeAt(0);
    }
  }
}
