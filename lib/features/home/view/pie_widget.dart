import 'package:fl_chart/fl_chart.dart';
import 'package:pos/features/home/controller/home_ctrl.dart';
import 'package:pos/main.export.dart';

class PieWidget extends HookConsumerWidget {
  const PieWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pieData = ref.watch(pieDataCtrlProvider);
    final touchedIndex = useState<int?>(null);

    return ShadCard(
      height: 500,
      width: 500,
      title: const Text('Transaction types'),
      childPadding: Pads.lg('t'),
      footer: _footer(),
      child: PieChart(
        PieChartData(
          pieTouchData: PieTouchData(
            touchCallback: (event, res) {
              if (!event.isInterestedForInteractions || res?.touchedSection == null) {
                touchedIndex.value = null;
                return;
              }
              final i = res?.touchedSection?.touchedSectionIndex ?? -1;
              touchedIndex.value = i == -1 ? null : i;
            },
          ),
          sectionsSpace: 0,
          centerSpaceRadius: 60,

          sections: [
            for (final MapEntry(:key, :value) in pieData.entries)
              PieChartSectionData(
                color: key.color,
                value: value.fromTypes([key]).map((e) => e.amount).sum.toDouble(),
                title: value.fromTypes([key]).map((e) => e.amount).sum.currency(),
                titleStyle: context.text.small.textColor(
                  key.color.computeLuminance() > 0.5 ? Colors.black : Colors.white,
                ),
                radius: touchedIndex.value == null
                    ? 50
                    : TransactionType.values[touchedIndex.value!] == key
                    ? 60
                    : 50,
              ),
          ],
        ),
      ),
    );
  }

  Widget _footer() {
    return Wrap(
      spacing: Insets.lg,
      runSpacing: Insets.xs,
      children: [
        for (final type in TransactionType.values)
          Row(
            mainAxisSize: MainAxisSize.min,
            spacing: Insets.sm,
            children: [
              CircleAvatar(backgroundColor: type.color, radius: 5),
              Text(type.name.titleCase),
            ],
          ),
      ],
    );
  }
}
