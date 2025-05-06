import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:pos/features/auth/controller/auth_ctrl.dart';
import 'package:pos/features/parties/controller/parties_ctrl.dart';
import 'package:pos/features/payment_accounts/controller/payment_accounts_ctrl.dart';
import 'package:pos/features/staffs/controller/staffs_ctrl.dart';
import 'package:pos/features/transactions/controller/transactions_ctrl.dart';
import 'package:pos/main.export.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

const _headings = [
  TableHeading.positional('To'),
  TableHeading.positional('From'),
  TableHeading.positional('Amount', 300.0, Alignment.center),
  TableHeading.positional('Account', 150.0, Alignment.center),
  TableHeading.positional('Type', 110.0, Alignment.center),
  TableHeading.positional('Date', 150.0, Alignment.center),
  TableHeading.positional('Action', 100.0, Alignment.centerRight),
];

class TransactionsView extends HookConsumerWidget {
  const TransactionsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final partiList = ref.watch(transactionLogCtrlProvider);
    return BaseBody(
      title: 'Transaction logs',
      actions: [
        ShadButton(
          onPressed: () {
            showShadDialog(context: context, builder: (context) => const _TrxAddDialog());
          },
          child: const Text('Add manual transaction'),
        ),
      ],
      body: partiList.when(
        loading: () => const Loading(),
        error: (e, s) => ErrorView(e, s, prov: transactionLogCtrlProvider),
        data: (dues) {
          return DataTableBuilder<TransactionLog, TableHeading>(
            rowHeight: 120,
            items: dues,
            headings: _headings,
            headingBuilderIndexed: (heading, i) {
              final alignment = heading.alignment;
              return GridColumn(
                columnName: heading.name,
                columnWidthMode: ColumnWidthMode.fill,
                maximumWidth: heading.max,
                minimumWidth: context.layout.isDesktop ? 100 : 200,
                label: Container(padding: Pads.med(), alignment: alignment, child: Text(heading.name)),
              );
            },
            cellAlignment: Alignment.centerLeft,
            cellAlignmentBuilder: (i) => _headings.fromName(i).alignment,
            cellBuilder: (data, head) {
              return switch (head.name) {
                'To' => DataGridCell(
                  columnName: head.name,
                  value: _NameBuilder(data.getParti?.name, data.getParti?.phone),
                ),
                'From' => DataGridCell(
                  columnName: head.name,
                  value: _NameBuilder(data.transactionBy.name, data.transactionBy.phone),
                ),
                'Amount' => DataGridCell(
                  columnName: head.name,
                  value: Column(
                    spacing: Insets.xs,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SpacedText(left: 'Amount', right: data.amount.currency()),
                      if (data.usedDueBalance > 0)
                        SpacedText(
                          left: data.type == TransactionType.sale ? 'Balance used' : 'Due used',
                          right: data.usedDueBalance.currency(),
                        ),
                    ],
                  ),
                ),
                'Account' => DataGridCell(
                  columnName: head.name,
                  value: ShadBadge.secondary(child: Text(data.account.name.up)),
                ),
                'Type' => DataGridCell(
                  columnName: head.name,
                  value: ShadBadge.secondary(child: Text(data.type.name.up)),
                ),
                'Date' => DataGridCell(columnName: head.name, value: Center(child: Text(data.date.formatDate()))),
                'Action' => DataGridCell(
                  columnName: head.name,
                  value: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      ShadButton.secondary(
                        size: ShadButtonSize.sm,
                        leading: const Icon(LuIcons.eye),
                        onPressed: () {
                          showShadDialog(context: context, builder: (context) => _TrxViewDialog(trx: data));
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
}

class _NameBuilder extends StatelessWidget {
  const _NameBuilder(this.name, this.phone);
  final String? name;
  final String? phone;
  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: Insets.xs,
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [OverflowMarquee(child: Text(name ?? '--', style: context.text.list)), Text(phone ?? '--')],
    );
  }
}

class _TrxViewDialog extends HookConsumerWidget {
  const _TrxViewDialog({required this.trx});

  final TransactionLog trx;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final TransactionLog(getParti: parti, :transactTo, :transactToPhone, transactionBy: user) = trx;
    return ShadDialog(
      title: const Text('Transaction log'),
      description: Row(
        spacing: Insets.sm,
        children: [const Text('Details of a transaction'), ShadBadge.secondary(child: Text(trx.type.name.up))],
      ),

      actions: [ShadButton.destructive(onPressed: () => context.nPop(), child: const Text('Cancel'))],
      child: Container(
        padding: Pads.padding(v: Insets.med),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: Insets.med,
          children: [
            //! parti
            if (parti != null || transactTo != null || transactToPhone != null)
              ShadCard(
                title: Text('Transacted To', style: context.text.muted),
                childPadding: Pads.sm('t'),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  spacing: Insets.med,
                  children: [
                    if (parti?.getPhoto != null)
                      Flexible(
                        child: ShadCard(
                          height: 80,
                          width: 80,
                          padding: Pads.zero,
                          child: FittedBox(
                            child: HostedImage.square(parti!.getPhoto, dimension: 80, radius: Corners.med),
                          ),
                        ),
                      ),

                    Flexible(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        spacing: Insets.sm,
                        children: [
                          SpacedText(
                            left: 'Name',
                            right: parti?.name ?? transactTo ?? '--',
                            styleBuilder: (l, r) => (l, r.bold),
                            spaced: false,
                            crossAxisAlignment: CrossAxisAlignment.center,
                          ),

                          SpacedText(
                            left: 'Phone Number',
                            right: parti?.phone ?? transactToPhone ?? '--',
                            styleBuilder: (l, r) => (l, r.bold),
                            spaced: false,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            onTap: (left, right) => Copier.copy(right),
                          ),
                          if (parti?.isWalkIn ?? false)
                            ShadBadge.secondary(child: Text('Walk-In', style: context.text.muted)),
                          if (parti != null && !parti.isWalkIn) ...[
                            SpacedText(
                              left: 'Email',
                              right: parti.email ?? '--',
                              styleBuilder: (l, r) => (l, r.bold),
                              spaced: false,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              onTap: (left, right) => Copier.copy(right),
                            ),

                            SpacedText(
                              left: 'Address',
                              right: parti.address ?? '--',
                              styleBuilder: (l, r) => (l, r.bold),
                              spaced: false,
                              crossAxisAlignment: CrossAxisAlignment.center,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),

            //! user
            ShadCard(
              title: Text(
                trx.type == TransactionType.expanse ? 'Expense by' : 'Transacted By',
                style: context.text.muted,
              ),
              childPadding: Pads.sm('t'),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                spacing: Insets.med,
                children: [
                  ShadCard(
                    expanded: false,
                    height: 80,
                    width: 80,
                    padding: Pads.zero,
                    child: FittedBox(child: HostedImage.square(user.getPhoto, dimension: 80)),
                  ),
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
                      ],
                    ),
                  ),
                ],
              ),
            ),

            //! trx info
            const Gap(Insets.sm),
            SpacedText(
              left: 'Amount',
              right: trx.amount.currency(),
              styleBuilder: (l, r) => (l, r.bold),
              spaced: false,
            ),
            SpacedText(
              left: 'Used due balance',
              right: trx.usedDueBalance.currency(),
              styleBuilder: (l, r) => (l, r.bold),
              spaced: false,
            ),
            SpacedText(left: 'Account', right: trx.account.name, styleBuilder: (l, r) => (l, r.bold), spaced: false),
            SpacedText(left: 'Date', right: trx.date.formatDate(), styleBuilder: (l, r) => (l, r.bold), spaced: false),
            SpacedText(
              left: 'Note',
              right: trx.note ?? '--',
              styleBuilder: (l, r) => (l, context.text.muted),
              spaced: false,
            ),
          ],
        ),
      ),
    );
  }
}

class _TrxAddDialog extends HookConsumerWidget {
  const _TrxAddDialog();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formKey = useMemoized(GlobalKey<FormBuilderState>.new);

    final staffList = ref.watch(staffsCtrlProvider);
    final accountList = ref.watch(paymentAccountsCtrlProvider);
    final partiList = ref.watch(partiesCtrlProvider(null));
    final user = ref.watch(authStateSyncProvider).toNullable();
    return ShadDialog(
      title: const Text('Create'),
      description: const Text('Fill the form and to add a transaction log'),
      actions: [
        ShadButton.destructive(onPressed: () => context.nPop(), child: const Text('Cancel')),

        SubmitButton(
          onPressed: (l) async {
            final state = formKey.currentState!;
            if (!state.saveAndValidate()) return;
            final data = QMap.from(state.value);

            final ctrl = ref.read(transactionLogCtrlProvider.notifier);

            l.truthy();
            final result = await ctrl.createManual(data);
            l.falsey();

            // if (result case final Result r) {
            //   if (!context.mounted) return;
            //   r.showToast(context);
            //   if (r.success) context.pop(true);
            // }
          },
          child: const Text('Create'),
        ),
      ],
      child: Container(
        padding: Pads.padding(v: Insets.med),
        child: FormBuilder(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: Insets.med,
            children: [
              FormBuilderField<String>(
                name: 'transaction_type',
                validator: FormBuilderValidators.required(),
                initialValue: TransactionType.manual.name,
                builder: (form) {
                  return ShadInputDecorator(
                    label: const Text('Choose a type').required(),
                    error: form.errorText == null ? null : Text(form.errorText!),
                    decoration: context.theme.decoration.copyWith(hasError: form.hasError),
                    child: LimitedWidthBox(
                      child: ShadSelect<TransactionType>(
                        initialValue: TransactionType.values.tryByName(form.value),
                        placeholder: const Text('Transaction type'),
                        itemCount: PartiType.suppliers.length,
                        options: [
                          for (final type in TransactionType.values)
                            ShadOption(value: type, child: Text(type.name.titleCase)),
                        ],
                        onChanged: (value) => form.didChange(value?.name),
                        selectedOptionBuilder: (context, v) => Text(v.name),
                      ),
                    ),
                  );
                },
              ),
              Row(
                children: [
                  Flexible(child: ShadTextField(name: 'amount', hintText: 'Amount', label: 'Amount', numeric: true)),

                  Flexible(
                    child: staffList.maybeWhen(
                      orElse: () => ShadCard(padding: kDefInputPadding, child: const Loading()),
                      data: (staffs) {
                        return FormBuilderField<QMap>(
                          name: 'transaction_by',
                          validator: FormBuilderValidators.required(),
                          initialValue: user?.toMap(),
                          builder: (form) {
                            return ShadInputDecorator(
                              label: const Text('Transacted by').required(),
                              error: form.errorText == null ? null : Text(form.errorText!),
                              decoration: context.theme.decoration.copyWith(hasError: form.hasError),
                              child: LimitedWidthBox(
                                child: ShadSelect<AppUser>(
                                  initialValue: AppUser.tryParse(form.value),
                                  placeholder: const Text('Who did the transaction'),
                                  itemCount: PartiType.suppliers.length,
                                  options: [
                                    for (final type in staffs)
                                      ShadOption(value: type, child: Text(type.name.titleCase)),
                                  ],
                                  onChanged: (value) => form.didChange(value?.toMap()),
                                  selectedOptionBuilder: (context, v) => Text(v.name),
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
              accountList.maybeWhen(
                orElse: () => ShadCard(padding: kDefInputPadding, child: const Loading()),
                data: (accounts) {
                  return FormBuilderField<QMap>(
                    name: 'payment_account',
                    validator: FormBuilderValidators.required(),
                    builder: (form) {
                      return ShadInputDecorator(
                        label: const Text('Payment account').required(),
                        error: form.errorText == null ? null : Text(form.errorText!),
                        decoration: context.theme.decoration.copyWith(hasError: form.hasError),
                        child: LimitedWidthBox(
                          child: ShadSelect<PaymentAccount>(
                            placeholder: const Text('Payment account'),
                            itemCount: accounts.length,
                            options: [
                              for (final type in accounts) ShadOption(value: type, child: Text(type.name.titleCase)),
                            ],
                            onChanged: (value) => form.didChange(value?.toMap()),
                            selectedOptionBuilder: (context, v) => Text(v.name),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),

              ShadCard(
                title: Text('Transacted to', style: context.theme.decoration.labelStyle),
                child: Column(
                  spacing: Insets.med,
                  children: [
                    partiList.maybeWhen(
                      orElse: () => ShadCard(padding: kDefInputPadding, child: const Loading()),
                      data: (parties) {
                        return FormBuilderField<QMap>(
                          name: 'parties',
                          builder: (form) {
                            return ShadInputDecorator(
                              error: form.errorText == null ? null : Text(form.errorText!),
                              decoration: context.theme.decoration.copyWith(hasError: form.hasError),
                              child: LimitedWidthBox(
                                child: ShadSelect<Parti>(
                                  placeholder: const Text('To whom? '),
                                  itemCount: parties.length,
                                  options: [
                                    for (final type in parties)
                                      ShadOption(value: type, child: Text(type.name.titleCase)),
                                  ],
                                  onChanged: (value) => form.didChange(value?.toMap()),
                                  selectedOptionBuilder: (context, v) => Text(v.name),
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                    const Text('OR'),
                    Row(
                      children: [
                        Flexible(child: ShadTextField(name: 'transact_to', hintText: 'Name')),
                        Flexible(child: ShadTextField(name: 'transact_to_phone', hintText: 'Phone')),
                      ],
                    ),
                  ],
                ),
              ),

              ShadTextAreaField(name: 'note', label: 'Note'),
            ],
          ),
        ),
      ),
    );
  }
}
