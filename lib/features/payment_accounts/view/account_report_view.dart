import 'package:pos/features/transactions/controller/transactions_ctrl.dart';
import 'package:pos/main.export.dart';

class AccountReportView extends HookConsumerWidget {
  const AccountReportView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trxList = ref.watch(transactionLogCtrlProvider());
    final range = useState<ShadDateTimeRange?>(null);

    return trxList.when(
      loading: () => const Loading(),
      error: (e, s) => ErrorView(e, s, prov: transactionLogCtrlProvider),
      data: (accounts) {
        return ShadDialog(
          title: const Text('Account report'),
          actions: [
            ShadButton.destructive(onPressed: () => context.nPop(), child: const Text('Cancel')),
            ShadButton(onPressed: () {}, child: const Text('Download')),
          ],
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ShadDatePicker.range(onRangeChanged: range.set),
            ],
          ),
        );
      },
    );
  }
}
