import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:pos/features/filter/view/filter_bar.dart';
import 'package:pos/features/inventory_record/controller/inventory_record_ctrl.dart';
import 'package:pos/features/inventory_record/controller/record_editing_ctrl.dart';
import 'package:pos/features/inventory_record/view/local/inv_invoice_widget.dart';
import 'package:pos/features/parties/view/parties_view.dart';
import 'package:pos/features/payment_accounts/controller/payment_accounts_ctrl.dart';
import 'package:pos/features/payment_accounts/view/payment_accounts_view.dart';
import 'package:pos/features/products/view/product_view_dialog.dart';
import 'package:pos/features/settings/controller/settings_ctrl.dart';
import 'package:pos/main.export.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

const _headings = [
  TableHeading.positional('#', 60.0),
  TableHeading.positional('Invoice'),
  TableHeading.positional('Parti'),
  TableHeading.positional('Product', 400.0),
  TableHeading.positional('Vat & Shipping', 300.0),
  TableHeading.positional('Due', double.nan, Alignment.center, 300.0),
  TableHeading.positional('Discount', double.nan, Alignment.center, 250),
  TableHeading.positional('Amount', 350),
  TableHeading.positional('Account', 150, Alignment.center),
  TableHeading.positional('Status', 100, Alignment.center),
  TableHeading.positional('Action', double.nan, Alignment.centerRight, 500.0),
];

class InventoryRecordView extends HookConsumerWidget {
  const InventoryRecordView({super.key, required this.type});

  final RecordType type;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final inventoryList = ref.watch(inventoryCtrlProvider(type));
    final invCtrl = useCallback(() => ref.read(inventoryCtrlProvider(type).notifier), [type]);
    final accountList = ref.watch(paymentAccountsCtrlProvider()).maybeList();

    return BaseBody(
      title: 'All ${type.name}',
      actions: [
        ShadButton(
          child: SelectionContainer.disabled(child: SelectionContainer.disabled(child: Text('Create ${type.name}'))),
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
          FilterBar(
            hintText: 'Search by invoice, product or ${type.isSale ? 'customer' : 'supplier'} name',
            statuses: InventoryStatus.values,
            accounts: accountList,
            onSearch: (q) => invCtrl().search(q),
            onReset: () => invCtrl().refresh(),
            showDateRange: true,
          ),

          Expanded(
            child: inventoryList.when(
              loading: () => const Loading(),
              error: (e, s) => ErrorView(e, s, prov: inventoryCtrlProvider),
              data: (inventories) {
                return RecordTable(inventories: inventories, actionSpread: true, showFooter: true);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class RecordTable extends ConsumerWidget {
  const RecordTable({
    super.key,
    required this.inventories,
    this.excludes = const [],
    this.actionSpread = false,
    this.showFooter = false,
  });

  final List<InventoryRecord> inventories;
  final List<String> excludes;
  final bool actionSpread;
  final bool showFooter;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final heads = _headings.where((e) => !excludes.contains(e.name)).toList();

    return DataTableBuilder<InventoryRecord, TableHeading>(
      rowHeight: 100,
      items: inventories,
      headings: heads,
      headingBuilderIndexed: (heading, i) {
        final alignment = heading.alignment;
        return GridColumn(
          columnName: heading.name,
          columnWidthMode: ColumnWidthMode.fill,
          maximumWidth: heading.max,
          minimumWidth: heading.minWidth ?? 150,
          label: Container(
            padding: Pads.med(),
            alignment: alignment,
            child: Text(
              heading.name,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        );
      },
      cellAlignmentBuilder: (h) => heads.fromName(h).alignment,
      cellBuilder: (data, head) {
        return switch (head.name) {
          '#' => DataGridCell(columnName: head.name, value: Text((inventories.indexOf(data) + 1).toString())),
          'Invoice' => DataGridCell(
            columnName: head.name,
            value: Text.rich(
              TextSpan(
                text: data.invoiceNo,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w300,
                ),
                children: [
                  WidgetSpan(
                    child: SmallButton(
                      icon: LuIcons.copy,
                      iconSize: 15,
                      onPressed: () => Copier.copy(data.invoiceNo),
                    ),
                  ),
                ],
              ),
              style: context.text.list,
            ),
          ),
          'Parti' => DataGridCell(columnName: head.name, value: _nameCellBuilder(data.getParti)),
          'Product' => DataGridCell(columnName: head.name, value: _productCellBuilder(data)),
          'Vat & Shipping' => DataGridCell(columnName: head.name, value: _vatAndShippingBuilder(data)),
          'Due' => DataGridCell(columnName: head.name, value: _dueBuilder(data)),
          'Discount' => DataGridCell(columnName: head.name, value: _discountBuilder(data)),
          'Amount' => DataGridCell(columnName: head.name, value: _amountBuilder(data)),
          'Account' => DataGridCell(
            columnName: head.name,
            value: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  data.account?.name ?? '--',
                  style: const TextStyle(
                    fontWeight: FontWeight.w300,
                  ),
                ),
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
          'Status' => DataGridCell(
            columnName: head.name,
            value: ShadBadge.secondary(
              child: Text(
                data.status.name.titleCase,
              ),
            ).colored(data.status.color),
          ),
          'Action' => DataGridCell(
            columnName: head.name,
            value: PopOverBuilder(
              actionSpread: actionSpread,
              children: (context, hide) => [
                PopOverButton(
                  color: Colors.blue,
                  dense: actionSpread,
                  icon: const Icon(LuIcons.eye),
                  onPressed: () async {
                    if (data.type.isSale) RPaths.saleDetails(data.id).pushNamed(context);
                    if (data.type.isPurchase) RPaths.purchaseDetails(data.id).pushNamed(context);
                  },
                  toolTip: 'View',
                  child: const Text('View'),
                ),
                PopOverButton(
                  color: Colors.green,
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
                  toolTip: 'Download invoice',
                  child: const Text('Download invoice'),
                ),
                if (data.status != InventoryStatus.returned)
                  PopOverButton(
                    dense: actionSpread,
                    icon: const Icon(LuIcons.undo2),
                    isDestructive: true,
                    onPressed: () {
                      showShadDialog(
                        context: context,
                        builder: (context) => ReturnRecordDialog(inventory: data),
                      );
                    },
                    toolTip: 'Return',
                    child: const Text('Return'),
                  ),
              ],
            ),
          ),
          _ => DataGridCell(columnName: head.name, value: Text(data.toString())),
        };
      },

      footer: !showFooter
          ? null
          : DecoContainer(
              color: context.colors.primary.op(.05),
              padding: Pads.med(),
              height: 80,
              child: Row(
                spacing: Insets.xl,
                children: [
                  SpacedText(
                    left: 'Total ',
                    right: inventories.whereNot((e) => e.status.isReturned).map((e) => e.paidAmount).sum.currency(),
                    crossAxisAlignment: CrossAxisAlignment.center,
                    useFlexible: false,
                    style: context.text.list.success(),
                    styleBuilder: (l, r) => (l, context.text.large.success()),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _nameCellBuilder(Party? parti) {
    return Builder(
      builder: (context) {
        return DefaultSelectionStyle(
          mouseCursor: SystemMouseCursors.click,
          child: GestureDetector(
            onTap: () {
              if (parti == null) return;
              showShadDialog(
                context: context,
                builder: (context) => PartiViewDialog(parti: parti),
              );
            },
            child: Column(
              spacing: Insets.xs,
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Text(
                      parti?.name ?? '--',
                      style: const TextStyle(
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    if (parti?.isWalkIn != true)
                      SmallButton(
                        icon: LuIcons.arrowUpRight,
                        onPressed: () {
                          if (parti == null) return;
                          showShadDialog(
                            context: context,
                            builder: (context) => PartiViewDialog(parti: parti),
                          );
                        },
                      ),
                  ],
                ),
                if (parti?.isWalkIn != true && parti != null)
                  OverflowMarquee(
                    child: Text(
                      'Phone: ${parti.phone}',

                      style: const TextStyle(
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                  ),
                if (parti?.email != null)
                  OverflowMarquee(
                    child: Text(
                      'Email: ${parti!.email}',
                      style: const TextStyle(
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _productCellBuilder(InventoryRecord rec) {
    final details = rec.details;
    return Builder(
      builder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (final p in details.takeFirst(2))
              MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                  onTap: () {
                    showShadDialog(
                      context: context,
                      builder: (context) => ProductViewDialog(product: p.product),
                    );
                  },
                  child: Row(
                    spacing: Insets.xs,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Flexible(
                        child: Text(
                          p.product.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.w400,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(' (${p.quantity})', style: context.text.muted.size(12)),
                      SmallButton(
                        icon: LuIcons.arrowUpRight,
                        onPressed: () {
                          showShadDialog(
                            context: context,
                            builder: (context) => ProductViewDialog(product: p.product),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),

            if (details.length > 2)
              Text('+ ${details.length - 2} more', style: context.text.muted.size(12)).clickable(
                onTap: () {
                  if (rec.type.isSale) RPaths.saleDetails(rec.id).pushNamed(context);
                  if (rec.type.isPurchase) RPaths.purchaseDetails(rec.id).pushNamed(context);
                },
              ),
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
          spacing: Insets.xs,
          children: [
            SpacedText(
              left: data.type == RecordType.purchase ? 'Paid' : 'Paid',

              style: TextStyle(fontWeight: FontWeight.w300, color: context.colors.secondaryForeground),
              right: data.paidAmount.currency(),
              crossAxisAlignment: CrossAxisAlignment.center,
              styleBuilder: (l, r) => (l, r),
              maxLines: 1,
            ),

            SpacedText(
              left: 'Total',
              style: TextStyle(fontWeight: FontWeight.w300, color: context.colors.secondaryForeground),
              right: data.total.currency(),
              crossAxisAlignment: CrossAxisAlignment.center,
              styleBuilder: (l, r) => (l, r.medium),
              maxLines: 1,
            ),
          ],
        );
      },
    );
  }

  Widget _discountBuilder(InventoryRecord data) {
    return Builder(
      builder: (context) {
        return Text(
          data.discountString(),
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: Colors.green,
          ),
        );
      },
    );
  }

  Widget _dueBuilder(InventoryRecord data) {
    return Builder(
      builder: (context) {
        return Text(
          data.hasDue ? '- ${data.due.abs().currency()}' : data.due.abs().currency(),
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: data.hasDue ? Colors.red : Colors.green,
          ),
        );
      },
    );
  }

  Widget _vatAndShippingBuilder(InventoryRecord data) {
    return Builder(
      builder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          spacing: Insets.xs,
          children: [
            SpacedText(
              left: 'Vat',
              right: data.vat.currency(),
              style: TextStyle(fontWeight: FontWeight.w300, color: context.colors.secondaryForeground),
              crossAxisAlignment: CrossAxisAlignment.center,
              styleBuilder: (l, r) => (l, r.medium),
              maxLines: 1,
            ),

            SpacedText(
              left: 'Shipping',
              right: data.shipping.currency(),
              style: TextStyle(fontWeight: FontWeight.w300, color: context.colors.secondaryForeground),
              crossAxisAlignment: CrossAxisAlignment.center,
              styleBuilder: (l, r) => (l, r.medium),
              maxLines: 1,
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

      actions: [
        ShadButton.destructive(
          onPressed: () => context.nPop(),
          child: const SelectionContainer.disabled(child: SelectionContainer.disabled(child: Text('Cancel'))),
        ),
      ],
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
        ShadButton.destructive(
          onPressed: () => context.nPop(),
          child: const SelectionContainer.disabled(child: Text('Cancel')),
        ),
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
