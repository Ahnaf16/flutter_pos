import 'package:pos/features/filter/view/filter_bar.dart';
import 'package:pos/features/inventory_record/controller/inventory_record_ctrl.dart';
import 'package:pos/features/payment_accounts/controller/payment_accounts_ctrl.dart';
import 'package:pos/features/transactions/view/transactions_view.dart';
import 'package:pos/main.export.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

const _headings = [
  TableHeading.positional('#', 80.0),
  TableHeading.positional('Invoice'),
  TableHeading.positional('From'),
  TableHeading.positional('By'),
  TableHeading.positional('Amount', 300.0),
  TableHeading.positional('Account', 200.0, Alignment.center),
  TableHeading.positional('Date', 150.0, Alignment.center),
];

class ReturnView extends HookConsumerWidget {
  const ReturnView({super.key, required this.isSale});

  final bool isSale;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final inventoryList = ref.watch(inventoryReturnCtrlProvider(isSale));
    final invCtrl = useCallback(() => ref.read(inventoryReturnCtrlProvider(isSale).notifier), [isSale]);
    final accountList = ref.watch(paymentAccountsCtrlProvider()).maybeList();

    return BaseBody(
      title: '${isSale ? 'Sale' : 'Purchase'} Returns',

      body: Column(
        children: [
          FilterBar(
            hintText: 'Search by ${isSale ? 'customer' : 'supplier'} name',
            accounts: accountList,
            onSearch: (q) => invCtrl().search(q),
            onReset: () => invCtrl().refresh(),
            showDateRange: true,
          ),
          Expanded(
            child: inventoryList.when(
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
                      '#' => DataGridCell(
                        columnName: head.name,
                        value: Text((inventories.indexOf(data) + 1).toString()),
                      ),
                      'Invoice' => DataGridCell(
                        columnName: head.name,
                        value: Text.rich(
                          TextSpan(
                            text: data.returnedRec?.invoiceNo ?? '--',
                            children: [
                              if (data.returnedRec != null)
                                WidgetSpan(
                                  child: SmallButton(
                                    icon: LuIcons.copy,
                                    onPressed: () => Copier.copy(data.returnedRec?.invoiceNo),
                                  ),
                                ),
                            ],
                          ),
                          style: context.text.list,
                        ),
                      ),
                      'From' => DataGridCell(
                        columnName: head.name,
                        value: NameCellBuilder(data.returnedRec?.getParti.name, data.returnedRec?.getParti.phone),
                      ),
                      'By' => DataGridCell(
                        columnName: head.name,
                        value: NameCellBuilder(data.returnedBy.name, data.returnedBy.phone),
                      ),
                      'Amount' => DataGridCell(
                        columnName: head.name,
                        value: SpacedText(
                          left: 'Return amount',
                          right: data.totalReturn.currency(),
                        ),
                      ),
                      'Account' => DataGridCell(
                        columnName: head.name,
                        value: ShadBadge.secondary(child: Text(data.account?.name.up ?? '--')),
                      ),

                      'Date' => DataGridCell(
                        columnName: head.name,
                        value: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(data.returnDate.formatDate()),
                            Text(data.returnDate.ago),
                          ],
                        ),
                      ),

                      _ => DataGridCell(columnName: head.name, value: Text(data.toString())),
                    };
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
