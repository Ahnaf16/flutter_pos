import 'package:pos/features/home/controller/home_ctrl.dart';
import 'package:pos/features/products/controller/products_ctrl.dart';
import 'package:pos/main.export.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

const _headings = [('Name', double.nan), ('Warehouse', 150.0), ('Stock', 100.0), ('Pricing', 200.0), ('Action', 200.0)];

class ProductsView extends HookConsumerWidget {
  const ProductsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productList = ref.watch(productsCtrlProvider);
    final viewingWh = ref.watch(viewingWHProvider);

    return BaseBody(
      title: 'Products',
      actions: [
        ShadButton(
          child: const Text('Add a Product'),
          onPressed: () {
            RPaths.createProduct.pushNamed(context);
          },
        ),
      ],
      body: productList.when(
        loading: () => const Loading(),
        error: (e, s) => ErrorView(e, s, prov: productsCtrlProvider),
        data: (products) {
          return DataTableBuilder<Product, (String, double)>(
            rowHeight: 120,
            items: products,
            headings: _headings,
            headingBuilder: (heading) {
              return GridColumn(
                columnName: heading.$1,
                columnWidthMode: ColumnWidthMode.fill,
                maximumWidth: heading.$2,
                minimumWidth: 200,
                label: Container(
                  padding: Pads.med(),
                  alignment: heading.$1 == 'Action' ? Alignment.centerRight : Alignment.centerLeft,
                  child: Text(heading.$1),
                ),
              );
            },
            cellAlignment: Alignment.centerLeft,
            cellBuilder: (data, head) {
              final hId = (viewingWh == null) ? null : viewingWh.id;
              return switch (head.$1) {
                'Name' => DataGridCell(columnName: head.$1, value: nameCellBuilder(data)),
                'Warehouse' => DataGridCell(
                  columnName: head.$1,
                  value: Text(
                    data.stocksByHouse(hId).firstWhereOrNull((e) => e.warehouse != null)?.warehouse?.name ?? '--',
                  ),
                ),
                'Stock' => DataGridCell(
                  columnName: head.$1,
                  value: Text('${data.quantityByHouse(hId)}${data.unitName}'),
                ),
                'Pricing' => DataGridCell(columnName: head.$1, value: _priceCellBuilder(data)),
                'Action' => DataGridCell(
                  columnName: head.$1,
                  value: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      ShadButton.secondary(
                        size: ShadButtonSize.sm,
                        leading: const Icon(LuIcons.eye),
                        onPressed:
                            () => showShadDialog(
                              context: context,
                              builder: (context) => _ProductViewDialog(product: data),
                            ),
                      ),
                      ShadButton.secondary(
                        size: ShadButtonSize.sm,
                        leading: const Icon(LuIcons.pen),
                        onPressed: () => RPaths.editProduct(data.id).pushNamed(context),
                      ),
                    ],
                  ),
                ),
                _ => DataGridCell(columnName: head.$1, value: Text(data.toString())),
              };
            },
          );
        },
      ),
    );
  }

  Widget _priceCellBuilder(Product product) => Builder(
    builder: (context) {
      final stock = product.stock.firstOrNull;
      return Column(
        spacing: Insets.xs,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          OverflowMarquee(child: Text('Purchase: ${stock?.purchasePrice.toString() ?? '--'}')),
          OverflowMarquee(child: Text('Sale: ${stock?.salesPrice.toString() ?? '--'}')),
          OverflowMarquee(child: Text('Wholesale: ${stock?.wholesalePrice.toString() ?? '--'}')),
          OverflowMarquee(child: Text('Dealer: ${stock?.dealerPrice.toString() ?? '--'}')),
        ],
      );
    },
  );
  static Widget nameCellBuilder(Product product, [double gap = Insets.xs, double imgSize = 40]) => Builder(
    builder: (context) {
      return Row(
        spacing: Insets.med,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          HostedImage.square(product.getPhoto, radius: Corners.sm, dimension: imgSize),

          Flexible(
            child: Column(
              spacing: gap,
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                OverflowMarquee(child: Text(product.name, style: context.text.list)),
                if (product.sku != null)
                  OverflowMarquee(child: Text('SKU: ${product.sku ?? '--'}', style: context.text.muted)),
                if (product.manufacturer != null)
                  OverflowMarquee(child: Text(product.manufacturer ?? '--', style: context.text.muted)),
              ],
            ),
          ),
        ],
      );
    },
  );
}

class _ProductViewDialog extends HookConsumerWidget {
  const _ProductViewDialog({required this.product});

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
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            if (product.photo != null) HostedImage.square(product.getPhoto, dimension: 80, radius: Corners.med),

            SpacedText(left: 'Name', right: product.name, styleBuilder: (l, r) => (l, r.bold), spaced: false),
            SpacedText(
              left: 'Manufacturer',
              right: product.manufacturer ?? '--',
              styleBuilder: (l, r) => (l, r.bold),
              spaced: false,
            ),
            SpacedText(
              left: 'Total Stock',
              right: '${product.quantity} ${product.unitName}',
              styleBuilder: (l, r) => (l, r.bold),
              spaced: false,
            ),
            SpacedText(
              left: 'SKU',
              right: product.sku ?? '--',
              styleBuilder: (l, r) => (l, r.bold),
              spaced: false,
              trailing: SmallButton(icon: LuIcons.copy, onPressed: () => Copier.copy(product.sku)),
            ),

            const Gap(Insets.xs),
            const Text('Stock Locations:'),
            for (final stock in product.stock)
              SpacedText(
                left: stock.warehouse?.name ?? '--',
                right:
                    '${stock.quantity} ${product.unitName}  |  Purchase ${stock.purchasePrice}  |  Sale ${stock.salesPrice}',
                styleBuilder: (l, r) => (l, r.bold),
                spaced: false,
              ),
            const Gap(Insets.xs),
            if (product.description != null) ...[const Text('Description:'), Text(product.description ?? '--')],
          ],
        ),
      ),
    );
  }
}
