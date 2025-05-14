import 'package:pos/main.export.dart';

class AccountNameBuilder extends StatelessWidget {
  const AccountNameBuilder(this.account, {super.key});

  final PaymentAccount account;

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(
        children: [
          TextSpan(text: account.name),
          TextSpan(
            text: ' (${account.amount.currency()})',
            style: context.text.muted.textColor(account.amount <= 0 ? context.colors.destructive : null),
          ),
        ],
      ),
    );
  }
}
