import 'package:pos/features/products/controller/products_ctrl.dart';
import 'package:pos/main.export.dart';

class ProductDetailsView extends ConsumerWidget {
  const ProductDetailsView({super.key});

  @override
  Widget build(BuildContext context, ref) {
    final id = context.param('id');
    final product = ref.watch(productDetailsProvider(id));

    return BaseBody(
      title: 'Product Details',
      scrollable: true,
      alignment: Alignment.topLeft,
      body: product.when(
        loading: () => const Loading(),
        error: (e, s) => ErrorView(e, s, prov: productDetailsProvider),
        data: (product) {
          if (product == null) return const ErrorDisplay('Product not found');
          return LimitedWidthBox(
            maxWidth: 800,
            center: false,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  spacing: Insets.med,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ShadCard(
                      expanded: false,
                      child: HostedImage.square(product.getPhoto, dimension: 150, radius: Corners.med),
                    ),
                    Flexible(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        spacing: Insets.med,
                        children: [
                          Row(
                            spacing: Insets.sm,
                            children: [
                              Text(product.name, style: context.text.h3),
                              if (product.manufacturer != null)
                                ShadBadge.outline(
                                  child: Text('${product.manufacturer}', style: context.text.muted),
                                ),
                            ],
                          ),
                          Text(product.salePrice.currency(), style: context.text.h4.primary(context)),

                          Text(
                            'SKU: ${product.sku}',
                            style: context.text.muted.size(12).textHeight(1),
                          ),
                          Row(
                            spacing: Insets.sm,
                            children: [
                              ShadBadge.secondary(
                                child: Text(
                                  '${product.quantity}${product.unitName}',
                                ),
                              ),
                              ShadBadge.secondary(
                                child: Text('${product.nonEmptyStocks().length} Stocks'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                if (product.description != null) ...[
                  const Gap(Insets.lg),
                  ShadCard(
                    title: Text('Description', style: context.text.list),
                    child: Text(product.description ?? ''),
                  ),
                ],
                const Gap(Insets.lg),
                if (product.nonEmptyStocks().isNotEmpty)
                  ShadCard(
                    child: ShadAccordion<int>(
                      initialValue: 1,
                      children: [
                        ShadAccordionItem<int>(
                          value: 1,
                          padding: Pads.sm(),
                          separator: const ShadSeparator.horizontal(margin: Pads.zero),
                          title: const Text('Stocks'),
                          child: ListView.separated(
                            itemCount: product.nonEmptyStocks().length,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            separatorBuilder: (_, __) => const ShadSeparator.horizontal(margin: Pads.zero),

                            itemBuilder: (BuildContext context, int index) {
                              final stock = product.nonEmptyStocks()[index];
                              return Padding(
                                padding: Pads.med(),
                                child: Row(
                                  spacing: Insets.sm,
                                  children: [
                                    Expanded(
                                      child: SpacedText(
                                        left: 'Purchase',
                                        right: (stock.purchasePrice).currency(),
                                        style: context.text.muted,
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        styleBuilder: (l, r) => (l, context.text.small),
                                      ),
                                    ),
                                    Expanded(
                                      child: CenterLeft(
                                        child: ShadBadge(child: Text(stock.warehouse?.name ?? '--')),
                                      ),
                                    ),

                                    Expanded(
                                      child: CenterRight(
                                        child: Text(
                                          '${stock.quantity} ${product.unitName}',
                                          style: context.text.list.textColor(
                                            stock.quantity > 0 ? Colors.green : Colors.red,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                      ],
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
