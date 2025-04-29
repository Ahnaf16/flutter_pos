import 'package:pos/features/products/controller/products_ctrl.dart';
import 'package:pos/features/products/view/products_view.dart';
import 'package:pos/features/stock/controller/stock_ctrl.dart';
import 'package:pos/main.export.dart';
import 'package:sliver_tools/sliver_tools.dart';

const _headings = [
  ('id', 10.0),
  ('Name', double.nan),
  ('Warehouse', 200.0),
  ('Stock', 200.0),
  ('Pricing', 200.0),
  ('Action', 200.0),
];

class StockView extends HookConsumerWidget {
  const StockView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productList = ref.watch(productsCtrlProvider);
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
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SizedBox(
            width: 800,
            height: context.height,
            child: CustomScrollView(
              slivers: [
                MultiSliver(
                  children: [
                    for (final product in mockStock) _ProductSection(model: product),
                    SizedBox(height: MediaQuery.of(context).viewPadding.bottom),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),

      // productList.when(
      //   loading: () => const Loading(),
      //   error: (e, s) => ErrorView(e, s, prov: staffsCtrlProvider),
      //   data: (products) {
      //     return CustomScrollView(
      //       slivers: [
      //         MultiSliver(
      //           children: [
      //             for (final product in products) _ProductSection(model: product),
      //             SizedBox(height: MediaQuery.of(context).viewPadding.bottom),
      //           ],
      //         ),
      //       ],
      //     );
      //   },
      // ),
    );
  }

  // Widget _priceCellBuilder(Product product) => Builder(
  //   builder: (context) {
  //     final stock = product.stock.firstOrNull;
  //     return Column(
  //       spacing: Insets.xs,
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       mainAxisSize: MainAxisSize.min,
  //       children: [
  //         OverflowMarquee(child: Text('Purchase: ${stock?.purchasePrice.toString() ?? '--'}')),
  //         OverflowMarquee(child: Text('Sale: ${stock?.salesPrice.toString() ?? '--'}')),
  //         OverflowMarquee(child: Text('Wholesale: ${stock?.wholesalePrice.toString() ?? '--'}')),
  //         OverflowMarquee(child: Text('Dealer: ${stock?.dealerPrice.toString() ?? '--'}')),
  //       ],
  //     );
  //   },
  // );
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
                        right: stock.purchasePrice.toString(),
                        spaced: false,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        styleBuilder: (_, _) => (context.text.muted, context.text.small),
                      ),
                      SpacedText(
                        left: 'Sale',
                        right: stock.salesPrice.toString(),
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
                        left: 'Wholesale',
                        right: stock.wholesalePrice.toString(),
                        spaced: false,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        styleBuilder: (_, _) => (context.text.muted, context.text.small),
                      ),
                      SpacedText(
                        left: 'Dealer',
                        right: stock.dealerPrice.toString(),
                        spaced: false,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        styleBuilder: (_, _) => (context.text.muted, context.text.small),
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
        child: ProductsView.nameCellBuilder(product, 0, 40),
      ),
    );
  }
}
