import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:pos/features/expense/controller/expense_ctrl.dart';
import 'package:pos/main.export.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

const _headings = [
  TableHeading.positional('#', 50.0),
  TableHeading.positional('Name'),
  TableHeading.positional('Enabled', 150),
  TableHeading.positional('Action', 200, Alignment.centerRight),
];

class ExpenseCategoryView extends HookConsumerWidget {
  const ExpenseCategoryView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productList = ref.watch(expenseCategoryCtrlProvider);

    return BaseBody(
      title: 'Expense category',
      actions: [
        ShadButton(
          child: const SelectionContainer.disabled(child: Text('Add a category')),
          onPressed: () {
            showShadDialog(context: context, builder: (context) => const ExCategoryAddDialog());
          },
        ),
      ],
      body: productList.when(
        loading: () => const Loading(),
        error: (e, s) => ErrorView(e, s, prov: expenseCategoryCtrlProvider),
        data: (category) {
          return DataTableBuilder<ExpenseCategory, TableHeading>(
            rowHeight: 80,
            items: category,
            headings: _headings,
            headingBuilder: (heading) {
              return GridColumn(
                columnName: heading.name,
                columnWidthMode: ColumnWidthMode.fill,
                maximumWidth: heading.max,
                minimumWidth: heading.minWidth ?? 150,
                label: Container(
                  padding: Pads.med(),
                  alignment: heading.alignment,
                  child: Text(heading.name),
                ),
              );
            },
            cellAlignment: Alignment.centerLeft,
            cellBuilderIndexed: (data, head, i) {
              return switch (head.name) {
                '#' => DataGridCell(columnName: head.name, value: Text((i + 1).toString())),
                'Name' => DataGridCell(
                  columnName: head.name,
                  value: Text(data.name, style: context.text.list),
                ),
                'Enabled' => DataGridCell(columnName: head.name, value: _buildActiveCell(data)),
                'Action' => DataGridCell(
                  columnName: head.name,
                  value: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      PopOverButton(
                        color: Colors.green,
                        toolTip: 'Edit',
                        icon: const Icon(LuIcons.pen),
                        dense: true,
                        onPressed: () => showShadDialog(
                          context: context,
                          builder: (context) => ExCategoryAddDialog(category: data),
                        ),
                      ),
                      PopOverButton(
                        toolTip: 'Delete',
                        icon: const Icon(LuIcons.trash),
                        isDestructive: true,
                        dense: true,
                        onPressed: () {
                          showShadDialog(
                            context: context,
                            builder: (c) {
                              return ShadDialog.alert(
                                title: const Text('Delete Category'),
                                description: Text('This will delete ${data.name} permanently.'),
                                actions: [
                                  ShadButton(
                                    onPressed: () => c.nPop(),
                                    child: const SelectionContainer.disabled(child: Text('Cancel')),
                                  ),
                                  ShadButton.destructive(
                                    onPressed: () async {
                                      await ref.read(expenseCategoryCtrlProvider.notifier).delete(data);
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
                _ => DataGridCell(columnName: head.name, value: Text(data.toString())),
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

class ExCategoryAddDialog extends HookConsumerWidget {
  const ExCategoryAddDialog({super.key, this.category});

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
        ShadButton.destructive(
          onPressed: () => context.nPop(),
          child: const SelectionContainer.disabled(child: Text('Cancel')),
        ),
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
          child: ShadTextField(name: 'name', label: 'Name', isRequired: true),
        ),
      ),
    );
  }
}
