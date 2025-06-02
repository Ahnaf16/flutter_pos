import 'package:pos/main.export.dart';

class ProductViewDialog extends HookConsumerWidget {
  const ProductViewDialog({super.key, required this.product});

  final Product product;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ShadDialog(
      title: const Text('Product'),
      description: Text('Details of ${product.name}'),
      constraints: const BoxConstraints(maxWidth: 700),
      actions: [ShadButton.destructive(onPressed: () => context.nPop(), child: const Text('Cancel'))],
      child: Container(
        padding: Pads.padding(v: Insets.med),
        child: Column(
          spacing: Insets.med,
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (product.photo != null) HostedImage.square(product.getPhoto(), dimension: 80, radius: Corners.med),

            SpacedText(left: 'Name', right: product.name, styleBuilder: (l, r) => (l, r.bold)),
            SpacedText(left: 'Manufacturer', right: product.manufacturer ?? '--', styleBuilder: (l, r) => (l, r.bold)),
            SpacedText(
              left: 'Total Stock',
              right: '${product.quantity} ${product.unitName}',
              styleBuilder: (l, r) => (l, r.bold),
            ),
            SpacedText(
              left: 'SKU',
              right: product.sku ?? '--',
              styleBuilder: (l, r) => (l, r.bold),
              trailing: SmallButton(icon: LuIcons.copy, onPressed: () => Copier.copy(product.sku)),
            ),
            SpacedText(
              left: 'Sale price',
              right: product.salePrice.currency(),
              styleBuilder: (l, r) => (l, r.bold),
              trailing: SmallButton(icon: LuIcons.copy, onPressed: () => Copier.copy(product.sku)),
            ),

            const Gap(Insets.xs),
            if (product.stock.isNotEmpty) const Text('Stock Locations:'),
            for (final stock in product.stock)
              SpacedText(
                left: stock.warehouse?.name ?? '--',
                right: '${stock.quantity} ${product.unitName}  |  Purchase ${stock.purchasePrice}',
                styleBuilder: (l, r) => (l, r.bold),
              ),
            const Gap(Insets.xs),
            if (product.description != null) ...[const Text('Description:'), Text(product.description ?? '--')],
          ],
        ),
      ),
    );
  }
}
