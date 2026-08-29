// Verification suite for the undo/redo history used by the document editor.
//
// Covers DOC-09. NOTE ON SEVERITY: the original finding described "_redo is
// unbounded". Closer analysis during this slice could not construct a
// reachable sequence that grows _redo beyond maxDepth, because every undo
// consumes an entry from the bounded _undo list. The real defect was that the
// `redo()` method added to _undo *without* applying the maxDepth trim, so the
// "length <= maxDepth" invariant was preserved only by an argument about the
// whole state machine rather than enforced locally. The trim is now applied in
// both directions and the invariant is asserted directly below.

import 'package:docdr/core/services/undo_redo_stack.dart';
import 'package:test/test.dart';

void main() {
  group('basic behaviour', () {
    // SEMANTIC CONTRACT (unchanged from the implementation under test):
    // `_undo` holds states the editor has already committed. `push(x)` records
    // x as history *before* an edit is applied; `undo(current)` returns the
    // newest recorded state and files `current` into the redo list. So the
    // editor calls push(previousState) and passes its live state to undo/redo.
    test('push then undo returns the previous state', () {
      final stack = UndoRedoStack<String>();
      stack.push('a');
      stack.push('b');
      // 'c' is the state currently on screen; 'b' is the newest recorded one.
      expect(stack.undo('c'), 'b');
    });

    test('undo returns null when the stack is empty', () {
      final stack = UndoRedoStack<String>();
      expect(stack.undo('current'), isNull);
      expect(stack.canUndo, isFalse);
    });

    test('redo returns null when there is nothing to redo', () {
      final stack = UndoRedoStack<String>();
      expect(stack.redo('current'), isNull);
      expect(stack.canRedo, isFalse);
    });

    test('redo restores the state that undo displaced', () {
      final stack = UndoRedoStack<String>();
      stack.push('one');
      stack.push('two');

      expect(stack.undo('three'), 'two');
      expect(stack.redo('two'), 'three');
    });

    test('repeated undo walks back through history', () {
      final stack = UndoRedoStack<String>();
      stack.push('one');
      stack.push('two');
      stack.push('three');

      expect(stack.undo('four'), 'three');
      expect(stack.undo('three'), 'two');
      expect(stack.undo('two'), 'one');
      expect(stack.undo('one'), isNull);
    });

    test('a new edit clears the redo history', () {
      final stack = UndoRedoStack<String>();
      stack.push('one');
      stack.push('two');
      stack.undo('three');
      expect(stack.canRedo, isTrue);

      stack.push('four');
      expect(stack.canRedo, isFalse);
    });

    test('clear discards both directions', () {
      final stack = UndoRedoStack<String>();
      stack.push('one');
      stack.undo('two');
      stack.clear();
      expect(stack.canUndo, isFalse);
      expect(stack.canRedo, isFalse);
      expect(stack.undoDepth, 0);
      expect(stack.redoDepth, 0);
    });
  });

  group('bounding', () {
    test('undo history is capped at maxDepth', () {
      final stack = UndoRedoStack<int>(maxDepth: 3);
      for (var i = 0; i < 10; i++) {
        stack.push(i);
      }
      expect(stack.undoDepth, 3);
    });

    test('redo history is capped at maxDepth', () {
      final stack = UndoRedoStack<int>(maxDepth: 3);
      for (var i = 0; i < 10; i++) {
        stack.push(i);
      }
      var current = 999;
      for (var i = 0; i < 10; i++) {
        final previous = stack.undo(current);
        if (previous == null) {
          break;
        }
        current = previous;
      }
      expect(stack.redoDepth, lessThanOrEqualTo(3));
    });

    test('both directions stay bounded across a long mixed session', () {
      const max = 4;
      final stack = UndoRedoStack<int>(maxDepth: max);

      for (var cycle = 0; cycle < 50; cycle++) {
        stack.push(cycle);

        if (cycle % 3 == 0) {
          var current = cycle;
          for (var u = 0; u < 6; u++) {
            final previous = stack.undo(current);
            if (previous == null) {
              break;
            }
            current = previous;
          }
        }

        if (cycle % 5 == 0) {
          var current = cycle;
          for (var r = 0; r < 6; r++) {
            final next = stack.redo(current);
            if (next == null) {
              break;
            }
            current = next;
          }
        }

        // The invariant the previous implementation did not enforce locally.
        expect(stack.undoDepth, lessThanOrEqualTo(max));
        expect(stack.redoDepth, lessThanOrEqualTo(max));
      }
    });

    test('rejects a non-positive maxDepth', () {
      expect(() => UndoRedoStack<String>(maxDepth: 0), throwsArgumentError);
      expect(() => UndoRedoStack<String>(maxDepth: -1), throwsArgumentError);
    });
  });
}
