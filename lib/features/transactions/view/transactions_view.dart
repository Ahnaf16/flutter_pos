import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:pos/features/auth/controller/auth_ctrl.dart';
import 'package:pos/features/auth/view/user_card.dart';
import 'package:pos/features/parties/controller/parties_ctrl.dart';
import 'package:pos/features/payment_accounts/controller/payment_accounts_ctrl.dart';
import 'package:pos/features/transactions/controller/transactions_ctrl.dart';
import 'package:pos/main.export.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

part '_trx_add_dialog.dart';

class TransactionsView extends HookConsumerWidget {
  const TransactionsView({super.key, this.type});

  final TransactionType? type;

  final _headings = const [
    TableHeading.positional('To'),
    TableHeading.positional('From'),
    TableHeading.positional('Amount', 300.0, Alignment.center),
    TableHeading.positional('Account', 150.0, Alignment.center),
    TableHeading.positional('Type', 110.0, Alignment.center),
    TableHeading.positional('Date', 150.0, Alignment.center),
    TableHeading.positional('Action', 100.0, Alignment.centerRight),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final partiList = ref.watch(transactionLogCtrlProvider(type));
    return BaseBody(
      title: type == TransactionType.transfer ? 'Money transfer' : 'Transaction logs',
      actions: [
        if (type == TransactionType.transfer)
          ShadButton(
            onPressed: () {
              showShadDialog(context: context, builder: (context) => const _TransferDialog());
            },
            child: const Text('Transfer money'),
          ),
      ],
      body: partiList.when(
        loading: () => const Loading(),
        error: (e, s) => ErrorView(e, s, prov: transactionLogCtrlProvider),
        data: (dues) {
          return DataTableBuilder<TransactionLog, TableHeading>(
            rowHeight: 120,
            items: dues,
            headings: _headings,
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
            cellAlignmentBuilder: (i) => _headings.fromName(i).alignment,
            cellBuilder: (data, head) {
              return switch (head.name) {
                'To' => DataGridCell(
                  columnName: head.name,
                  value: NameCellBuilder(data.getParti?.name, data.getParti?.phone),
                ),
                'From' => DataGridCell(
                  columnName: head.name,
                  value: NameCellBuilder(
                    data.transactionBy?.name ?? data.transactionFormParti?.name,
                    data.transactionFormParti?.phone,
                  ),
                ),
                'Amount' => DataGridCell(
                  columnName: head.name,
                  value: Column(
                    spacing: Insets.xs,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SpacedText(left: 'Amount', right: data.amount.currency()),
                      if (data.usedDueBalance > 0)
                        SpacedText(
                          left: data.type == TransactionType.sale ? 'Balance used' : 'Due used',
                          right: data.usedDueBalance.currency(),
                        ),
                    ],
                  ),
                ),
                'Account' => DataGridCell(
                  columnName: head.name,
                  value: ShadBadge.secondary(child: Text(data.account.name.up)),
                ),
                'Type' => DataGridCell(
                  columnName: head.name,
                  value: ShadBadge.secondary(child: Text(data.type.name.up)),
                ),
                'Date' => DataGridCell(columnName: head.name, value: Center(child: Text(data.date.formatDate()))),
                'Action' => DataGridCell(
                  columnName: head.name,
                  value: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      ShadButton.secondary(
                        size: ShadButtonSize.sm,
                        leading: const Icon(LuIcons.eye),
                        onPressed: () {
                          showShadDialog(context: context, builder: (context) => _TrxViewDialog(trx: data));
                        },
                      ),
                    ],
                  ),
                ),
                _ => DataGridCell(columnName: head.name, value: Text(data.toString())),
              };
            },
          );
        },
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
    final TransactionLog(
      getParti: parti,
      :transactTo,
      :transactToPhone,
      transactionBy: user,
      transactionFormParti: transactionFor,
    ) = trx;
    return ShadDialog(
      title: Text('${trx.type.name.titleCase} log'),
      description: Row(
        spacing: Insets.sm,
        children: [Text('Details of a ${trx.type.name}'), ShadBadge.secondary(child: Text(trx.type.name.up))],
      ),

      actions: [ShadButton.destructive(onPressed: () => context.nPop(), child: const Text('Cancel'))],
      child: Container(
        padding: Pads.padding(v: Insets.med),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: Insets.med,
          children: [
            //! from
            if (transactionFor != null) UserCard.parti(imgSize: 70, parti: transactionFor, title: 'Transaction from'),

            //! parti
            if (parti != null || transactTo != null || transactToPhone != null)
              UserCard.parti(imgSize: 70, parti: parti, title: 'Transacted To'),

            //! user
            if (user != null) UserCard.user(imgSize: 70, user: user, title: '${trx.type.name.titleCase} By'),

            //! trx info
            const Gap(Insets.sm),
            SpacedText(
              left: 'Amount',
              right: trx.amount.currency(),
              styleBuilder: (l, r) => (l, r.bold),
              spaced: false,
            ),
            SpacedText(
              left: 'Used due/balance',
              right: trx.usedDueBalance.currency(),
              styleBuilder: (l, r) => (l, r.bold),
              spaced: false,
            ),
            SpacedText(left: 'Account', right: trx.account.name, styleBuilder: (l, r) => (l, r.bold), spaced: false),
            SpacedText(left: 'Date', right: trx.date.formatDate(), styleBuilder: (l, r) => (l, r.bold), spaced: false),
            SpacedText(
              left: 'Note',
              right: trx.note ?? '--',
              styleBuilder: (l, r) => (l, context.text.muted),
              spaced: false,
            ),
          ],
        ),
      ),
    );
  }
}
