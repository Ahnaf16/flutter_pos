import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:pos/features/filter/view/filter_bar.dart';
import 'package:pos/features/payment_accounts/controller/payment_accounts_ctrl.dart';
import 'package:pos/features/payment_accounts/view/account_add_dialog.dart';
import 'package:pos/main.export.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

import 'local/account_name_builder.dart';

const _headings = [
  TableHeading.positional('#', 50.0),
  TableHeading.positional('Name'),
  TableHeading.positional('Amount', 300.0),
  TableHeading.positional('Type', 200.0),
  TableHeading.positional('Active', 200.0),
  TableHeading.positional('Action', 250.0, Alignment.centerRight),
];

class PaymentAccountsView extends HookConsumerWidget {
  const PaymentAccountsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accountList = ref.watch(paymentAccountsCtrlProvider(false));
    final accCtrl = useCallback(() => ref.read(paymentAccountsCtrlProvider(false).notifier));

    return BaseBody(
      title: 'Payment Accounts',
      actions: [
        ShadButton(
          child: const SelectionContainer.disabled(child: Text('Add a account')),
          onPressed: () {
            showShadDialog(context: context, builder: (context) => const AccountAddDialog());
          },
        ),
      ],
      body: Column(
        children: [
          FilterBar(
            hintText: 'Search by name or type',
            onSearch: (q) => accCtrl().search(q),
            onReset: () => accCtrl().refresh(),
          ),

          Expanded(
            child: accountList.when(
              loading: () => const Loading(),
              error: (e, s) => ErrorView(e, s, prov: paymentAccountsCtrlProvider),
              data: (accounts) {
                return DataTableBuilder<PaymentAccount, TableHeading>(
                  rowHeight: 70,
                  items: accounts,
                  headings: _headings,
                  headingBuilder: (heading) => GridColumn(
                    columnName: heading.name,
                    columnWidthMode: ColumnWidthMode.fill,
                    maximumWidth: heading.max,
                    minimumWidth: heading.minWidth ?? 200,
                    label: Container(padding: Pads.med(), alignment: heading.alignment, child: Text(heading.name)),
                  ),
                  cellAlignmentBuilder: (h) => _headings.fromName(h).alignment,
                  cellBuilder: (data, head) {
                    return switch (head.name) {
                      '#' => DataGridCell(
                        columnName: head.name,
                        value: Text((accounts.indexWhere((e) => e.id == data.id) + 1).toString()),
                      ),
                      'Name' => DataGridCell(
                        columnName: head.name,
                        value: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(data.name),
                            if (data.description != null)
                              Text(data.description!, style: context.text.muted, maxLines: 1),
                          ],
                        ),
                      ),
                      'Amount' => DataGridCell(columnName: head.name, value: Text(data.amount.currency())),
                      'Type' => DataGridCell(
                        columnName: head.name,
                        value: ShadBadge.secondary(child: Text(data.type.name.titleCase)),
                      ),

                      'Active' => DataGridCell(columnName: head.name, value: _buildActiveCell(data)),

                      'Action' => DataGridCell(
                        columnName: head.name,
                        value: PopOverBuilder(
                          actionSpread: true,
                          children: (context, hide) => [
                            PopOverButton(
                              dense: true,
                              color: Colors.blue,
                              icon: const Icon(LuIcons.eye),
                              toolTip: 'View',
                              onPressed: () {
                                hide();
                                showShadDialog(
                                  context: context,
                                  builder: (context) => AccountViewDialog(acc: data),
                                );
                              },
                              child: const Text('View'),
                            ),
                            PopOverButton(
                              dense: true,
                              color: Colors.green,
                              icon: const Icon(LuIcons.pen),
                              toolTip: 'Edit',
                              onPressed: () {
                                hide();
                                showShadDialog(
                                  context: context,
                                  builder: (context) => AccountAddDialog(acc: data),
                                );
                              },
                              child: const Text('Edit'),
                            ),

                            if (data.amount > 0 && accounts.length > 1)
                              PopOverButton(
                                dense: true,
                                color: Colors.purple,
                                icon: const Icon(LuIcons.arrowLeftRight),
                                toolTip: 'Transfer',
                                onPressed: () {
                                  hide();
                                  showShadDialog(
                                    context: context,
                                    builder: (context) => _AccountBalanceTransfer(acc: data),
                                  );
                                },
                                child: const Text('Transfer'),
                              ),

                            PopOverButton(
                              dense: true,

                              isDestructive: true,
                              icon: const Icon(LuIcons.trash),
                              toolTip: 'Delete',
                              child: const Text('Delete'),
                              onPressed: () {
                                hide();
                                if (accounts.length == 1) {
                                  return Toast.showErr(context, 'At least one account is required');
                                }

                                showShadDialog(
                                  context: context,
                                  builder: (context) => _AccountDeleteDialog(acc: data),
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
          ),
        ],
      ),
    );
  }

  Widget _buildActiveCell(PaymentAccount acc) {
    return HookConsumer(
      builder: (context, ref, c) {
        final loading = useState(false);
        if (loading.value) return const Loading(center: false);
        return ShadSwitch(
          value: acc.isActive,
          onChanged: (v) async {
            try {
              final ctrl = ref.read(paymentAccountsCtrlProvider(false).notifier);
              loading.truthy();
              await ctrl.toggleEnable(v, acc);
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

class _AccountBalanceTransfer extends HookConsumerWidget {
  const _AccountBalanceTransfer({required this.acc});

  final PaymentAccount acc;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formKey = useMemoized(GlobalKey<FormBuilderState>.new);

    final accountList = ref.watch(paymentAccountsCtrlProvider());

    return FormBuilder(
      key: formKey,
      child: ShadDialog(
        title: const Text('Account'),
        description: Text('Transfer balance from ${acc.name}'),
        actions: [
          ShadButton.destructive(
            onPressed: () => context.nPop(),
            child: const SelectionContainer.disabled(child: Text('Cancel')),
          ),
          ShadButton(
            enabled: acc.amount > 0,
            onPressed: () async {
              final state = formKey.currentState!;
              if (!state.saveAndValidate()) return;
              final data = QMap.from(state.transformedValues);

              final transferState = AccBalanceTransferState.fromMap(data);
              final ctrl = ref.read(paymentAccountsCtrlProvider().notifier);
              final result = await ctrl.transferBalance(transferState);

              if (context.mounted) {
                result.showToast(context);
                if (result.success) context.nPop();
              }
            },
            child: const SelectionContainer.disabled(child: Text('Transfer')),
          ),
        ],
        child: Container(
          padding: Pads.padding(v: Insets.med),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: Insets.sm,
            children: [
              VisibilityField<PaymentAccount>(name: 'from', data: acc, valueTransformer: (v) => v?.toMap()),
              SpacedText(
                left: 'Available balance',
                right: acc.amount.currency(),
                styleBuilder: (l, r) => (l, context.text.list),
                crossAxisAlignment: CrossAxisAlignment.center,
              ),

              //! TO
              ShadCard(
                title: Text(
                  'Transfer to',
                  style: context.theme.decoration.labelStyle,
                ),
                childPadding: Pads.med('t'),
                child: Row(
                  children: [
                    Expanded(
                      child: accountList.maybeWhen(
                        orElse: () => ShadCard(padding: kDefInputPadding, child: const Loading()),
                        data: (accounts) {
                          accounts = accounts.where((e) => e.id != acc.id).toList();
                          return ShadSelectField<PaymentAccount>(
                            name: 'to',
                            hintText: 'select an account',
                            label: 'Payment account',
                            isRequired: true,
                            options: accounts,
                            valueTransformer: (value) => value?.toMap(),
                            optionBuilder: (_, v, i) {
                              return ShadOption(value: v, child: AccountNameBuilder(v));
                            },
                            selectedBuilder: (_, v) => AccountNameBuilder(v),
                          );
                        },
                      ),
                    ),
                    Expanded(
                      child: ShadTextField(
                        name: 'amount',
                        hintText: 'Amount',
                        label: 'Amount',
                        numeric: true,
                        isRequired: true,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AccountDeleteDialog extends HookConsumerWidget {
  const _AccountDeleteDialog({
    required this.acc,
  });

  final PaymentAccount acc;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formKey = useMemoized(GlobalKey<FormBuilderState>.new);

    final accountList = ref.watch(paymentAccountsCtrlProvider());

    final needToTransfer = acc.amount > 0;

    return FormBuilder(
      key: formKey,
      child: ShadDialog(
        title: const Text('Delete Account'),
        description: Text('Are you sure you want to delete ${acc.name}?'),
        actions: [
          ShadButton(
            onPressed: () => context.nPop(),
            child: const SelectionContainer.disabled(child: Text('Cancel')),
          ),
          SubmitButton(
            variant: ShadButtonVariant.destructive,
            onPressed: (l) async {
              final state = formKey.currentState!;
              if (!state.saveAndValidate()) return;
              final data = QMap.from(state.transformedValues);

              final ctrl = ref.read(paymentAccountsCtrlProvider().notifier);

              if (needToTransfer) {
                final transferState = AccBalanceTransferState.fromMap(data);
                final result = await ctrl.transferBalance(transferState);
                if (context.mounted && !result.success) {
                  result.showToast(context);
                  return;
                }
              }
              final result = await ctrl.delete(acc);

              if (context.mounted) {
                result.showToast(context);
                if (result.success) context.nPop();
              }
            },
            child: SelectionContainer.disabled(child: Text(needToTransfer ? 'Transfer and Delete' : 'Delete')),
          ),
        ],
        child: Container(
          padding: Pads.padding(v: Insets.med),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: Insets.sm,
            children: [
              if (needToTransfer)
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: Insets.sm,
                  children: [
                    ShadAlert.destructive(
                      iconData: LuIcons.triangleAlert,
                      description: Text(
                        '"${acc.name}" has ${acc.amount.currency()} in it. Transfer them before deleting the account.',
                      ),
                    ),
                    VisibilityField<PaymentAccount>(name: 'from', data: acc, valueTransformer: (v) => v?.toMap()),
                    VisibilityField<String>(name: 'amount', data: '${acc.amount}'),

                    SpacedText(
                      left: 'Transferable balance',
                      right: acc.amount.currency(),
                      styleBuilder: (l, r) => (l, context.text.list),
                      crossAxisAlignment: CrossAxisAlignment.center,
                    ),

                    //! TO
                    accountList.maybeWhen(
                      orElse: () => ShadCard(padding: kDefInputPadding, child: const Loading()),
                      data: (accounts) {
                        accounts = accounts.where((e) => e.id != acc.id).toList();
                        return ShadSelectField<PaymentAccount>(
                          name: 'to',
                          hintText: 'select an account',
                          label: 'Payment account',
                          isRequired: true,
                          options: accounts,
                          valueTransformer: (value) => value?.toMap(),
                          optionBuilder: (_, v, i) {
                            return ShadOption(value: v, child: AccountNameBuilder(v));
                          },
                          selectedBuilder: (_, v) => AccountNameBuilder(v),
                        );
                      },
                    ),
                  ],
                )
              else
                ShadAlert.destructive(
                  iconData: LuIcons.triangleAlert,
                  description: Text('"${acc.name}" will be permanently deleted.'),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class AccountViewDialog extends HookConsumerWidget {
  const AccountViewDialog({super.key, required this.acc});

  final PaymentAccount acc;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ShadDialog(
      title: const Text('Account'),
      description: Text('Details of ${acc.name}'),
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
          spacing: Insets.sm,
          children: [
            Row(
              spacing: Insets.med,
              children: [
                ShadBadge.raw(
                  variant: acc.isActive ? ShadBadgeVariant.primary : ShadBadgeVariant.destructive,
                  child: Text(acc.isActive ? 'Active' : 'Inactive'),
                ),
                ShadBadge(child: Text(acc.type.name.titleCase)),
              ],
            ),
            SpacedText(left: 'Name', right: acc.name, styleBuilder: (l, r) => (l, r.bold)),
            SpacedText(
              left: 'Amount',
              right: acc.amount.currency(),
              styleBuilder: (l, r) => (l, context.text.list),
              crossAxisAlignment: CrossAxisAlignment.center,
            ),
            if (acc.description != null)
              SpacedText(left: 'Description', right: acc.description!, styleBuilder: (l, r) => (l, context.text.muted)),

            Text('Custom info:', style: context.theme.decoration.labelStyle),
            for (final MapEntry(:key, :value) in acc.customInfo.entries)
              SpacedText(left: key, right: value, styleBuilder: (l, r) => (l, r.bold)),
          ],
        ),
      ),
    );
  }
}
