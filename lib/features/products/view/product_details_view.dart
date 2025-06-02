import 'package:pos/features/inventory_record/controller/inventory_record_ctrl.dart';
import 'package:pos/features/products/controller/products_ctrl.dart';
import 'package:pos/main.export.dart';

class ProductDetailsView extends ConsumerWidget {
  const ProductDetailsView({super.key});

  @override
  Widget build(BuildContext context, ref) {
    final id = context.param('id');
    final product = ref.watch(productDetailsProvider(id));
    final invDetails = ref.watch(recordDetailsByProductProvider(id)).maybeList();
    final sales = invDetails.where((e) => e.record?.type.isSale ?? false).toList();
    final purchases = invDetails.where((e) => e.record?.type.isPurchase ?? false).toList();

    return BaseBody(
      title: 'Product Details',
      alignment: Alignment.topLeft,
      actions: [
        if (id != null)
          ShadButton(
            child: const Text('Update'),
            onPressed: () {
              RPaths.editProduct(id).pushNamed(context);
            },
          ),
        if (!context.layout.isDesktop)
          ShadIconButton.outline(
            icon: const Icon(LuIcons.menu),
            onPressed: () {
              showShadSheet(
                context: context,
                side: ShadSheetSide.right,
                builder: (context) => ShadSheet(
                  title: const Text('Records'),
                  closeIconData: LuIcons.x,
                  constraints: const BoxConstraints(maxWidth: 500),
                  padding: Pads.padding(h: Insets.med, v: Insets.lg),
                  child: _InvDetails(
                    sales: sales,
                    purchases: purchases,
                    noBorder: true,
                  ),
                ),
              );
            },
          ),
      ],
      body: product.when(
        loading: () => const Loading(),
        error: (e, s) => ErrorView(e, s, prov: productDetailsProvider),
        data: (product) {
          if (product == null) return const ErrorDisplay('Product not found');
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: Insets.med,
            children: [
              Expanded(
                flex: 2,
                child: ShadCard(
                  height: context.layout.isDesktop ? double.infinity : null,
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          spacing: Insets.med,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ShadCard(
                              expanded: false,
                              child: HostedImage.square(product.getPhoto(35), dimension: 150, radius: Corners.med),
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
                                    style: context.text.muted.textHeight(1),
                                  ),
                                  Text(
                                    'Created At: ${product.createdAt.formatDate()}',
                                    style: context.text.muted.size(12).textHeight(1),
                                  ),
                                  Row(
                                    spacing: Insets.sm,
                                    children: [
                                      ShadBadge.raw(
                                        variant: product.quantity <= 0
                                            ? ShadBadgeVariant.destructive
                                            : ShadBadgeVariant.secondary,
                                        child: Text('${product.quantity}${product.unitName}'),
                                      ),
                                      ShadBadge.raw(
                                        variant: product.nonEmptyStocks().isEmpty
                                            ? ShadBadgeVariant.destructive
                                            : ShadBadgeVariant.secondary,
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

                        if (product.nonEmptyStocks().isEmpty)
                          const EmptyWidget('No Stock found')
                        else
                          ShadAccordion<int>(
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
                                    return StockTile(stock: stock, unit: product.unitName);
                                  },
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                ),
              ),
              if (context.layout.isDesktop)
                Expanded(
                  child: _InvDetails(sales: sales, purchases: purchases),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _InvDetails extends StatelessWidget {
  const _InvDetails({
    required this.sales,
    required this.purchases,
    this.noBorder = false,
  });

  final List<InventoryDetails> sales;
  final List<InventoryDetails> purchases;
  final bool noBorder;

  @override
  Widget build(BuildContext context) {
    return ShadCard(
      height: context.layout.isDesktop ? double.infinity : null,
      border: noBorder ? const Border() : null,
      shadows: noBorder ? [] : null,
      child: ShadTabs<RecordType>(
        value: RecordType.sale,
        tabs: [
          for (final type in RecordType.values)
            if ((type.isSale ? sales.length : purchases.length) == 0)
              ShadTab(
                value: type,
                content: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    EmptyWidget('No ${type.name.titleCase} found'),
                  ],
                ),
                child: Text(type.name.titleCase),
              )
            else
              ShadTab(
                value: type,
                content: ListView.separated(
                  shrinkWrap: true,
                  itemCount: type.isSale ? sales.length : purchases.length,
                  separatorBuilder: (_, _) => const Gap(Insets.sm),
                  itemBuilder: (context, index) {
                    final data = type.isSale ? sales[index] : purchases[index];
                    return ShadCard(
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              spacing: Insets.med,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text.rich(
                                        TextSpan(
                                          text: '${data.record?.invoiceNo ?? '--'} ',
                                          children: [
                                            WidgetSpan(
                                              child: SmallButton(
                                                icon: LuIcons.arrowUpRight,
                                                onPressed: () {
                                                  if (type.isSale) {
                                                    RPaths.saleDetails(data.record!.id).pushNamed(context);
                                                  } else {
                                                    RPaths.purchaseDetails(
                                                      data.record!.id,
                                                    ).pushNamed(context);
                                                  }
                                                },
                                              ),
                                            ),
                                          ],
                                        ),

                                        maxLines: 1,
                                        style: context.text.p.primary(context),
                                      ),
                                    ),
                                    Expanded(
                                      child: Text.rich(
                                        TextSpan(
                                          text: '${data.record?.getParti.name ?? '--'} ',
                                          children: [
                                            if (data.record?.getParti.isWalkIn == false)
                                              WidgetSpan(
                                                child: SmallButton(
                                                  icon: LuIcons.arrowUpRight,
                                                  onPressed: () {
                                                    final party = data.record?.getParti;
                                                    if (party == null) return;

                                                    if (party.isCustomer) {
                                                      RPaths.customerDetails(party.id).pushNamed(context);
                                                    } else {
                                                      RPaths.supplierDetails(party.id).pushNamed(context);
                                                    }
                                                  },
                                                ),
                                              ),
                                          ],
                                        ),
                                        maxLines: 1,
                                        style: context.text.p,
                                      ),
                                    ),
                                  ],
                                ),
                                Wrap(
                                  spacing: Insets.med,
                                  runSpacing: Insets.sm,
                                  children: [
                                    if (data.record?.account != null)
                                      ShadBadge(child: Text(data.record?.account?.name ?? '--')),
                                    ShadBadge.secondary(
                                      child: Text(data.record?.status.name ?? '--'),
                                    ).colored(data.record?.status.color ?? context.colors.destructive),
                                    ShadBadge.secondary(
                                      child: Text('${data.quantity} ${data.product.unitName}'),
                                    ),
                                    ShadBadge.secondary(
                                      child: Text(data.stock.warehouse?.name ?? '--'),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            spacing: Insets.med,
                            children: [
                              Text(data.record?.paidAmount.currency() ?? '--'),
                              Text(data.createdDate.formatDate()),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
                child: Text(type.name.titleCase),
              ),
        ],
      ),
    );
  }
}

class StockTile extends StatelessWidget {
  const StockTile({
    super.key,
    required this.stock,
    required this.unit,
  });

  final Stock stock;
  final String unit;

  @override
  Widget build(BuildContext context) {
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
                '${stock.quantity} $unit',
                style: context.text.list.textColor(
                  stock.quantity > 0 ? Colors.green : Colors.red,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
