import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:pos/features/payment_accounts/controller/payment_accounts_ctrl.dart';
import 'package:pos/features/staffs/controller/staffs_ctrl.dart';
import 'package:pos/main.export.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

const _headings = [('Name', double.nan), ('Amount', double.nan), ('Active', 200.0), ('Action', 200.0)];

class PaymentAccountsView extends HookConsumerWidget {
  const PaymentAccountsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productList = ref.watch(paymentAccountsCtrlProvider);

    return BaseBody(
      title: 'Payment Accounts',
      actions: [
        ShadButton(
          child: const Text('Add a account'),
          onPressed: () {
            showShadDialog(context: context, builder: (context) => const _AccountAddDialog());
          },
        ),
      ],
      body: productList.when(
        loading: () => const Loading(),
        error: (e, s) => ErrorView(e, s, prov: staffsCtrlProvider),
        data: (products) {
          return DataTableBuilder<PaymentAccount, (String, double)>(
            rowHeight: 70,
            items: products,
            headings: _headings,
            headingBuilder: (heading) {
              return GridColumn(
                columnName: heading.$1,
                columnWidthMode: ColumnWidthMode.fill,
                maximumWidth: heading.$2,
                minimumWidth: 200,
                label: Container(
                  padding: Pads.med(),
                  alignment: heading.$1 == 'Action' ? Alignment.centerRight : Alignment.centerLeft,
                  child: Text(heading.$1),
                ),
              );
            },
            cellAlignment: Alignment.centerLeft,
            cellBuilder: (data, head) {
              return switch (head.$1) {
                'Name' => DataGridCell(
                  columnName: head.$1,
                  value: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(data.name),
                      if (data.description != null) Text(data.description!, style: context.text.muted, maxLines: 1),
                    ],
                  ),
                ),
                'Amount' => DataGridCell(columnName: head.$1, value: Text(data.amount.currency())),

                'Active' => DataGridCell(columnName: head.$1, value: _buildActiveCell(data)),

                'Action' => DataGridCell(
                  columnName: head.$1,
                  value: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      ShadButton.secondary(
                        size: ShadButtonSize.sm,
                        leading: const Icon(LuIcons.pen),
                        onPressed:
                            () => showShadDialog(context: context, builder: (context) => _AccountAddDialog(acc: data)),
                      ),
                    ],
                  ),
                ),
                _ => DataGridCell(columnName: head.$1, value: Text(data.toString())),
              };
            },
          );
        },
      ),
    );
  }

  Widget _buildActiveCell(PaymentAccount acc) {
    return HookConsumer(
      builder: (context, ref, c) {
        final loading = useState(false);
        if (loading.value) return const Loading(center: false);
        return ShadSwitch(
          value: acc.isActive,
          onChanged: (v) async {
            try {
              final ctrl = ref.read(paymentAccountsCtrlProvider.notifier);
              loading.truthy();
              await ctrl.toggleEnable(v, acc);
              loading.falsey();
            } catch (e) {
              loading.falsey();
            }
          },
        );
      },
    );
  }
}

class _AccountAddDialog extends HookConsumerWidget {
  const _AccountAddDialog({this.acc});

  final PaymentAccount? acc;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formKey = useMemoized(GlobalKey<FormBuilderState>.new);
    final actionTxt = acc == null ? 'Add' : 'Update';
    return ShadDialog(
      title: Text('$actionTxt Unit'),
      description: Text(acc == null ? 'Fill the form to add a new account' : 'Update the form for ${acc!.name}'),
      actions: [
        ShadButton.destructive(onPressed: () => context.nPop(), child: const Text('Cancel')),
        SubmitButton(
          onPressed: (l) async {
            final state = formKey.currentState!;
            if (!state.saveAndValidate()) return;
            final data = state.value;

            final ctrl = ref.read(paymentAccountsCtrlProvider.notifier);
            (bool, String)? result;

            if (acc == null) {
              l.truthy();
              result = await ctrl.createUnit(data);
              l.falsey();
            } else {
              final updated = acc?.marge(data);
              if (updated == null) return;
              l.truthy();
              result = await ctrl.updateUnit(updated);
              l.falsey();
            }

            if (result case final Result r) {
              if (!context.mounted) return;
              r.showToast(context);
              if (r.success) context.pop();
            }
          },
          child: Text(actionTxt),
        ),
      ],
      child: Container(
        padding: Pads.padding(v: Insets.med),
        child: FormBuilder(
          key: formKey,
          initialValue: acc?.toMap() ?? {},
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: Insets.med,
            children: [
              const ShadField(name: 'name', label: 'Name', isRequired: true),
              const ShadField(name: 'description', label: 'description'),
              if (acc == null) const ShadField(name: 'amount', label: 'initial amount'),
            ],
          ),
        ),
      ),
    );
  }
}
