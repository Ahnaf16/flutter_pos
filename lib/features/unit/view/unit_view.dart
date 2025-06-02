import 'package:pos/features/unit/controller/unit_ctrl.dart';
import 'package:pos/features/unit/view/unit_add_dialog.dart';
import 'package:pos/main.export.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

const _headings = [('#', 60.0), ('Name', double.nan), ('Active', 200.0), ('Action', 200.0)];

class UnitView extends HookConsumerWidget {
  const UnitView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unitList = ref.watch(unitCtrlProvider);

    return BaseBody(
      title: 'Product Unit',
      actions: [
        ShadButton(
          child: const Text('Add a Unit'),
          onPressed: () {
            showShadDialog(context: context, builder: (context) => const UnitAddDialog());
          },
        ),
      ],
      body: unitList.when(
        loading: () => const Loading(),
        error: (e, s) => ErrorView(e, s, prov: unitCtrlProvider),
        data: (units) {
          return DataTableBuilder<ProductUnit, (String, double)>(
            rowHeight: 80,
            items: units,
            headings: _headings,
            headingBuilder: (heading) {
              return GridColumn(
                columnName: heading.$1,
                columnWidthMode: ColumnWidthMode.fill,
                maximumWidth: heading.$2,
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
                '#' => DataGridCell(
                  columnName: head.$1,
                  value: Text((units.indexWhere((e) => e.id == data.id) + 1).toString()),
                ),
                'Name' => DataGridCell(columnName: head.$1, value: Text(data.name)),

                'Active' => DataGridCell(columnName: head.$1, value: _buildActiveCell(data)),

                'Action' => DataGridCell(
                  columnName: head.$1,
                  value: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      PopOverButton(
                        color: Colors.blue,
                        icon: const Icon(LuIcons.pen),
                        dense: true,
                        onPressed: () => showShadDialog(
                          context: context,
                          builder: (context) => UnitAddDialog(unit: data),
                        ),
                      ),
                      PopOverButton(
                        icon: const Icon(LuIcons.trash),
                        isDestructive: true,
                        dense: true,
                        onPressed: () {
                          showShadDialog(
                            context: context,
                            builder: (c) {
                              return ShadDialog.alert(
                                title: const Text('Delete Product unit'),
                                description: Text('This will delete ${data.name} permanently.'),
                                actions: [
                                  ShadButton(onPressed: () => c.nPop(), child: const Text('Cancel')),
                                  ShadButton.destructive(
                                    onPressed: () async {
                                      await ref.read(unitCtrlProvider.notifier).delete(data);
                                      if (c.mounted) c.nPop();
                                    },
                                    child: const Text('Delete'),
                                  ),
                                ],
                              );
                            },
                          );
                        },
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

  Widget _buildActiveCell(ProductUnit unit) {
    return HookConsumer(
      builder: (context, ref, c) {
        final loading = useState(false);
        if (loading.value) return const Loading(center: false);
        return ShadSwitch(
          value: unit.isActive,
          onChanged: (v) async {
            try {
              final ctrl = ref.read(unitCtrlProvider.notifier);
              loading.truthy();
              await ctrl.toggleEnable(v, unit);
              loading.falsey();
            } catch (e) {
              loading.falsey();
            }
          },
        );
      },
    );
  }
}
