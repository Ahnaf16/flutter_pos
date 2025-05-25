import 'package:pos/features/inventory_record/controller/inventory_record_ctrl.dart';
import 'package:pos/features/payment_accounts/controller/payment_accounts_ctrl.dart';
import 'package:pos/features/transactions/view/transactions_view.dart';
import 'package:pos/main.export.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

const _headings = [
  TableHeading.positional('#', 80.0),
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
    final accountList = ref.watch(paymentAccountsCtrlProvider());

    return BaseBody(
      title: '${isSale ? 'Sale' : 'Purchase'} Returns',

      body: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: ShadTextField(
                  hintText: 'Search',
                  onChanged: (v) => invCtrl().search(v ?? ''),
                  showClearButton: true,
                ),
              ),

              Expanded(
                child: accountList.maybeWhen(
                  orElse: () => ShadCard(padding: kDefInputPadding, child: const Loading()),
                  data: (accounts) {
                    return ShadSelectField<PaymentAccount>(
                      hintText: 'Account',
                      options: accounts,
                      selectedBuilder: (context, value) => Text(value.name),
                      optionBuilder: (_, value, _) {
                        return ShadOption(value: value, child: Text(value.name));
                      },
                      onChanged: (v) => invCtrl().filter(account: v),
                    );
                  },
                ),
              ),

              const Gap(Insets.xs),
              ShadDatePicker.range(
                key: ValueKey(isSale),
                onRangeChanged: (v) => invCtrl().filter(range: v),
              ),
              ShadIconButton.raw(
                icon: const Icon(LuIcons.x),
                onPressed: () => invCtrl().filter(),
                variant: ShadButtonVariant.destructive,
              ),
            ],
          ),
          const Gap(Insets.med),
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
                        value: Column(
                          spacing: Insets.xs,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SpacedText(
                              left: 'Account',
                              right: '${data.isSale ? '-' : '+'}${data.adjustAccount.currency()}',
                            ),
                            SpacedText(
                              left: 'Total',
                              right: '${data.isSale ? '-' : '+'}${data.totalReturn.currency()}',
                            ),
                          ],
                        ),
                      ),
                      'Account' => DataGridCell(
                        columnName: head.name,
                        value: ShadBadge.secondary(child: Text(data.returnedRec?.account?.name.up ?? '--')),
                      ),

                      'Date' => DataGridCell(
                        columnName: head.name,
                        value: Center(child: Text(data.returnDate.formatDate())),
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
