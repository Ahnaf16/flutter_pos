import 'package:pos/features/filter/view/filter_bar.dart';
import 'package:pos/features/inventory_record/controller/inventory_record_ctrl.dart';
import 'package:pos/features/inventory_record/view/local/inv_invoice_widget.dart';
import 'package:pos/features/payment_accounts/controller/payment_accounts_ctrl.dart';
import 'package:pos/features/payment_accounts/view/payment_accounts_view.dart';
import 'package:pos/features/settings/controller/settings_ctrl.dart';
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
  TableHeading.positional('Action', 200.0, Alignment.centerRight),
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
                          left: 'Total return',
                          right: data.totalReturn.currency(),
                        ),
                      ),
                      'Account' => DataGridCell(
                        columnName: head.name,
                        value: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(data.account?.name ?? '--', style: context.text.list),
                            if (data.account != null)
                              SmallButton(
                                icon: LuIcons.arrowUpRight,
                                onPressed: () {
                                  showShadDialog(
                                    context: context,
                                    builder: (context) => AccountViewDialog(acc: data.account!),
                                  );
                                },
                              ),
                          ],
                        ),
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
                      'Action' => DataGridCell(
                        columnName: head.name,
                        value: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            if (data.returnedRec != null)
                              ShadIconButton(
                                icon: const Icon(LuIcons.eye),
                                onPressed: () {
                                  if (isSale) {
                                    RPaths.saleDetails(data.returnedRec!.id).pushNamed(context);
                                  } else {
                                    RPaths.purchaseDetails(data.returnedRec!.id).pushNamed(context);
                                  }
                                },
                              ).colored(Colors.blue).toolTip('View'),
                            if (data.returnedRec != null)
                              PopOverButton(
                                color: Colors.green,
                                dense: true,
                                icon: const Icon(LuIcons.download),
                                onPressed: () async {
                                  final rec = await ref.read(recordDetailsProvider(data.returnedRec!.id).future);
                                  if (rec == null) return;
                                  final config = await ref.read(configCtrlAsyncProvider.future);

                                  if (!context.mounted) return;
                                  await showShadDialog(
                                    context: context,
                                    builder: (context) => InvInvoiceWidget(rec: rec, config: config),
                                  );
                                },
                                toolTip: 'Download invoice',
                                child: const Text('Download invoice'),
                              ),
                            ShadIconButton(
                              icon: const Icon(LuIcons.trash),
                              onPressed: () async {
                                await showShadDialog(
                                  context: context,
                                  builder: (c) {
                                    return ShadDialog.alert(
                                      title: const Text('Delete Return Record'),
                                      description: Text(
                                        'Deleting a ${isSale ? 'sale' : 'purchase'} return will adjust the stock and account balance but wont create and Transaction. Are you sure?',
                                      ),
                                      actions: [
                                        ShadButton(onPressed: () => c.nPop(), child: const Text('Cancel')),
                                        ShadButton.destructive(
                                          onPressed: () async {
                                            final result = await invCtrl().delete(data);
                                            if (!context.mounted) return;
                                            result.showToast(context);
                                            c.nPop();
                                          },
                                          child: const Text('Delete'),
                                        ),
                                      ],
                                    );
                                  },
                                );
                              },
                            ).colored(context.colors.destructive).toolTip('Delete'),
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
