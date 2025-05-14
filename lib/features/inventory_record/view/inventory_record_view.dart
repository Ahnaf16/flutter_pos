import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:pos/features/inventory_record/controller/inventory_record_ctrl.dart';
import 'package:pos/features/inventory_record/controller/record_editing_ctrl.dart';
import 'package:pos/main.export.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

const _headings = [
  TableHeading.positional('Parti'),
  TableHeading.positional('Product', 400.0),
  TableHeading.positional('Amount', 300.0),
  TableHeading.positional('Account', 200.0, Alignment.center),
  TableHeading.positional('Status', 130.0, Alignment.center),
  TableHeading.positional('Action', 200.0, Alignment.centerRight),
];

class InventoryRecordView extends HookConsumerWidget {
  const InventoryRecordView({super.key, required this.type});

  final RecordType type;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final inventoryList = ref.watch(inventoryCtrlProvider(type));
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
      body: inventoryList.when(
        loading: () => const Loading(),
        error: (e, s) => ErrorView(e, s, prov: inventoryCtrlProvider),
        data: (inventories) {
          return DataTableBuilder<InventoryRecord, TableHeading>(
            rowHeight: 150,
            items: inventories,
            headings: _headings,
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
            cellAlignmentBuilder: (h) => _headings.fromName(h).alignment,
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
                  value: CenterRight(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ShadButton.secondary(
                          size: ShadButtonSize.sm,
                          leading: const Icon(LuIcons.eye),
                          onPressed: () {
                            showShadDialog(
                              context: context,
                              builder: (context) => _InventoryViewDialog(inventory: data),
                            );
                          },
                        ),
                        if (data.status != InventoryStatus.returned)
                          ShadButton.destructive(
                            size: ShadButtonSize.sm,
                            leading: const Icon(LuIcons.undo2),
                            onPressed: () {
                              showShadDialog(context: context, builder: (context) => _ReturnDialog(inventory: data));
                            },
                          ),
                      ],
                    ),
                  ),
                ),
                _ => DataGridCell(columnName: head.name, value: Text(data.toString())),
              };
            },
          );
        },
      ),
    );
  }

  Widget _nameCellBuilder(Party? parti) => Builder(
    builder: (context) {
      return Column(
        spacing: Insets.xs,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          OverflowMarquee(child: Text(parti?.name ?? '--', style: context.text.list)),
          if (parti != null) OverflowMarquee(child: Text('Phone: ${parti.phone}')),
          if (parti?.email != null) OverflowMarquee(child: Text('Email: ${parti!.email}')),
        ],
      );
    },
  );
  Widget _productCellBuilder(List<InventoryDetails> details) => Builder(
    builder: (context) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final p in details.takeFirst(2))
            Row(
              spacing: Insets.xs,
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(child: Text(p.product.name, style: context.text.small, maxLines: 1)),
                Text(' (${p.quantity})', style: context.text.muted.size(12)),
              ],
            ),

          if (details.length > 2) Text('+ ${details.length - 2} more', style: context.text.muted.size(12)),
        ],
      );
    },
  );
  Widget _amountBuilder(InventoryRecord data) => Builder(
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
          if (data.due > 0)
            SpacedText(
              left: 'Due',
              right: data.due.currency(),
              crossAxisAlignment: CrossAxisAlignment.center,
              styleBuilder: (l, r) => (context.text.muted.textHeight(1.1), r.bold.error(context)),
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

class _ReturnDialog extends HookConsumerWidget {
  const _ReturnDialog({required this.inventory});

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
