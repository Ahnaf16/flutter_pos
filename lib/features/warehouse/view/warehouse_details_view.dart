import 'package:pos/features/products/controller/products_ctrl.dart';
import 'package:pos/features/warehouse/controller/warehouse_ctrl.dart';
import 'package:pos/main.export.dart';

final _headings = ['#', 'Name', 'Quantity', 'Sale price', 'Total'];

class WarehouseDetailsView extends HookConsumerWidget {
  const WarehouseDetailsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final id = context.pathParams['id']!;
    final warehouseData = ref.watch(warehouseDetailsProvider(id));
    final products = ref.watch(productsCtrlProvider).maybeList().toList();

    return BaseBody(
      title: 'Warehouse',
      body: warehouseData.when(
        loading: () => const Loading(),
        error: (e, s) => ErrorView(e, s, prov: warehouseDetailsProvider),
        data: (house) {
          if (house == null) return const ErrorDisplay('Warehouse not found');
          return Container(
            padding: Pads.padding(v: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: Insets.sm,
              children: [
                _Summary(products: products, id: id, house: house),
                const Gap(0),
                Expanded(
                  child: ShadCard(
                    title: const Text('Products'),
                    child: ShadTable(
                      columnCount: _headings.length,
                      rowCount: products.where((e) => e.stocksByHouse(id).isNotEmpty).length,

                      columnSpanExtent: (index) {
                        if (index == 0) return const FixedTableSpanExtent(50);
                        if (index == 1) return const FixedTableSpanExtent(300);
                        if (index == 2) return const FixedTableSpanExtent(250);
                        if (index == 3) return const FixedTableSpanExtent(300);
                        if (index == 4) {
                          return const MaxTableSpanExtent(
                            FixedTableSpanExtent(300),
                            RemainingTableSpanExtent(),
                          );
                        }

                        return null;
                      },
                      header: (context, column) {
                        final isLast = column == _headings.length - 1;
                        return ShadTableCell.header(
                          alignment: isLast ? Alignment.centerRight : Alignment.centerLeft,
                          child: Text(_headings[column]),
                        );
                      },
                      builder: (context, index) {
                        final product = products.where((e) => e.stocksByHouse(id).isNotEmpty).toList()[index.row];
                        final data = [
                          (index.row + 1).toString(),
                          product.name,
                          '${product.quantityByHouse(id)} ${product.unitName}',
                          product.salePrice.currency(),
                          (product.salePrice * product.quantityByHouse(id)).currency(),
                        ];
                        final isLast = index.column == _headings.length - 1;

                        return ShadTableCell(
                          alignment: isLast ? Alignment.centerRight : Alignment.centerLeft,
                          child: Row(
                            mainAxisAlignment: isLast ? MainAxisAlignment.end : MainAxisAlignment.start,
                            spacing: Insets.med,
                            children: [
                              Flexible(
                                child: Text(data[index.column], style: context.text.list, maxLines: 1),
                              ),
                              if (index.column == 1)
                                SmallButton(
                                  icon: LuIcons.arrowUpRight,
                                  onPressed: () => RPaths.productDetails(product.id).pushNamed(context),
                                ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _Summary extends StatelessWidget {
  const _Summary({
    required this.products,
    required this.id,
    required this.house,
  });

  final WareHouse house;
  final List<Product> products;
  final String id;

  @override
  Widget build(BuildContext context) {
    final products = this.products.where((e) => e.stocksByHouse(id).isNotEmpty).toList();
    return IntrinsicHeight(
      child: Row(
        spacing: Insets.med,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: ShadCard(
              title: const Text('Details'),
              childPadding: Pads.sm('t'),
              child: Column(
                children: [
                  SpacedText(
                    left: 'Name',
                    right: house.name,
                    style: context.text.list,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    trailing: !house.isDefault ? null : const ShadBadge.outline(child: Text('Default')),
                  ),
                  SpacedText(
                    left: 'Address',
                    right: house.address,
                    style: context.text.list,
                    trailing: SmallButton(icon: LuIcons.copy, onPressed: () => Copier.copy(house.address)),
                  ),
                  SpacedText(
                    left: 'Contact Person',
                    right: house.contactPerson ?? 'N/a',
                    style: context.text.list,
                  ),
                  SpacedText(
                    left: 'Contact Number',
                    right: house.contactNumber,
                    style: context.text.list,
                    trailing: SmallButton(
                      icon: LuIcons.copy,
                      onPressed: () => Copier.copy(house.contactNumber),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: ShadCard(
              title: const Text('Inventory info'),
              childPadding: Pads.sm('t'),
              child: Column(
                children: [
                  SpacedText(
                    left: 'Total product',
                    right: products.length.toString(),
                    style: context.text.list,
                  ),
                  SpacedText(
                    left: 'Total product qty',
                    right: products.map((e) => e.quantityByHouse(id)).sum.toString(),
                    style: context.text.list,
                  ),
                  SpacedText(
                    left: 'Total value',
                    right: products.map((e) => e.salePrice).sum.currency(),
                    style: context.text.list,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
