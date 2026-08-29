/// Selection state kept separate from the document model.
class EditorSelectionState {
  final String? selectedId;

  const EditorSelectionState({this.selectedId});

  bool contains(String id) => selectedId == id;

  EditorSelectionState select(String id) => EditorSelectionState(selectedId: id);
  EditorSelectionState clear() => const EditorSelectionState();
}
