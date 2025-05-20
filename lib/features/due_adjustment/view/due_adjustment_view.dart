import 'package:pos/features/parties/controller/parties_ctrl.dart';
import 'package:pos/main.export.dart';

class DueAdjustmentView extends HookConsumerWidget {
  const DueAdjustmentView({super.key, required this.isCustomer});
  final bool isCustomer;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final partiList = ref.watch(partiesCtrlProvider(isCustomer));
    // final accountList = ref.watch(paymentAccountsCtrlProvider());

    final title = isCustomer ? 'Customer' : 'Supplier';
    return BaseBody(
      title: title,
      scrollable: true,
      alignment: Alignment.topLeft,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LimitedWidthBox(
            maxWidth: 500,
            center: false,
            child: partiList.when(
              loading: () => const Loading(),
              error: (e, s) => ErrorView(e, s, prov: partiesCtrlProvider),
              data: (parties) {
                return ShadSelectField<Party>(
                  hintText: 'Select $title',
                  optionBuilder: (_, v, i) => ShadOption(value: v, child: Text(v.name)),
                  options: parties,
                  selectedBuilder: (context, value) => Text(value.name),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
