import 'package:pos/features/auth/view/user_card.dart';
import 'package:pos/features/inventory_record/controller/inventory_record_ctrl.dart';
import 'package:pos/features/inventory_record/view/inventory_record_view.dart';
import 'package:pos/features/parties/controller/parties_ctrl.dart';
import 'package:pos/features/transactions/controller/transactions_ctrl.dart';
import 'package:pos/features/transactions/view/transactions_view.dart';
import 'package:pos/main.export.dart';

class PartyDetailsView extends HookConsumerWidget {
  const PartyDetailsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final id = context.param('id');

    final party = ref.watch(partyDetailsProvider(id));
    final trxLogsList = ref.watch(transactionsByPartiProvider(id));
    final orderList = ref.watch(recordsByPartiProvider(id));

    final tabValue = useState(true);

    return BaseBody(
      title: 'Party Details',
      // scrollable: true,
      body: party.when(
        loading: () => const Loading(),
        error: (e, s) => ErrorView(e, s, prov: partyDetailsProvider),
        data: (party) {
          if (party == null) return const ErrorDisplay('Product not found');
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
                    UserCard.parti(parti: party, imgSize: 100, showDue: true, direction: Axis.vertical),
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
