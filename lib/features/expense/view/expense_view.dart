import 'package:flutter/services.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:open_filex/open_filex.dart';
import 'package:pos/features/expense/controller/expense_ctrl.dart';
import 'package:pos/features/expense/view/expense_category_view.dart';
import 'package:pos/features/filter/view/filter_bar.dart';
import 'package:pos/features/payment_accounts/controller/payment_accounts_ctrl.dart';
import 'package:pos/features/payment_accounts/view/account_add_dialog.dart';
import 'package:pos/features/payment_accounts/view/payment_accounts_view.dart';
import 'package:pos/features/settings/controller/settings_ctrl.dart';
import 'package:pos/features/staffs/controller/staffs_ctrl.dart';
import 'package:pos/main.export.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

const _headings = [
  TableHeading.positional('#', 50.0),
  TableHeading.positional('Amount'),
  TableHeading.positional('By', 250.0),
  TableHeading.positional('For', 200),
  TableHeading.positional('Category', 150.0),
  TableHeading.positional('Account', 150.0),
  TableHeading.positional('date', 130.0),
  TableHeading.positional('Action', 100.0, Alignment.centerRight),
];

class ExpenseView extends HookConsumerWidget {
  const ExpenseView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final expenseList = ref.watch(expenseCtrlProvider);
    final exCtrl = useCallback(() => ref.read(expenseCtrlProvider.notifier));
    final accountList = ref.watch(paymentAccountsCtrlProvider(false)).maybeList();
    // final categoryList = ref.watch(expenseCategoryCtrlProvider);

    return BaseBody(
      title: 'Expense',
      actions: [
        ShadButton(
          child: const SelectionContainer.disabled(child: Text('Add a expense')),
          onPressed: () {
            showShadDialog(context: context, builder: (context) => const _ExpenseAddDialog());
          },
        ),
      ],
      body: Column(
        children: [
          FilterBar(
            hintText: 'Search by name, email or phone',
            accounts: accountList,
            onSearch: (q) => exCtrl().search(q),
            onReset: () => exCtrl().refresh(),
            showDateRange: true,
          ),
          Expanded(
            child: expenseList.when(
              loading: () => const Loading(),
              error: (e, s) => ErrorView(e, s, prov: expenseCtrlProvider),
              data: (expenses) {
                return DataTableBuilder<Expense, TableHeading>(
                  rowHeight: 110,
                  items: expenses,
                  headings: _headings,
                  headingBuilder: (heading) {
                    return GridColumn(
                      columnName: heading.name,
                      columnWidthMode: ColumnWidthMode.fill,
                      maximumWidth: heading.max,
                      minimumWidth: heading.minWidth ?? 100,
                      label: Container(
                        padding: Pads.med(),
                        alignment: heading.alignment,
                        child: Text(heading.name),
                      ),
                    );
                  },
                  cellAlignmentBuilder: (head) => _headings.fromName(head).alignment,
                  cellBuilder: (data, head) {
                    return switch (head.name) {
                      '#' => DataGridCell(
                        columnName: head.name,
                        value: Text((expenses.indexWhere((e) => e.id == data.id) + 1).toString()),
                      ),
                      'Amount' => DataGridCell(
                        columnName: head.name,
                        value: Text(data.amount.currency(), style: context.text.lead),
                      ),
                      'For' => DataGridCell(
                        columnName: head.name,
                        value: Text(data.expanseFor, style: context.text.p, maxLines: 2),
                      ),
                      'Category' => DataGridCell(
                        columnName: head.name,
                        value: ShadBadge.secondary(child: Text(data.category.name.titleCase, style: context.text.p)),
                      ),

                      'By' => DataGridCell(
                        columnName: head.name,
                        value: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(data.expenseBy.name, style: context.text.list),
                            Text(data.expenseBy.email, style: context.text.small, maxLines: 1),
                          ],
                        ),
                      ),
                      'Account' => DataGridCell(
                        columnName: head.name,
                        value: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(data.account.name, style: context.text.list),
                            SmallButton(
                              icon: LuIcons.arrowUpRight,
                              onPressed: () {
                                showShadDialog(
                                  context: context,
                                  builder: (context) => AccountViewDialog(acc: data.account),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                      'date' => DataGridCell(
                        columnName: head.name,
                        value: Column(
                          mainAxisSize: MainAxisSize.min,

                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(data.date.formatDate()),
                            Text(data.date.ago),
                          ],
                        ),
                      ),

                      'Action' => DataGridCell(
                        columnName: head.name,
                        value: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ShadButton(
                              size: ShadButtonSize.sm,
                              leading: const Icon(LuIcons.eye),
                              onPressed: () => showShadDialog(
                                context: context,
                                builder: (context) => _ExpenseViewDialog(ex: data),
                              ),
                            ).colored(Colors.blue).toolTip('View'),
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
}

class _ExpenseViewDialog extends HookConsumerWidget {
  const _ExpenseViewDialog({required this.ex});

  final Expense ex;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final Expense(expenseBy: user) = ex;
    return ShadDialog(
      title: const Text('Expense'),
      description: const Text('Details of an expense'),
      actions: [
        ShadButton.destructive(
          onPressed: () => context.nPop(),
          child: const SelectionContainer.disabled(child: Text('Cancel')),
        ),
      ],
      child: Container(
        padding: Pads.padding(v: Insets.med),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: Insets.med,
          children: [
            //! user
            ShadCard(
              title: Text('Expense By', style: context.text.muted),
              childPadding: Pads.sm('t'),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                spacing: Insets.med,
                children: [
                  HostedImage.square(user.getPhoto, dimension: 80, radius: Corners.med),
                  Flexible(
                    child: Column(
                      spacing: Insets.sm,
                      children: [
                        SpacedText(
                          left: 'Name',
                          right: user.name,
                          styleBuilder: (l, r) => (l, r.bold),
                          crossAxisAlignment: CrossAxisAlignment.center,
                        ),
                        SpacedText(
                          left: 'Phone Number',
                          right: user.phone,
                          styleBuilder: (l, r) => (l, r.bold),
                          crossAxisAlignment: CrossAxisAlignment.center,
                          onTap: (left, right) => Copier.copy(right),
                        ),
                        SpacedText(
                          left: 'Email',
                          right: user.email,
                          styleBuilder: (l, r) => (l, r.bold),
                          crossAxisAlignment: CrossAxisAlignment.center,
                          onTap: (left, right) => Copier.copy(right),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            if (ex.file != null)
              ShadCard(
                child: Row(
                  spacing: Insets.sm,
                  children: [
                    const ShadAvatar(LuIcons.file),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(ex.file!.name, style: context.text.p),
                          Text(ex.file!.ext),
                        ],
                      ),
                    ),
                    ShadIconButton(
                      icon: const Icon(LuIcons.download),
                      onPressed: () async {
                        final path = await ex.file!.download();
                        if (!context.mounted) return;
                        Toast.show(
                          context,
                          'Downloaded',
                          action: (id) => SmallButton(
                            icon: LuIcons.externalLink,
                            onPressed: () => OpenFilex.open(path),
                          ),
                        );
                      },
                    ).toolTip('Download'),
                  ],
                ),
              ),

            //! trx info
            SpacedText(left: 'Amount', right: ex.amount.currency(), styleBuilder: (l, r) => (l, r.bold)),
            SpacedText(left: 'Category', right: ex.category.name, styleBuilder: (l, r) => (l, r.bold)),
            SpacedText(left: 'Account', right: ex.account.name, styleBuilder: (l, r) => (l, r.bold)),
            SpacedText(left: 'Date', right: ex.date.formatDate(), styleBuilder: (l, r) => (l, r.bold)),
            SpacedText(left: 'Note', right: ex.note ?? '--', styleBuilder: (l, r) => (l, context.text.muted)),
          ],
        ),
      ),
    );
  }
}

class _ExpenseAddDialog extends HookConsumerWidget {
  // ignore: unused_element_parameter
  const _ExpenseAddDialog({this.ex});

  final Expense? ex;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watch(configCtrlProvider);

    final staffList = ref.watch(staffsCtrlProvider);
    final accountList = ref.watch(paymentAccountsCtrlProvider());
    final categoryList = ref.watch(expenseCategoryCtrlProvider);

    final formKey = useMemoized(GlobalKey<FormBuilderState>.new);
    final selectedFile = useState<PFile?>(null);

    final actionTxt = ex == null ? 'Add' : 'Update';
    return ShadDialog(
      title: Text('$actionTxt Expense'),
      description: Text(ex == null ? 'Fill the form to add an expense' : 'Fill the form to update'),
      actions: [
        ShadButton.destructive(
          onPressed: () => context.nPop(),
          child: const SelectionContainer.disabled(child: Text('Cancel')),
        ),
        SubmitButton(
          onPressed: (l) async {
            final state = formKey.currentState!;
            if (!state.saveAndValidate()) return;
            final data = state.transformedValues;

            final ctrl = ref.read(expenseCtrlProvider.notifier);
            (bool, String)? result;

            if (ex == null) {
              l.truthy();
              result = await ctrl.createExpense(data, selectedFile.value);
              l.falsey();
            } else {
              final updated = ex?.marge(data);
              if (updated == null) return;
              l.truthy();
              result = await ctrl.updateExpense(updated);
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
          initialValue: ex?.toMap() ?? {},
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: Insets.med,
            children: [
              ShadTextField(
                name: 'amount',
                label: 'Amount',
                isRequired: true,
                inputFormatters: [FilteringTextInputFormatter.allow(numRegExp)],
              ),
              Row(
                children: [
                  Flexible(
                    child: ShadTextField(name: 'expanse_for', label: 'Expanse For', isRequired: true),
                  ),
                  Flexible(
                    child: categoryList.maybeWhen(
                      orElse: () => ShadCard(padding: kDefInputPadding, child: const Loading()),
                      data: (category) {
                        return ShadSelectField<ExpenseCategory>(
                          name: 'expanseCategory',
                          label: 'Category',
                          hintText: 'Select a category',
                          isRequired: true,
                          initialValue: ex?.category,
                          valueTransformer: (value) => value?.toMap(),
                          options: category,
                          optionBuilder: (_, c, _) => ShadOption(value: c, child: Text(c.name)),
                          selectedBuilder: (context, v) => Text(v.name),
                          outsideTrailing: ShadIconButton.outline(
                            icon: const Icon(LuIcons.plus),
                            onPressed: () {
                              showShadDialog(context: context, builder: (context) => const ExCategoryAddDialog());
                            },
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Flexible(
                    child: staffList.maybeWhen(
                      orElse: () => ShadCard(padding: kDefInputPadding, child: const Loading()),
                      data: (roles) {
                        return ShadSelectField<AppUser>(
                          name: 'users',
                          label: 'Expense By',
                          hintText: 'Who is expending?',
                          initialValue: ex?.expenseBy,
                          isRequired: true,
                          valueTransformer: (value) => value?.toMap(),
                          options: roles,
                          optionBuilder: (_, c, _) => ShadOption(value: c, child: Text(c.name)),
                          selectedBuilder: (context, v) => Text(v.name),
                        );
                      },
                    ),
                  ),
                  Flexible(
                    child: accountList.maybeWhen(
                      orElse: () => ShadCard(padding: kDefInputPadding, child: const Loading()),
                      data: (acc) {
                        return ShadSelectField<PaymentAccount>(
                          name: 'payment_account',
                          label: 'Payment Account',
                          hintText: 'Select a account',
                          initialValue: ex?.account ?? config.defAccount,
                          isRequired: true,
                          valueTransformer: (value) => value?.toMap(),
                          options: acc,
                          optionBuilder: (_, c, _) => ShadOption(value: c, child: Text(c.name)),
                          selectedBuilder: (context, v) => Text(v.name),
                          outsideTrailing: ShadIconButton.outline(
                            icon: const Icon(LuIcons.plus),
                            onPressed: () {
                              showShadDialog(context: context, builder: (context) => const AccountAddDialog());
                            },
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
              ShadTextAreaField(name: 'note', label: 'Expanse For'),

              FilePickerField(selectedFile: selectedFile.value, onSelect: selectedFile.set),
            ],
          ),
        ),
      ),
    );
  }
}
