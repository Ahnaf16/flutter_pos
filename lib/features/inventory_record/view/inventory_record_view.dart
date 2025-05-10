import 'package:pos/features/inventory_record/controller/inventory_record_ctrl.dart';
import 'package:pos/main.export.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

const _headings = [
  ('Parti', double.nan, Alignment.centerLeft),
  ('Product', 400.0, Alignment.center),
  ('Amount', 300.0, Alignment.center),
  ('Account', 200.0, Alignment.center),
  ('Status', 130.0, Alignment.center),
  ('Action', 200.0, Alignment.centerRight),
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
          return DataTableBuilder<InventoryRecord, (String, double, Alignment)>(
            rowHeight: 150,
            items: inventories,
            headings: _headings,
            headingBuilderIndexed: (heading, i) {
              final alignment = heading.$3;
              return GridColumn(
                columnName: heading.$1,
                columnWidthMode: ColumnWidthMode.fill,
                maximumWidth: heading.$2,
                minimumWidth: heading.$1 == 'Status' ? 100 : 150,
                label: Container(padding: Pads.med(), alignment: alignment, child: Text(heading.$1)),
              );
            },
            cellAlignmentBuilder: (h) => _headings.firstWhere((element) => element.$1 == h).$3,
            cellBuilder: (data, head) {
              return switch (head.$1) {
                'Parti' => DataGridCell(columnName: head.$1, value: _nameCellBuilder(data.getParti)),
                'Product' => DataGridCell(columnName: head.$1, value: _productCellBuilder(data.details)),
                'Amount' => DataGridCell(columnName: head.$1, value: _amountBuilder(data)),
                'Account' => DataGridCell(columnName: head.$1, value: Text(data.account.name)),
                'Status' => DataGridCell(
                  columnName: head.$1,
                  value: ShadBadge.secondary(child: Text(data.status.name.titleCase)),
                ),
                'Action' => DataGridCell(
                  columnName: head.$1,
                  value: CenterRight(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ShadButton.secondary(
                          size: ShadButtonSize.sm,
                          leading: const Icon(LuIcons.eye),
                          onPressed:
                              () => showShadDialog(
                                context: context,
                                builder: (context) => _InventoryViewDialog(inventory: data),
                              ),
                        ),
                        // ShadButton.secondary(
                        //   size: ShadButtonSize.sm,
                        //   leading: const Icon(LuIcons.pen),
                        //   onPressed: () => RPaths.editStaffs(data.id).pushNamed(context),
                        // ),
                      ],
                    ),
                  ),
                ),
                _ => DataGridCell(columnName: head.$1, value: Text(data.toString())),
              };
            },
          );
        },
      ),
    );
  }

  Widget _nameCellBuilder(Parti? parti) => Builder(
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SpacedText(
            left: data.type == RecordType.purchase ? 'Paid' : 'Received',
            right: data.amount.currency(),
            crossAxisAlignment: CrossAxisAlignment.center,
            styleBuilder: (l, r) => (context.text.muted.textHeight(1.1), r.bold),
          ),
          if (data.dueBalance != 0)
            SpacedText(
              left: data.type.isSale ? 'Balance used' : 'Due used',
              right: data.dueBalance.currency(),
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
