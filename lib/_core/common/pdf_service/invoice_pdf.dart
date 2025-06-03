// ignore_for_file: prefer_const_constructors_in_immutables, use_key_in_widget_constructors

import 'dart:typed_data';

import 'package:collection/collection.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart';
import 'package:pos/_core/_core.dart';
import 'package:pos/locator.dart';
import 'package:pos/models/config/config.dart';
import 'package:pos/models/config/shop_config.dart';
import 'package:pos/models/inventory/inventory_record.dart';

class InvoicePDF {
  InvoicePDF(this.record, this.config);

  final InventoryRecord record;
  final Config config;
  final _st = locate<AwStorage>();

  Future<List<Widget>> fullPDF() async {
    Uint8List? bytes;
    if (config.shop.shopLogo case final String id) {
      bytes = await _st.imgPreview(id);
    }
    return [_Invoice(record, config, bytes)];
  }
}

class _Invoice extends StatelessWidget {
  _Invoice(this.rec, this.config, this.bytes);

  final InventoryRecord rec;
  final Config config;
  final Uint8List? bytes;

  @override
  Widget build(Context context) {
    final ShopConfig(:shopAddress, :shopLogo, :shopName) = config.shop;

    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: Insets.xxxl),
      alignment: Alignment.topRight,
      child: Column(
        children: [
          if (shopLogo != null)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
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
          if (shopAddress != null) Text(shopAddress, textAlign: TextAlign.center),
          Divider(color: PdfColors.black),
          _SpacedText(left: 'Invoice', right: rec.invoiceNo, mainAxisAlignment: MainAxisAlignment.center),
          _gapH(Insets.xs),
          Text(rec.date.formatDate('EEE, MMM dd, yyyy hh:mm a')),
          Divider(color: PdfColors.black),
          _gapH(Insets.med),
          _SpacedText(
            left: '${rec.type.isSale ? 'Customer' : 'Supplier'} Name',
            right: rec.getParti.name,
            styleBuilder: (l, r) => (l, r.copyWith(fontWeight: FontWeight.bold)),
            spaced: true,
          ),

          if (!rec.getParti.isWalkIn) ...[
            _SpacedText(
              left: 'Phone',
              right: rec.getParti.phone,
              spaced: true,
              styleBuilder: (l, r) => (l, r.copyWith(fontWeight: FontWeight.bold)),
            ),
            if (rec.getParti.address != null)
              _SpacedText(
                left: 'Address',
                right: rec.getParti.address!,
                spaced: true,
                styleBuilder: (l, r) => (l, r.copyWith(fontWeight: FontWeight.bold)),
              ),
          ],
          _gapH(Insets.lg),
          Row(
            children: [
              Expanded(flex: 2, child: Text('Product')),
              Expanded(child: Center(child: Text('Qty'))),
              Expanded(
                child: Align(alignment: Alignment.centerRight, child: Text('Price')),
              ),
            ],
          ),
          Divider(color: PdfColors.black),
          for (final item in rec.details) ...[
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Text('${rec.details.indexWhere((e) => e.id == item.id) + 1}.  ${item.product.name}'),
                ),
                Expanded(child: Center(child: Text(item.quantity.toString()))),
                Expanded(
                  child: Align(alignment: Alignment.centerRight, child: Text(item.price.currency())),
                ),
              ],
            ),
            _gapH(Insets.xs),
          ],

          Divider(color: PdfColors.black),
          _gapH(Insets.sm),
          _SpacedText(
            left: 'Subtotal',
            right: rec.subtotal.currency(),
            spaced: true,
            styleBuilder: (l, r) => (l, r.copyWith(fontWeight: FontWeight.bold)),
          ),
          _SpacedText(
            left: 'Discount',
            right: rec.discount.currency(),
            spaced: true,
            styleBuilder: (l, r) => (l, r.copyWith(fontWeight: FontWeight.bold)),
          ),
          _SpacedText(
            left: 'Shipping',
            right: rec.shipping.currency(),
            spaced: true,
            styleBuilder: (l, r) => (l, r.copyWith(fontWeight: FontWeight.bold)),
          ),
          _SpacedText(
            left: 'Vat',
            right: rec.vat.currency(),
            spaced: true,
            styleBuilder: (l, r) => (l, r.copyWith(fontWeight: FontWeight.bold)),
          ),
          _SpacedText(
            left: 'Total',
            right: rec.total.currency(),
            spaced: true,
            style: theme.header4,
            styleBuilder: (l, r) => (l, r.copyWith(fontWeight: FontWeight.bold)),
          ),
          Divider(color: PdfColors.black),
          if (rec.account != null)
            _SpacedText(
              left: 'Paid By',
              right: rec.account!.name,
              spaced: true,
              styleBuilder: (l, r) => (l, r.copyWith(fontWeight: FontWeight.bold)),
            ),
          _SpacedText(
            left: 'Paid amount',
            right: rec.paidAmount.currency(),
            spaced: true,
            styleBuilder: (l, r) => (l, r.copyWith(fontWeight: FontWeight.bold)),
          ),
          _SpacedText(
            left: 'Due amount',
            right: rec.due.currency(),
            spaced: true,
            styleBuilder: (l, r) => (l, r.copyWith(fontWeight: FontWeight.bold)),
          ),
          if (rec.returnRecord != null)
            _SpacedText(
              left: 'Return Qty',
              right: (rec.returnRecord!.detailsQtyMap.values.sum.abs()).toString(),
              style: theme.header5,
              spaced: true,
              styleBuilder: (l, r) => (l, r.copyWith(fontWeight: FontWeight.bold)),
            ),
          if (rec.returnRecord != null)
            _SpacedText(
              left: 'Return amount',
              right: (rec.returnRecord!.totalReturn).currency(),
              style: theme.header4,
              spaced: true,
              styleBuilder: (l, r) => (l, r.copyWith(fontWeight: FontWeight.bold)),
            ),
        ],
      ),
    );
  }
}

EdgeInsets get cellPadding => const EdgeInsets.symmetric(horizontal: 10, vertical: 5);

Widget _gapH(double h) => SizedBox(height: h);
Widget _gapW(double w) => SizedBox(width: w);

typedef _StyleBuilder = (TextStyle, TextStyle) Function(TextStyle left, TextStyle right);

class _SpacedText extends StatelessWidget {
  _SpacedText({
    required this.left,
    required this.right,
    this.style,
    this.spaced = false,
    this.mainAxisAlignment,
    this.styleBuilder,
  });

  final String left;
  final TextStyle? style;
  final String right;
  final _StyleBuilder? styleBuilder;
  final bool spaced;
  final MainAxisAlignment? mainAxisAlignment;

  @override
  Widget build(Context context) {
    final effectiveStyle = style ?? const TextStyle(fontSize: 11);
    final defBuilder = (effectiveStyle, effectiveStyle);

    final (lSty, rSty) = styleBuilder?.call(effectiveStyle, effectiveStyle) ?? defBuilder;

    return Row(
      mainAxisAlignment: spaced ? MainAxisAlignment.spaceBetween : (mainAxisAlignment ?? MainAxisAlignment.start),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('$left:', style: lSty),
        _gapH(Insets.med),
        Flexible(
          child: DefaultTextStyle(style: rSty, textAlign: spaced ? TextAlign.end : TextAlign.start, child: Text(right)),
        ),
      ],
    );
  }
}
