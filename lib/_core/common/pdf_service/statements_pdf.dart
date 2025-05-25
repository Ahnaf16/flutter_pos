// ignore_for_file: prefer_const_constructors_in_immutables, use_key_in_widget_constructors

import 'dart:typed_data';

import 'package:collection/collection.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart';
import 'package:pos/_core/_core.dart';
import 'package:pos/locator.dart';
import 'package:pos/models/models.dart';
import 'package:recase/recase.dart';

class StatementsPdf {
  StatementsPdf(this.logs, this.config, this.start, this.end);

  final List<TransactionLog> logs;
  final Config config;
  final DateTime? start;
  final DateTime? end;

  final _st = locate<AwStorage>();

  Future<List<Widget>> fullPDF() async {
    Uint8List? bytes;
    if (config.shop.shopLogo case final String id) bytes = await _st.imgPreview(id);

    return [_PDFHeader(logs, config, bytes, start, end), _PDFTable(logs), _PDFFooter(logs)];
  }
}

class _PDFHeader extends StatelessWidget {
  _PDFHeader(this.logs, this.config, this.bytes, this.start, this.end);

  final List<TransactionLog> logs;
  final Config config;
  final Uint8List? bytes;
  final DateTime? start;
  final DateTime? end;

  @override
  Widget build(Context context) {
    final ShopConfig(:shopAddress, :shopLogo, :shopName) = config.shop;
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            if (bytes != null)
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(100)),
                alignment: Alignment.center,
                child: Image(MemoryImage(bytes!)),
              ),
            if (bytes != null) _gapW(Insets.sm),
            Text(shopName ?? kAppName, style: theme.header4),
          ],
        ),
        _gapH(Insets.med),
        Row(
          children: [
            Text('Statement '),
            if (start != null) Text(': ${start!.formatDate()}', style: const TextStyle(fontSize: 10)),
            if (start != null && end != null) Text('  to  ', style: const TextStyle(fontSize: 8)),
            if (end != null) Text(end!.formatDate(), style: const TextStyle(fontSize: 10)),
          ],
        ),
        _gapH(Insets.sm),
        if (shopAddress != null) Text('Address: $shopAddress', style: const TextStyle(fontSize: 10)),
        _gapH(Insets.xs),
        Text('Generated on ${DateTime.now().formatFull()}', style: const TextStyle(fontSize: 10)),
        _gapH(Insets.med),
      ],
    );
  }
}

class _PDFTable extends StatelessWidget {
  _PDFTable(this.logs);

  final List<TransactionLog> logs;

  @override
  Widget build(Context context) {
    final grouped = logs.groupListsBy((e) => e.date.justDate);

    List<List<dynamic>> items() {
      final result = <List<Object>>[];

      for (var a = 0; a < grouped.length; a++) {
        final MapEntry(:value) = grouped.entries.toList()[a];
        for (var b = 0; b < value.length; b++) {
          final item = value[b];
          final index = result.where((e) => e.first != '').length + 1;
          result.add([
            index,
            (item.date.formatDate()),
            item.account?.name ?? '--',
            item.amount.currency(),
            Text('${item.type.name.titleCase}. ${item.note ?? ''}', style: const TextStyle(fontSize: 10)),
          ]);
        }
        result.add(['', '', '____', '____', '']);
        result.add(['', 'Total', '', value.map((e) => e.amount).sum.currency(), '']);
        result.add(['', '', '', '']);
      }
      return result;
    }

    return TableHelper.fromTextArray(
      border: const TableBorder(),
      headerDecoration: const BoxDecoration(color: PdfColors.grey300),
      headerStyle: const TextStyle(fontSize: 10),
      headerAlignments: {3: Alignment.centerRight},
      headerAlignment: Alignment.centerLeft,
      cellAlignments: {3: Alignment.centerRight},
      cellAlignment: Alignment.centerLeft,
      cellStyle: const TextStyle(fontSize: 10),
      cellPadding: cellPadding,
      columnWidths: const {0: FlexColumnWidth(), 4: FixedColumnWidth(220)},
      defaultColumnWidth: const FlexColumnWidth(3),
      cellFormat: (_, data) {
        data = data ?? '';
        if (data == '____') return '';
        if (data == '___') return '';
        if ('$data'.toLowerCase() == 'null') return '';
        return data.toString();
      },
      cellDecoration: (index, data, rowNum) {
        final bottom = data == '____';
        return BoxDecoration(
          border: Border(bottom: bottom ? const BorderSide() : BorderSide.none),
        );
      },
      headers: ['#', 'Date', 'Account', 'Amount', 'Description'],
      data: items(),
    );
  }
}

class _PDFFooter extends StatelessWidget {
  _PDFFooter(
    this.logs,
  );

  final List<TransactionLog> logs;

  @override
  Widget build(Context context) {
    final accGrouped = logs.groupSetsBy((e) => e.account?.id);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Divider(color: PdfColors.grey400),
        for (final MapEntry(:value) in accGrouped.entries)
          Container(
            padding: cellPadding,
            child: Row(
              children: [
                Text(
                  '${value.firstOrNull?.account?.name ?? 'Unknown account'} Total',
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                ),
                _gapW(Insets.lg),
                Text(
                  value.map((e) => e.amount).sum.currency(),
                  textAlign: TextAlign.right,
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        _gapH(Insets.sm),
        Container(
          decoration: const BoxDecoration(color: PdfColors.grey300),
          padding: cellPadding,
          child: Row(
            children: [
              Expanded(
                child: Text('Total', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
              ),
              Expanded(
                child: Text(
                  logs.map((e) => e.amount).sum.currency(),
                  textAlign: TextAlign.right,
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

EdgeInsets get cellPadding => const EdgeInsets.symmetric(horizontal: 10, vertical: 5);

Widget _gapH(double h) => SizedBox(height: h);
Widget _gapW(double w) => SizedBox(width: w);
