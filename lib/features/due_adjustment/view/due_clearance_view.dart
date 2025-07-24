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

class DueClearanceView extends HookConsumerWidget {
  const DueClearanceView({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final extra = context.tryGetExtra<Party>();
    final formKey = useMemoized(GlobalKey<FormBuilderState>.new);

    final selectedParty = useState<Party?>(extra);

    final config = ref.watch(configCtrlProvider);
    final user = ref.watch(authStateSyncProvider).toNullable();

    final partiList = ref.watch(partiesCtrlProvider(false));
    final accountList = ref.watch(paymentAccountsCtrlProvider());

    final selectedFile = useState<PFile?>(null);

    return BaseBody(
      title: 'Supplier due clearance',
      alignment: Alignment.topLeft,
      scrollable: !context.layout.isDesktop,
      body: LimitedWidthBox(
        maxWidth: Layouts.maxContentWidth,
        child: Flex(
          direction: context.layout.isDesktop ? Axis.horizontal : Axis.vertical,
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: Insets.med,
          children: [
            ShadCard(
              title: Padding(padding: Pads.med('tlr'), child: const Text('Clearance information')),
              height: context.layout.isDesktop ? double.maxFinite : null,
              padding: Pads.zero,
              child: FormBuilder(
                key: formKey,
                child: SingleChildScrollView(
                  padding: Pads.med(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      //! user
                      VisibilityField<AppUser>(name: 'transaction_by', data: user, valueTransformer: (v) => v?.toMap()),
                      LimitedWidthBox(
                        maxWidth: 500,
                        center: false,
                        child: partiList.when(
                          loading: () => const Loading(),
                          error: (e, s) => ErrorView(e, s, prov: partiesCtrlProvider),
                          data: (parties) {
                            return ShadSelectField<Party>(
                              initialValue: extra,
                              hintText: 'Select Supplier',
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
                      if (selectedParty.value != null) ...[
                        Row(
                          spacing: Insets.med,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ShadCard(
                              expanded: false,
                              height: 80,
                              width: 80,
                              padding: Pads.zero,
                              child: FittedBox(child: HostedImage.square(selectedParty.value!.getPhoto, dimension: 80)),
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
                                      styleBuilder: (l, r) => (l, r.bold),
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                    ),
                                    SpacedText(
                                      left: 'Phone',
                                      right: selectedParty.value?.phone ?? '--',
                                      styleBuilder: (l, r) => (l, r.bold),
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                    ),
                                    if (selectedParty.value?.email != null)
                                      SpacedText(
                                        left: 'Email',
                                        right: selectedParty.value?.email ?? '--',
                                        styleBuilder: (l, r) => (l, r.bold),
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                      ),
                                    if (selectedParty.value?.address != null)
                                      SpacedText(
                                        left: 'Address',
                                        right: selectedParty.value?.address ?? '--',
                                        styleBuilder: (l, r) => (l, r.bold),
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                      ),

                                    if (selectedParty.value!.hasBalance())
                                      Text.rich(
                                        TextSpan(
                                          text: 'Payable to ',
                                          children: [
                                            TextSpan(text: '"${selectedParty.value!.name}" : '),
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
                                          text: 'Receivable from "${selectedParty.value!.name}" ',
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
                      ],

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
                                  isRequired: true,
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

                      const Gap(Insets.xl),
                      if (selectedParty.value?.hasBalance() == true)
                        SubmitButton(
                          enabled: selectedParty.value?.hasBalance() == true,
                          onPressed: (l) async {
                            final state = formKey.currentState!;
                            if (!state.saveAndValidate()) return;
                            final data = QMap.from(state.transformedValues);
                            data.addAll({
                              'date': DateTime.now().toIso8601String(),
                              'transaction_type': TransactionType.payment.name,
                              'transaction_to': selectedParty.value?.toMap(),
                              'transacted_to_shop': false,
                            });
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
                              selectedFile.value = null;
                              selectedParty.value = null;
                              state.reset();
                            }
                          },
                          child: const Text('Make due payment'),
                        ),
                      if (selectedParty.value?.hasBalance() != true)
                        SubmitButton(
                          enabled: selectedParty.value?.hasDue() == true,
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
                            final log = TransactionLog.fromMap(data);

                            final err = log.validate();
                            if (err != null) {
                              return Toast.showErr(context, err);
                            }

                            final ok = await showShadDialog<bool>(
                              context: context,
                              builder: (context) => _DueClearDialog(log, selectedFile.value),
                            );
                            if (ok == true) {
                              selectedFile.value = null;
                              selectedParty.value = null;
                              state.reset();
                            }
                          },
                          child: const Text('Clear supplier Due'),
                        ),
                    ],
                  ),
                ),
              ),
            ).conditionalExpanded(context.layout.isDesktop, 2),

            // if (selectedParty.value != null)
            RelatedRecords(
              scroll: context.layout.isDesktop,
              party: selectedParty.value,
              unpaid: selectedParty.value?.hasBalance() == true,
            ).conditionalExpanded(context.layout.isDesktop),
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
      title: const Text('Make due payment'),
      description: const Text('Confirm payment to supplier'),
      actions: [
        ShadButton.destructive(
          onPressed: () => context.nPop(),
          child: const SelectionContainer.disabled(child: Text('Cancel')),
        ),
        SubmitButton(
          onPressed: (l) async {
            final ctrl = ref.read(transactionLogCtrlProvider.notifier);

            l.truthy();
            final result = await ctrl.supplierDuePayment(log.toMap(), true, file);
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
            TextSpan(text: 'You are about to make a payment of ', style: context.text.muted),
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

class _DueClearDialog extends ConsumerWidget {
  const _DueClearDialog(this.log, this.file);

  final TransactionLog log;
  final PFile? file;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ShadDialog(
      title: const Text('Clear due'),
      description: const Text('Clear supplier due'),
      actions: [
        ShadButton.destructive(
          onPressed: () => context.nPop(),
          child: const SelectionContainer.disabled(child: Text('Cancel')),
        ),
        SubmitButton(
          onPressed: (l) async {
            final ctrl = ref.read(transactionLogCtrlProvider.notifier);

            l.truthy();
            final result = await ctrl.supplierDuePayment(log.toMap(), false, file);
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
