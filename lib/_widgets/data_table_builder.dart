import 'package:pos/main.export.dart';
import 'package:syncfusion_flutter_core/theme.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

class DataTableBuilder<T, R> extends StatelessWidget {
  const DataTableBuilder({
    super.key,
    required this.items,
    required this.headings,
    required this.cellBuilder,
    required this.headingBuilder,
    this.rowHeight,
    this.cellPadding,
    this.cellAlignment,
    this.footer,
  });

  final List<T> items;
  final List<R> headings;
  final DataGridCell<Widget> Function(T data, R head) cellBuilder;
  final GridColumn Function(R heading) headingBuilder;
  final double? rowHeight;
  final EdgeInsetsGeometry? cellPadding;
  final AlignmentGeometry? cellAlignment;
  final Widget? footer;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: Corners.medBorder,
      child: SfDataGridTheme(
        data: SfDataGridThemeData(headerColor: context.colors.border, gridLineColor: context.colors.border),
        child: SfDataGrid(
          source: _DataSource(
            items: items,
            headings: headings,
            cellBuilder: cellBuilder,
            padding: cellPadding,
            alignment: cellAlignment,
          ),
          headerGridLinesVisibility: GridLinesVisibility.both,
          highlightRowOnHover: false,
          isScrollbarAlwaysShown: true,
          rowHeight: rowHeight ?? double.nan,
          columns: [for (final h in headings) headingBuilder(h)],
          footer: footer,
        ),
      ),
    );
  }
}

class _DataSource<T, R> extends DataGridSource {
  _DataSource({
    required List<T> items,
    required List<R> headings,
    required DataGridCell<Widget> Function(T data, R head) cellBuilder,
    this.padding,
    this.alignment,
  }) {
    datas = items.map((e) => DataGridRow(cells: headings.map((h) => cellBuilder(e, h)).toList())).toList();
  }

  List<DataGridRow> datas = [];
  final EdgeInsetsGeometry? padding;
  final AlignmentGeometry? alignment;

  @override
  List<DataGridRow> get rows => datas;

  @override
  DataGridRowAdapter? buildRow(DataGridRow row) {
    return DataGridRowAdapter(
      cells: [
        for (final cell in row.getCells())
          if (cell.value is Widget)
            Padding(
              padding: padding ?? Pads.med(),
              child: Align(alignment: alignment ?? Alignment.center, child: cell.value as Widget),
            ),
      ],
    );
  }
}
