import 'package:pos/features/products/controller/products_ctrl.dart';
import 'package:pos/main.export.dart';
import 'package:sliver_tools/sliver_tools.dart';

class StockView extends HookConsumerWidget {
  const StockView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productList = ref.watch(productsCtrlProvider);
    final scrCtrl = useScrollController();
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
      body: Scrollbar(
        controller: scrCtrl,
        child: SingleChildScrollView(
          controller: scrCtrl,
          scrollDirection: Axis.horizontal,
          child: LimitedWidthBox(
            maxWidth: Layouts.maxContentWidth,
            minWidth: Layouts.minContentWidth,
            useActualWidth: true,
            child: productList.when(
              loading: () => const Loading(),
              error: (e, s) => ErrorView(e, s, prov: productsCtrlProvider),
              data: (products) {
                return CustomScrollView(
                  slivers: [
                    MultiSliver(children: [for (final product in products) _ProductSection(model: product)]),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _ProductSection extends StatelessWidget {
  const _ProductSection({required this.model});

  final Product model;

  @override
  Widget build(BuildContext context) {
    return MultiSliver(
      pushPinnedChildren: true,
      children: [
        SliverStack(
          insetOnOverlap: true,
          children: [
            const SliverPositioned.fill(top: _ProductHeader.topInset, child: ShadCard()),
            MultiSliver(
              children: [SliverPinnedHeader(child: _ProductHeader(product: model)), SliverClip(child: _stockList())],
            ),
          ],
        ),
      ],
    );
  }

  Widget _stockList() {
    final list = SliverPadding(
      padding: Pads.padding(padding: _ProductHeader.topInset),
      sliver: SliverList.separated(
        itemCount: model.stock.length,
        separatorBuilder: (_, _) => const ShadSeparator.horizontal(margin: Pads.zero),
        itemBuilder: (context, index) {
          final stock = model.stock[index];
          return Padding(
            padding: Pads.sm(),
            child: Row(
              spacing: Insets.sm,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [Text(stock.warehouse?.name ?? '--'), Text('${stock.quantity} ${model.unitName}')],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SpacedText(
                        left: 'Purchase',
                        right: stock.purchasePrice.currency(),
                        spaced: false,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        styleBuilder: (_, _) => (context.text.muted, context.text.small),
                      ),
                      SpacedText(
                        left: 'Sale',
                        right: stock.salesPrice.currency(),
                        spaced: false,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        styleBuilder: (_, _) => (context.text.muted, context.text.small),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SpacedText(
                        left: stock.isProfitable ? 'Profit' : 'Loss',
                        right: (stock.getProfitLoss).currency(),
                        spaced: false,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        styleBuilder: (_, _) {
                          final c = stock.isProfitable ? Colors.green.shade500 : context.colors.destructive;
                          return (context.text.muted.textColor(c), context.text.small.textColor(c));
                        },
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [Text('Date: ${stock.createdAt.formatDate()}', style: context.text.muted)],
                  ),
                ),
                // const Expanded(
                //   child: Row(
                //     mainAxisAlignment: MainAxisAlignment.end,
                //     children: [ShadButton.secondary(size: ShadButtonSize.sm, leading: Icon(LuIcons.eye))],
                //   ),
                // ),
              ],
            ),
          );
        },
      ),
    );
    return list;
  }
}

class _ProductHeader extends StatelessWidget {
  final Product product;

  static const topInset = Insets.sm;

  const _ProductHeader({required this.product});

  @override
  Widget build(BuildContext context) {
    return ShadDecorator(
      decoration: ShadDecoration(border: ShadBorder(bottom: ShadBorderSide(width: 1, color: context.colors.border))),
      child: Padding(
        padding: Pads.padding(top: topInset * 2, bottom: topInset, h: topInset),
        child: Row(
          spacing: Insets.med,
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            ShadCard(
              expanded: false,
              padding: Pads.xs(),
              child: HostedImage.square(product.getPhoto, radius: Corners.sm, dimension: 40),
            ),

            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  OverflowMarquee(child: Text(product.name, style: context.text.list)),

                  Row(
                    spacing: Insets.med,
                    children: [
                      if (product.sku != null) Text('SKU: ${product.sku ?? '--'}', style: context.text.muted),
                      if (product.sku != null && product.manufacturer != null)
                        DecoContainer(size: 5, color: context.colors.primary.op7, borderRadius: Corners.circle),
                      if (product.manufacturer != null)
                        Text('Manufacturer: ${product.manufacturer ?? '--'}', style: context.text.muted),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
