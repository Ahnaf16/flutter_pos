import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:pos/features/expense/controller/expense_ctrl.dart';
import 'package:pos/main.export.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

const _headings = [('Name', double.nan), ('Enabled', 300.0), ('Action', 400.0)];

class ExpenseCategoryView extends HookConsumerWidget {
  const ExpenseCategoryView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productList = ref.watch(expenseCategoryCtrlProvider);

    return BaseBody(
      title: 'Expense category',
      actions: [
        ShadButton(
          child: const Text('Add a category'),
          onPressed: () {
            showShadDialog(context: context, builder: (context) => const _CategoryAddDialog());
          },
        ),
      ],
      body: productList.when(
        loading: () => const Loading(),
        error: (e, s) => ErrorView(e, s, prov: expenseCategoryCtrlProvider),
        data: (products) {
          return DataTableBuilder<ExpenseCategory, (String, double)>(
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

                'Enabled' => DataGridCell(columnName: head.$1, value: _buildActiveCell(data)),

                'Action' => DataGridCell(
                  columnName: head.$1,
                  value: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      ShadButton.secondary(
                        size: ShadButtonSize.sm,
                        leading: const Icon(LuIcons.pen),
                        onPressed:
                            () => showShadDialog(
                              context: context,
                              builder: (context) => _CategoryAddDialog(category: data),
                            ),
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

  Widget _buildActiveCell(ExpenseCategory category) {
    return HookConsumer(
      builder: (context, ref, c) {
        final loading = useState(false);
        if (loading.value) return const Loading(center: false);
        return ShadSwitch(
          value: category.enabled,
          onChanged: (v) async {
            try {
              final ctrl = ref.read(expenseCategoryCtrlProvider.notifier);
              loading.truthy();
              await ctrl.toggleEnable(v, category);
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

class _CategoryAddDialog extends HookConsumerWidget {
  const _CategoryAddDialog({this.category});

  final ExpenseCategory? category;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formKey = useMemoized(GlobalKey<FormBuilderState>.new);
    final actionTxt = category == null ? 'Add' : 'Update';
    return ShadDialog(
      title: Text('$actionTxt Unit'),
      description: Text(
        category == null ? 'Fill the form to add a new Category' : 'Fill the form to update ${category!.name}',
      ),
      actions: [
        ShadButton.destructive(onPressed: () => context.nPop(), child: const Text('Cancel')),
        SubmitButton(
          onPressed: (l) async {
            final state = formKey.currentState!;
            if (!state.saveAndValidate()) return;
            final data = state.value;

            final ctrl = ref.read(expenseCategoryCtrlProvider.notifier);
            (bool, String)? result;

            if (category == null) {
              l.truthy();
              result = await ctrl.createCategory(data);
              l.falsey();
            } else {
              final updated = category?.marge(data);
              if (updated == null) return;
              l.truthy();
              result = await ctrl.updateCategory(updated);
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
          initialValue: category?.toMap() ?? {},
          child: const ShadField(name: 'name', label: 'Name', isRequired: true),
        ),
      ),
    );
  }
}
