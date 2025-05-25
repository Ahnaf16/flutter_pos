import 'package:open_filex/open_filex.dart';
import 'package:pos/main.export.dart';

class InvInvoiceWidget extends HookConsumerWidget {
  const InvInvoiceWidget({super.key, required this.rec, required this.config});

  final InventoryRecord rec;
  final Config config;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ShopConfig(:shopAddress, :shopLogo, :shopName) = config.shop;

    return ShadDialog(
      title: const Row(
        spacing: Insets.med,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [Text('Print invoice'), CloseButton()],
      ),
      actions: [
        ShadButton.destructive(child: const Text('Cancel'), onPressed: () => context.nPop()),
        SubmitButton(
          leading: const Icon(LuIcons.printer),
          onPressed: (l) async {
            final ctrl = PDFCtrl();
            l.truthy();
            final pdf = await InvoicePDF(rec, config).fullPDF();
            final doc = await ctrl.getDoc(pdf);
            final path = await ctrl.save(doc, rec.invoiceNo);
            l.falsey();
            if (context.mounted) {
              Toast.show(
                context,
                'Invoice download',
                action: (id) {
                  if (path == null) return null;
                  return ShadIconButton.ghost(
                    icon: const Icon(LuIcons.externalLink),
                    onPressed: () => OpenFilex.open(path),
                  );
                },
              );
            }
          },
          child: const Text('Print Invoice'),
        ),
      ],
      scrollable: true,
      constraints: BoxConstraints(maxHeight: context.height * .9, maxWidth: 550),
      child: SingleChildScrollView(
        child: Container(
          color: Colors.white12,
          padding: Pads.padding(h: Insets.offset),
          child: Column(
            children: [
              if (shopLogo != null)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  spacing: Insets.med,
                  children: [
                    HostedImage.square(AwImg(shopLogo), dimension: 40, radius: Corners.circle),
                    Text(shopName ?? kAppName, style: context.text.large),
                  ],
                ),

              if (shopAddress != null) Text(shopAddress, style: context.text.p, textAlign: TextAlign.center),
              ShadSeparator.horizontal(margin: Pads.med('tb'), color: Colors.black26),
              SpacedText(
                left: 'Invoice',
                right: rec.invoiceNo,
                style: context.text.list,
                mainAxisAlignment: MainAxisAlignment.center,
                styleBuilder: (l, r) => (l, r.bold),
              ),
              Text(rec.date.formatDate('EEE, MMM dd, yyyy hh:mm a'), style: context.text.p),
              ShadSeparator.horizontal(margin: Pads.med('tb'), color: Colors.black26),
              SpacedText(
                left: '${rec.type.isSale ? 'Customer' : 'Supplier'} Name',
                right: rec.getParti.name,
                style: context.text.list,
                mainAxisAlignment: MainAxisAlignment.center,
                spaced: true,
                styleBuilder: (l, r) => (l, r.bold),
              ),

              if (!rec.getParti.isWalkIn) ...[
                SpacedText(
                  left: 'Phone',
                  right: rec.getParti.phone,
                  style: context.text.list,
                  spaced: true,
                  styleBuilder: (l, r) => (l, r.bold),
                ),
                if (rec.getParti.address != null)
                  SpacedText(
                    left: 'Address',
                    right: rec.getParti.address!,
                    style: context.text.list,
                    spaced: true,
                    styleBuilder: (l, r) => (l, r.bold),
                  ),
              ],
              const Gap(Insets.lg),

              const Row(
                children: [
                  Expanded(flex: 2, child: Text('Product')),
                  Expanded(child: Center(child: Text('Qty'))),
                  Expanded(child: CenterRight(child: Text('Price'))),
                ],
              ),
              ShadSeparator.horizontal(margin: Pads.med('tb'), color: Colors.black26),
              for (final item in rec.details)
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Text('${rec.details.indexWhere((e) => e.id == item.id) + 1}.  ${item.product.name}'),
                    ),
                    Expanded(child: Center(child: Text(item.quantity.toString()))),
                    Expanded(child: CenterRight(child: Text(item.price.currency()))),
                  ],
                ),

              ShadSeparator.horizontal(margin: Pads.med('tb'), color: Colors.black26),
              SpacedText(
                left: 'Subtotal',
                right: rec.subtotal.currency(),
                style: context.text.list,
                spaced: true,
                styleBuilder: (l, r) => (l, r.bold),
              ),
              SpacedText(
                left: 'Discount',
                right: rec.discount.currency(),
                style: context.text.list,
                spaced: true,
                styleBuilder: (l, r) => (l, r.bold),
              ),
              SpacedText(
                left: 'Shipping',
                right: rec.shipping.currency(),
                style: context.text.list,
                spaced: true,
                styleBuilder: (l, r) => (l, r.bold),
              ),
              SpacedText(
                left: 'Vat',
                right: rec.vat.currency(),
                style: context.text.list,
                spaced: true,
                styleBuilder: (l, r) => (l, r.bold),
              ),
              SpacedText(
                left: 'Total',
                right: rec.total.currency(),
                style: context.text.large,
                spaced: true,
                styleBuilder: (l, r) => (l.bold, r.bold),
              ),
              ShadSeparator.horizontal(margin: Pads.med('tb'), color: Colors.black26),
              if (rec.account != null)
                SpacedText(
                  left: 'Paid By',
                  right: rec.account!.name,
                  style: context.text.list,
                  spaced: true,
                  styleBuilder: (l, r) => (l, r.bold),
                ),
              SpacedText(
                left: 'Paid amount',
                right: rec.paidAmount.currency(),
                style: context.text.list,
                spaced: true,
                styleBuilder: (l, r) => (l, r.bold),
              ),
              SpacedText(
                left: 'Due amount',
                right: rec.due.currency(),
                style: context.text.list,
                spaced: true,
                styleBuilder: (l, r) => (l, r.bold),
              ),
              if (rec.returnRecord != null)
                SpacedText(
                  left: 'Return amount',
                  right: (rec.returnRecord!.totalReturn).currency(),
                  style: context.text.large,
                  spaced: true,
                  styleBuilder: (l, r) => (l.bold, r.bold),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
