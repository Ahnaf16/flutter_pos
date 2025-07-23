import 'package:pos/features/home/controller/home_ctrl.dart';
import 'package:pos/features/products/controller/products_ctrl.dart';
import 'package:pos/features/products/view/product_filter_fields.dart';
import 'package:pos/main.export.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

const _headings = [
  TableHeading.positional('#', 50.0),
  TableHeading.positional('Name'),
  TableHeading.positional('SKU'),
  TableHeading.positional('Warehouse'),
  TableHeading.positional('Stock'),
  TableHeading.positional('Purchase'),
  TableHeading.positional('Sale'),
  TableHeading.positional('Action', 200.0, Alignment.center),
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
          onPressed: () {
            RPaths.createProduct.pushNamed(context);
          },

          child: const SelectionContainer.disabled(
            child: SelectionContainer.disabled(child: Text('Add a Product')),
          ),
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
                      minimumWidth: heading.minWidth ?? 150,

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
                      'SKU' => DataGridCell(columnName: head.name, value: skuCellBuilder(data)),
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
                      'Purchase' => DataGridCell(columnName: head.name, value: _purchaseCellBuilder(data)),
                      'Sale' => DataGridCell(columnName: head.name, value: _saleCellBuilder(data)),
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
                            ).colored(Colors.blue).toolTip('View'),
                            ShadButton.secondary(
                              size: ShadButtonSize.sm,
                              leading: const Icon(LuIcons.pen),
                              onPressed: () => RPaths.editProduct(data.id).pushNamed(context),
                            ).colored(Colors.green).toolTip('Edit'),
                            ShadButton.secondary(
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
                                        ShadButton(
                                          onPressed: () => c.nPop(),
                                          child: const SelectionContainer.disabled(child: Text('Cancel')),
                                        ),
                                        ShadButton.destructive(
                                          onPressed: () async {
                                            await ref.read(productsCtrlProvider.notifier).deleteProduct(data);
                                            if (c.mounted) c.nPop();
                                          },
                                          child: const SelectionContainer.disabled(child: Text('Delete')),
                                        ),
                                      ],
                                    );
                                  },
                                );
                              },
                            ).colored(context.colors.destructive).toolTip('Delete'),
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

  Widget _purchaseCellBuilder(Product product) => Builder(
    builder: (context) {
      final stock = product.stock.firstOrNull;
      return Text('Purchase: ${stock?.purchasePrice.currency() ?? '--'}');
    },
  );
  Widget _saleCellBuilder(Product product) => Builder(
    builder: (context) {
      return Text('Sale: ${product.salePrice.currency()}');
    },
  );

  static Widget nameCellBuilder(Product? product, [double gap = Insets.xs, double imgSize = 40]) => Builder(
    builder: (context) {
      if (product == null) return const Text('Unknown product');
      return Wrap(
        spacing: Insets.med,
        runSpacing: Insets.xs,

        children: [
          ShadCard(
            expanded: false,
            padding: Pads.zero,
            child: HostedImage.square(product.getPhoto(), radius: Corners.sm, dimension: imgSize),
          ),

          SizedBox(
            width: 200,
            child: Column(
              spacing: gap,
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(product.name, style: context.text.list, overflow: TextOverflow.ellipsis),

                if (product.manufacturer != null)
                  Text(product.manufacturer ?? '--', style: context.text.muted, overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        ],
      );
    },
  );
  static Widget skuCellBuilder(Product? product, [double gap = Insets.xs, double imgSize = 40]) => Builder(
    builder: (context) {
      if (product == null) return const Text('Unknown product');
      return Wrap(
        spacing: Insets.med,
        runSpacing: Insets.xs,

        children: [
          SizedBox(
            width: 200,
            child: Column(
              spacing: gap,
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (product.sku != null)
                  Text('SKU: ${product.sku ?? '--'}', style: context.text.muted, overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        ],
      );
    },
  );
}
