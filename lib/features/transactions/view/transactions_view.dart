import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:pos/features/auth/controller/auth_ctrl.dart';
import 'package:pos/features/filter/view/filter_bar.dart';
import 'package:pos/features/parties/controller/parties_ctrl.dart';
import 'package:pos/features/parties/view/party_name_builder.dart';
import 'package:pos/features/payment_accounts/controller/payment_accounts_ctrl.dart';
import 'package:pos/features/payment_accounts/view/local/account_name_builder.dart';
import 'package:pos/features/settings/controller/settings_ctrl.dart';
import 'package:pos/features/transactions/controller/transactions_ctrl.dart';
import 'package:pos/features/transactions/view/trx_report_view.dart';
import 'package:pos/main.export.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

part '_trx_add_dialog.dart';

const _headings = [
  TableHeading.positional('#', 50.0),
  TableHeading.positional('To'),
  TableHeading.positional('From'),
  TableHeading.positional('Amount', 300.0),
  TableHeading.positional('Account', 150.0, Alignment.center),
  TableHeading.positional('Type', 200.0, Alignment.center),
  TableHeading.positional('Date', 150.0, Alignment.center),
  TableHeading.positional('Action', 100.0, Alignment.centerRight),
];

class TransactionsView extends HookConsumerWidget {
  const TransactionsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trxList = ref.watch(transactionLogCtrlProvider);
    final trxCtrl = useCallback(() => ref.read(transactionLogCtrlProvider.notifier));

    final accountList = ref.watch(paymentAccountsCtrlProvider()).maybeList();

    return BaseBody(
      title: 'Transaction logs',
      actions: [
        ShadButton.outline(
          child: const Text('Generate Report'),
          onPressed: () {
            showShadDialog(
              context: context,
              builder: (context) => const TrxReportView(),
            );
          },
        ),
      ],
      body: Column(
        spacing: Insets.med,
        children: [
          FilterBar(
            types: TransactionType.values,
            accounts: accountList,
            onSearch: (q) => trxCtrl().search(q),
            onReset: () => trxCtrl().refresh(),
            allowDate: true,
            allowDateTo: true,
          ),
          Expanded(
            child: trxList.when(
              loading: () => const Loading(),
              error: (e, s) => ErrorView(e, s, prov: transactionLogCtrlProvider),
              data: (dues) {
                return TrxTable(logs: dues, showFooter: true);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class TrxTable extends StatelessWidget {
  const TrxTable({super.key, required this.logs, this.excludes = const [], this.showFooter = false});

  final List<TransactionLog> logs;
  final List<String> excludes;
  final bool showFooter;

  @override
  Widget build(BuildContext context) {
    final heads = _headings.where((e) => !excludes.contains(e.name)).toList();
    return DataTableBuilder<TransactionLog, TableHeading>(
      rowHeight: 120,
      items: logs,
      headings: heads,
      headingBuilderIndexed: (heading, i) {
        final alignment = heading.alignment;
        return GridColumn(
          columnName: heading.name,
          columnWidthMode: ColumnWidthMode.fill,
          maximumWidth: heading.max,
          minimumWidth: context.layout.isDesktop ? 100 : 200,
          label: Container(padding: Pads.med(), alignment: alignment, child: Text(heading.name)),
        );
      },
      cellAlignment: Alignment.centerLeft,
      cellAlignmentBuilder: (i) => heads.fromName(i).alignment,
      cellBuilderIndexed: (data, head, i) {
        final toName = data.effectiveTo.name;
        final toPhone = data.effectiveTo.phone;
        final fromName = data.effectiveFrom.name;
        final fromPhone = data.effectiveFrom.phone;

        return switch (head.name) {
          '#' => DataGridCell(columnName: head.name, value: Text((i + 1).toString())),
          'To' => DataGridCell(columnName: head.name, value: NameCellBuilder(toName, toPhone)),
          'From' => DataGridCell(columnName: head.name, value: NameCellBuilder(fromName, fromPhone)),
          'Amount' => DataGridCell(
            columnName: head.name,
            value: Text(data.amount.currency(), style: context.text.list),
          ),
          'Account' => DataGridCell(
            columnName: head.name,
            value: Column(
              spacing: Insets.xs,
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Row(),
                Text(data.account?.name.titleCase ?? '--', style: context.text.list),
                if (data.customInfo case {'pre': final pre}) SpacedText(left: 'Pre', right: pre),
                if (data.customInfo case {'post': final post}) SpacedText(left: 'Post', right: post),
              ],
            ),
          ),
          'Type' => DataGridCell(
            columnName: head.name,
            value: ShadBadge.secondary(child: Text(data.type.name.titleCase)).colored(data.type.color),
          ),
          'Date' => DataGridCell(
            columnName: head.name,
            value: Center(child: Text(data.date.formatDate())),
          ),
          'Action' => DataGridCell(
            columnName: head.name,
            value: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ShadButton.secondary(
                  size: ShadButtonSize.sm,
                  leading: const Icon(LuIcons.eye),
                  onPressed: () {
                    showShadDialog(
                      context: context,
                      builder: (context) => _TrxViewDialog(trx: data),
                    );
                  },
                ),
              ],
            ),
          ),
          _ => DataGridCell(columnName: head.name, value: Text(data.toString())),
        };
      },

      footer: DecoContainer(
        color: context.colors.border,
        padding: Pads.med(),
        height: 80,
        child: Row(
          spacing: Insets.xl,
          children: [
            SpacedText(
              left: 'Total in ',
              right: logs.where((e) => e.isIncome == true).map((e) => e.amount).sum.currency(),
              crossAxisAlignment: CrossAxisAlignment.center,
              useFlexible: false,
              style: context.text.list.primary(context),
              styleBuilder: (l, r) => (l, r.bold),
            ),
            const ShadSeparator.vertical(margin: Pads.zero, color: Colors.black),
            SpacedText(
              left: 'Total Out ',
              right: logs.where((e) => e.isIncome == false).map((e) => e.amount).sum.currency(),
              crossAxisAlignment: CrossAxisAlignment.center,
              useFlexible: false,
              style: context.text.list.error(context),
              styleBuilder: (l, r) => (l, r.bold),
            ),
            const ShadSeparator.vertical(margin: Pads.zero, color: Colors.black),
            SpacedText(
              left: 'Total Return ',
              right: logs.fromTypes([TransactionType.returned]).map((e) => e.amount).sum.currency(),
              crossAxisAlignment: CrossAxisAlignment.center,
              useFlexible: false,
              style: context.text.list.textColor(Colors.grey.shade600),
              styleBuilder: (l, r) => (l, r.bold),
            ),
          ],
        ),
      ),
    );
  }
}

class NameCellBuilder extends StatelessWidget {
  const NameCellBuilder(this.name, this.phone, {super.key});
  final String? name;
  final String? phone;
  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: Insets.xs,
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        OverflowMarquee(child: Text(name ?? '--', style: context.text.list)),
        if (phone != null) Text(phone ?? '--'),
      ],
    );
  }
}

class _TrxViewDialog extends HookConsumerWidget {
  const _TrxViewDialog({required this.trx});

  final TransactionLog trx;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ShadDialog(
      title: Text('${trx.type.name.titleCase} log'),
      description: Row(
        spacing: Insets.sm,
        children: [
          Text('Details of a ${trx.type.name}'),
          ShadBadge(child: Text(trx.type.name.titleCase)).colored(trx.type.color),
        ],
      ),

      actions: [ShadButton.destructive(onPressed: () => context.nPop(), child: const Text('Cancel'))],
      child: Container(
        padding: Pads.padding(v: Insets.med),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: Insets.med,
          children: [
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                spacing: Insets.med,
                children: [
                  Expanded(
                    child: ShadCard(
                      childPadding: Pads.sm('t'),
                      title: Text('From', style: context.text.list),
                      child: Column(
                        spacing: Insets.sm,
                        children: [
                          SpacedText(left: 'Name', right: trx.effectiveFrom.name ?? '--'),
                          if (trx.effectiveFrom.phone != null)
                            SpacedText(left: 'Phone', right: trx.effectiveFrom.phone ?? '--'),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: ShadCard(
                      childPadding: Pads.sm('t'),
                      title: Text('To', style: context.text.list),
                      child: Column(
                        spacing: Insets.sm,
                        children: [
                          SpacedText(left: 'Name', right: trx.effectiveTo.name ?? '--'),
                          if (trx.effectiveTo.phone != null)
                            SpacedText(left: 'Phone', right: trx.effectiveTo.phone ?? '--'),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            //! trx info
            const Gap(Insets.sm),
            SpacedText(left: 'Amount', right: trx.amount.currency(), styleBuilder: (l, r) => (l, r.bold)),
            if (trx.payMethod != null)
              SpacedText(left: 'Payment method', right: trx.payMethod!.name, styleBuilder: (l, r) => (l, r.bold)),

            if (trx.account != null)
              SpacedText(left: 'Account', right: trx.account?.name ?? '--', styleBuilder: (l, r) => (l, r.bold)),

            SpacedText(left: 'Date', right: trx.date.formatDate(), styleBuilder: (l, r) => (l, r.bold)),

            if (trx.note != null)
              SpacedText(left: 'Note', right: trx.note ?? '--', styleBuilder: (l, r) => (l, context.text.muted)),

            Text('Custom info:', style: context.theme.decoration.labelStyle),
            for (final MapEntry(:key, :value) in trx.customInfo.entries)
              SpacedText(left: key, right: value, styleBuilder: (l, r) => (l, r.bold)),
          ],
        ),
      ),
    );
  }
}
