part of 'transactions_view.dart';

// ignore: unused_element
class _TransferDialog extends HookConsumerWidget {
  const _TransferDialog();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formKey = useMemoized(GlobalKey<FormBuilderState>.new);

    final fromCustomer = useState<bool?>(null);
    final toCustom = useState<bool?>(null);
    final selected = useState<Party?>(null);
    final config = ref.watch(configCtrlProvider);

    final accountList = ref.watch(paymentAccountsCtrlProvider());
    final partiList = ref.watch(partiesCtrlProvider(null));
    final user = ref.watch(authStateSyncProvider).toNullable();

    return ShadDialog(
      title: const Text('Transfer money'),
      description: const Text('Transfer money to someone'),
      actions: [
        ShadButton.destructive(onPressed: () => context.nPop(), child: const Text('Cancel')),

        SubmitButton(
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
          child: const Text('Transfer'),
        ),
      ],
      child: Container(
        padding: Pads.padding(v: Insets.med),
        child: partiList.when(
          loading: () => const Loading(),
          error: (e, s) => ErrorView(e, s, prov: transactionLogCtrlProvider),
          data: (parties) {
            return FormBuilder(
              key: formKey,
              onChanged: () {
                final state = formKey.currentState!;
                if (state.instantValue.containsKey('transaction_from')) {
                  selected.value = Party.tryParse(state.instantValue['transaction_from']);
                }
              },
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

                  //! Amount
                  ShadTextField(name: 'amount', hintText: 'Amount', label: 'Amount', numeric: true),
                  const Gap(Insets.med),

                  //! from
                  _PeopleSelector(
                    name: 'transaction_from',
                    hintText: 'Select a customer/Supplier',
                    label: 'Transfer form',
                    parties: parties,
                    onSelect: (customer, _) {
                      fromCustomer.set(customer);
                      if (customer == true) {
                        formKey.currentState?.fields['transaction_to']?.reset();
                        formKey.currentState?.fields['custom_info']?.reset();
                      }
                      if (customer == false) {
                        formKey.currentState?.fields['transaction_to']?.reset();
                        formKey.currentState?.fields['payment_account']?.reset();
                      }
                    },
                  ),
                  const Gap(Insets.med),
                  //! to
                  if (fromCustomer.value == false) ...[
                    _PeopleSelector(
                      name: 'transaction_to',
                      hintText: 'Select a supplier',
                      label: 'Transfer to',
                      parties: parties.where((p) => !p.isCustomer && p.id != selected.value?.id).toList(),
                      isRequired: false,
                      allowCustom: true,
                      onSelect: (_, custom) {
                        toCustom.set(custom);
                        if (custom != true) {
                          formKey.currentState?.fields['custom_info']?.reset();
                        }
                      },
                    ),

                    if (toCustom.value == true) ...[
                      const Gap(Insets.med),
                      const CustomInfoFiled(title: 'Add custom info'),
                    ],
                  ],

                  //! Account
                  if (fromCustomer.value == true)
                    accountList.maybeWhen(
                      orElse: () => ShadCard(padding: kDefInputPadding, child: const Loading()),
                      data: (accounts) {
                        return ShadSelectField<PaymentAccount>(
                          name: 'payment_account',
                          hintText: 'Payment account',
                          label: 'Payment account',
                          initialValue: config.defaultAccount,
                          options: accounts,
                          isRequired: true,
                          valueTransformer: (value) => value?.toMap(),
                          optionBuilder: (_, v, i) {
                            return ShadOption(value: v, child: AccountNameBuilder(v));
                          },
                          selectedBuilder: (_, v) => AccountNameBuilder(v),
                        );
                      },
                    ),

                  const Gap(Insets.med),
                  ShadTextAreaField(name: 'note', label: 'Note'),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _PeopleSelector extends StatelessWidget {
  const _PeopleSelector({
    required this.parties,
    required this.name,
    required this.label,
    required this.hintText,
    this.onSelect,
    this.isRequired = true,
    this.allowCustom = false,
  });

  final String name;
  final String label;
  final String hintText;
  final List<Party> parties;
  final bool allowCustom;
  final bool isRequired;
  final Function(bool? isCustomer, bool? isCustom)? onSelect;

  @override
  Widget build(BuildContext context) {
    List<Party> list = parties;
    if (allowCustom) {
      list = [Party.fromCustom(), ...list];
    }

    return ShadSelectField<Party>(
      name: name,
      hintText: hintText,
      label: label,
      options: list,
      valueTransformer: (value) => value?.toMap(),
      optionBuilder: (_, v, i) {
        return ShadOption(value: v, child: PartyNameBuilder(v, showType: true));
      },
      selectedBuilder: (context, v) {
        return PartyNameBuilder(v, showType: true);
      },
      onChanged: (value) => onSelect?.call(value?.isCustomer, value?.isWalkIn),
    );
  }
}
