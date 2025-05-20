import 'package:flutter/services.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:pos/features/expense/controller/expense_ctrl.dart';
import 'package:pos/features/expense/view/expense_category_view.dart';
import 'package:pos/features/payment_accounts/controller/payment_accounts_ctrl.dart';
import 'package:pos/features/payment_accounts/view/account_add_dialog.dart';
import 'package:pos/features/settings/controller/settings_ctrl.dart';
import 'package:pos/features/staffs/controller/staffs_ctrl.dart';
import 'package:pos/main.export.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

const _headings = [('For', double.nan), ('By', 300.0), ('Account', 200.0), ('date', 130.0), ('Action', 200.0)];

class ExpenseView extends HookConsumerWidget {
  const ExpenseView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final expenseList = ref.watch(expenseCtrlProvider);
    final exCtrl = useCallback(() => ref.read(expenseCtrlProvider.notifier));
    final accountList = ref.watch(paymentAccountsCtrlProvider(false));
    final categoryList = ref.watch(expenseCategoryCtrlProvider);

    return BaseBody(
      title: 'Expense',
      actions: [
        ShadButton(
          child: const Text('Add a expense'),
          onPressed: () {
            showShadDialog(context: context, builder: (context) => const _ExpenseAddDialog());
          },
        ),
      ],
      body: Column(
        children: [
          Row(
            children: [
              SizedBox(
                width: 350,
                child: ShadTextField(
                  hintText: 'Search',
                  onChanged: (v) => exCtrl().search(v ?? ''),
                  showClearButton: true,
                ),
              ),
              SizedBox(
                width: 250,
                child: categoryList.maybeWhen(
                  orElse: () => ShadCard(padding: kDefInputPadding, child: const Loading()),
                  data: (categories) {
                    return ShadSelectField<ExpenseCategory>(
                      hintText: 'Category',
                      options: categories,
                      selectedBuilder: (context, value) => Text(value.name),
                      optionBuilder: (_, value, _) {
                        return ShadOption(value: value, child: Text(value.name));
                      },
                      onChanged: (v) => exCtrl().filter(category: v),
                    );
                  },
                ),
              ),
              SizedBox(
                width: 250,
                child: accountList.maybeWhen(
                  orElse: () => ShadCard(padding: kDefInputPadding, child: const Loading()),
                  data: (accounts) {
                    return ShadSelectField<PaymentAccount>(
                      hintText: 'Accounts',
                      options: accounts,
                      selectedBuilder: (context, value) => Text(value.name),
                      optionBuilder: (_, value, _) {
                        return ShadOption(value: value, child: Text(value.name));
                      },
                      onChanged: (v) => exCtrl().filter(acc: v),
                    );
                  },
                ),
              ),
            ],
          ),
          const Gap(Insets.med),
          Expanded(
            child: expenseList.when(
              loading: () => const Loading(),
              error: (e, s) => ErrorView(e, s, prov: expenseCtrlProvider),
              data: (expenses) {
                return DataTableBuilder<Expense, (String, double)>(
                  rowHeight: 110,
                  items: expenses,
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
                      'For' => DataGridCell(
                        columnName: head.$1,
                        value: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(data.amount.currency(), style: context.text.lead),
                            Text(data.expanseFor, style: context.text.small, maxLines: 2),
                          ],
                        ),
                      ),

                      'By' => DataGridCell(
                        columnName: head.$1,
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
                        columnName: head.$1,
                        value: Text(data.account.name, style: context.text.list),
                      ),
                      'date' => DataGridCell(columnName: head.$1, value: Text(data.date.formatDate())),

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
                                    builder: (context) => _ExpenseViewDialog(ex: data),
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
      actions: [ShadButton.destructive(onPressed: () => context.nPop(), child: const Text('Cancel'))],
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
            //! trx info
            const Gap(Insets.sm),
            SpacedText(left: 'Amount', right: ex.amount.currency(), styleBuilder: (l, r) => (l, r.bold)),

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
    final actionTxt = ex == null ? 'Add' : 'Update';
    return ShadDialog(
      title: Text('$actionTxt Expense'),
      description: Text(ex == null ? 'Fill the form to add an expense' : 'Fill the form to update'),
      actions: [
        ShadButton.destructive(onPressed: () => context.nPop(), child: const Text('Cancel')),
        SubmitButton(
          onPressed: (l) async {
            final state = formKey.currentState!;
            if (!state.saveAndValidate()) return;
            final data = state.transformedValues;

            final ctrl = ref.read(expenseCtrlProvider.notifier);
            (bool, String)? result;

            if (ex == null) {
              l.truthy();
              result = await ctrl.createExpense(data);
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
                  Flexible(child: ShadTextField(name: 'expanse_for', label: 'Expanse For', isRequired: true)),
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
            ],
          ),
        ),
      ),
    );
  }
}
