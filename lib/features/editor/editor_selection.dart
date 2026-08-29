import '../../core/models/docdr_template.dart';

class DocDrEditorSelection {
  final String? selectedId;

  const DocDrEditorSelection({this.selectedId});

  bool contains(DocDrElement element) => element.id == selectedId;

  DocDrEditorSelection select(String id) => DocDrEditorSelection(selectedId: id);
  DocDrEditorSelection clear() => const DocDrEditorSelection();
}
