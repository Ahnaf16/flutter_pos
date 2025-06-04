import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:pos/features/payment_accounts/controller/payment_accounts_ctrl.dart';
import 'package:pos/features/settings/controller/settings_ctrl.dart';
import 'package:pos/main.export.dart';

class GeneralSettingsView extends HookConsumerWidget {
  const GeneralSettingsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watch(configCtrlProvider);

    final formKey = useMemoized(GlobalKey<FormBuilderState>.new);

    final accountList = ref.watch(paymentAccountsCtrlProvider());

    return ShadCard(
      border: const Border(),
      shadows: const [],
      padding: Pads.med(),
      childPadding: Pads.med('t'),
      title: const Text('General'),
      description: const Text('General settings for the application'),
      child: SingleChildScrollView(
        child: LimitedWidthBox(
          center: false,
          maxWidth: 700,
          child: FormBuilder(
            key: formKey,
            initialValue: config.toMap(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: Insets.med,
              children: [
                const Gap(Insets.sm),

                Row(
                  children: [
                    Expanded(
                      child: ShadTextField(
                        name: 'currency_symbol',
                        label: 'Currency symbol',
                        hintText: 'Enter currency symbol',
                      ),
                    ),
                    Expanded(
                      child: FormBuilderField<bool>(
                        name: 'currency_symbol_on_left',
                        builder: (form) {
                          return ShadInputDecorator(
                            label: const Text('Show currency on left side'),
                            child: ShadSelect<bool>(
                              initialValue: form.value,
                              minWidth: 250,
                              maxWidth: 300,
                              maxHeight: 80,
                              placeholder: const Text('Select'),
                              selectedOptionBuilder: (context, value) => Text(value.toString()),
                              onChanged: (value) => form.didChange(value),
                              itemCount: 2,
                              optionsBuilder: (_, i) =>
                                  ShadOption(value: i == 0, child: Text(i == 0 ? 'True' : 'False')),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),

                Row(
                  children: [
                    Expanded(
                      child: ShadTextField(
                        name: 'invoice_prefix',
                        label: 'Invoice prefix',
                        hintText: 'Enter invoice prefix',
                      ),
                    ),
                    Expanded(
                      child: ShadTextField(
                        name: 'sku_prefix',
                        label: 'SKU prefix',
                        hintText: 'Enter SKU prefix',
                      ),
                    ),
                  ],
                ),

                accountList.maybeWhen(
                  orElse: () => ShadCard(padding: kDefInputPadding, child: const Loading()),
                  data: (accounts) {
                    return ShadSelectField<PaymentAccount>(
                      name: 'default_account',
                      hintText: 'Set a default payment account',
                      label: 'Default payment account',
                      initialValue: config.defaultAccount,
                      options: accounts,
                      valueTransformer: (value) => value?.toMap(),
                      optionBuilder: (_, v, i) {
                        return ShadOption(value: v, child: Text(v.name));
                      },
                      selectedBuilder: (_, v) => Text(v.name),
                    );
                  },
                ),
                FormBuilderField<String>(
                  name: 'stock_distribution_policy',
                  builder: (form) {
                    return ShadInputDecorator(
                      label: const Text('Stock distribution policy'),
                      child: ShadSelect<StockDistPolicy>(
                        minWidth: 250,
                        maxWidth: 300,
                        maxHeight: 80,
                        initialValue: StockDistPolicy.values.tryByName(form.value),
                        placeholder: const Text('Select'),
                        selectedOptionBuilder: (context, value) => Text(value.name.titleCase),
                        itemCount: StockDistPolicy.values.length,
                        onChanged: (value) => form.didChange(value?.name),
                        optionsBuilder: (_, i) => ShadOption<StockDistPolicy>(
                          value: StockDistPolicy.values[i],
                          child: Text(StockDistPolicy.values[i].name.titleCase),
                        ),
                      ),
                    );
                  },
                ),

                const Gap(Insets.med),
                SubmitButton(
                  child: const Text('Update Settings'),
                  onPressed: (l) async {
                    final state = formKey.currentState!;
                    if (!state.saveAndValidate()) return;
                    final data = state.value;

                    l.truthy();
                    final ctrl = ref.read(configCtrlProvider.notifier);
                    final result = await ctrl.updateConfig(data);
                    l.falsey();

                    if (result case final Result r) {
                      if (!context.mounted) return;
                      r.showToast(context);
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
