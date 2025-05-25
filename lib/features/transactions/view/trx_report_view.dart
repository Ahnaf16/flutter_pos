import 'package:pos/features/transactions/controller/transactions_ctrl.dart';
import 'package:pos/main.export.dart';

class TrxReportView extends HookConsumerWidget {
  const TrxReportView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final range = useState<ShadDateTimeRange?>(null);

    return ShadDialog(
      title: const Text('Report'),
      actions: [
        ShadButton.destructive(onPressed: () => context.nPop(), child: const Text('Cancel')),
        ShadButton(
          onPressed: () async {
            final trx = await ref.read(trxFilteredProvider([]).future);

            cat(trx.length);
          },
          child: const Text('Download'),
        ),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ShadDatePicker.range(
            onRangeChanged: range.set,
            selected: range.value,
          ),
        ],
      ),
    );
  }
}
