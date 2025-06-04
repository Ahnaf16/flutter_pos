import 'package:pos/features/inventory_record/controller/inventory_record_ctrl.dart';
import 'package:pos/features/inventory_record/view/inventory_record_view.dart';
import 'package:pos/features/parties/controller/parties_ctrl.dart';
import 'package:pos/features/transactions/controller/transactions_ctrl.dart';
import 'package:pos/features/transactions/view/transactions_view.dart';
import 'package:pos/main.export.dart';

class PartyDetailsView extends HookConsumerWidget {
  const PartyDetailsView({super.key, this.isCustomer = true});

  final bool isCustomer;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final id = context.param('id');

    final party = ref.watch(partyDetailsProvider(id));
    final trxLogsList = ref.watch(transactionsByPartiProvider(id)).maybeList();
    final invList = ref.watch(recordsByPartiProvider(id)).maybeList();

    final tabValue = useState(true);

    final typeName = isCustomer ? 'Customer' : 'Supplier';

    return BaseBody(
      title: '$typeName Details',
      body: party.when(
        loading: () => const Loading(),
        error: (e, s) => ErrorView(e, s, prov: partyDetailsProvider),
        data: (party) {
          if (party == null) return ErrorDisplay('No $typeName found');
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [
              IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  spacing: Insets.med,
                  children: [
                    Expanded(
                      child: ShadCard(
                        title: Text('$typeName details'),
                        childPadding: Pads.med('t'),
                        child: Row(
                          children: [
                            if (party.photo != null)
                              HostedImage.square(party.getPhoto, dimension: 80, radius: Corners.med),
                            Flexible(
                              child: Column(
                                spacing: Insets.xs,
                                children: [
                                  SpacedText(left: 'Name', right: party.name, style: context.text.list),
                                  SpacedText(left: 'Phone', right: party.phone, style: context.text.list),
                                  if (party.email != null)
                                    SpacedText(left: 'Email', right: party.email!, style: context.text.list),
                                  if (party.address != null)
                                    SpacedText(left: 'Address', right: party.address!, style: context.text.list),

                                  SpacedText(
                                    left: party.hasDue() ? 'Due' : 'Balance',
                                    right: party.due.abs().currency(),
                                    trailing: SmallButton(
                                      icon: LuIcons.pen,
                                      onPressed: () {
                                        showShadDialog(
                                          context: context,
                                          builder: (context) => PartyBalanceDialog(party: party),
                                        );
                                      },
                                    ),
                                    style: context.text.lead,
                                    styleBuilder: (l, r) {
                                      return (l, r.bold.textColor(party.hasDue() ? Colors.red : Colors.green));
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    Expanded(
                      child: ShadCard(
                        title: const Text('Invoice summary'),
                        childPadding: Pads.med('t'),
                        child: Column(
                          children: [
                            SpacedText(left: 'Total Orders', right: '${invList.length}', style: context.text.list),
                            SpacedText(
                              left: 'Total Returns',
                              right: '${invList.where((e) => e.status.isReturned).length}',
                              style: context.text.list,
                            ),
                            SpacedText(
                              left: party.isCustomer ? 'Total bought' : 'Total sold',
                              right: invList
                                  .whereNot((e) => e.status.isReturned)
                                  .map((e) => e.paidAmount)
                                  .sum
                                  .currency(),
                              style: context.text.list,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Gap(Insets.med),
              ShadTabs<bool>(
                value: tabValue.value,
                onChanged: (value) => tabValue.set(value),
                scrollable: true,
                tabs: const [
                  ShadTab(value: true, child: Text('Recent Invoices')),
                  ShadTab(value: false, child: Text('Recent Transactions')),
                ],
              ),
              if (tabValue.value)
                Expanded(
                  child: RecordTable(inventories: invList.takeFirst(10), excludes: const ['Parti'], actionSpread: true),
                )
              else
                Expanded(
                  child: TrxTable(logs: trxLogsList.takeFirst(10), excludes: const ['To', 'From']),
                ),
            ],
          );
        },
      ),
    );
  }
}

class PartyBalanceDialog extends HookConsumerWidget {
  const PartyBalanceDialog({super.key, required this.party});

  final Party party;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dueCtrl = useTextEditingController();
    final noteCtrl = useTextEditingController();

    final due = useState(0.0);
    void listener() => due.set(double.tryParse(dueCtrl.text) ?? 0);

    useEffect(() {
      dueCtrl.addListener(listener);
      return () {
        dueCtrl.removeListener(listener);
      };
    });

    final totalDue = party.due + due.value;

    return ShadDialog(
      title: const Text('Update Due'),
      description: Row(
        spacing: Insets.sm,
        children: [
          Text('Update ${party.name}\'s Due'),
          ShadBadge.outline(child: Text(party.type.name)),
        ],
      ),

      actions: [
        ShadButton.destructive(onPressed: () => context.nPop(), child: const Text('Cancel')),
        SubmitButton(
          onPressed: (l) async {
            final ctrl = ref.read(partiesCtrlProvider(party.isCustomer).notifier);
            l.truthy();
            final result = await ctrl.updatePartyDue(party, due.value, noteCtrl.text);
            l.falsey();

            if (context.mounted) {
              result.showToast(context);
              if (result.success) context.nPop();
            }
          },
          child: const Text('Update'),
        ),
      ],
      child: Container(
        padding: Pads.padding(v: Insets.med),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: Insets.sm,
          children: [
            Text.rich(
              TextSpan(
                children: [
                  TextSpan(text: 'Current ${party.due > 0 ? 'Due' : 'Balance'}: '),
                  TextSpan(
                    text: party.due.abs().currency(),
                    style: context.text.list.textColor(party.due > 0 ? context.colors.destructive : Colors.green),
                  ),
                ],
              ),
              style: context.text.list,
            ),
            Text.rich(
              TextSpan(
                children: [
                  TextSpan(text: 'Updated ${totalDue > 0 ? 'Due' : 'Balance'}:  '),
                  TextSpan(
                    text: totalDue.abs().currency(),
                    style: context.text.list.textColor(totalDue > 0 ? context.colors.destructive : Colors.green),
                  ),
                ],
              ),
              style: context.text.list,
            ),
            ShadTextField(
              controller: dueCtrl,
              label: 'Balance/Due',
              isRequired: true,
              helperText: 'Use (-) to add balance and (+) for due',
              numeric: true,
              numericSymbol: true,
            ),

            ShadTextAreaField(controller: noteCtrl, label: 'Note'),
          ],
        ),
      ),
    );
  }
}
