import 'package:fpdart/fpdart.dart';
import 'package:pos/features/home/controller/home_ctrl.dart';
import 'package:pos/features/inventory_record/controller/inventory_record_ctrl.dart';
import 'package:pos/features/transactions/controller/transactions_ctrl.dart';
import 'package:pos/main.export.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class _PieData {
  _PieData(this.x, this.y);
  final TransactionType x;
  final num? y;
}

class _BarData {
  _BarData(this.x, this.y);

  final String x;
  final num? y;
}

class _LineData {
  _LineData(this.x, this.y);

  final DateTime x;
  final num? y;
}

class PieWidget extends HookConsumerWidget {
  const PieWidget(this.start, this.end, {super.key});
  final DateTime? start;
  final DateTime? end;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trxList = ref.watch(transactionLogCtrlProvider).maybeList().filterByDateRange(start, end, (e) => e.date);

    List<_PieData> chartData() {
      final data = <_PieData>[];

      final trxGroup = trxList.groupListsBy((e) => e.type);
      for (final type in TransactionType.values) {
        data.add(_PieData(type, trxGroup[type]?.map((e) => e.amount).sum));
      }

      return data;
    }

    return ShadCard(
      height: 600,
      width: context.layout.isDesktop ? context.width * .35 : null,
      child: SfCircularChart(
        title: const ChartTitle(
          text: 'Transactions by type',
          alignment: ChartAlignment.near,
        ),
        legend: const Legend(isVisible: true, position: LegendPosition.bottom),
        tooltipBehavior: TooltipBehavior(enable: true, duration: 1000),
        annotations: [
          CircularChartAnnotation(
            widget: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Total', style: context.text.list),
                Text(chartData().map((e) => e.y ?? 0).sum.currency(), style: context.text.lead),
              ],
            ),
          ),
        ],

        series: [
          DoughnutSeries<_PieData, String>(
            dataSource: chartData(),
            explode: true,
            yValueMapper: (data, _) => data.y,
            xValueMapper: (data, _) => data.x.name.titleCase,
            pointColorMapper: (data, _) => data.x.color,
            dataLabelMapper: (data, _) => data.y?.currency(),
            dataLabelSettings: const DataLabelSettings(
              isVisible: true,
              showZeroValue: false,
              labelPosition: ChartDataLabelPosition.outside,
              connectorLineSettings: ConnectorLineSettings(type: ConnectorType.curve),
            ),
            innerRadius: '65%',
          ),
        ],
      ),
    );
  }
}

class BarWidget extends HookConsumerWidget {
  const BarWidget(this.start, this.end, {super.key});
  final DateTime? start;
  final DateTime? end;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final trxList = ref.watch(transactionLogCtrlProvider).maybeList().filterByDateRange(start, end, (e) => e.date);

    // Your existing data functions remain unchanged
    List<_BarData> inData() {
      final data = <_BarData>[];
      final trxGroup = trxList.where((e) => e.isIncome == true).groupListsBy((e) => e.date.month);
      for (var month = 1; month <= 12; month++) {
        data.add(_BarData(getMonthName(month), trxGroup[month]?.map((e) => e.amount).sum));
      }
      return data;
    }

    List<_BarData> outData() {
      final data = <_BarData>[];
      final trxGroup = trxList.where((e) => e.isIncome != true).groupListsBy((e) => e.date.month);
      for (var month = 1; month <= 12; month++) {
        data.add(_BarData(getMonthName(month), trxGroup[month]?.map((e) => e.amount).sum));
      }
      return data;
    }

    List<_BarData> returnData() {
      final data = <_BarData>[];
      final trxGroup = trxList.fromTypes([TransactionType.returned]).groupListsBy((e) => e.date.month);
      for (var month = 1; month <= 12; month++) {
        data.add(_BarData(getMonthName(month), trxGroup[month]?.map((e) => e.amount).sum));
      }
      return data;
    }

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: theme.cardColor,
      ),
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Transactions',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const Gap(16),
          Expanded(
            child: SfCartesianChart(
              title: ChartTitle(
                alignment: ChartAlignment.near,
                textStyle: theme.textTheme.titleMedium,
              ),
              tooltipBehavior: TooltipBehavior(
                enable: true,
                duration: 1000,
                color: isDark ? Colors.grey[900] : Colors.white,
                borderColor: theme.dividerColor,
                textStyle: theme.textTheme.bodySmall,
              ),

              legend: Legend(
                isVisible: true,
                position: LegendPosition.bottom,
                textStyle: theme.textTheme.bodyMedium,
                overflowMode: LegendItemOverflowMode.wrap,
                orientation: LegendItemOrientation.horizontal,
              ),
              plotAreaBorderWidth: 0,
              primaryXAxis: CategoryAxis(
                labelStyle: theme.textTheme.bodySmall,
              ),
              primaryYAxis: NumericAxis(
                numberFormat: currencyFormate(compact: true),
                labelStyle: theme.textTheme.bodySmall,
              ),
              series: [
                ColumnSeries<_BarData, String>(
                  name: 'In',
                  dataSource: inData(),
                  xValueMapper: (data, _) => data.x,
                  yValueMapper: (data, _) => data.y,
                  color: const Color(0xFF2FA2FF),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
                  spacing: 0.3,
                  width: 0.9,
                ),

                SplineSeries<_BarData, String>(
                  dataSource: returnData(),
                  xValueMapper: (d, _) => d.x,
                  yValueMapper: (d, _) => d.y,
                  name: 'Return',
                  color: Colors.redAccent,
                  width: 2.5,
                  splineType: SplineType.monotonic,
                  markerSettings: const MarkerSettings(
                    isVisible: true,
                    height: 6,
                    width: 6,
                  ),
                ),

                SplineSeries<_BarData, String>(
                  dataSource: outData(),
                  xValueMapper: (d, _) => d.x,
                  yValueMapper: (d, _) => d.y,
                  name: 'Out',
                  color: Colors.amber.shade700,
                  splineType: SplineType.monotonic,
                  width: 2.5,
                  markerSettings: const MarkerSettings(
                    isVisible: true,
                    height: 6,
                    width: 6,
                  ),
                ),

                // ColumnSeries<_BarData, String>(
                //   name: 'Out',
                //   dataSource: outData(),
                //   xValueMapper: (data, _) => data.x,
                //   yValueMapper: (data, _) => data.y,
                //   color: Colors.amber.shade700,
                //   borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                //   spacing: 0.3,
                //   width: 0.9,
                // ),
                // ColumnSeries<_BarData, String>(
                //   name: 'Return',
                //   dataSource: returnData(),
                //   xValueMapper: (data, _) => data.x,
                //   yValueMapper: (data, _) => data.y,
                //   color: Colors.redAccent,
                //   borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                //   spacing: 0.3,
                //   width: 0.9,
                // ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class LineChartWidget extends HookConsumerWidget {
  const LineChartWidget(this.start, this.end, {super.key});
  final DateTime? start;
  final DateTime? end;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final inventory = ref
        .watch(inventoryCtrlProvider(null))
        .maybeList()
        .sortWithDate((e) => e.date)
        .filterByDateRange(start, end, (e) => e.date);

    final max = useState(DateTime.now().addDays(1));

    List<_LineData> sale() {
      final data = <_LineData>[];

      final invList = inventory.where((e) => e.type.isSale).groupListsBy((e) => e.date.justDate);
      for (final inv in invList.entries) {
        data.add(_LineData(inv.key, inv.value.map((e) => e.total).sum));
        max.value = inv.key.isAfter(max.value) ? inv.key : max.value;
      }

      return data;
    }

    List<_LineData> purchase() {
      final data = <_LineData>[];

      final invList = inventory.where((e) => e.type.isPurchase).groupListsBy((e) => e.date.justDate);
      for (final inv in invList.entries) {
        data.add(_LineData(inv.key, inv.value.map((e) => e.total).sum));
      }

      return data;
    }

    return ShadCard(
      child: SfCartesianChart(
        title: const ChartTitle(text: 'Invoice records', alignment: ChartAlignment.near),
        tooltipBehavior: TooltipBehavior(enable: true),
        legend: const Legend(isVisible: true, position: LegendPosition.bottom),
        primaryXAxis: DateTimeAxis(maximum: max.value),
        primaryYAxis: NumericAxis(
          numberFormat: currencyFormate(compact: true),
        ),
        series: [
          SplineSeries<_LineData, DateTime>(
            name: 'Sale',
            dataSource: sale(),
            xValueMapper: (data, _) => data.x,
            yValueMapper: (data, _) => data.y,
            color: RecordType.sale.color,
            markerSettings: const MarkerSettings(isVisible: true),
            splineType: SplineType.monotonic,
          ),
          SplineSeries<_LineData, DateTime>(
            name: 'Purchase',
            dataSource: purchase(),
            xValueMapper: (data, _) => data.x,
            yValueMapper: (data, _) => data.y,
            color: RecordType.purchase.color,
            markerSettings: const MarkerSettings(isVisible: true),
            splineType: SplineType.monotonic,
          ),
        ],
      ),
    );
  }
}
