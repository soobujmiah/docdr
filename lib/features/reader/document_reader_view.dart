import 'package:flutter/material.dart';

import '../../core/models/reader_state.dart';

class DocDrDocumentReaderView extends StatefulWidget {
  final Widget page;
  final int pageCount;

  const DocDrDocumentReaderView({super.key, required this.page, required this.pageCount});

  @override
  State<DocDrDocumentReaderView> createState() => _DocDrDocumentReaderViewState();
}

class _DocDrDocumentReaderViewState extends State<DocDrDocumentReaderView> {
  late DocDrReaderState state;
  final TransformationController transform = TransformationController();

  @override
  void initState() {
    super.initState();
    state = DocDrReaderState(pageCount: widget.pageCount);
  }

  void _zoom(double factor) {
    setState(() => state = state.copyWith(zoom: (state.zoom * factor).clamp(.25, 8.0), fitWidth: false));
    transform.value = Matrix4.identity()..scale(state.zoom);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Material(
          child: Row(
            children: [
              IconButton(onPressed: state.pageIndex > 0 ? () => setState(() => state = state.previousPage()) : null, icon: const Icon(Icons.chevron_left)),
              Text('${state.pageIndex + 1} / ${state.pageCount}'),
              IconButton(onPressed: state.pageIndex + 1 < state.pageCount ? () => setState(() => state = state.nextPage()) : null, icon: const Icon(Icons.chevron_right)),
              const Spacer(),
              IconButton(onPressed: () => _zoom(.8), icon: const Icon(Icons.remove)),
              Text('${(state.zoom * 100).round()}%'),
              IconButton(onPressed: () => _zoom(1.25), icon: const Icon(Icons.add)),
              IconButton(onPressed: () => setState(() { state = state.copyWith(zoom: 1, fitWidth: true); transform.value = Matrix4.identity(); }), icon: const Icon(Icons.fit_screen)),
            ],
          ),
        ),
        Expanded(
          child: InteractiveViewer(
            transformationController: transform,
            minScale: .25,
            maxScale: 8,
            boundaryMargin: const EdgeInsets.all(80),
            child: Center(child: widget.page),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    transform.dispose();
    super.dispose();
  }
}
