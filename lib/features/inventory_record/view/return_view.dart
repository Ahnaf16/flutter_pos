import 'package:pos/features/inventory_record/controller/inventory_record_ctrl.dart';
import 'package:pos/features/transactions/view/transactions_view.dart';
import 'package:pos/main.export.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

const _headings = [
  TableHeading.positional('From'),
  TableHeading.positional('By'),
  TableHeading.positional('Amount', 300.0, Alignment.center),
  TableHeading.positional('Account', 200.0, Alignment.center),
  TableHeading.positional('Date', 150.0, Alignment.center),
];

class ReturnView extends HookConsumerWidget {
  const ReturnView({super.key, required this.isSale});

  final bool isSale;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final inventoryList = ref.watch(inventoryReturnCtrlProvider(isSale));
    return BaseBody(
      title: '${isSale ? 'Sale' : 'Purchase'} Returns',

      body: inventoryList.when(
        loading: () => const Loading(),
        error: (e, s) => ErrorView(e, s, prov: inventoryReturnCtrlProvider),
        data: (inventories) {
          return DataTableBuilder<ReturnRecord, TableHeading>(
            rowHeight: 110,
            items: inventories,
            headings: _headings,
            headingBuilderIndexed: (heading, i) {
              final alignment = heading.alignment;
              return GridColumn(
                columnName: heading.name,
                columnWidthMode: ColumnWidthMode.fill,
                maximumWidth: heading.max,
                minimumWidth: context.layout.isDesktop ? 100 : 200,
                label: Container(padding: Pads.med(), alignment: alignment, child: Text(heading.name)),
              );
            },
            cellAlignmentBuilder: (i) => _headings.fromName(i).alignment,
            cellBuilder: (data, head) {
              return switch (head.name) {
                'From' => DataGridCell(
                  columnName: head.name,
                  value: NameCellBuilder(data.returnedRec.getParti?.name, data.returnedRec.getParti?.phone),
                ),
                'By' => DataGridCell(
                  columnName: head.name,
                  value: NameCellBuilder(data.returnedBy.name, data.returnedBy.phone),
                ),
                'Amount' => DataGridCell(
                  columnName: head.name,
                  value: Column(
                    spacing: Insets.xs,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SpacedText(
                        left: 'Amount',
                        right: '${data.isSale ? '-' : '+'}${data.deductedFromAccount.currency()}',
                      ),
                      if (data.deductedFromParty > 0)
                        SpacedText(left: 'Party', right: data.deductedFromParty.currency()),
                    ],
                  ),
                ),
                'Account' => DataGridCell(
                  columnName: head.name,
                  value: ShadBadge.secondary(child: Text(data.returnedRec.account.name.up)),
                ),

                'Date' => DataGridCell(columnName: head.name, value: Center(child: Text(data.returnDate.formatDate()))),

                _ => DataGridCell(columnName: head.name, value: Text(data.toString())),
              };
            },
          );
        },
      ),
    );
  }
}
