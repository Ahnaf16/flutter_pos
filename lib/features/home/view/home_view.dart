import 'package:fpdart/fpdart.dart';
import 'package:pos/features/payment_accounts/controller/payment_accounts_ctrl.dart';
import 'package:pos/main.export.dart';

class HomeView extends HookConsumerWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accounts = ref.watch(paymentAccountsCtrlProvider(false)).maybeWhen(data: identity, orElse: () => null);

    return BaseBody(
      scrollable: true,
      noAPPBar: true,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: Insets.lg,
        children: [
          if (accounts != null && accounts.isEmpty)
            const ShadAlert.destructive(
              title: Text('Setup payment account'),
              description: Text('No payment account has been added'),
              iconData: LuIcons.triangleAlert,
            ),
          const Row(
            spacing: Insets.lg,
            children: [
              ShadCard(expanded: false, height: 200, width: 300),
              ShadCard(expanded: false, height: 200, width: 300),
            ],
          ),
        ],
      ),
    );
  }
}
