import 'package:pos/main.export.dart';

class StockSelectionDialog extends ConsumerWidget {
  const StockSelectionDialog({super.key, required this.product, required this.stocks, required this.detailIds});

  final Product product;
  final List<Stock> stocks;
  final List<String> detailIds;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ShadDialog(
      title: Text('Select another stock', style: context.text.lead),
      scrollable: true,
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: Insets.med,
          mainAxisSpacing: Insets.med,
          mainAxisExtent: 110,
        ),
        itemCount: stocks.length,
        shrinkWrap: true,
        itemBuilder: (BuildContext context, int index) {
          final stock = stocks[index];
          return StockInfoTile(stock: stock, product: product, onSelect: () => context.nPop(stock));
        },
      ),
    );
  }
}

class StockInfoTile extends HookWidget {
  const StockInfoTile({
    super.key,
    required this.stock,
    required this.product,
    required this.onSelect,
  });

  final Stock stock;
  final Product product;
  final Function() onSelect;

  @override
  Widget build(BuildContext context) {
    final isHover = useState(false);
    return ShadGestureDetector(
      cursor: SystemMouseCursors.click,
      onHoverChange: (value) => isHover.value = value,
      onTap: onSelect,
      child: Stack(
        children: [
          ShadDottedBorder(
            color: isHover.value ? context.colors.primary : context.colors.foreground.op4,
            strokeWidth: isHover.value ? 2 : 1,
            child: DecoContainer(
              alignment: Alignment.centerLeft,
              color: isHover.value ? context.colors.primary.op(0) : Colors.transparent,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(stock.purchasePrice.currency()),
                  const Gap(Insets.xs),
                  Text('${stock.quantity} ${product.unit?.name ?? ''}', style: context.text.lead),
                ],
              ),
            ),
          ),
          if (stock.warehouse != null)
            Positioned(
              right: 8,
              top: 8,
              child: ShadBadge.secondary(child: Text(stock.warehouse?.name ?? '', style: context.text.list)),
            ),
        ],
      ),
    );
  }
}
