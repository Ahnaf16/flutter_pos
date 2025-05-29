import 'package:pos/features/home/controller/home_ctrl.dart';
import 'package:pos/features/products/controller/products_ctrl.dart';
import 'package:pos/features/products/view/product_filter_fields.dart';
import 'package:pos/main.export.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

const _headings = [
  TableHeading.positional('#', 60.0),
  TableHeading.positional('Name'),
  TableHeading.positional('Warehouse', 150.0),
  TableHeading.positional('Stock', 100.0),
  TableHeading.positional('Pricing', 200.0),
  TableHeading.positional('Action', 200.0),
];

class ProductsView extends HookConsumerWidget {
  const ProductsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productList = ref.watch(productsCtrlProvider);
    final productCtrl = useCallback(() => ref.read(productsCtrlProvider.notifier));

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
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ProductFilterFields(productCtrl: productCtrl),
          Expanded(
            child: productList.when(
              loading: () => const Loading(),
              error: (e, s) => ErrorView(e, s, prov: productsCtrlProvider),
              data: (products) {
                return DataTableBuilder<Product, TableHeading>(
                  rowHeight: 120,
                  items: products,
                  headings: _headings,
                  headingBuilder: (heading) {
                    return GridColumn(
                      columnName: heading.name,
                      columnWidthMode: ColumnWidthMode.fill,
                      maximumWidth: heading.max,
                      minimumWidth: 200,
                      label: Container(
                        padding: Pads.med(),
                        alignment: heading.alignment,
                        child: Text(heading.name),
                      ),
                    );
                  },
                  cellAlignmentBuilder: (h) => _headings.fromName(h).alignment,
                  cellBuilder: (data, head) {
                    final hId = (viewingWh.viewing == null) ? null : viewingWh.viewing!.id;
                    return switch (head.name) {
                      '#' => DataGridCell(
                        columnName: head.name,
                        value: Text((products.indexWhere((e) => e.id == data.id) + 1).toString()),
                      ),
                      'Name' => DataGridCell(columnName: head.name, value: nameCellBuilder(data)),
                      'Warehouse' => DataGridCell(
                        columnName: head.name,
                        value: Text(
                          data.stocksByHouse(hId).firstWhereOrNull((e) => e.warehouse != null)?.warehouse?.name ?? '--',
                        ),
                      ),
                      'Stock' => DataGridCell(
                        columnName: head.name,
                        value: Text('${data.quantityByHouse(hId)}${data.unitName}'),
                      ),
                      'Pricing' => DataGridCell(columnName: head.name, value: _priceCellBuilder(data)),
                      'Action' => DataGridCell(
                        columnName: head.name,
                        value: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            ShadButton.secondary(
                              size: ShadButtonSize.sm,
                              leading: const Icon(LuIcons.eye),
                              onPressed: () {
                                RPaths.productDetails(data.id).pushNamed(context);
                              },
                            ),
                            ShadButton.secondary(
                              size: ShadButtonSize.sm,
                              leading: const Icon(LuIcons.pen),
                              onPressed: () => RPaths.editProduct(data.id).pushNamed(context),
                            ),
                            ShadButton.destructive(
                              size: ShadButtonSize.sm,
                              leading: const Icon(LuIcons.trash),
                              onPressed: () {
                                showShadDialog(
                                  context: context,
                                  builder: (c) {
                                    return ShadDialog.alert(
                                      title: const Text('Delete Product'),
                                      description: Text(
                                        'This will delete ${data.name} and its ${data.stock.length} stocks permanently.',
                                      ),
                                      actions: [
                                        ShadButton(onPressed: () => c.nPop(), child: const Text('Cancel')),
                                        ShadButton.destructive(
                                          onPressed: () async {
                                            await ref.read(productsCtrlProvider.notifier).deleteProduct(data);
                                            if (c.mounted) c.nPop();
                                          },
                                          child: const Text('Delete'),
                                        ),
                                      ],
                                    );
                                  },
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                      _ => DataGridCell(columnName: head.name, value: Text(data.toString())),
                    };
                  },
                );
              },
            ),
          ),
        ],
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
          OverflowMarquee(child: Text('Sale: ${product.salePrice.toString()}')),
        ],
      );
    },
  );
  static Widget nameCellBuilder(Product? product, [double gap = Insets.xs, double imgSize = 40]) => Builder(
    builder: (context) {
      if (product == null) return const Text('Unknown product');
      return Row(
        spacing: Insets.med,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          ShadCard(
            expanded: false,
            child: HostedImage.square(product.getPhoto, radius: Corners.sm, dimension: imgSize),
          ),

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
