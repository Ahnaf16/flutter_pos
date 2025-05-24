import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:pos/features/payment_accounts/controller/payment_accounts_ctrl.dart';
import 'package:pos/main.export.dart';

class AccountAddDialog extends HookConsumerWidget {
  const AccountAddDialog({super.key, this.acc});

  final PaymentAccount? acc;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formKey = useMemoized(GlobalKey<FormBuilderState>.new);
    final actionTxt = acc == null ? 'Add' : 'Update';

    final type = useState(acc?.type ?? AccountType.cash);

    return ShadDialog(
      title: Text('$actionTxt account'),
      description: Text(acc == null ? 'Fill the form to add a new account' : 'Update the form for ${acc!.name}'),
      actions: [
        ShadButton.destructive(onPressed: () => context.nPop(), child: const Text('Cancel')),
        SubmitButton(
          onPressed: (l) async {
            final state = formKey.currentState!;
            if (!state.saveAndValidate()) return;
            final data = state.transformedValues;

            final ctrl = ref.read(paymentAccountsCtrlProvider(false).notifier);
            (bool, String)? result;

            if (acc == null) {
              l.truthy();
              result = await ctrl.createAccount(data);
              l.falsey();
            } else {
              final updated = acc?.marge(data);
              if (updated == null) return;
              l.truthy();
              result = await ctrl.updateAccount(updated);
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
          initialValue: acc?.toMap() ?? {},
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: Insets.med,
            children: [
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: ShadTextField(name: 'name', label: 'Name', isRequired: true),
                  ),
                  Expanded(
                    child: ShadSelectField<AccountType>(
                      name: 'type',
                      label: 'Type',
                      hintText: 'Account Type',
                      isRequired: true,
                      initialValue: type.value,
                      valueTransformer: (value) => value?.name,
                      options: AccountType.values,
                      optionBuilder: (_, v, i) => ShadOption(value: v, child: Text(v.name.titleCase)),
                      selectedBuilder: (_, v) => Text(v.name.titleCase),
                      onChanged: (value) {
                        if (value == null) return;
                        type.value = value;
                        formKey.currentState?.fields['custom_info']?.reset();
                      },
                    ),
                  ),
                ],
              ),
              ShadTextField(name: 'description', label: 'description'),
              if (acc == null) ShadTextField(name: 'amount', label: 'initial amount'),
              if (type.value != AccountType.cash) CustomInfoFiled(initialInfo: acc?.customInfo),
            ],
          ),
        ),
      ),
    );
  }
}
