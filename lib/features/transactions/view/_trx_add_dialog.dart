part of 'transactions_view.dart';

// ignore: unused_element
class _TransferDialog extends HookConsumerWidget {
  const _TransferDialog();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formKey = useMemoized(GlobalKey<FormBuilderState>.new);

    final fromMe = useState(true);
    final toParti = useState(true);
    final config = ref.watch(configCtrlProvider);

    final accountList = ref.watch(paymentAccountsCtrlProvider());
    final partiList = ref.watch(partiesCtrlProvider(null));
    final user = ref.watch(authStateSyncProvider).toNullable();
    return ShadDialog(
      title: const Text('Transfer money'),
      description: const Text('Select parties to transfer money'),
      actions: [
        ShadButton.destructive(onPressed: () => context.nPop(), child: const Text('Cancel')),

        SubmitButton(
          onPressed: (l) async {
            final state = formKey.currentState!;
            if (!state.saveAndValidate()) return;
            final data = QMap.from(state.transformedValues);

            final ctrl = ref.read(transactionLogCtrlProvider(TransactionType.transfer).notifier);

            l.truthy();
            final result = await ctrl.createManual(data, fromMe.value);
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
        child: FormBuilder(
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
              //! from - to
              partiList.maybeWhen(
                orElse: () => ShadCard(padding: kDefInputPadding, child: const Loading()),
                data: (parties) {
                  return ShadCard(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      spacing: Insets.med,
                      children: [
                        if (user != null)
                          ShadTabs<bool>(
                            value: fromMe.value,
                            onChanged: (v) {
                              fromMe.value = v;
                              formKey.currentState?.fields['transaction_for']?.reset();
                            },
                            tabs: [
                              ShadTab(value: true, content: UserCard.user(user: user), child: const Text('From me')),
                              ShadTab(
                                value: false,
                                content: _TransactionForParti(parties: parties),
                                child: const Text('From parti'),
                              ),
                            ],
                          )
                        else
                          _TransactionForParti(parties: parties),

                        Row(
                          children: [
                            Flexible(child: ShadSeparator.horizontal(margin: Pads.lg('tb'))),
                            Padding(padding: Pads.lg('lr'), child: const Text('TO')),
                            Flexible(child: ShadSeparator.horizontal(margin: Pads.lg('tb'))),
                          ],
                        ),

                        ShadTabs<bool>(
                          value: toParti.value,
                          onChanged: (v) {
                            toParti.value = v;
                            formKey.currentState?.fields['transaction_for']?.reset();
                          },
                          tabs: [
                            ShadTab(
                              value: true,
                              content: ShadSelectField<Parti>(
                                name: 'parties',
                                hintText: 'To whom?',
                                label: 'Transfer to',
                                options: parties,
                                allowDeselection: true,
                                valueTransformer: (value) => value?.toMap(),
                                optionBuilder: (_, v, i) {
                                  return ShadOption(
                                    value: v,
                                    child: Text.rich(
                                      TextSpan(
                                        children: [
                                          TextSpan(text: v.name),
                                          TextSpan(text: ' (${v.type.name})', style: context.text.muted.size(12)),
                                          // TextSpan(
                                          //   text: ' ${v.hasDue() ? 'Due: ' : 'Balance: '}${v.due.abs().currency()}',
                                          //   style: context.text.muted.textColor(v.dueColor),
                                          // ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                                selectedBuilder: (context, v) {
                                  return Text.rich(
                                    TextSpan(
                                      children: [
                                        TextSpan(text: v.name),
                                        TextSpan(text: ' (${v.type.name})', style: context.text.muted.size(12)),
                                        // TextSpan(
                                        //   text: ' ${v.hasDue() ? 'Due: ' : 'Balance: '}${v.due.abs().currency()}',
                                        //   style: context.text.muted.textColor(v.dueColor),
                                        // ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                              child: const Text('Parti'),
                            ),
                            ShadTab(
                              value: false,
                              content: Row(
                                children: [
                                  Flexible(
                                    child: ShadTextField(name: 'transact_to', label: 'Name', hintText: 'Enter name'),
                                  ),
                                  Flexible(
                                    child: ShadTextField(
                                      name: 'transact_to_phone',
                                      label: 'Phone',
                                      hintText: 'Enter phone',
                                    ),
                                  ),
                                ],
                              ),
                              child: const Text('Custom'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
              const Gap(Insets.med),
              ShadCard(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        //! Amount
                        Flexible(
                          child: ShadTextField(name: 'amount', hintText: 'Amount', label: 'Amount', numeric: true),
                        ),
                        //! Account
                        Flexible(
                          child: accountList.maybeWhen(
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
                                  return ShadOption(
                                    value: v,
                                    child: Text.rich(
                                      TextSpan(
                                        children: [
                                          TextSpan(text: v.name),
                                          TextSpan(
                                            text: ' (${v.amount.currency()})',
                                            style: context.text.muted.textColor(
                                              v.amount <= 0 ? context.colors.destructive : null,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                                selectedBuilder: (_, v) {
                                  return Text.rich(
                                    TextSpan(
                                      children: [
                                        TextSpan(text: v.name),
                                        TextSpan(
                                          text: ' (${v.amount.currency()})',
                                          style: context.text.muted.textColor(
                                            v.amount <= 0 ? context.colors.destructive : null,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Gap(Insets.med),
              ShadTextAreaField(name: 'note', label: 'Note'),
            ],
          ),
        ),
      ),
    );
  }
}

class _TransactionForParti extends StatelessWidget {
  const _TransactionForParti({required this.parties});

  final List<Parti> parties;

  @override
  Widget build(BuildContext context) {
    return ShadSelectField<Parti>(
      name: 'transaction_for',
      hintText: 'Select a parti',
      label: 'Transfer form',
      options: parties,
      allowDeselection: true,
      valueTransformer: (value) => value?.toMap(),
      optionBuilder: (_, v, i) {
        return ShadOption(
          value: v,
          child: Text.rich(
            TextSpan(
              children: [
                TextSpan(text: v.name),
                TextSpan(text: ' (${v.type.name})', style: context.text.muted.size(12)),
                // TextSpan(
                //   text: ' ${v.hasDue() ? 'Due: ' : 'Balance: '}${v.due.abs().currency()}',
                //   style: context.text.muted.textColor(v.dueColor),
                // ),
              ],
            ),
          ),
        );
      },
      selectedBuilder: (context, v) {
        return Text.rich(
          TextSpan(
            children: [
              TextSpan(text: v.name),
              TextSpan(text: ' (${v.type.name})', style: context.text.muted.size(12)),
              // TextSpan(
              //   text: ' ${v.hasDue() ? 'Due: ' : 'Balance: '}${v.due.abs().currency()}',
              //   style: context.text.muted.textColor(v.dueColor),
              // ),
            ],
          ),
        );
      },
    );
  }
}
