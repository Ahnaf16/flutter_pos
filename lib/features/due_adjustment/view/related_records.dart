import 'package:pos/features/inventory_record/controller/inventory_record_ctrl.dart';
import 'package:pos/main.export.dart';

class RelatedRecords extends ConsumerWidget {
  const RelatedRecords({
    super.key,
    required this.party,
    this.unpaid = false,
  });
  final Party party;
  final bool unpaid;

  @override
  Widget build(BuildContext context, ref) {
    final inventoryList = ref.watch(recordsByPartiProvider(party.id));

    return ShadCard(
      title: Text(unpaid ? 'Unpaid/Partial invoices' : 'Invoices', style: context.text.p),
      height: context.layout.isDesktop ? double.maxFinite : null,
      childPadding: Pads.med('t'),
      child: inventoryList.when(
        loading: () => const Loading(),
        error: (e, s) => ErrorView(e, s, prov: inventoryCtrlProvider),
        data: (inventories) {
          if (unpaid) {
            inventories = inventories.where((e) => e.status.isUnpaid || e.status.isPartial).toList();
          }
          if (inventories.isEmpty) return const EmptyWidget('No Invoice Found');

          return ListView.separated(
            shrinkWrap: true,
            itemCount: inventories.length,
            separatorBuilder: (_, _) => const Gap(Insets.med),
            itemBuilder: (BuildContext context, int index) {
              final rec = inventories[index];
              return _InvCard(
                rec: rec,
                index: index,
              );
            },
          );
        },
      ),
    );
  }
}

class _InvCard extends HookWidget {
  const _InvCard({
    required this.rec,
    required this.index,
  });

  final InventoryRecord rec;
  final int index;

  @override
  Widget build(BuildContext context) {
    final hovering = useState(false);
    return MouseRegion(
      onEnter: (event) => hovering.truthy(),
      onExit: (event) => hovering.falsey(),

      child: Stack(
        children: [
          ShadCard(
            padding: Pads.padding(v: Insets.med, h: Insets.sm),
            child: Row(
              spacing: Insets.med,
              children: [
                Text((index + 1).toString()),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      for (final p in rec.details.takeFirst(2))
                        Text(
                          p.product.name.showUntil(15),
                          style: context.text.small,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      if (rec.details.length > 2)
                        Text('+ ${rec.details.length - 2} more', style: context.text.muted.size(12)),
                    ],
                  ),
                ),
                Expanded(
                  flex: context.layout.isTablet ? 2 : 1,
                  child: Flex(
                    direction: context.layout.isTablet ? Axis.horizontal : Axis.vertical,
                    spacing: Insets.xs,
                    children: [
                      SpacedText(
                        left: 'Paid',
                        right: rec.paidAmount.currency(),
                        crossAxisAlignment: CrossAxisAlignment.center,
                        styleBuilder: (l, r) => (context.text.muted, r.bold),
                      ).conditionalExpanded(context.layout.isTablet),

                      SpacedText(
                        left: 'Total',
                        right: rec.total.currency(),
                        crossAxisAlignment: CrossAxisAlignment.center,
                        styleBuilder: (l, r) => (context.text.muted, r.bold),
                      ).conditionalExpanded(context.layout.isTablet),
                      if (rec.due != 0)
                        SpacedText(
                          left: rec.hasDue ? 'Due' : 'Extra',
                          right: rec.due.abs().currency(),
                          crossAxisAlignment: CrossAxisAlignment.center,
                          styleBuilder: (l, r) =>
                              (context.text.muted, r.bold.textColor(rec.hasDue ? Colors.red : Colors.green)),
                        ).conditionalExpanded(context.layout.isTablet),
                    ],
                  ),
                ),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    spacing: Insets.xs,
                    children: [
                      ShadBadge(child: Text(rec.status.name)).colored(rec.status.color),
                      Text(rec.date.formatDate()),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (hovering.value)
            Positioned(
              top: 3,
              right: 3,
              child: SmallButton(
                icon: LuIcons.squareArrowOutUpRight,
                onPressed: () => RPaths.saleDetails(rec.id).pushNamed(context),
              ),
            ),
        ],
      ),
    );
  }
}
