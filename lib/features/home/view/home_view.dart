// import 'package:pos/features/home/view/bar_widget.dart';
// import 'package:pos/features/home/view/pie_widget.dart';
// import 'package:pos/features/transactions/view/transactions_view.dart';
import 'package:pos/features/filter/view/filter_bar.dart';
import 'package:pos/features/home/view/charts_widget.dart';
import 'package:pos/features/home/view/home_counter_widget.dart';
import 'package:pos/features/settings/controller/settings_ctrl.dart';
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
  'Custom date',
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
    final config = ref.watch(configCtrlProvider);

    return BaseBody(
      scrollable: true,
      noAPPBar: true,
      padding: Pads.med(),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: Insets.lg,
        children: [
          Row(
            spacing: Insets.lg,
            children: [
              if (context.layout.isMobile) ...[
                if (config.shop.shopLogo != null) CircleImage(Img.aw(config.shop.shopLogo!), radius: 20),
                Text(config.shop.shopName ?? kAppName),
              ],
              Expanded(
                child: CenterRight(
                  child: ShadSelect<int>(
                    minWidth: context.layout.isMobile ? 250 : 300,
                    initialValue: 0,
                    placeholder: const Text('Select date'),
                    selectedOptionBuilder: (_, v) => Text(_list[v]),
                    options: [
                      for (int i = 0; i < _list.length; i++) ShadOption(value: i, child: Text(_list[i])),
                    ],
                    allowDeselection: true,
                    onChanged: (v) async {
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
                      if (v == 6) {
                        await showShadDialog(
                          context: context,
                          builder: (context) => ShadDialog(
                            title: const Text('Select date range'),
                            child: DateRangeSelector(
                              onApply: (from, to) {
                                start.value = from;
                                end.value = to;
                              },
                            ),
                          ),
                        );
                      }
                    },
                  ),
                ),
              ),
            ],
          ),
          HomeCounterWidget(start.value, end.value),

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

          LineChartWidget(start.value, end.value),

          ShadCard(
            height: 850,
            title: Row(
              spacing: Insets.med,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Transactions'),
                ShadButton.link(child: const Text('View all'), onPressed: () => RPaths.transactions.pushNamed(context)),
              ],
            ),
            // childPadding: Pads.lg('t'),
            child: TrxTable(logs: trxList.takeFirst(6), accountAmounts: false),
          ),
          const Gap(0),
        ],
      ),
    );
  }
}
