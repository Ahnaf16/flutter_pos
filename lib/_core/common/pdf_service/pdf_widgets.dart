// ignore_for_file: prefer_const_constructors_in_immutables, use_key_in_widget_constructors

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart';
import 'package:pos/_core/_core.dart';
import 'package:pos/models/inventory/inventory_record.dart';

class InvoicePDF {
  InvoicePDF(this.record);

  final InventoryRecord record;

  List<Widget> get fullPDF {
    return [_Invoice(record)];
  }
}

class _Invoice extends StatelessWidget {
  _Invoice(this.record);

  final InventoryRecord record;

  @override
  Widget build(Context context) {
    final InventoryRecord(party: parti) = record;
    final theme = Theme.of(context);

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,

          children: [Text(kAppName), Text('INVOICE', style: theme.header3)],
        ),
        _gapH(20),
        Row(
          children: [
            if (parti != null)
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Bill to:'),
                    _gapH(4),
                    Text(parti.name),
                    Text(parti.phone),
                    if (parti.email != null) Text(parti.email!),
                    if (parti.address != null) Text(parti.address!),
                  ],
                ),
              ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _SpacedText(left: 'Invoice', right: record.id),
                  _SpacedText(left: 'Invoice Date', right: record.date.formatDate()),
                  _SpacedText(left: 'Status', right: record.status.name),
                ],
              ),
            ),
          ],
        ),
        _gapH(20),

        TableHelper.fromTextArray(
          border: TableBorder.all(color: PdfColors.grey500),
          cellPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          headerDecoration: const BoxDecoration(color: PdfColors.grey300),
          headerAlignment: Alignment.centerRight,
          headerAlignments: {0: Alignment.centerLeft},
          cellAlignment: Alignment.centerRight,
          cellAlignments: {0: Alignment.centerLeft},
          columnWidths: {
            0: const FlexColumnWidth(4),
            1: const FlexColumnWidth(2),
            2: const FlexColumnWidth(),
            3: const FlexColumnWidth(2),
          },
          headers: ['Item', 'Unit price', 'Qty', 'Total'],
          data: [
            for (final item in record.details)
              [
                Text(item.product.name, maxLines: 1),
                item.price.currency(),
                item.quantity.toString(),
                (item.price * item.quantity).currency(),
              ],
          ],
        ),
        _gapH(20),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            SizedBox(
              width: 200,
              child: Column(
                children: [
                  _SpacedText(left: 'Subtotal', right: record.subtotal.currency()),
                  if (record.vat != 0) _SpacedText(left: 'Vat', right: record.vat.currency()),
                  if (record.shipping != 0) _SpacedText(left: 'Shipping', right: record.shipping.currency()),
                  if (record.discount != 0) _SpacedText(left: 'Discount', right: record.discountString()),
                  _SpacedText(left: 'Paid', right: record.amount.currency()),
                  if (record.due != 0) _SpacedText(left: 'Due', right: record.due.currency()),
                  _gapH(5),
                  _SpacedText(left: 'Total', right: record.total.currency(), style: theme.header4),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}

EdgeInsets get cellPadding => const EdgeInsets.symmetric(horizontal: 10, vertical: 5);

Widget _gapH(double h) => SizedBox(height: h);

class _SpacedText extends StatelessWidget {
  _SpacedText({required this.left, required this.right, this.style});

  final String left;
  final String right;
  final TextStyle? style;

  @override
  Widget build(Context context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [Flexible(child: Text('$left: ', style: style)), Flexible(child: Text(right, style: style))],
      ),
    );
  }
}
