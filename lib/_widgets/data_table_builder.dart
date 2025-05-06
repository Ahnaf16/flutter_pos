import 'package:pos/main.export.dart';
import 'package:syncfusion_flutter_core/theme.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

class DataTableBuilder<T, R> extends StatefulWidget {
  const DataTableBuilder({
    super.key,
    required this.items,
    required this.headings,
    required this.cellBuilder,
    this.headingBuilder,
    this.headingBuilderIndexed,
    this.rowHeight,
    this.cellPadding,
    this.cellAlignment,
    this.cellAlignmentBuilder,
    this.footer,
  }) : assert(
         headingBuilder != null || headingBuilderIndexed != null,
         'Either headingBuilder or headingBuilderIndexed must be provided',
       );

  final List<T> items;
  final List<R> headings;
  final DataGridCell Function(T data, R head) cellBuilder;

  /// will be ignored if headingBuilderIndexed is provided
  final GridColumn Function(R heading)? headingBuilder;
  final GridColumn Function(R heading, int index)? headingBuilderIndexed;
  final double? rowHeight;
  final EdgeInsetsGeometry? cellPadding;
  final AlignmentGeometry? cellAlignment;
  final AlignmentGeometry Function(String head)? cellAlignmentBuilder;

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
            alignmentBuilder: widget.cellAlignmentBuilder,
          ),
          allowExpandCollapseGroup: true,
          headerGridLinesVisibility: GridLinesVisibility.both,
          highlightRowOnHover: false,
          isScrollbarAlwaysShown: true,
          rowHeight: widget.rowHeight ?? double.nan,
          columns: [
            for (int i = 0; i < widget.headings.length; i++)
              widget.headingBuilderIndexed?.call(widget.headings[i], i) ?? widget.headingBuilder!(widget.headings[i]),
          ],
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
    this.alignmentBuilder,
  }) {
    datas = items.map((e) => DataGridRow(cells: headings.map((h) => cellBuilder(e, h)).toList())).toList();
  }

  List<DataGridRow> datas = [];
  final EdgeInsetsGeometry? padding;
  final AlignmentGeometry? alignment;
  final AlignmentGeometry Function(String head)? alignmentBuilder;

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
              child: Align(
                alignment: alignmentBuilder?.call(cell.columnName) ?? alignment ?? Alignment.center,
                child: cell.value as Widget,
              ),
            )
          else
            Text(cell.value.toString()),
      ],
    );
  }
}

class TableHeading {
  const TableHeading({
    required this.name,
    this.max = double.nan,
    this.min = double.nan,
    this.alignment = Alignment.centerLeft,
  });

  final String name;
  final double max;
  final double min;
  final Alignment alignment;
}

extension TableHeadingEx on List<TableHeading> {
  TableHeading operator [](int index) => this[index];

  TableHeading fromName(String name) => firstWhere((e) => e.name == name);
}
