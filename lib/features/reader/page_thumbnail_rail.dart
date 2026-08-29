import 'package:flutter/material.dart';

class DocDrPageThumbnailRail extends StatelessWidget {
  final int pageCount;
  final int currentPage;
  final ValueChanged<int> onPageSelected;

  const DocDrPageThumbnailRail({super.key, required this.pageCount, required this.currentPage, required this.onPageSelected});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 92,
      child: ListView.separated(
        padding: const EdgeInsets.all(8),
        itemCount: pageCount,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (_, index) => InkWell(
          onTap: () => onPageSelected(index),
          borderRadius: BorderRadius.circular(6),
          child: Container(
            height: 112,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              border: Border.all(
                width: index == currentPage ? 2 : 1,
                color: index == currentPage ? Theme.of(context).colorScheme.primary : Theme.of(context).dividerColor,
              ),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text('${index + 1}'),
          ),
        ),
      ),
    );
  }
}
