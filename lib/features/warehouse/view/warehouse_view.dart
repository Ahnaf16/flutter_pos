import 'package:pos/features/warehouse/controller/warehouse_ctrl.dart';
import 'package:pos/main.export.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

const _headings = [
  TableHeading.positional('#', 50.0),
  TableHeading.positional('Name', 200.0),
  TableHeading.positional('Address'),
  TableHeading.positional('Default', 200.0),
  TableHeading.positional('Action', 260.0),
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
          child: const Text('Create warehouse'),
          onPressed: () {
            RPaths.createWarehouse.pushNamed(context);
          },
        ),
      ],
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 350,
            child: ShadTextField(hintText: 'Search', onChanged: (v) => whCtrl().search(v ?? ''), showClearButton: true),
          ),
          const Gap(Insets.med),
          Expanded(
            child: warehouseList.when(
              loading: () => const Loading(),
              error: (e, s) => ErrorView(e, s, prov: warehouseCtrlProvider),
              data: (warehouses) {
                return DataTableBuilder<WareHouse, TableHeading>(
                  rowHeight: 100,
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
                          child: Text(data.isDefault ? 'Default' : 'Not Default'),
                        ),
                      ),
                      'Action' => DataGridCell(
                        columnName: head.name,
                        value: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            ShadButton(
                              size: ShadButtonSize.sm,
                              leading: const Icon(LuIcons.eye),
                              onPressed: () => showShadDialog(
                                context: context,
                                builder: (context) => _WarehouseViewDialog(house: data),
                              ),
                            ).colored(Colors.blue).toolTip('View'),
                            ShadButton(
                              size: ShadButtonSize.sm,
                              leading: const Icon(LuIcons.pen),
                              onPressed: () => RPaths.editWarehouse(data.id).pushNamed(context),
                            ).colored(Colors.green).toolTip('Edit'),
                            ShadButton(
                              size: ShadButtonSize.sm,
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
            SpacedText(left: 'Name', right: house.name, styleBuilder: (l, r) => (l, r.bold)),
            SpacedText(
              left: 'Address',
              right: house.address,
              styleBuilder: (l, r) => (l, r.bold),
              trailing: SmallButton(icon: LuIcons.copy, onPressed: () => Copier.copy(house.address)),
            ),
            SpacedText(
              left: 'Contact Person',
              right: house.contactPerson ?? 'N/a',
              styleBuilder: (l, r) => (l, r.bold),
            ),
            SpacedText(
              left: 'Contact Number',
              right: house.contactNumber,
              styleBuilder: (l, r) => (l, r.bold),
              trailing: SmallButton(icon: LuIcons.copy, onPressed: () => Copier.copy(house.contactNumber)),
            ),
          ],
        ),
      ),
    );
  }
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
