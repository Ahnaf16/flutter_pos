import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:pos/features/auth/controller/auth_ctrl.dart';
import 'package:pos/features/auth/view/user_card.dart';
import 'package:pos/features/parties/controller/parties_ctrl.dart';
import 'package:pos/features/parties/view/party_name_builder.dart';
import 'package:pos/features/payment_accounts/controller/payment_accounts_ctrl.dart';
import 'package:pos/features/payment_accounts/view/local/account_name_builder.dart';
import 'package:pos/features/settings/controller/settings_ctrl.dart';
import 'package:pos/features/transactions/controller/transactions_ctrl.dart';
import 'package:pos/main.export.dart';

class PartyDueDialog extends HookConsumerWidget {
  const PartyDueDialog({super.key, required this.parti, required this.type});

  final Party parti;
  final PartiType type;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formKey = useMemoized(GlobalKey<FormBuilderState>.new);
    final isCustomer = type == PartiType.customer;

    final selectedParty = useState(parti);
    final config = ref.watch(configCtrlProvider);
    final user = ref.watch(authStateSyncProvider).toNullable();

    final partiList = ref.watch(partiesCtrlProvider(isCustomer));
    final accountList = ref.watch(paymentAccountsCtrlProvider());

    return ShadDialog(
      title: Text('${parti.type.name.titleCase} Due adjustment'),

      actions: [
        ShadButton.destructive(onPressed: () => context.nPop(), child: const Text('Cancel')),
        SubmitButton(
          enabled: parti.hasDue() == true,
          onPressed: (l) async {
            final state = formKey.currentState!;
            if (!state.saveAndValidate()) return;
            final data = QMap.from(state.transformedValues);

            final ctrl = ref.read(transactionLogCtrlProvider.notifier);

            l.truthy();
            final result = await ctrl.adjustCustomerDue(data);
            l.falsey();

            if (result case final Result r) {
              if (!context.mounted) return;
              r.showToast(context);
              if (r.success) context.pop(true);
            }
          },
          child: const Text('Submit'),
        ),
      ],
      child: Container(
        padding: Pads.padding(v: Insets.med),
        child: partiList.when(
          loading: () => const Loading(),
          error: (e, s) => ErrorView(e, s, prov: partiesCtrlProvider),
          data: (parties) {
            final party = selectedParty.value;
            return FormBuilder(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  //! type
                  VisibilityField<TransactionType>(
                    name: 'transaction_type',
                    data: TransactionType.dueAdjustment,
                    valueTransformer: (v) => v?.name,
                  ),

                  //! user
                  VisibilityField<AppUser>(name: 'transaction_by', data: user, valueTransformer: (v) => v?.toMap()),
                  VisibilityField<Party>(name: 'transaction_from', data: parti, valueTransformer: (v) => v?.toMap()),

                  const Gap(Insets.med),
                  UserCard.parti(parti: party, imgSize: 80, showDue: true),

                  if (party.hasDue() == true) ...[
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
                  ],
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class SupplierDueDialog extends HookConsumerWidget {
  const SupplierDueDialog({super.key, this.parti, required this.type});

  final Party? parti;
  final PartiType type;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formKey = useMemoized(GlobalKey<FormBuilderState>.new);
    final isCustomer = type == PartiType.customer;

    final selectedParty = useState(parti);
    final config = ref.watch(configCtrlProvider);
    final user = ref.watch(authStateSyncProvider).toNullable();

    final partiList = ref.watch(partiesCtrlProvider(isCustomer));
    final accountList = ref.watch(paymentAccountsCtrlProvider());

    return ShadDialog(
      title: Text('${parti?.type.name.titleCase ?? ''} Due payment'),

      actions: [
        ShadButton.destructive(onPressed: () => context.nPop(), child: const Text('Cancel')),
        SubmitButton(
          enabled: parti != null && parti?.hasBalance() == true,
          onPressed: (l) async {
            final state = formKey.currentState!;
            if (!state.saveAndValidate()) return;
            final data = QMap.from(state.transformedValues);

            final ctrl = ref.read(transactionLogCtrlProvider.notifier);

            l.truthy();
            final result = await ctrl.supplierDuePayment(data);
            l.falsey();

            if (result case final Result r) {
              if (!context.mounted) return;
              r.showToast(context);
              if (r.success) context.pop(true);
            }
          },
          child: const Text('Submit'),
        ),
      ],
      child: Container(
        padding: Pads.padding(v: Insets.med),
        child: partiList.when(
          loading: () => const Loading(),
          error: (e, s) => ErrorView(e, s, prov: partiesCtrlProvider),
          data: (parties) {
            final party = selectedParty.value;
            return FormBuilder(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  //! type
                  VisibilityField<TransactionType>(
                    name: 'transaction_type',
                    data: TransactionType.payment,
                    valueTransformer: (v) => v?.name,
                  ),

                  //! user
                  VisibilityField<AppUser>(name: 'transaction_by', data: user, valueTransformer: (v) => v?.toMap()),
                  VisibilityField<Party>(name: 'transaction_to', data: parti, valueTransformer: (v) => v?.toMap()),

                  const Gap(Insets.med),
                  UserCard.parti(parti: party, imgSize: 80, showDue: true),

                  if (party?.hasBalance() == true) ...[
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
                  ],
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class BalanceTransferDialog extends HookConsumerWidget {
  const BalanceTransferDialog({super.key, this.parti, required this.type});

  final Party? parti;
  final PartiType type;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formKey = useMemoized(GlobalKey<FormBuilderState>.new);

    final selectedParty = useState(parti);
    // final useCustom = useState(false);
    final user = ref.watch(authStateSyncProvider).toNullable();

    final partiList = ref.watch(partiesCtrlProvider(null));

    return ShadDialog(
      title: const Text('Balance Transfer'),

      actions: [
        ShadButton.destructive(onPressed: () => context.nPop(), child: const Text('Cancel')),
        SubmitButton(
          enabled: parti != null && parti?.hasBalance() == true,
          onPressed: (l) async {
            final state = formKey.currentState!;
            if (!state.saveAndValidate()) return;
            final data = QMap.from(state.transformedValues);

            cat(data);

            final ctrl = ref.read(transactionLogCtrlProvider.notifier);

            l.truthy();
            final result = await ctrl.transferBalance(data);
            l.falsey();

            if (result case final Result r) {
              if (!context.mounted) return;
              r.showToast(context);
              if (r.success) context.pop(true);
            }
          },
          child: const Text('Submit'),
        ),
      ],
      child: Container(
        padding: Pads.padding(v: Insets.med),
        child: partiList.when(
          loading: () => const Loading(),
          error: (e, s) => ErrorView(e, s, prov: partiesCtrlProvider),
          data: (parties) {
            final party = selectedParty.value;
            return FormBuilder(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  //! type
                  VisibilityField<TransactionType>(
                    name: 'transaction_type',
                    data: TransactionType.transfer,
                    valueTransformer: (v) => v?.name,
                  ),

                  //! user
                  VisibilityField<AppUser>(name: 'transaction_by', data: user, valueTransformer: (v) => v?.toMap()),

                  Visibility(
                    maintainState: true,
                    maintainAnimation: true,
                    visible: parti == null,
                    child: ShadSelectField<Party>(
                      name: 'transaction_from',
                      hintText: 'Select customer',
                      initialValue: parti,
                      enabled: parti == null,
                      options: parties.where((e) => e.isCustomer && e.hasBalance()).toList(),
                      valueTransformer: (value) => value?.toMap(),
                      optionBuilder: (_, v, i) {
                        return ShadOption(value: v, child: PartyNameBuilder(v));
                      },
                      selectedBuilder: (context, v) {
                        return PartyNameBuilder(v);
                      },
                      onChanged: selectedParty.set,
                    ),
                  ),
                  const Gap(Insets.med),
                  UserCard.parti(parti: party, imgSize: 80, showDue: true),

                  if (party?.hasBalance() == true) ...[
                    const Gap(Insets.med),

                    Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: ShadTextField(
                            name: 'amount',
                            hintText: 'Amount',
                            label: 'Amount',
                            numeric: true,
                            isRequired: true,
                          ),
                        ),
                        // Expanded(
                        //   child: ShadSelectField<AccountType>(
                        //     name: 'pay_method',
                        //     label: 'Payment method',
                        //     hintText: 'Select',
                        //     valueTransformer: (value) => value?.name,
                        //     options: AccountType.values,
                        //     optionBuilder: (_, v, i) => ShadOption(value: v, child: Text(v.name.titleCase)),
                        //     selectedBuilder: (_, v) => Text(v.name.titleCase),
                        //   ),
                        // ),
                      ],
                    ),

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

                    const Gap(Insets.med),
                    ShadTextAreaField(name: 'note', label: 'Note'),
                  ],
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
