import 'package:pos/features/home/controller/home_ctrl.dart';
import 'package:pos/features/products/controller/products_ctrl.dart';
import 'package:pos/features/unit/controller/unit_ctrl.dart';
import 'package:pos/features/warehouse/controller/warehouse_ctrl.dart';
import 'package:pos/main.export.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

const _headings = [('Name', double.nan), ('Warehouse', 150.0), ('Stock', 100.0), ('Pricing', 200.0), ('Action', 200.0)];

class ProductsView extends HookConsumerWidget {
  const ProductsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productList = ref.watch(productsCtrlProvider);
    final productCtrl = useCallback(() => ref.read(productsCtrlProvider.notifier));
    final warehouseList = ref.watch(warehouseCtrlProvider);
    final unitList = ref.watch(unitCtrlProvider);

    final viewingWh = ref.watch(viewingWHProvider);
    final search = useTextEditingController();

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
          LimitedWidthBox(
            maxWidth: 800,
            center: false,
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: ShadTextField(
                    controller: search,
                    hintText: 'Search',
                    onChanged: (v) => productCtrl().search(v ?? ''),
                    showClearButton: true,
                  ),
                ),

                Expanded(
                  flex: 2,
                  child: warehouseList.maybeWhen(
                    orElse: () => ShadCard(padding: kDefInputPadding, child: const Loading()),
                    data: (warehouses) {
                      return ShadSelectField<WareHouse>(
                        hintText: 'Filter by warehouse',
                        options: warehouses,
                        selectedBuilder: (context, value) => Text(value.name),
                        optionBuilder: (_, value, _) {
                          return ShadOption(value: value, child: Text(value.name));
                        },
                        onChanged: (v) => productCtrl().filter(wh: v),
                      );
                    },
                  ),
                ),
                Expanded(
                  child: unitList.maybeWhen(
                    orElse: () => ShadCard(padding: kDefInputPadding, child: const Loading()),
                    data: (units) {
                      return ShadSelectField<ProductUnit>(
                        hintText: 'Filter by unit',
                        options: units,
                        selectedBuilder: (context, value) => Text(value.name),
                        optionBuilder: (_, value, _) {
                          return ShadOption(value: value, child: Text(value.name));
                        },
                        onChanged: (v) => productCtrl().filter(unit: v),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          const Gap(Insets.sm),
          Expanded(
            child: productList.when(
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
                      _ => DataGridCell(columnName: head.$1, value: Text(data.toString())),
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
            const Text('Stock Locations:'),
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
