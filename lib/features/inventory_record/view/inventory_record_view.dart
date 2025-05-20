import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:pos/features/inventory_record/controller/inventory_record_ctrl.dart';
import 'package:pos/features/inventory_record/controller/record_editing_ctrl.dart';
import 'package:pos/features/inventory_record/view/local/inv_invoice_widget.dart';
import 'package:pos/features/parties/view/parties_view.dart';
import 'package:pos/features/payment_accounts/controller/payment_accounts_ctrl.dart';
import 'package:pos/features/products/view/product_view_dialog.dart';
import 'package:pos/features/settings/controller/settings_ctrl.dart';
import 'package:pos/main.export.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

const _headings = [
  TableHeading.positional('Parti'),
  TableHeading.positional('Product', 400.0),
  TableHeading.positional('Amount', 300.0),
  TableHeading.positional('Account', 200.0, Alignment.center),
  TableHeading.positional('Status', 130.0, Alignment.center),
  TableHeading.positional('Action', double.nan, Alignment.centerRight),
];

class InventoryRecordView extends HookConsumerWidget {
  const InventoryRecordView({super.key, required this.type});

  final RecordType type;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final inventoryList = ref.watch(inventoryCtrlProvider(type));
    final invCtrl = useCallback(() => ref.read(inventoryCtrlProvider(type).notifier), [type]);
    final accountList = ref.watch(paymentAccountsCtrlProvider());

    return BaseBody(
      title: 'All ${type.name}',
      actions: [
        ShadButton(
          child: Text('Create ${type.name}'),
          onPressed: () {
            if (type == RecordType.purchase) {
              RPaths.createPurchases.pushNamed(context);
            } else {
              RPaths.createSales.pushNamed(context);
            }
          },
        ),
      ],
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
              Expanded(
                child: ShadSelectField<InventoryStatus>(
                  hintText: 'Status',
                  options: InventoryStatus.values,
                  selectedBuilder: (context, value) => Text(value.name),
                  optionBuilder: (_, value, _) {
                    return ShadOption(value: value, child: Text(value.name));
                  },
                  onChanged: (v) => invCtrl().filter(status: v),
                ),
              ),
              const Gap(Insets.xs),
              ShadDatePicker.range(key: ValueKey(type), onRangeChanged: (v) => invCtrl().filter(range: v)),
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
              error: (e, s) => ErrorView(e, s, prov: inventoryCtrlProvider),
              data: (inventories) {
                return RecordTable(inventories: inventories, actionSpread: true);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class RecordTable extends ConsumerWidget {
  const RecordTable({super.key, required this.inventories, this.excludes = const [], this.actionSpread = false});

  final List<InventoryRecord> inventories;
  final List<String> excludes;
  final bool actionSpread;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final heads = _headings.where((e) => !excludes.contains(e.name)).toList();

    return DataTableBuilder<InventoryRecord, TableHeading>(
      rowHeight: 150,
      items: inventories,
      headings: heads,
      headingBuilderIndexed: (heading, i) {
        final alignment = heading.alignment;
        return GridColumn(
          columnName: heading.name,
          columnWidthMode: ColumnWidthMode.fill,
          maximumWidth: heading.max,
          minimumWidth: heading.name == 'Status' ? 100 : 150,
          label: Container(padding: Pads.med(), alignment: alignment, child: Text(heading.name)),
        );
      },
      cellAlignmentBuilder: (h) => heads.fromName(h).alignment,
      cellBuilder: (data, head) {
        return switch (head.name) {
          'Parti' => DataGridCell(columnName: head.name, value: _nameCellBuilder(data.getParti)),
          'Product' => DataGridCell(columnName: head.name, value: _productCellBuilder(data.details)),
          'Amount' => DataGridCell(columnName: head.name, value: _amountBuilder(data)),
          'Account' => DataGridCell(columnName: head.name, value: Text(data.account?.name ?? '--')),
          'Status' => DataGridCell(
            columnName: head.name,
            value: ShadBadge.secondary(child: Text(data.status.name.titleCase)),
          ),
          'Action' => DataGridCell(
            columnName: head.name,
            value: PopOverBuilder(
              actionSpread: actionSpread,
              children: [
                // if (!parti.isWalkIn) ...[
                //   if (parti.hasDue() && data.hasDue)
                //     PopOverButton(
                //       dense: actionSpread,
                //       icon: const Icon(LuIcons.handCoins),
                //       onPressed: () {
                //         showShadDialog(
                //           context: context,
                //           builder: (context) => PartyDueDialog(parti: parti, type: parti.type),
                //         );
                //       },
                //       child: const Text('Due adjustment'),
                //     ),
                //   if (parti.hasBalance() && !parti.isCustomer && data.hasDue)
                //     PopOverButton(
                //       dense: actionSpread,
                //       icon: const Icon(LuIcons.handCoins),
                //       onPressed: () {
                //         showShadDialog(
                //           context: context,
                //           builder: (context) => SupplierDueDialog(parti: parti, type: parti.type),
                //         );
                //       },
                //       child: const Text('Due clearance'),
                //     ),
                // ],
                PopOverButton(
                  dense: actionSpread,
                  icon: const Icon(LuIcons.eye),
                  onPressed: () async {
                    if (data.type.isSale) RPaths.saleDetails(data.id).pushNamed(context);
                    if (data.type.isPurchase) RPaths.purchaseDetails(data.id).pushNamed(context);
                  },
                  child: const Text('View'),
                ),
                PopOverButton(
                  dense: actionSpread,
                  icon: const Icon(LuIcons.download),
                  onPressed: () async {
                    final config = await ref.read(configCtrlAsyncProvider.future);

                    if (!context.mounted) return;
                    await showShadDialog(
                      context: context,
                      builder: (context) => InvInvoiceWidget(rec: data, config: config),
                    );
                  },
                  child: const Text('Download invoice'),
                ),
                if (data.status != InventoryStatus.returned)
                  PopOverButton(
                    dense: actionSpread,
                    icon: const Icon(LuIcons.undo2),
                    isDestructive: true,
                    onPressed: () {
                      showShadDialog(context: context, builder: (context) => ReturnRecordDialog(inventory: data));
                    },
                    child: const Text('Return'),
                  ),
              ],
            ),
          ),
          _ => DataGridCell(columnName: head.name, value: Text(data.toString())),
        };
      },
    );
  }

  Widget _nameCellBuilder(Party? parti) {
    return Builder(
      builder: (context) {
        return Column(
          spacing: Insets.xs,
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            GestureDetector(
              onTap: () {
                if (parti == null) return;
                showShadDialog(context: context, builder: (context) => PartiViewDialog(parti: parti));
              },
              child: OverflowMarquee(child: Text(parti?.name ?? '--', style: context.text.list)),
            ),
            if (parti != null) OverflowMarquee(child: Text('Phone: ${parti.phone}')),
            if (parti?.email != null) OverflowMarquee(child: Text('Email: ${parti!.email}')),
          ],
        );
      },
    );
  }

  Widget _productCellBuilder(List<InventoryDetails> details) {
    return Builder(
      builder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (final p in details.takeFirst(2))
              GestureDetector(
                onTap: () {
                  showShadDialog(context: context, builder: (context) => ProductViewDialog(product: p.product));
                },
                child: Row(
                  spacing: Insets.xs,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(child: Text(p.product.name, style: context.text.small, maxLines: 1)),
                    Text(' (${p.quantity})', style: context.text.muted.size(12)),
                  ],
                ),
              ),

            if (details.length > 2) Text('+ ${details.length - 2} more', style: context.text.muted.size(12)),
          ],
        );
      },
    );
  }

  Widget _amountBuilder(InventoryRecord data) {
    return Builder(
      builder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            SpacedText(
              left: data.type == RecordType.purchase ? 'Paid' : 'Received',
              right: data.amount.currency(),
              crossAxisAlignment: CrossAxisAlignment.center,
              styleBuilder: (l, r) => (context.text.muted.textHeight(1.1), r.bold),
            ),

            if (data.vat != 0)
              SpacedText(
                left: 'Vat',
                right: data.vat.currency(),
                crossAxisAlignment: CrossAxisAlignment.center,
                styleBuilder: (l, r) => (context.text.muted.textHeight(1.1), r.bold),
              ),
            if (data.shipping != 0)
              SpacedText(
                left: 'Shipping',
                right: data.shipping.currency(),
                crossAxisAlignment: CrossAxisAlignment.center,
                styleBuilder: (l, r) => (context.text.muted.textHeight(1.1), r.bold),
              ),
            if (data.discount != 0)
              SpacedText(
                left: 'Discount',
                right: data.discountString(),
                crossAxisAlignment: CrossAxisAlignment.center,
                styleBuilder: (l, r) => (context.text.muted.textHeight(1.1), r.bold),
              ),
            if (data.due != 0)
              SpacedText(
                left: 'Due',
                right: data.due.currency(),
                crossAxisAlignment: CrossAxisAlignment.center,
                styleBuilder: (l, r) => (context.text.muted.textHeight(1.1), r.error(context)),
              ),
            SpacedText(
              left: 'Total',
              right: data.total.currency(),
              crossAxisAlignment: CrossAxisAlignment.center,
              styleBuilder: (l, r) => (context.text.small.textHeight(1.1), context.text.p.bold),
            ),
          ],
        );
      },
    );
  }
}

// ignore: unused_element
class _InventoryViewDialog extends HookConsumerWidget {
  const _InventoryViewDialog({required this.inventory});

  final InventoryRecord inventory;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ShadDialog(
      title: const Text('Inventory'),
      description: Text('Details of ${inventory.id}'),

      actions: [ShadButton.destructive(onPressed: () => context.nPop(), child: const Text('Cancel'))],
      child: Container(
        padding: Pads.padding(v: Insets.med),
        child: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: Insets.sm,
        ),
      ),
    );
  }
}

class ReturnRecordDialog extends HookConsumerWidget {
  const ReturnRecordDialog({super.key, required this.inventory});

  final InventoryRecord inventory;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formKey = useMemoized(() => GlobalKey<FormBuilderState>());
    return ShadDialog(
      title: const Text('Return'),
      description: const Text('Do you want to return this inventory?'),

      actions: [
        ShadButton.destructive(onPressed: () => context.nPop(), child: const Text('Cancel')),
        SubmitButton(
          onPressed: (l) async {
            final state = formKey.currentState!;
            if (!state.saveAndValidate()) return;

            final data = state.value;
            final ctrl = ref.read(recordEditingCtrlProvider(inventory.type).notifier);
            l.truthy();
            final res = await ctrl.returnInventory(inventory, data);
            l.falsey();

            if (!context.mounted) return;
            res.showToast(context);
            if (res.success) context.pop(true);
          },
          child: const Text('Return'),
        ),
      ],
      child: Container(
        padding: Pads.padding(v: Insets.med),
        child: FormBuilder(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: Insets.sm,
            children: [
              for (final p in inventory.details) ...[
                Text(p.product.name, style: context.text.list),
                Row(
                  children: [
                    Expanded(
                      child: ShadTextField(
                        name: p.id,
                        label: 'Return Quantity',
                        initialValue: inventory.type.isSale ? p.quantity.toString() : p.stock.quantity.toString(),
                        numeric: true,
                        validators: [
                          FormBuilderValidators.min(1),
                          if (inventory.type.isSale) FormBuilderValidators.max(p.quantity),
                          if (inventory.type.isPurchase) FormBuilderValidators.max(p.stock.quantity),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
