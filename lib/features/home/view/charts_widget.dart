import 'package:pos/features/home/controller/home_ctrl.dart';
import 'package:pos/features/transactions/controller/transactions_ctrl.dart';
import 'package:pos/main.export.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class _PieData {
  _PieData(this.x, this.y);
  final TransactionType x;
  final num? y;
}

class _BarData {
  _BarData(this.month, this.y);

  final int month;
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
      width: context.layout.isDesktop ? context.width * .25 : null,
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
    final trxList = ref.watch(transactionLogCtrlProvider).maybeList().filterByDateRange(start, end, (e) => e.date);

    List<_BarData> inData() {
      final data = <_BarData>[];

      final trxGroup = trxList.where((e) => e.isIncome == true).groupListsBy((e) => e.date.month);
      for (var month = 1; month <= 12; month++) {
        data.add(_BarData(month, trxGroup[month]?.map((e) => e.amount).sum));
      }

      return data;
    }

    List<_BarData> outData() {
      final data = <_BarData>[];

      final trxGroup = trxList.where((e) => e.isIncome != true).groupListsBy((e) => e.date.month);
      for (var month = 1; month <= 12; month++) {
        data.add(_BarData(month, trxGroup[month]?.map((e) => e.amount).sum));
      }

      return data;
    }

    List<_BarData> returnData() {
      final data = <_BarData>[];

      final trxGroup = trxList.fromTypes([TransactionType.returned]).groupListsBy((e) => e.date.month);
      for (var month = 1; month <= 12; month++) {
        data.add(_BarData(month, trxGroup[month]?.map((e) => e.amount).sum));
      }

      return data;
    }

    return SfCartesianChart(
      title: const ChartTitle(text: 'Transactions', alignment: ChartAlignment.near),
      tooltipBehavior: TooltipBehavior(enable: true, duration: 1000),
      legend: const Legend(isVisible: true, position: LegendPosition.bottom),
      primaryXAxis: const CategoryAxis(),
      primaryYAxis: NumericAxis(
        numberFormat: currencyFormate(compact: true),
      ),
      series: [
        ColumnSeries<_BarData, String>(
          name: 'In',
          dataSource: inData(),
          xValueMapper: (data, _) => getMonthName(data.month),
          yValueMapper: (data, _) => data.y,
          color: Colors.blue,
          borderRadius: Corners.smBorder.copyWith(bottomLeft: Radius.zero, bottomRight: Radius.zero),
          spacing: .3,
          width: 0.8,
        ),
        ColumnSeries<_BarData, String>(
          name: 'Out',
          dataSource: outData(),
          xValueMapper: (data, _) => getMonthName(data.month),
          yValueMapper: (data, _) => data.y,
          color: Colors.amber.shade900,
          borderRadius: Corners.smBorder.copyWith(bottomLeft: Radius.zero, bottomRight: Radius.zero),
          spacing: .3,
          width: 0.8,
        ),
        ColumnSeries<_BarData, String>(
          name: 'Return',
          dataSource: returnData(),
          xValueMapper: (data, _) => getMonthName(data.month),
          yValueMapper: (data, _) => data.y,
          color: Colors.red,
          borderRadius: Corners.smBorder.copyWith(bottomLeft: Radius.zero, bottomRight: Radius.zero),
          spacing: .3,
          width: 0.8,
        ),
      ],
    );
  }
}
