import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:pos/features/unit/controller/unit_ctrl.dart';
import 'package:pos/main.export.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

const _headings = [('Name', double.nan), ('Unit Name', double.nan), ('Active', 200.0), ('Action', 200.0)];

class UnitView extends HookConsumerWidget {
  const UnitView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productList = ref.watch(unitCtrlProvider);

    return BaseBody(
      title: 'Product Unit',
      actions: [
        ShadButton(
          child: const Text('Add a Unit'),
          onPressed: () {
            showShadDialog(context: context, builder: (context) => const _UnitAddDialog());
          },
        ),
      ],
      body: productList.when(
        loading: () => const Loading(),
        error: (e, s) => ErrorView(e, s, prov: unitCtrlProvider),
        data: (products) {
          return DataTableBuilder<ProductUnit, (String, double)>(
            rowHeight: 60,
            items: products,
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
                'Unit Name' => DataGridCell(columnName: head.$1, value: Text(data.unitName)),

                'Active' => DataGridCell(columnName: head.$1, value: _buildActiveCell(data)),

                'Action' => DataGridCell(
                  columnName: head.$1,
                  value: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      ShadButton.secondary(
                        size: ShadButtonSize.sm,
                        leading: const Icon(LuIcons.pen),
                        onPressed:
                            () => showShadDialog(context: context, builder: (context) => _UnitAddDialog(unit: data)),
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

class _UnitAddDialog extends HookConsumerWidget {
  const _UnitAddDialog({this.unit});

  final ProductUnit? unit;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formKey = useMemoized(GlobalKey<FormBuilderState>.new);
    final actionTxt = unit == null ? 'Add' : 'Update';
    return ShadDialog(
      title: Text('$actionTxt Unit'),
      description: Text(unit == null ? 'Fill the form and add a new unit' : 'Fill the form to update ${unit!.name}'),
      actions: [
        ShadButton.destructive(onPressed: () => context.nPop(), child: const Text('Cancel')),
        SubmitButton(
          onPressed: (l) async {
            final state = formKey.currentState!;
            if (!state.saveAndValidate()) return;
            final data = state.value;

            final ctrl = ref.read(unitCtrlProvider.notifier);
            (bool, String)? result;

            if (unit == null) {
              l.truthy();
              result = await ctrl.createUnit(data);
              l.falsey();
            } else {
              final updated = unit?.marge(data);
              if (updated == null) return;
              l.truthy();
              result = await ctrl.updateUnit(updated);
              l.falsey();
            }

            if (result case final Result r) {
              if (!context.mounted) return;
              r.showToast(context);
              if (r.success) context.pop();
            }
          },
          child: Text(actionTxt),
        ),
      ],
      child: Container(
        padding: Pads.padding(v: Insets.med),
        child: FormBuilder(
          key: formKey,
          initialValue: unit?.toMap() ?? {},
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: Insets.med,
            children: [
              ShadFormField(name: 'name', label: 'Name', isRequired: true),
              ShadFormField(name: 'unit_name', label: 'Unit Name', isRequired: true),
            ],
          ),
        ),
      ),
    );
  }
}
