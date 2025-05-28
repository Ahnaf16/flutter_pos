import 'package:fl_chart/fl_chart.dart';
import 'package:pos/features/home/controller/home_ctrl.dart';
import 'package:pos/main.export.dart';

class BarWidget extends HookConsumerWidget {
  const BarWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final now = DateTime.now().justDate;

    final type = useState(TableType.yearly);
    final month = useState(now.month);

    final barData = ref.watch(barDataCtrlProvider(type.value, month.value));

    return ShadCard(
      title: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Expanded(child: Text('Transactions summary')),
          LimitedWidthBox(
            maxWidth: 200,
            child: ShadSelectField<TableType>(
              initialValue: type.value,
              options: TableType.values,
              optionBuilder: (_, value, _) => ShadOption(value: value, child: Text(value.name.titleCase)),
              selectedBuilder: (context, value) => Text(value.name.titleCase),
              onChanged: (v) => type.set(v ?? TableType.yearly),
            ),
          ),
          if (type.value == TableType.monthly)
            LimitedWidthBox(
              maxWidth: 150,
              child: ShadSelectField<int>(
                initialValue: month.value,
                options: List.generate(12, (i) => i + 1),
                optionBuilder: (_, value, _) => ShadOption(value: value, child: Text(getMonthName(value))),
                selectedBuilder: (context, value) => Text(getMonthName(value)),
                onChanged: (v) => month.set(v ?? now.month),
              ),
            ),
        ],
      ),
      footer: _footer(),
      childPadding: Pads.lg('t'),
      child: SizedBox(
        height: 400,
        child: BarChart(
          BarChartData(
            titlesData: FlTitlesData(
              rightTitles: const AxisTitles(),
              topTitles: const AxisTitles(),
              leftTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: true, maxIncluded: false, reservedSize: 44),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  maxIncluded: false,
                  minIncluded: false,
                  reservedSize: 40,
                  getTitlesWidget: (value, meta) {
                    final text = type.value == TableType.monthly
                        ? value.toInt().toString()
                        : getMonthName(value.toInt());
                    return SideTitleWidget(meta: meta, child: Text(text));
                  },
                ),
              ),
            ),
            borderData: FlBorderData(border: Border.all(color: context.colors.border)),
            gridData: const FlGridData(show: false),
            barTouchData: BarTouchData(
              enabled: true,
              touchTooltipData: BarTouchTooltipData(
                fitInsideVertically: true,
                fitInsideHorizontally: true,
                tooltipBorder: BorderSide(color: context.colors.border),
                tooltipBorderRadius: Corners.smBorder,
                getTooltipColor: (group) => context.colors.card,
                getTooltipItem: (g, gi, r, ri) =>
                    BarTooltipItem(r.toY.currency(), context.text.small.textColor(r.color)),
              ),
            ),
            barGroups: [
              for (final MapEntry(:key, :value) in barData.entries)
                BarChartGroupData(
                  x: key,
                  barRods: [
                    BarChartRodData(
                      toY: value.where((e) => e.isIncome == true).map((e) => e.amount).sum.toDouble(),
                      color: Colors.blue,
                    ),
                    BarChartRodData(
                      toY: value.where((e) => e.isIncome == false).map((e) => e.amount).sum.toDouble(),
                      color: Colors.pink,
                    ),
                    BarChartRodData(
                      toY: value.fromTypes([TransactionType.returned]).map((e) => e.amount).sum.toDouble(),
                      color: Colors.grey.shade500,
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  Row _footer() {
    return Row(
      spacing: Insets.lg,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Row(
          spacing: Insets.sm,
          children: [
            CircleAvatar(backgroundColor: Colors.blue, radius: 5),
            Text('In'),
          ],
        ),
        const Row(
          spacing: Insets.sm,
          children: [
            CircleAvatar(backgroundColor: Colors.pink, radius: 5),
            Text('Out'),
          ],
        ),
        Row(
          spacing: Insets.sm,
          children: [
            CircleAvatar(backgroundColor: Colors.grey.shade500, radius: 5),
            const Text('Return'),
          ],
        ),
      ],
    );
  }
}
