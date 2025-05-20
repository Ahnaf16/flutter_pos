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
    return BaseBody(
      title: 'Inventory Record',
      scrollable: true,
      alignment: Alignment.topLeft,
      body: details.when(
        loading: () => const Loading(),
        error: (e, s) => ErrorView(e, s, prov: recordDetailsProvider),
        data: (rec) {
          if (rec == null) return const ErrorDisplay('No record found');
          final InventoryRecord(:getParti, :details, :amount, :account, returnRecord: returned) = rec;
          return Column(
            spacing: Insets.med,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
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
                        showShadDialog(context: context, builder: (context) => ReturnRecordDialog(inventory: rec));
                      },
                    ),
                ],
              ),

              IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  spacing: Insets.med,
                  children: [
                    Expanded(
                      flex: 2,
                      child: Column(
                        spacing: Insets.med,
                        children: [
                          ShadCard(
                            title: Text('Product summary (${details.length})'),
                            childSeparator: ShadSeparator.horizontal(margin: Pads.med('tb')),
                            child: Column(
                              spacing: Insets.med,
                              children: [
                                for (final d in details)
                                  Row(
                                    spacing: Insets.lg,

                                    children: [
                                      Text((details.indexWhere((e) => e.id == d.id) + 1).toString()),
                                      Expanded(
                                        flex: 2,
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(d.product.name, style: context.text.list),
                                            if (d.product.sku != null) Text(d.product.sku!, style: context.text.muted),
                                          ],
                                        ),
                                      ),

                                      Expanded(
                                        child: CenterLeft(
                                          child: Text(
                                            'Price: ${d.price.currency()} x(${d.quantity})',
                                            style: context.text.list,
                                          ),
                                        ),
                                      ),

                                      Expanded(
                                        child: CenterRight(
                                          child: Text(
                                            'Total Price: ${(d.price * d.quantity).currency()}',
                                            style: context.text.list,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                              ],
                            ),
                          ),
                          IntrinsicHeight(
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              spacing: Insets.med,
                              children: [
                                Expanded(
                                  child: ShadCard(
                                    title: const Text('Order Summary'),
                                    childSeparator: ShadSeparator.horizontal(margin: Pads.med('tb')),
                                    child: Column(
                                      spacing: Insets.med,
                                      children: [
                                        SpacedText(
                                          left: 'Account',
                                          right: account?.name.titleCase ?? 'N/A',
                                          builder: (v) => ShadBadge.secondary(child: Text(v)),
                                        ),
                                        SpacedText(
                                          left: 'Status',
                                          right: rec.status.name.titleCase,
                                          builder: (v) => ShadBadge(child: Text(v)),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                if (returned != null)
                                  Expanded(
                                    child: ShadCard(
                                      title: const Text('Return Summary'),
                                      childSeparator: ShadSeparator.horizontal(margin: Pads.med('tb')),
                                      child: Column(
                                        spacing: Insets.med,
                                        children: [
                                          SpacedText(
                                            left: 'Return date',
                                            right: returned.returnDate.formatDate('MMM dd, yyyy hh:mm a'),
                                          ),
                                          SpacedText(
                                            left: 'Return amount',
                                            right:
                                                (returned.deductedFromAccount + returned.deductedFromParty).currency(),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          ShadCard(
                            title: const Text('Billing Summary'),
                            childSeparator: ShadSeparator.horizontal(margin: Pads.med('tb')),
                            child: Column(
                              spacing: Insets.med,
                              children: [
                                SpacedText(left: 'Subtotal', right: rec.subtotal.currency()),
                                SpacedText(left: 'Discount', right: rec.discountString()),
                                SpacedText(left: 'Shipping', right: rec.shipping.currency()),
                                SpacedText(left: 'Vat', right: rec.vat.currency()),
                                SpacedText(left: 'Total', right: rec.total.currency(), style: context.text.large),
                                ShadSeparator.horizontal(margin: Pads.sm('b')),
                                SpacedText(left: 'paid amount', right: rec.amount.currency()),
                                SpacedText(
                                  left: rec.hasBalance ? 'Extra amount' : 'Due amount',
                                  right: rec.due.currency(),
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  trailing:
                                      rec.due == 0
                                          ? null
                                          : ShadTooltip(
                                            child: const Icon(LuIcons.info),
                                            builder: (context) {
                                              return Text(
                                                // TODO : check condition
                                                rec.hasBalance
                                                    ? 'Extra amount paid ${rec.type.isSale ? 'by customer' : 'to supplier'}.'
                                                    : 'Remaining amount to be paid ${rec.type.isSale ? 'by customer' : 'to supplier'}.',
                                              );
                                            },
                                          ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: UserCard.parti(
                        parti: getParti,
                        title: isSale ? 'Customer' : 'Supplier',
                        titleStyle: context.text.large.copyWith(color: context.colors.cardForeground),
                        childSeparator: ShadSeparator.horizontal(margin: Pads.med('tb')),
                        imgSize: 80,
                        showDue: !getParti.isWalkIn,
                        direction: Axis.vertical,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
