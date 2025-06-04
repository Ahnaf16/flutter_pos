import 'package:pos/features/payment_accounts/controller/payment_accounts_ctrl.dart';
import 'package:pos/features/settings/controller/settings_ctrl.dart';
import 'package:pos/main.export.dart';

class PaymentAccountSelect extends HookConsumerWidget {
  const PaymentAccountSelect({
    super.key,
    required this.onAccountSelect,
    required this.type,
    this.isRequired = false,
    this.outsideTrailing,
  });

  final Function(PaymentAccount? acc) onAccountSelect;
  final RecordType type;
  final bool isRequired;
  final Widget? outsideTrailing;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accList = ref.watch(paymentAccountsCtrlProvider());
    final config = ref.watch(configCtrlProvider);

    useEffect(() {
      if (config.defaultAccount != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) => onAccountSelect(config.defaultAccount));
      }
      return null;
    }, const []);

    return accList.when(
      loading: () => Padding(
        padding: Pads.sm('lrt'),
        child: const ShadCard(width: 300, child: Loading()),
      ),
      error: (e, s) => ErrorView(e, s, prov: paymentAccountsCtrlProvider),
      data: (accounts) {
        return ShadSelectField<PaymentAccount>(
          label: 'Account',
          minWidth: 300,
          hintText: 'Select a payment account',
          initialValue: config.defaultAccount,
          isRequired: isRequired,
          optionBuilder: (context, acc, _) {
            return ShadOption<PaymentAccount>(
              value: acc,
              child: Row(
                children: [
                  Text(acc.name),
                  Text(
                    ' (${acc.amount.currency()})',
                    style: context.text.muted.textColor(acc.amount <= 0 ? context.colors.destructive : null),
                  ),
                ],
              ),
            );
          },
          options: accounts,
          selectedBuilder: (_, v) {
            return Row(
              children: [
                Text(v.name),
                Text(
                  ' (${v.amount.currency()})',
                  style: context.text.muted.textColor(v.amount <= 0 ? context.colors.destructive : null),
                ),
              ],
            );
          },
          onChanged: (v) => onAccountSelect(v),
          anchor: const ShadAnchorAuto(targetAnchor: Alignment.topCenter, followerAnchor: Alignment.topCenter),
          outsideTrailing: outsideTrailing,
        );
      },
    );
  }
}
