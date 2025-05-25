import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:pos/features/auth/controller/auth_ctrl.dart';
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
  const TransactionsView({super.key, this.type});

  final TransactionType? type;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trxList = ref.watch(transactionLogCtrlProvider(type));
    final trxCtrl = useCallback(() => ref.read(transactionLogCtrlProvider(type).notifier), [type]);

    final accountList = ref.watch(paymentAccountsCtrlProvider());

    return BaseBody(
      title: type == TransactionType.transfer ? 'Money transfer' : 'Transaction logs',
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
        if (type == TransactionType.transfer)
          ShadButton(
            onPressed: () {
              showShadDialog(context: context, builder: (context) => const _TransferDialog());
            },
            child: const Text('Transfer money'),
          ),
      ],
      body: Column(
        spacing: Insets.med,
        children: [
          Row(
            children: [
              Expanded(
                child: ShadTextField(
                  hintText: 'Search',
                  onChanged: (v) => trxCtrl().search(v ?? ''),
                  showClearButton: true,
                ),
              ),

              Expanded(
                child: accountList.maybeWhen(
                  orElse: () => ShadCard(padding: kDefInputPadding, child: const Loading()),
                  data: (accounts) {
                    return ShadSelectField<PaymentAccount>(
                      hintText: 'Account',
                      options: accounts,
                      selectedBuilder: (context, value) => Text(value.name),
                      optionBuilder: (_, value, _) {
                        return ShadOption(value: value, child: Text(value.name));
                      },
                      onChanged: (v) => trxCtrl().filter(account: v),
                    );
                  },
                ),
              ),
              Expanded(
                child: ShadSelectField<TransactionType>(
                  hintText: 'Type',
                  options: TransactionType.values,
                  selectedBuilder: (context, value) => Text(value.name.titleCase),
                  optionBuilder: (_, value, _) {
                    return ShadOption(value: value, child: Text(value.name.titleCase));
                  },
                  onChanged: (v) => trxCtrl().filter(type: v),
                ),
              ),
              const Gap(Insets.xs),
              ShadDatePicker.range(
                key: ValueKey(type),
                onRangeChanged: (v) => trxCtrl().filter(range: v),
              ),
              ShadIconButton.raw(
                icon: const Icon(LuIcons.x),
                onPressed: () => trxCtrl().filter(),
                variant: ShadButtonVariant.destructive,
              ),
            ],
          ),
          Expanded(
            child: trxList.when(
              loading: () => const Loading(),
              error: (e, s) => ErrorView(e, s, prov: transactionLogCtrlProvider),
              data: (dues) {
                return TrxTable(logs: dues);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class TrxTable extends StatelessWidget {
  const TrxTable({super.key, required this.logs, this.excludes = const []});
  final List<TransactionLog> logs;

  final List<String> excludes;

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
          'Amount' => DataGridCell(columnName: head.name, value: Text(data.amount.currency())),
          'Account' => DataGridCell(
            columnName: head.name,
            value: ShadBadge.secondary(child: Text(data.account?.name.titleCase ?? '--')),
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
            Row(
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
