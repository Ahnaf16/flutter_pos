import 'package:pos/features/filter/view/filter_bar.dart';
import 'package:pos/features/warehouse/controller/warehouse_ctrl.dart';
import 'package:pos/main.export.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

const _headings = [
  TableHeading.positional('#', 50.0),
  TableHeading.positional('Name'),
  TableHeading.positional('Phone', 300),
  TableHeading.positional('Contact Person', 300),
  TableHeading.positional('Address', 300),
  TableHeading.positional('Default', 200),
  TableHeading.positional('Action', 200),
];

class WarehouseView extends HookConsumerWidget {
  const WarehouseView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final warehouseList = ref.watch(warehouseCtrlProvider);
    final whCtrl = useCallback(() => ref.read(warehouseCtrlProvider.notifier));
    return BaseBody(
      title: 'Warehouse',
      actions: [
        ShadButton(
          child: const SelectionContainer.disabled(child: Text('Create warehouse')),
          onPressed: () {
            RPaths.createWarehouse.pushNamed(context);
          },
        ),
      ],
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FilterBar(
            hintText: 'Search by name or contact number',
            onSearch: (q) => whCtrl().search(q),
            onReset: () => whCtrl().refresh(),
          ),
          Expanded(
            child: warehouseList.when(
              loading: () => const Loading(),
              error: (e, s) => ErrorView(e, s, prov: warehouseCtrlProvider),
              data: (warehouses) {
                return DataTableBuilder<WareHouse, TableHeading>(
                  rowHeight: 80,
                  items: warehouses,
                  headings: _headings,
                  headingBuilder: (heading) {
                    return GridColumn(
                      columnName: heading.name,
                      columnWidthMode: ColumnWidthMode.fill,
                      maximumWidth: heading.max,
                      minimumWidth: heading.minWidth ?? 200,
                      label: Container(
                        padding: Pads.med(),
                        alignment: heading.name == 'Action' ? Alignment.centerRight : Alignment.centerLeft,
                        child: Text(heading.name),
                      ),
                    );
                  },
                  cellAlignment: Alignment.centerLeft,
                  cellBuilder: (data, head) {
                    return switch (head.name) {
                      '#' => DataGridCell(
                        columnName: head.name,
                        value: Text((warehouses.indexWhere((e) => e.id == data.id) + 1).toString()),
                      ),
                      'Name' => DataGridCell(columnName: head.name, value: Text(data.name)),
                      'Phone' => DataGridCell(columnName: head.name, value: _phoneCellBuilder(data)),
                      'Contact Person' => DataGridCell(columnName: head.name, value: _contectCellBuilder(data)),
                      'Address' => DataGridCell(columnName: head.name, value: _addressCellBuilder(data)),
                      'Default' => DataGridCell(
                        columnName: head.name,
                        value: ShadBadge.raw(
                          variant: data.isDefault ? ShadBadgeVariant.primary : ShadBadgeVariant.secondary,
                          onPressed: () {
                            if (data.isDefault) return;
                            showShadDialog(
                              context: context,
                              builder: (context) => _WarehouseDefaultDialog(house: data),
                            );
                          },
                          child: Text(
                            data.isDefault ? 'Default' : 'Not Default',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w300,
                            ),
                          ),
                        ),
                      ),
                      'Action' => DataGridCell(
                        columnName: head.name,
                        value: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            ShadButton(
                              size: ShadButtonSize.sm,
                              height: 40,
                              width: 40,
                              leading: const Icon(LuIcons.eye),
                              onPressed: () => RPaths.warehouseDetails(data.id).pushNamed(context),
                            ).colored(Colors.blue).toolTip('View'),
                            ShadButton(
                              size: ShadButtonSize.sm,
                              height: 40,
                              width: 40,
                              leading: const Icon(LuIcons.pen),
                              onPressed: () => RPaths.editWarehouse(data.id).pushNamed(context),
                            ).colored(Colors.green).toolTip('Edit'),
                            ShadButton(
                              size: ShadButtonSize.sm,
                              height: 40,
                              width: 40,
                              leading: const Icon(LuIcons.trash),
                              onPressed: () {
                                showShadDialog(
                                  context: context,
                                  builder: (c) {
                                    return ShadDialog.alert(
                                      title: const Text('Delete Warehouse'),
                                      description: Text('This will delete "${data.name}" warehouse permanently.'),
                                      actions: [
                                        ShadButton(onPressed: () => c.nPop(), child: const Text('Cancel')),
                                        ShadButton.destructive(
                                          onPressed: () async {
                                            final res = await whCtrl().delete(data);
                                            if (!c.mounted) return;
                                            res.showToast(c);
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

  Widget _addressCellBuilder(WareHouse house) => Builder(
    builder: (context) {
      return Column(
        spacing: Insets.xs,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          OverflowMarquee(child: Text(house.address, maxLines: 2)),
        ],
      );
    },
  );
  Widget _phoneCellBuilder(WareHouse house) => Builder(
    builder: (context) {
      return Column(
        spacing: Insets.xs,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          OverflowMarquee(child: Text(house.contactNumber)),
        ],
      );
    },
  );
  Widget _contectCellBuilder(WareHouse house) => Builder(
    builder: (context) {
      return Column(
        spacing: Insets.xs,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (house.contactPerson != null) OverflowMarquee(child: Text(house.contactPerson ?? '--')),
        ],
      );
    },
  );
}

class _WarehouseDefaultDialog extends HookConsumerWidget {
  const _WarehouseDefaultDialog({required this.house});

  final WareHouse house;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ShadDialog(
      title: const Text('Set as Default?'),
      description: Text('"${house.name}" will be set as default warehouse'),
      constraints: const BoxConstraints(maxWidth: 500),
      gap: 20,
      actions: [
        ShadButton.destructive(onPressed: () => context.nPop(), child: const Text('Cancel')),
        SubmitButton(
          onPressed: (l) async {
            final ctrl = ref.read(warehouseCtrlProvider.notifier);
            final result = await ctrl.changeDefault(house);
            if (context.mounted) {
              result.showToast(context);
              context.nPop();
            }
          },
          child: const Text('Make Default'),
        ),
      ],
    );
  }
}
