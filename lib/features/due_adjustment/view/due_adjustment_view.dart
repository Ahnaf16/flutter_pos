import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:pos/features/auth/controller/auth_ctrl.dart';
import 'package:pos/features/due_adjustment/view/related_records.dart';
import 'package:pos/features/parties/controller/parties_ctrl.dart';
import 'package:pos/features/parties/view/party_name_builder.dart';
import 'package:pos/features/payment_accounts/controller/payment_accounts_ctrl.dart';
import 'package:pos/features/payment_accounts/view/local/account_name_builder.dart';
import 'package:pos/features/settings/controller/settings_ctrl.dart';
import 'package:pos/features/transactions/controller/transactions_ctrl.dart';
import 'package:pos/main.export.dart';

class DueAdjustmentView extends HookConsumerWidget {
  const DueAdjustmentView({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final extra = context.tryGetExtra<Party>();
    final transfer = context.query('isTransfer') == 'true';

    final formKey = useMemoized(GlobalKey<FormBuilderState>.new);

    final selectedParty = useState<Party?>(extra);

    final config = ref.watch(configCtrlProvider);
    final user = ref.watch(authStateSyncProvider).toNullable();

    final partiList = ref.watch(partiesCtrlProvider(true));
    final accountList = ref.watch(paymentAccountsCtrlProvider());

    final isTransfer = useState(transfer);

    final selectedFile = useState<PFile?>(null);

    return BaseBody(
      title: 'Customer due adjustment',
      alignment: Alignment.topLeft,
      scrollable: !context.layout.isDesktop,
      body: LimitedWidthBox(
        center: false,
        maxWidth: Layouts.maxContentWidth,
        child: Flex(
          direction: context.layout.isDesktop ? Axis.horizontal : Axis.vertical,
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: Insets.med,
          children: [
            ShadCard(
              title: const Text('Adjustment Details'),
              childPadding: Pads.med('t'),
              height: context.layout.isDesktop ? double.maxFinite : null,
              child: FormBuilder(
                key: formKey,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      //! user
                      VisibilityField<AppUser>(name: 'transaction_by', data: user, valueTransformer: (v) => v?.toMap()),
                      LimitedWidthBox(
                        maxWidth: 450,
                        center: false,
                        child: partiList.when(
                          loading: () => const Loading(),
                          error: (e, s) => ErrorView(e, s, prov: partiesCtrlProvider),
                          data: (parties) {
                            return ShadSelectField<Party>(
                              initialValue: extra,
                              hintText: 'Select Customer',
                              optionBuilder: (_, v, i) => ShadOption(value: v, child: PartyNameBuilder(v)),
                              options: parties,
                              selectedBuilder: (context, value) => Text(value.name),
                              onChanged: (v) {
                                selectedParty.set(v);
                              },
                              valueTransformer: (v) => v?.toMap(),
                            );
                          },
                        ),
                      ),

                      const Gap(Insets.med),
                      if (selectedParty.value != null)
                        Row(
                          spacing: Insets.med,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ShadCard(
                              expanded: false,
                              height: 100,
                              width: 100,
                              padding: Pads.zero,
                              child: FittedBox(
                                child: HostedImage.square(selectedParty.value!.getPhoto, dimension: 100),
                              ),
                            ),
                            Flexible(
                              child: Padding(
                                padding: Pads.sm('t'),
                                child: Column(
                                  spacing: Insets.sm,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SpacedText(
                                      left: 'Name',
                                      right: selectedParty.value?.name ?? '--',
                                      styleBuilder: (l, r) => (l, r),
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                    ),
                                    SpacedText(
                                      left: 'Phone',
                                      right: selectedParty.value?.phone ?? '--',
                                      styleBuilder: (l, r) => (l, r),
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                    ),
                                    if (selectedParty.value?.email != null)
                                      SpacedText(
                                        left: 'Email',
                                        right: selectedParty.value?.email ?? '--',
                                        styleBuilder: (l, r) => (l, r),
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                      ),
                                    if (selectedParty.value?.address != null)
                                      SpacedText(
                                        left: 'Address',
                                        right: selectedParty.value?.address ?? '--',
                                        styleBuilder: (l, r) => (l, r),
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                      ),

                                    if (selectedParty.value!.hasBalance())
                                      Text.rich(
                                        TextSpan(
                                          text: 'Payable to "${selectedParty.value!.name}" : ',
                                          children: [
                                            TextSpan(
                                              text: selectedParty.value!.due.abs().currency(),
                                              style: const TextStyle(color: Colors.red),
                                            ),
                                          ],
                                        ),
                                        style: context.text.list,
                                      ),
                                    if (selectedParty.value!.hasDue())
                                      Text.rich(
                                        TextSpan(
                                          text: 'Receivable from "${selectedParty.value!.name}" :  ',
                                          children: [
                                            TextSpan(
                                              text: selectedParty.value!.due.abs().currency(),
                                              style: const TextStyle(color: Colors.green),
                                            ),
                                          ],
                                        ),
                                        style: context.text.list,
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),

                      const Gap(Insets.med),
                      Row(
                        children: [
                          Expanded(
                            child: ShadTextField(
                              name: 'amount',
                              hintText: 'Amount',
                              label: 'Amount',
                              numeric: true,
                              isRequired: true,
                            ),
                          ),
                          Expanded(
                            child: accountList.maybeWhen(
                              orElse: () => ShadCard(padding: kDefInputPadding, child: const Loading()),
                              data: (accounts) {
                                return ShadSelectField<PaymentAccount>(
                                  name: 'payment_account',
                                  hintText: 'select an account',
                                  label: 'Payment account',
                                  isRequired: !isTransfer.value,
                                  initialValue: config.defaultAccount,
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
                        ],
                      ),

                      const Gap(Insets.med),
                      ShadTextAreaField(name: 'note', label: 'Note'),

                      const Gap(Insets.med),
                      FilePickerField(selectedFile: selectedFile.value, onSelect: selectedFile.set, compact: true),

                      //! transfer balance
                      if (selectedParty.value?.hasBalance() == true) ...[
                        const Gap(Insets.med),
                        ShadCheckbox(
                          value: isTransfer.value,
                          onChanged: (v) => isTransfer.value = v,
                          label: const Text('Transfer balance'),
                        ),
                        if (isTransfer.value) ...[
                          const Gap(Insets.med),
                          ShadCard(
                            padding: Pads.med(),
                            child: CustomInfoFiled(
                              fixedInitialField: const {'Name': '', 'Phone': ''},
                              header: (context, add) {
                                return Row(
                                  spacing: Insets.med,
                                  children: [
                                    Text('Add custom field', style: context.text.p),
                                    SmallButton(
                                      icon: LuIcons.plus,
                                      variant: ShadButtonVariant.primary,
                                      onPressed: add,
                                      size: 25,
                                    ),
                                  ],
                                );
                              },
                            ),
                          ),
                        ],
                      ],

                      const Gap(Insets.xl),

                      if (selectedParty.value?.hasDue() == true)
                        SubmitButton(
                          onPressed: (l) async {
                            final state = formKey.currentState!;
                            if (!state.saveAndValidate()) return;
                            final data = QMap.from(state.transformedValues);
                            data.addAll({
                              'date': DateTime.now().toIso8601String(),
                              'transaction_type': TransactionType.dueAdjustment.name,
                              'transaction_from': selectedParty.value?.toMap(),
                              'transacted_to_shop': true,
                            });
                            if (!isTransfer.value) data.remove('custom_info');

                            final log = TransactionLog.fromMap(data);
                            final err = log.validate();
                            if (err != null) {
                              return Toast.showErr(context, err);
                            }

                            final ok = await showShadDialog<bool>(
                              context: context,
                              builder: (context) => _DuePayDialog(log, selectedFile.value),
                            );
                            if (ok == true) {
                              selectedParty.value = null;
                              selectedFile.value = null;
                              state.reset();
                            }
                          },
                          child: const Text('Due payment'),
                        ),
                      if (selectedParty.value?.hasBalance() == true)
                        SubmitButton(
                          onPressed: (l) async {
                            final state = formKey.currentState!;
                            if (!state.saveAndValidate()) return;
                            final data = QMap.from(state.transformedValues);

                            final transfer = isTransfer.value;

                            data.addAll({
                              'date': DateTime.now().toIso8601String(),
                              'transaction_type': (transfer ? TransactionType.transfer : TransactionType.payment).name,
                              if (transfer) 'transaction_from': selectedParty.value?.toMap(),
                              if (!transfer) 'transaction_to': selectedParty.value?.toMap(),
                            });
                            if (!transfer) data.remove('custom_info');

                            final log = TransactionLog.fromMap(data);

                            final err = log.validate();
                            if (err != null) {
                              return Toast.showErr(context, err);
                            }

                            bool? ok;
                            if (transfer) {
                              ok = await showShadDialog<bool>(
                                context: context,
                                builder: (context) => _TransferDialog(log, selectedFile.value),
                              );
                            } else {
                              ok = await showShadDialog<bool>(
                                context: context,
                                builder: (context) => _DueClearDialog(log, selectedFile.value),
                              );
                            }
                            if (ok == true) {
                              selectedFile.value = null;
                              selectedParty.value = null;
                              state.reset();
                            }
                          },
                          child: Text(isTransfer.value ? 'Transfer balance' : 'Clear due'),
                        ),
                    ],
                  ),
                ),
              ),
            ).conditionalExpanded(context.layout.isDesktop, 2),

            if (selectedParty.value != null)
              RelatedRecords(
                scroll: context.layout.isDesktop,
                party: selectedParty.value!,
                unpaid: selectedParty.value?.hasDue() == true,
              ).conditionalExpanded(context.layout.isDesktop),
          ],
        ),
      ),
    );
  }
}

class _DueClearDialog extends ConsumerWidget {
  const _DueClearDialog(this.log, this.file);

  final TransactionLog log;
  final PFile? file;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ShadDialog(
      title: const Text('Clear customer due'),
      description: const Text('Confirm customer due clearance'),
      actions: [
        ShadButton.destructive(
          onPressed: () => context.nPop(),
          child: const SelectionContainer.disabled(child: Text('Cancel')),
        ),
        SubmitButton(
          onPressed: (l) async {
            final ctrl = ref.read(transactionLogCtrlProvider.notifier);

            l.truthy();
            final result = await ctrl.adjustCustomerDue(log.toMap(), true, file);
            l.falsey();

            if (result case final Result r) {
              if (!context.mounted) return;
              r.showToast(context);
              if (r.success) context.pop(true);
            }
          },
          child: const Text('Confirm'),
        ),
      ],
      child: Text.rich(
        TextSpan(
          children: [
            TextSpan(text: 'You are about to pay ', style: context.text.muted),
            TextSpan(text: log.amount.currency(), style: context.text.p.bold),
            TextSpan(text: ' to ', style: context.text.muted),
            TextSpan(text: log.transactedTo?.name, style: context.text.p.bold),
            TextSpan(text: ' from ', style: context.text.muted),
            TextSpan(text: log.account?.name, style: context.text.p.bold),
            const TextSpan(text: '.\n'),
            TextSpan(text: 'Current balance of ', style: context.text.muted),
            TextSpan(text: '${log.account?.name} : ', style: context.text.p.bold),
            TextSpan(text: log.account?.amount.currency(), style: context.text.p.bold),
            const TextSpan(text: '.\n'),
            TextSpan(text: 'Updated balance : ', style: context.text.muted),
            TextSpan(text: (log.account!.amount - log.amount).currency(), style: context.text.p.bold),
          ],
        ),
      ),
    );
  }
}

class _DuePayDialog extends ConsumerWidget {
  const _DuePayDialog(this.log, this.file);

  final TransactionLog log;
  final PFile? file;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ShadDialog(
      title: const Text('Customer due payment'),
      description: const Text('Confirm due payment from customer'),
      actions: [
        ShadButton.destructive(
          onPressed: () => context.nPop(),
          child: const SelectionContainer.disabled(child: Text('Cancel')),
        ),
        SubmitButton(
          onPressed: (l) async {
            final ctrl = ref.read(transactionLogCtrlProvider.notifier);

            l.truthy();
            final result = await ctrl.adjustCustomerDue(log.toMap(), false, file);
            l.falsey();

            if (result case final Result r) {
              if (!context.mounted) return;
              r.showToast(context);
              if (r.success) context.pop(true);
            }
          },
          child: const Text('Confirm'),
        ),
      ],
      child: Text.rich(
        TextSpan(
          children: [
            TextSpan(text: log.transactionForm?.name, style: context.text.p.bold),
            TextSpan(text: ' is about to pay you ', style: context.text.muted),
            TextSpan(text: log.amount.currency(), style: context.text.p.bold),
            TextSpan(text: ' for due clearance', style: context.text.muted),

            const TextSpan(text: '.\n'),
            TextSpan(text: 'Current balance of ', style: context.text.muted),
            TextSpan(text: '${log.account?.name} : ', style: context.text.p.bold),
            TextSpan(text: log.account?.amount.currency(), style: context.text.p.bold),
            const TextSpan(text: '.\n'),
            TextSpan(text: 'Updated balance : ', style: context.text.muted),
            TextSpan(text: (log.account!.amount + log.amount).currency(), style: context.text.p.bold),
          ],
        ),
      ),
    );
  }
}

class _TransferDialog extends ConsumerWidget {
  const _TransferDialog(this.log, this.file);

  final TransactionLog log;
  final PFile? file;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ShadDialog(
      title: const Text('Transfer balance'),
      description: const Text('Confirm balance transfer from customer'),
      actions: [
        ShadButton.destructive(
          onPressed: () => context.nPop(),
          child: const SelectionContainer.disabled(child: Text('Cancel')),
        ),
        SubmitButton(
          onPressed: (l) async {
            final ctrl = ref.read(transactionLogCtrlProvider.notifier);

            l.truthy();
            final result = await ctrl.transferBalance(log.toMap(), file);
            l.falsey();

            if (result case final Result r) {
              if (!context.mounted) return;
              r.showToast(context);
              if (r.success) context.pop(true);
            }
          },
          child: const Text('Confirm'),
        ),
      ],
      child: Text.rich(
        TextSpan(
          children: [
            TextSpan(text: log.transactionForm?.name, style: context.text.p.bold),
            TextSpan(text: ' is about to transfer  ', style: context.text.muted),
            TextSpan(text: log.amount.currency(), style: context.text.p.bold),
            TextSpan(text: ' to:\n', style: context.text.muted),
            for (final i in log.customInfo.entries) ...[
              TextSpan(text: '${i.key} : ', style: context.text.muted),
              TextSpan(text: '${i.value}\n', style: context.text.p),
            ],

            if (log.account == null) ...[
              WidgetSpan(
                child: Icon(LuIcons.info, size: 15, color: context.colors.destructive),
                alignment: PlaceholderAlignment.middle,
              ),
              TextSpan(
                text: '  No transaction between account will be created because no account was selected.',
                style: context.text.small.error(context).textHeight(2),
              ),
            ] else ...[
              TextSpan(text: 'Current balance of ', style: context.text.muted),
              TextSpan(text: '${log.account?.name} : ', style: context.text.p.bold),
              TextSpan(text: log.account?.amount.currency(), style: context.text.p.bold),
              const TextSpan(text: '.\n'),
              TextSpan(text: 'Updated balance : ', style: context.text.muted),
              TextSpan(text: (log.account!.amount - log.amount).currency(), style: context.text.p.bold),
            ],
          ],
        ),
      ),
    );
  }
}
