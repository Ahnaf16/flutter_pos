import 'package:pos/features/payment_accounts/controller/payment_accounts_ctrl.dart';
import 'package:pos/features/payment_accounts/view/account_add_dialog.dart';
import 'package:pos/main.export.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

const _headings = [('Name', double.nan), ('Amount', double.nan), ('Active', 200.0), ('Action', 200.0)];

class PaymentAccountsView extends HookConsumerWidget {
  const PaymentAccountsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productList = ref.watch(paymentAccountsCtrlProvider(false));

    return BaseBody(
      title: 'Payment Accounts',
      actions: [
        ShadButton(
          child: const Text('Add a account'),
          onPressed: () {
            showShadDialog(context: context, builder: (context) => const AccountAddDialog());
          },
        ),
      ],
      body: productList.when(
        loading: () => const Loading(),
        error: (e, s) => ErrorView(e, s, prov: paymentAccountsCtrlProvider),
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
                            () => showShadDialog(context: context, builder: (context) => AccountAddDialog(acc: data)),
                      ),
                      ShadButton.secondary(
                        size: ShadButtonSize.sm,
                        leading: const Icon(LuIcons.eye),
                        onPressed:
                            () => showShadDialog(context: context, builder: (context) => _AccountViewDialog(acc: data)),
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
              final ctrl = ref.read(paymentAccountsCtrlProvider(false).notifier);
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

class _AccountViewDialog extends HookConsumerWidget {
  const _AccountViewDialog({required this.acc});

  final PaymentAccount acc;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ShadDialog(
      title: const Text('Account'),
      description: Text('Details of ${acc.name}'),
      actions: [ShadButton.destructive(onPressed: () => context.nPop(), child: const Text('Cancel'))],
      child: Container(
        padding: Pads.padding(v: Insets.med),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: Insets.sm,
          children: [
            Row(
              spacing: Insets.med,
              children: [
                ShadBadge.raw(
                  variant: acc.isActive ? ShadBadgeVariant.primary : ShadBadgeVariant.destructive,
                  child: Text(acc.isActive ? 'Active' : 'Inactive'),
                ),
                ShadBadge(child: Text(acc.type.name.titleCase)),
              ],
            ),
            SpacedText(left: 'Name', right: acc.name, styleBuilder: (l, r) => (l, r.bold)),
            SpacedText(
              left: 'Amount',
              right: acc.amount.currency(),
              styleBuilder: (l, r) => (l, context.text.list),
              crossAxisAlignment: CrossAxisAlignment.center,
            ),
            if (acc.description != null)
              SpacedText(left: 'Description', right: acc.description!, styleBuilder: (l, r) => (l, context.text.muted)),

            Text('Custom info:', style: context.theme.decoration.labelStyle),
            for (final MapEntry(:key, :value) in acc.customInfo.entries)
              SpacedText(left: key, right: value, styleBuilder: (l, r) => (l, r.bold)),
          ],
        ),
      ),
    );
  }
}
