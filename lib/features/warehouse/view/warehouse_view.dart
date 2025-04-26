import 'package:pos/features/warehouse/controller/warehouse_ctrl.dart';
import 'package:pos/main.export.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

const _headings = [('Name', 200.0), ('Address', double.nan), ('Default', 200.0), ('Action', 260.0)];

class WarehouseView extends HookConsumerWidget {
  const WarehouseView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final warehouseList = ref.watch(warehouseCtrlProvider);
    return BaseBody(
      title: 'Warehouse',
      actions: [
        ShadButton(
          child: const Text('Create warehouse'),
          onPressed: () {
            RPaths.createWarehouse.pushNamed(context);
          },
        ),
      ],
      body: warehouseList.when(
        loading: () => const Loading(),
        error: (e, s) => ErrorView(e, s, prov: warehouseCtrlProvider),
        data: (warehouses) {
          return DataTableBuilder<WareHouse, (String, double)>(
            rowHeight: 100,
            items: warehouses,
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
                'Name' => DataGridCell(columnName: head.$1, value: Text(data.name)),
                'Address' => DataGridCell(columnName: head.$1, value: _addressCellBuilder(data)),
                'Default' => DataGridCell(
                  columnName: head.$1,
                  value: ShadBadge.raw(
                    variant: data.isDefault ? ShadBadgeVariant.primary : ShadBadgeVariant.secondary,
                    child: Text(data.isDefault ? 'Default' : 'Not Default'),
                  ),
                ),
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
                              builder: (context) => _WarehouseViewDialog(house: data),
                            ),
                      ),
                      ShadButton.secondary(
                        size: ShadButtonSize.sm,
                        leading: const Icon(LuIcons.pen),
                        onPressed: () => RPaths.editWarehouse(data.id).pushNamed(context),
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

  Widget _addressCellBuilder(WareHouse house) => Builder(
    builder: (context) {
      return Column(
        spacing: Insets.xs,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (house.contactPerson != null) OverflowMarquee(child: Text(house.contactPerson ?? '--')),
          OverflowMarquee(child: Text('Phone: ${house.contactNumber}')),
          OverflowMarquee(child: Text(house.address, maxLines: 2)),
        ],
      );
    },
  );
}

class _WarehouseViewDialog extends HookConsumerWidget {
  const _WarehouseViewDialog({required this.house});

  final WareHouse house;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ShadDialog(
      title: const Text('Warehouse'),
      description: Text('Details of ${house.name}'),
      actions: [ShadButton.destructive(onPressed: () => context.nPop(), child: const Text('Cancel'))],
      child: Container(
        padding: Pads.padding(v: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: Insets.med,
          children: [
            SpacedText(left: 'Name', right: house.name, styleBuilder: (l, r) => (l, r.bold), spaced: false),
            SpacedText(
              left: 'Address',
              right: house.address,
              styleBuilder: (l, r) => (l, r.bold),
              spaced: false,
              trailing: SmallButton(icon: LuIcons.copy, onPressed: () => Copier.copy(house.address)),
            ),
            SpacedText(
              left: 'Contact Person',
              right: house.contactPerson ?? 'N/a',
              styleBuilder: (l, r) => (l, r.bold),
              spaced: false,
            ),
            SpacedText(
              left: 'Contact Number',
              right: house.contactNumber,
              styleBuilder: (l, r) => (l, r.bold),
              spaced: false,
              trailing: SmallButton(icon: LuIcons.copy, onPressed: () => Copier.copy(house.contactNumber)),
            ),
          ],
        ),
      ),
    );
  }
}
