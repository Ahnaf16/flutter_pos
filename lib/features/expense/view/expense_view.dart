import 'package:flutter/services.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:pos/features/expense/controller/expense_ctrl.dart';
import 'package:pos/features/payment_accounts/controller/payment_accounts_ctrl.dart';
import 'package:pos/features/staffs/controller/staffs_ctrl.dart';
import 'package:pos/main.export.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

const _headings = [('For', double.nan), ('By', 300.0), ('Account', 200.0), ('date', 130.0), ('Action', 200.0)];

class ExpenseView extends HookConsumerWidget {
  const ExpenseView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final expenseList = ref.watch(expenseCtrlProvider);

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
      body: expenseList.when(
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
                            () => showShadDialog(context: context, builder: (context) => _ExpenseViewDialog(ex: data)),
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
                          spaced: false,
                          crossAxisAlignment: CrossAxisAlignment.center,
                        ),
                        SpacedText(
                          left: 'Phone Number',
                          right: user.phone,
                          styleBuilder: (l, r) => (l, r.bold),
                          spaced: false,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          onTap: (left, right) => Copier.copy(right),
                        ),
                        SpacedText(
                          left: 'Email',
                          right: user.email,
                          styleBuilder: (l, r) => (l, r.bold),
                          spaced: false,
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
            SpacedText(left: 'Amount', right: ex.amount.currency(), styleBuilder: (l, r) => (l, r.bold), spaced: false),

            SpacedText(left: 'Account', right: ex.account.name, styleBuilder: (l, r) => (l, r.bold), spaced: false),
            SpacedText(left: 'Date', right: ex.date.formatDate(), styleBuilder: (l, r) => (l, r.bold), spaced: false),
            SpacedText(
              left: 'Note',
              right: ex.note ?? '--',
              styleBuilder: (l, r) => (l, context.text.muted),
              spaced: false,
            ),
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
    final staffList = ref.watch(staffsCtrlProvider);
    final accountList = ref.watch(paymentAccountsCtrlProvider);
    final categoryList = ref.watch(expenseCategoryCtrlProvider);

    final searchUser = useState('');

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
            final data = state.value;

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
              ShadField(
                name: 'amount',
                label: 'Amount',
                isRequired: true,
                inputFormatters: [FilteringTextInputFormatter.allow(decimalRegExp)],
              ),
              Row(
                children: [
                  const Flexible(child: ShadField(name: 'expanse_for', label: 'Expanse For', isRequired: true)),
                  Flexible(
                    child: FormBuilderField<QMap>(
                      name: 'expanseCategory',
                      validator: FormBuilderValidators.required(),
                      builder: (form) {
                        return ShadInputDecorator(
                          label: const Text('Category').required(),
                          error: form.errorText == null ? null : Text(form.errorText!),
                          decoration: context.theme.decoration.copyWith(hasError: form.hasError),
                          child: categoryList.maybeWhen(
                            orElse: () => ShadCard(padding: kDefInputPadding, child: const Loading()),
                            data: (roles) {
                              final filtered = roles.where((e) => e.name.low.contains(searchUser.value.low));
                              return LimitedWidthBox(
                                child: ShadSelect<ExpenseCategory>(
                                  initialValue: ExpenseCategory.tryParse(form.value),
                                  placeholder: const Text('Select a category'),
                                  options: [
                                    if (filtered.isEmpty)
                                      Padding(padding: Pads.padding(v: 24), child: const Text('No category found')),

                                    ...filtered.map((c) {
                                      return ShadOption(value: c, child: Text(c.name));
                                    }),
                                  ],
                                  selectedOptionBuilder: (context, v) => Text(v.name),
                                  onChanged: (v) => form.didChange(v?.toMap()),
                                ),
                              );
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
                    child: FormBuilderField<QMap>(
                      name: 'users',
                      validator: FormBuilderValidators.required(),
                      builder: (form) {
                        return ShadInputDecorator(
                          label: const Text('Expense By').required(),
                          error: form.errorText == null ? null : Text(form.errorText!),
                          decoration: context.theme.decoration.copyWith(hasError: form.hasError),
                          child: staffList.maybeWhen(
                            orElse: () => ShadCard(padding: kDefInputPadding, child: const Loading()),
                            data: (roles) {
                              final filtered = roles.where((e) => e.name.low.contains(searchUser.value.low));
                              return LimitedWidthBox(
                                child: ShadSelect<AppUser>.withSearch(
                                  initialValue: AppUser.tryParse(form.value),
                                  placeholder: const Text('Who is expensing?'),
                                  options: [
                                    if (filtered.isEmpty)
                                      Padding(padding: Pads.padding(v: 24), child: const Text('No one found')),

                                    ...filtered.map((user) {
                                      return ShadOption(value: user, child: Text(user.name));
                                    }),
                                  ],
                                  selectedOptionBuilder: (context, v) => Text(v.name),
                                  onSearchChanged: searchUser.set,
                                  onChanged: (v) => form.didChange(v?.toMap()),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
                  ),
                  Flexible(
                    child: FormBuilderField<QMap>(
                      name: 'payment_account',
                      validator: FormBuilderValidators.required(),
                      builder: (form) {
                        return ShadInputDecorator(
                          label: const Text('Payment Account').required(),
                          error: form.errorText == null ? null : Text(form.errorText!),
                          decoration: context.theme.decoration.copyWith(hasError: form.hasError),
                          child: accountList.maybeWhen(
                            orElse: () => ShadCard(padding: kDefInputPadding, child: const Loading()),
                            data: (acc) {
                              final filtered = acc.where((e) => e.name.low.contains(searchUser.value.low));
                              return LimitedWidthBox(
                                child: ShadSelect<PaymentAccount>(
                                  initialValue: PaymentAccount.tryParse(form.value),
                                  placeholder: const Text('Select a payment account'),
                                  options: [
                                    if (filtered.isEmpty)
                                      Padding(padding: Pads.padding(v: 24), child: const Text('Not found')),

                                    ...filtered.map((role) {
                                      return ShadOption(value: role, child: Text(role.name));
                                    }),
                                  ],
                                  selectedOptionBuilder: (context, v) => Text(v.name),
                                  onChanged: (v) => form.didChange(v?.toMap()),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
              const TextArea(name: 'note', label: 'Expanse For'),
            ],
          ),
        ),
      ),
    );
  }
}
