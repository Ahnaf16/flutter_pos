import 'package:pos/features/auth/view/user_card.dart';
import 'package:pos/features/inventory_record/controller/inventory_record_ctrl.dart';
import 'package:pos/features/inventory_record/view/inventory_record_view.dart';
import 'package:pos/features/inventory_record/view/local/inv_invoice_widget.dart';
import 'package:pos/features/settings/controller/settings_ctrl.dart';
import 'package:pos/main.export.dart';

class RecordDetailsView extends HookConsumerWidget {
  const RecordDetailsView({super.key, required this.isSale});
  final bool isSale;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final id = context.param('id');
    final details = ref.watch(recordDetailsProvider(id));
    final configData = ref.watch(configCtrlAsyncProvider);

    return details.when(
      loading: () => const Scaffold(body: Loading()),
      error: (e, s) => ErrorView(e, s, prov: recordDetailsProvider).withSF(),
      data: (rec) {
        if (rec == null) return const ErrorDisplay('No record found');
        final InventoryRecord(:getParti, :details, paidAmount: amount, :account, returnRecord: returned) = rec;
        return BaseBody(
          title: 'Inventory Record',
          scrollable: true,
          alignment: Alignment.topLeft,
          actions: [
            if (!context.layout.isDesktop)
              ShadIconButton.outline(
                icon: const Icon(LuIcons.menu),
                onPressed: () {
                  showShadSheet(
                    context: context,
                    side: ShadSheetSide.right,
                    builder: (context) => ShadSheet(
                      closeIconData: LuIcons.x,
                      constraints: const BoxConstraints(maxWidth: 500),
                      padding: Pads.padding(h: Insets.med, v: Insets.lg),
                      child: _PayLogs(
                        isSale: isSale,
                        logs: rec.paymentLogs,
                        noBorder: true,
                      ),
                    ),
                  );
                },
              ),
          ],
          body: configData.when(
            loading: () => const Loading(),
            error: (e, s) => ErrorView(e, s, prov: configCtrlAsyncProvider),
            data: (config) {
              return Column(
                spacing: Insets.med,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _Header(rec),

                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: Insets.med,
                    children: [
                      Expanded(
                        flex: 3,
                        child: Column(
                          spacing: Insets.med,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _Summaries(rec: rec, shop: config.shop),
                            _ProductSummary(details: details),
                            _OrderSummaryTable(rec),
                            _PayTable(rec),

                            const Gap(Insets.xl),
                          ],
                        ),
                      ),
                      if (rec.paymentLogs.isNotEmpty && context.layout.isDesktop)
                        Expanded(
                          child: _PayLogs(isSale: isSale, logs: rec.paymentLogs),
                        ),
                    ],
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }
}

class _PayTable extends StatelessWidget {
  const _PayTable(this.rec);
  final InventoryRecord rec;

  @override
  Widget build(BuildContext context) {
    final isMobile = context.layout.isMobile;
    return TopRight(
      child: Container(
        constraints: BoxConstraints(maxHeight: 100, maxWidth: isMobile ? double.infinity : 500),
        child: ShadCard(
          padding: Pads.zero,
          child: ShadTable.list(
            columnSpanExtent: (index) {
              if (index == 0) return const FractionalSpanExtent(.3);
              return const FractionalSpanExtent(.7);
            },

            children: [
              [
                const ShadTableCell(child: Text('Paid amount')),
                ShadTableCell(
                  alignment: Alignment.centerRight,
                  style: context.text.list.bold,
                  child: Text(rec.paidAmount.currency()),
                ),
              ],
              [
                ShadTableCell(
                  child: Text.rich(
                    TextSpan(
                      text: rec.hasDue ? 'Due amount  ' : 'Extra amount  ',
                      children: [
                        if (rec.due != 0)
                          WidgetSpan(
                            alignment: PlaceholderAlignment.middle,
                            child: const Icon(LuIcons.info).toolTip(
                              rec.hasBalance
                                  ? 'Extra amount paid ${rec.type.isSale ? 'by customer' : 'to supplier'}.'
                                  : 'Remaining amount to be paid ${rec.type.isSale ? 'by customer' : 'to supplier'}.',
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                ShadTableCell(
                  alignment: Alignment.centerRight,
                  style: context.text.p.bold.textColor(
                    rec.hasDue ? Colors.red : Colors.green,
                  ),
                  child: Text(rec.due.abs().currency()),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _OrderSummaryTable extends StatelessWidget {
  const _OrderSummaryTable(this.rec);
  final InventoryRecord rec;

  @override
  Widget build(BuildContext context) {
    final isMobile = context.layout.isMobile;
    return TopRight(
      child: Container(
        constraints: BoxConstraints(maxHeight: 242, maxWidth: isMobile ? double.infinity : 500),

        child: ShadCard(
          padding: Pads.zero,
          child: ShadTable.list(
            columnSpanExtent: (index) {
              if (index == 0) return const FractionalSpanExtent(.3);
              return const FractionalSpanExtent(.7);
            },

            footer: [
              ShadTableCell.footer(style: context.text.large, child: const Text('Total')),
              ShadTableCell.footer(
                alignment: Alignment.centerRight,
                style: context.text.large.primary(context),
                child: Text(rec.total.currency()),
              ),
            ],
            children: [
              [
                const ShadTableCell(child: Text('Subtotal')),
                ShadTableCell(
                  alignment: Alignment.centerRight,
                  style: context.text.p.bold,
                  child: Text(rec.subtotal.currency()),
                ),
              ],
              [
                const ShadTableCell(child: Text('Discount')),
                ShadTableCell(
                  alignment: Alignment.centerRight,
                  style: context.text.p.bold,
                  child: Text(rec.discountString()),
                ),
              ],
              [
                const ShadTableCell(child: Text('Shipping')),
                ShadTableCell(
                  alignment: Alignment.centerRight,
                  style: context.text.p.bold,
                  child: Text(rec.shipping.currency()),
                ),
              ],
              [
                const ShadTableCell(child: Text('Vat')),
                ShadTableCell(
                  alignment: Alignment.centerRight,
                  style: context.text.p.bold,
                  child: Text(rec.vat.currency()),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _ProductSummary extends StatelessWidget {
  const _ProductSummary({required this.details});

  final List<InventoryDetails> details;

  @override
  Widget build(BuildContext context) {
    return ShadCard(
      title: Text('Product summary (${details.length})'),
      childSeparator: ShadSeparator.horizontal(margin: Pads.med('tb')),
      child: Column(
        spacing: Insets.med,
        children: [
          Row(
            children: [
              Expanded(
                flex: 3,
                child: Text('Product', style: context.text.list.bold),
              ),
              Expanded(
                flex: 2,
                child: CenterLeft(child: Text('Unit Price', style: context.text.list.bold)),
              ),
              Expanded(
                flex: 2,
                child: CenterLeft(child: Text('Quantity', style: context.text.list.bold)),
              ),
              Expanded(
                child: CenterRight(child: Text('Total Price', style: context.text.list.bold)),
              ),
            ],
          ),
          for (final d in details)
            Row(
              spacing: Insets.lg,
              children: [
                Text((details.indexWhere((e) => e.id == d.id) + 1).toString()),
                Expanded(
                  flex: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text.rich(
                        TextSpan(
                          text: d.product.name,
                          children: [
                            WidgetSpan(
                              child: SmallButton(
                                icon: LuIcons.arrowUpRight,
                                onPressed: () {
                                  RPaths.productDetails(d.product.id).pushNamed(context);
                                },
                              ),
                            ),
                          ],
                        ),
                        style: context.text.list,
                      ),
                      Row(
                        spacing: Insets.med,
                        children: [
                          if (d.product.manufacturer != null) Text(d.product.manufacturer!, style: context.text.muted),

                          if (d.product.manufacturer != null && d.product.sku != null)
                            DecoContainer(
                              height: 5,
                              width: 5,
                              borderRadius: Corners.circle,
                              color: context.colors.primary,
                            ),
                          if (d.product.sku != null) Text(d.product.sku!, style: context.text.muted),
                        ],
                      ),
                    ],
                  ),
                ),

                Expanded(
                  flex: 2,
                  child: CenterLeft(
                    child: Text(
                      d.price.currency(),
                      style: context.text.list,
                    ),
                  ),
                ),

                Expanded(
                  flex: 2,
                  child: CenterLeft(
                    child: Text(
                      '${d.quantity}',
                      style: context.text.list,
                    ),
                  ),
                ),

                Expanded(
                  child: CenterRight(
                    child: Text(
                      (d.price * d.quantity).currency(),
                      style: context.text.list,
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

class _Summaries extends StatelessWidget {
  const _Summaries({required this.rec, required this.shop});

  final InventoryRecord rec;
  final ShopConfig shop;

  @override
  Widget build(BuildContext context) {
    final InventoryRecord(:getParti, :account, :type, returnRecord: returned) = rec;

    return IntrinsicHeight(
      child: Flex(
        direction: context.layout.isMobile ? Axis.vertical : Axis.horizontal,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: Insets.med,
        children: [
          _customer(getParti, type, context).conditionalExpanded(!context.layout.isMobile),
          _shop(type).conditionalExpanded(!context.layout.isMobile),
          _inv(account, returned).conditionalExpanded(!context.layout.isMobile),
        ],
      ),
    );
  }

  Widget _inv(PaymentAccount? account, ReturnRecord? returned) {
    return ShadCard(
      title: const Text('Invoice summary'),
      childSeparator: ShadSeparator.horizontal(margin: Pads.med('tb')),
      child: Column(
        spacing: Insets.med,
        children: [
          SpacedText(
            left: 'Payment account',
            right: account?.name.titleCase ?? 'N/A',
          ),
          SpacedText(
            left: 'Status',
            right: rec.status.name.titleCase,
            crossAxisAlignment: CrossAxisAlignment.center,
            builder: (v) => ShadBadge(child: Text(v)).colored(rec.status.color),
          ),
          if (returned != null) ...[
            SpacedText(
              left: 'Return date',
              right: returned.returnDate.formatDate('MMM dd, yyyy hh:mm a'),
            ),
            SpacedText(
              left: 'Return amount',
              right: (returned.adjustAccount + returned.adjustFromParty).currency(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _shop(RecordType type) {
    return ShadCard(
      title: Text(type.isSale ? 'Seller summary' : 'Buyer summary'),
      childSeparator: ShadSeparator.horizontal(margin: Pads.med('tb')),
      child: Column(
        spacing: Insets.med,
        children: [
          SpacedText(
            left: 'Name',
            right: rec.createdBy.name,
          ),
          SpacedText(
            left: 'Phone',
            right: rec.createdBy.phone,
          ),
          SpacedText(
            left: 'Shop name',
            right: shop.shopName ?? '--',
          ),
        ],
      ),
    );
  }

  Widget _customer(Party getParti, RecordType type, BuildContext context) {
    return UserCard.parti(
      parti: getParti,
      title: type.isSale ? 'Customer summary' : 'Supplier summary',
      titleStyle: context.text.large.copyWith(color: context.colors.cardForeground),
      childSeparator: ShadSeparator.horizontal(margin: Pads.med('tb')),
      imgSize: context.layout.isTablet ? 60 : 80,
      showDue: !getParti.isWalkIn,
    );
  }
}

class _Header extends ConsumerWidget {
  const _Header(this.rec);
  final InventoryRecord rec;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              spacing: Insets.med,
              children: [
                Text('Invoice: #${rec.invoiceNo}', style: context.text.lead),
                SmallButton(icon: LuIcons.copy, onPressed: () => Copier.copy(rec.invoiceNo)),
              ],
            ),
            Text(rec.date.formatDate('MMM dd, yyyy hh:mm a'), style: context.text.muted),
          ],
        ),
        const Spacer(),
        SubmitButton(
          leading: const Icon(LuIcons.printer),
          child: const Text('Print invoice'),
          onPressed: (l) async {
            l.truthy();
            final config = await ref.read(configCtrlAsyncProvider.future);
            l.falsey();
            if (!context.mounted) return;
            await showShadDialog(
              context: context,
              builder: (context) => InvInvoiceWidget(rec: rec, config: config),
            );
          },
        ),

        if (!rec.status.isReturned)
          ShadButton.destructive(
            leading: const Text('Return'),
            onPressed: () {
              showShadDialog(
                context: context,
                builder: (context) => ReturnRecordDialog(inventory: rec),
              );
            },
          ),
      ],
    );
  }
}

class _PayLogs extends StatelessWidget {
  const _PayLogs({required this.isSale, required this.logs, this.noBorder = false});

  final bool isSale;
  final List<PaymentLog> logs;
  final bool noBorder;

  @override
  Widget build(BuildContext context) {
    return ShadCard(
      border: noBorder ? const Border() : null,
      shadows: noBorder ? [] : null,
      padding: Pads.med('lrb'),
      child: ShadAccordion<int>(
        initialValue: 0,
        children: [
          ShadAccordionItem<int>(
            value: 0,
            title: Text('Payment Logs', style: context.text.large),
            separator: const Gap(0),
            underlineTitleOnHover: false,
            child: Column(
              spacing: Insets.med,
              children: [
                for (final log in logs)
                  ShadDottedBorder(
                    color: context.colors.foreground.op3,
                    child: SpacedText(
                      left: log.paymentDate.formatDate('MMM dd, yyyy hh:mm a'),
                      right: log.payAmount.currency(),
                      styleBuilder: (l, r) => (l, context.text.p.bold.success()),
                      crossAxisAlignment: CrossAxisAlignment.center,
                      spaced: true,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
