import 'package:pos/main.export.dart';
import 'package:syncfusion_flutter_core/theme.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

class DataTableBuilder<T, R> extends StatefulWidget {
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
  final DataGridCell Function(T data, R head) cellBuilder;
  final GridColumn Function(R heading) headingBuilder;
  final double? rowHeight;
  final EdgeInsetsGeometry? cellPadding;
  final AlignmentGeometry? cellAlignment;
  final Widget? footer;

  @override
  State<DataTableBuilder<T, R>> createState() => _DataTableBuilderState<T, R>();
}

class _DataTableBuilderState<T, R> extends State<DataTableBuilder<T, R>> {
  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: Corners.medBorder,
      child: SfDataGridTheme(
        data: SfDataGridThemeData(headerColor: context.colors.border, gridLineColor: context.colors.border),
        child: SfDataGrid(
          source: _DataSource<T, R>(
            items: widget.items,
            headings: widget.headings,
            cellBuilder: widget.cellBuilder,
            padding: widget.cellPadding,
            alignment: widget.cellAlignment,
          ),
          allowExpandCollapseGroup: true,
          headerGridLinesVisibility: GridLinesVisibility.both,
          highlightRowOnHover: false,
          isScrollbarAlwaysShown: true,
          rowHeight: widget.rowHeight ?? double.nan,
          columns: [for (final h in widget.headings) widget.headingBuilder(h)],
          footer: widget.footer,
        ),
      ),
    );
  }
}

class _DataSource<T, R> extends DataGridSource {
  _DataSource({
    required List<T> items,
    required List<R> headings,
    required DataGridCell Function(T data, R head) cellBuilder,
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
            )
          else
            Text(cell.value.toString()),
      ],
    );
  }
}

class TableHeading {
  const TableHeading({
    required this.cellWidget,
    required this.columnName,
    this.columnWidth,
    this.cellAlignment,
    this.headAlignment,
  });

  final Widget cellWidget;
  final String columnName;
  final double? columnWidth;
  final Alignment? cellAlignment;
  final Alignment? headAlignment;
}
