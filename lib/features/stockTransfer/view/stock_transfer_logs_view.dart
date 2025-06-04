import 'package:pos/features/filter/view/filter_bar.dart';
import 'package:pos/features/products/view/products_view.dart';
import 'package:pos/features/stockTransfer/controller/stock_transfer_list_ctrl.dart';
import 'package:pos/features/warehouse/controller/warehouse_ctrl.dart';
import 'package:pos/main.export.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

const _headings = [
  TableHeading.positional('#', 60.0),
  TableHeading.positional('Product'),
  TableHeading.positional('From', 200.0),
  TableHeading.positional('To', 200.0),
  TableHeading.positional('Transfer Qty', 300.0),
  TableHeading.positional('Date', 200.0, Alignment.centerRight),
];

class StockTransferLogsView extends HookConsumerWidget {
  const StockTransferLogsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final logList = ref.watch(stockTransferListCtrlProvider);
    final ctrl = useCallback(() => ref.read(stockTransferListCtrlProvider.notifier));

    final houseList = ref.watch(warehouseCtrlProvider).maybeList();

    return BaseBody(
      title: 'Stock Transfer',
      body: logList.when(
        loading: () => const Loading(),
        error: (e, s) => ErrorView(e, s, prov: stockTransferListCtrlProvider),
        data: (logs) {
          return Column(
            children: [
              FilterBar(
                hintText: 'Search by warehouse or product name',
                houses: houseList,
                onSearch: (q) => ctrl().search(q),
                onReset: () => ctrl().refresh(),
                showDateRange: true,
              ),
              Expanded(
                child: DataTableBuilder<StockTransferLog, TableHeading>(
                  rowHeight: 120,
                  items: logs,
                  headings: _headings,
                  headingBuilder: (heading) {
                    return GridColumn(
                      columnName: heading.name,
                      columnWidthMode: ColumnWidthMode.fill,
                      maximumWidth: heading.max,
                      minimumWidth: heading.minWidth ?? 200,
                      label: Container(
                        padding: Pads.med(),
                        alignment: heading.alignment,
                        child: Text(heading.name),
                      ),
                    );
                  },
                  cellAlignmentBuilder: (h) => _headings.fromName(h).alignment,
                  cellBuilder: (data, head) {
                    return switch (head.name) {
                      '#' => DataGridCell(
                        columnName: head.name,
                        value: Text((logs.indexWhere((e) => e.id == data.id) + 1).toString()),
                      ),
                      'Product' => DataGridCell(
                        columnName: head.name,
                        value: ProductsView.nameCellBuilder(data.product),
                      ),
                      'From' => DataGridCell(
                        columnName: head.name,
                        value: Text(data.from?.name ?? '--'),
                      ),
                      'To' => DataGridCell(
                        columnName: head.name,
                        value: Text(data.to?.name ?? '--'),
                      ),
                      'Transfer Qty' => DataGridCell(
                        columnName: head.name,
                        value: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          spacing: Insets.xs,
                          children: [
                            SpacedText(
                              left: 'Qty',
                              right: data.stock == null ? '--' : '${data.stock?.quantity} ${data.product?.unitName}',
                            ),
                            SpacedText(left: 'Purchase', right: data.stock?.purchasePrice.currency() ?? '--'),
                          ],
                        ),
                      ),
                      'Date' => DataGridCell(
                        columnName: head.name,
                        value: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(data.date.formatDate()),
                            Text(data.date.ago),
                          ],
                        ),
                      ),
                      _ => DataGridCell(columnName: head.name, value: Text(data.toString())),
                    };
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
