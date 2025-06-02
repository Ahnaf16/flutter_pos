// import 'package:pos/features/home/view/bar_widget.dart';
// import 'package:pos/features/home/view/pie_widget.dart';
// import 'package:pos/features/transactions/view/transactions_view.dart';
import 'package:pos/features/home/view/charts_widget.dart';
import 'package:pos/features/home/view/home_counter_widget.dart';
import 'package:pos/features/transactions/controller/transactions_ctrl.dart';
import 'package:pos/features/transactions/view/transactions_view.dart';
import 'package:pos/main.export.dart';

final _list = [
  'All time',
  'Today',
  'Yesterday',
  'This week',
  'This month',
  'This year',
];

class HomeView extends HookConsumerWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final start = useState<DateTime?>(null);
    final end = useState<DateTime?>(null);

    final trxList = ref
        .watch(transactionLogCtrlProvider)
        .maybeList()
        .filterByDateRange(start.value, end.value, (e) => e.date);

    return BaseBody(
      scrollable: true,
      noAPPBar: true,
      padding: Pads.med(),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: Insets.lg,
        children: [
          CenterRight(
            child: ShadSelect<int>(
              minWidth: 300,
              initialValue: 0,
              selectedOptionBuilder: (_, v) => Text(_list[v]),
              options: [
                for (int i = 0; i < _list.length; i++) ShadOption(value: i, child: Text(_list[i])),
              ],
              onChanged: (v) {
                final now = DateTime.now();
                if (v == 0) {
                  start.value = null;
                  end.value = null;
                }
                if (v == 1) {
                  start.value = now.startOfDay;
                  end.value = now.endOfDay;
                }
                if (v == 2) {
                  start.value = now.previousDay.startOfDay;
                  end.value = now.previousDay.endOfDay;
                }
                if (v == 3) {
                  start.value = now.startOfWeek;
                  end.value = now.endOfWeek;
                }
                if (v == 4) {
                  start.value = now.startOfMonth;
                  end.value = now.endOfMonth;
                }
                if (v == 5) {
                  start.value = now.startOfYear;
                  end.value = now.endOfYear;
                }
              },
            ),
          ),
          HomeCounterWidget(start.value, end.value),

          const Gap(8),

          Flex(
            direction: context.layout.isDesktop ? Axis.horizontal : Axis.vertical,
            spacing: Insets.med,
            children: [
              PieWidget(start.value, end.value),
              ShadCard(
                height: 600,
                child: BarWidget(start.value, end.value),
              ).conditionalExpanded(context.layout.isDesktop),
            ],
          ),
          const Gap(8),
          ShadCard(
            height: 600,
            title: const Text('Transactions'),
            childPadding: Pads.lg('t'),
            child: TrxTable(
              logs: trxList,
              accountAmounts: false,
            ),
          ),
          const Gap(8),
        ],
      ),
    );
  }
}
