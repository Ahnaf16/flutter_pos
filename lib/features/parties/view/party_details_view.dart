import 'package:pos/features/auth/view/user_card.dart';
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
    final trxLogsList = ref.watch(transactionsByPartiProvider(id));
    final orderList = ref.watch(recordsByPartiProvider(id));

    final tabValue = useState(true);

    return BaseBody(
      title: '${isCustomer ? 'Customer' : 'Supplier'} Details',
      body: party.when(
        loading: () => const Loading(),
        error: (e, s) => ErrorView(e, s, prov: partyDetailsProvider),
        data: (party) {
          if (party == null) return ErrorDisplay('No ${isCustomer ? 'Customer' : 'Supplier'} found');
          return Row(
            spacing: Insets.med,
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ShadTabs<bool>(
                      value: tabValue.value,
                      onChanged: (value) => tabValue.set(value),
                      scrollable: true,
                      tabs: const [
                        ShadTab(value: true, child: Text('Orders')),
                        ShadTab(value: false, child: Text('Transactions')),
                      ],
                    ),
                    if (tabValue.value)
                      Expanded(
                        child: orderList.when(
                          loading: () => const Loading(),
                          error: (e, s) => ErrorView(e, s, prov: transactionLogCtrlProvider),
                          data: (rec) {
                            return RecordTable(inventories: rec, excludes: const ['Parti']);
                          },
                        ),
                      )
                    else
                      Expanded(
                        child: trxLogsList.when(
                          loading: () => const Loading(),
                          error: (e, s) => ErrorView(e, s, prov: transactionLogCtrlProvider),
                          data: (logs) {
                            return TrxTable(logs: logs, excludes: const ['To', 'From']);
                          },
                        ),
                      ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  spacing: Insets.med,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Customer details', style: context.text.list),
                    UserCard.parti(
                      parti: party,
                      imgSize: 100,
                      showDue: true,
                      direction: Axis.vertical,
                      onEdit: () {
                        showShadDialog(
                          context: context,
                          builder: (context) => PartyBalanceDialog(party: party),
                        );
                      },
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

class PartyBalanceDialog extends HookConsumerWidget {
  const PartyBalanceDialog({super.key, required this.party});

  final Party party;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dueCtrl = useTextEditingController(text: party.due.toString());
    final noteCtrl = useTextEditingController();

    final due = useState(party.due);
    void listener() => due.set(double.tryParse(dueCtrl.text) ?? 0);

    useEffect(() {
      dueCtrl.addListener(listener);
      return () {
        dueCtrl.removeListener(listener);
      };
    });

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
                  TextSpan(text: 'Current ${due.value > 0 ? 'Due' : 'Balance'}: '),
                  TextSpan(
                    text: due.value.abs().currency(),
                    style: context.text.list.textColor(due.value > 0 ? context.colors.destructive : Colors.green),
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
