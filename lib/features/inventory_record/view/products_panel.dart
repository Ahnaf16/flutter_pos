import 'package:flutter/services.dart';
import 'package:pos/features/home/controller/home_ctrl.dart';
import 'package:pos/features/products/controller/products_ctrl.dart';
import 'package:pos/features/warehouse/controller/warehouse_ctrl.dart';
import 'package:pos/main.export.dart';

class ProductsPanel extends HookConsumerWidget {
  const ProductsPanel({super.key, required this.onProductSelect, required this.type, required this.userHouse});

  final Function(Product product, Stock? stock, WareHouse? warehouseId) onProductSelect;
  final RecordType type;
  final WareHouse? userHouse;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productList = ref.watch(productsCtrlProvider);
    final viewingWh = ref.watch(viewingWHProvider);
    final productCtrl = useCallback(() => ref.read(productsCtrlProvider.notifier));
    final search = useTextEditingController();

    return productList.when(
      loading: () => const Loading(),
      error: (e, s) => ErrorView(e, s, prov: productsCtrlProvider),
      data: (products) {
        final hId = (viewingWh == null) ? null : viewingWh.id;
        return IntrinsicWidth(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: Pads.sm('lrt'),
                child: ShadTextField(
                  controller: search,
                  hintText: 'Search',
                  onChanged: (v) => productCtrl().search(v ?? ''),
                  showClearButton: true,
                ),
              ),

              const ShadSeparator.horizontal(),
              Expanded(
                child: GridView.builder(
                  padding: Pads.med('blr'),
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 150,
                    mainAxisSpacing: Insets.sm,
                    crossAxisSpacing: Insets.sm,
                  ),
                  itemCount: products.length,
                  itemBuilder: (context, index) {
                    final product = products[index];
                    final qty = product.quantityByHouse(hId);
                    return HoverBuilder(
                      child: ShadCard(
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            DecoContainer(
                              color: context.colors.border,
                              borderRadius: Corners.sm,
                              alignment: Alignment.center,
                              child: HostedImage.square(product.getPhoto, radius: Corners.sm),
                            ),
                            Positioned(
                              bottom: 0,
                              left: -1,
                              right: -1,
                              child: DecoContainer(
                                color: context.colors.border.op8,
                                alignment: Alignment.center,
                                child: Text(product.name, maxLines: 2),
                              ),
                            ),
                            Positioned(
                              top: 3,
                              right: 3,
                              child: ShadBadge.raw(
                                variant:
                                    product.quantity <= 0 ? ShadBadgeVariant.destructive : ShadBadgeVariant.secondary,
                                child: Text('$qty${product.unitName}'),
                              ),
                            ),
                          ],
                        ),
                      ),
                      builder: (hovering, child) {
                        return GestureDetector(
                          onTap: () async {
                            if (type.isSale) {
                              onProductSelect(product, null, viewingWh);
                            } else {
                              final res = await showShadDialog<Stock>(
                                barrierDismissible: false,
                                context: context,
                                builder: (context) => const _AddStockDialog(),
                              );
                              onProductSelect(product, res, null);
                            }
                          },
                          child: Stack(
                            children: [
                              child,
                              Positioned.fill(
                                child: DecoContainer.animated(
                                  duration: 250.ms,
                                  color: hovering ? context.colors.border.op7 : Colors.transparent,
                                  alignment: Alignment.center,
                                  borderRadius: Corners.med,
                                  child:
                                      hovering
                                          ? DecoContainer(
                                            color: context.colors.primary.op9,
                                            borderRadius: Corners.circle,
                                            padding: Pads.sm(),
                                            child: Icon(LuIcons.plus, color: context.colors.primaryForeground),
                                          )
                                          : null,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _AddStockDialog extends HookConsumerWidget {
  const _AddStockDialog();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final warehouseList = ref.watch(warehouseCtrlProvider);
    final searchWarehouse = useState('');

    final stock = useState<Stock>(Stock.empty(ID.unique()));

    return ShadDialog(
      title: const Text('Stock'),
      description: const Text('Add stock details'),

      actions: [
        ShadButton.destructive(onPressed: () => context.nPop(), child: const Text('Cancel')),
        ShadButton(
          onPressed: () {
            context.nPop(stock.value);
          },
          child: const Text('Add'),
        ),
      ],
      child: Container(
        padding: Pads.padding(v: Insets.med),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: Insets.sm,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: ShadTextField(
                    name: 'purchase_price',
                    label: 'Purchase Price',
                    hintText: 'Enter purchase price',
                    isRequired: true,
                    numeric: true,
                    onChanged: (value) {
                      stock.value = stock.value.copyWith(purchasePrice: Parser.toNum(value));
                    },
                  ),
                ),
              ],
            ),

            Row(
              children: [
                Expanded(
                  child: ShadTextField(
                    name: 'quantity',
                    label: 'Quantity',
                    hintText: 'Enter Stock quantity',
                    isRequired: true,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    onChanged: (value) {
                      stock.value = stock.value.copyWith(quantity: Parser.toInt(value));
                    },
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: ShadInputDecorator(
                    label: const Text('Choose warehouse').required(),
                    child: warehouseList.maybeWhen(
                      orElse: () => ShadCard(padding: kDefInputPadding, child: const Loading()),
                      data: (warehouses) {
                        final filtered = warehouses.where((e) => e.name.low.contains(searchWarehouse.value.low));
                        return LimitedWidthBox(
                          child: ShadSelect<WareHouse>.withSearch(
                            placeholder: const Text('Warehouse'),
                            options: [
                              if (filtered.isEmpty)
                                Padding(padding: Pads.padding(v: 24), child: const Text('No warehouses found')),
                              ...filtered.map((house) {
                                return ShadOption(value: house, child: Text(house.name));
                              }),
                            ],
                            selectedOptionBuilder: (context, v) => Text(v.name),
                            onSearchChanged: searchWarehouse.set,
                            allowDeselection: true,
                            onChanged: (value) {
                              stock.value = stock.value.copyWith(warehouse: () => value);
                            },
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
