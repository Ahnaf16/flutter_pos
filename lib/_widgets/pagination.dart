import 'package:pos/main.export.dart';

class Pagination extends StatelessWidget {
  final int page;
  final int totalPages;
  final ValueChanged<int> onPageChanged;

  /// The maximum number of pages to show in the pagination.
  final int maxPages;
  final bool showSkipToFirstPage;
  final bool showSkipToLastPage;
  final bool hidePreviousOnFirstPage;
  final bool hideNextOnLastPage;
  final bool showLabel;

  const Pagination({
    super.key,
    required this.page,
    required this.totalPages,
    required this.onPageChanged,
    this.maxPages = 3,
    this.showSkipToFirstPage = true,
    this.showSkipToLastPage = true,
    this.hidePreviousOnFirstPage = false,
    this.hideNextOnLastPage = false,
    this.showLabel = true,
  });

  bool get hasPrevious => page > 1;
  bool get hasNext => page < totalPages;
  Iterable<int> get pages sync* {
    if (totalPages <= maxPages) {
      yield* List.generate(totalPages, (index) => index + 1);
    } else {
      final start = page - maxPages ~/ 2;
      final end = page + maxPages ~/ 2;
      if (start < 1) {
        yield* List.generate(maxPages, (index) => index + 1);
      } else if (end > totalPages) {
        yield* List.generate(maxPages, (index) => totalPages - maxPages + index + 1);
      } else {
        yield* List.generate(maxPages, (index) => start + index);
      }
    }
  }

  int get firstShownPage {
    if (totalPages <= maxPages) {
      return 1;
    } else {
      final start = page - maxPages ~/ 2;
      return start < 1 ? 1 : start;
    }
  }

  int get lastShownPage {
    if (totalPages <= maxPages) {
      return totalPages;
    } else {
      final end = page + maxPages ~/ 2;
      return end > totalPages ? totalPages : end;
    }
  }

  bool get hasMorePreviousPages => firstShownPage > 1;
  bool get hasMoreNextPages => lastShownPage < totalPages;

  Widget _buildPreviousLabel() {
    return ShadButton.ghost(
      onPressed: hasPrevious ? () => onPageChanged(page - 1) : null,
      leading: const Icon(LuIcons.chevronLeft, size: 12),
      child: showLabel ? const SelectionContainer.disabled(child: Text('Previous')) : null,
    );
  }

  Widget _buildNextLabel() {
    return ShadButton.ghost(
      onPressed: hasNext ? () => onPageChanged(page + 1) : null,
      trailing: const Icon(LuIcons.chevronRight, size: 12),
      child: showLabel ? const SelectionContainer.disabled(child: Text('Next')) : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (!hidePreviousOnFirstPage || hasPrevious) _buildPreviousLabel(),
          if (hasMorePreviousPages) ...[
            if (showSkipToFirstPage && firstShownPage - 1 > 1)
              ShadButton.ghost(onPressed: () => onPageChanged(1), child: const Text('1')),
            ShadButton.ghost(onPressed: () => onPageChanged(firstShownPage - 1), child: const Icon(LuIcons.ellipsis)),
          ],
          for (final p in pages)
            if (p == page)
              ShadButton.outline(onPressed: () => onPageChanged(p), child: Text('$p'))
            else
              ShadButton.ghost(onPressed: () => onPageChanged(p), child: Text('$p')),
          if (hasMoreNextPages) ...[
            ShadButton.ghost(onPressed: () => onPageChanged(lastShownPage + 1), child: const Icon(LuIcons.ellipsis)),
            if (showSkipToLastPage && lastShownPage + 1 < totalPages)
              ShadButton.ghost(onPressed: () => onPageChanged(totalPages), child: Text('$totalPages')),
          ],
          if (!hideNextOnLastPage || hasNext) _buildNextLabel(),
        ],
      ),
    );
  }
}
