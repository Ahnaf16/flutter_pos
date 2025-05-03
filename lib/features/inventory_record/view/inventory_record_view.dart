import 'package:pos/features/inventory_record/controller/inventory_record_ctrl.dart';
import 'package:pos/features/staffs/controller/staffs_ctrl.dart';
import 'package:pos/main.export.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

const _headings = [
  ('Product', 200.0),
  ('Parti', double.nan),
  ('Amount', 200.0),
  ('Account', 200.0),
  ('Status', 100.0),
  ('Action', 200.0),
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
        error: (e, s) => ErrorView(e, s, prov: staffsCtrlProvider),
        data: (inventories) {
          return DataTableBuilder<InventoryRecord, (String, double)>(
            rowHeight: 100,
            items: inventories,
            headings: _headings,
            headingBuilder: (heading) {
              return GridColumn(
                columnName: heading.$1,
                columnWidthMode: ColumnWidthMode.fill,
                maximumWidth: heading.$2,
                minimumWidth: 200,
                label: Container(
                  padding: Pads.med(),
                  alignment: heading.$1 == 'Action' ? Alignment.centerRight : Alignment.centerLeft,
                  child: Text(heading.$1),
                ),
              );
            },
            cellAlignment: Alignment.centerLeft,
            cellBuilder: (data, head) {
              return switch (head.$1) {
                'Parti' => DataGridCell(columnName: head.$1, value: _nameCellBuilder(data.parti)),
                'Product' => DataGridCell(columnName: head.$1, value: Text('${data.details.length}')),
                'Amount' => DataGridCell(columnName: head.$1, value: Text(data.amount.currency())),
                'Account' => DataGridCell(columnName: head.$1, value: Text(data.account.name)),
                'Status' => DataGridCell(columnName: head.$1, value: Text(data.status.name.titleCase)),
                'Action' => DataGridCell(
                  columnName: head.$1,
                  value: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
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
                      ShadButton.secondary(
                        size: ShadButtonSize.sm,
                        leading: const Icon(LuIcons.pen),
                        onPressed: () => RPaths.editStaffs(data.id).pushNamed(context),
                      ),
                    ],
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

  Widget _nameCellBuilder(Parti staff) => Builder(
    builder: (context) {
      return Column(
        spacing: Insets.xs,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          OverflowMarquee(child: Text(staff.name, style: context.text.list)),
          OverflowMarquee(child: Text('Phone: ${staff.phone}')),
          OverflowMarquee(child: Text('Email: ${staff.email}')),
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
