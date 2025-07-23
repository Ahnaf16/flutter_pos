import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:open_filex/open_filex.dart';
import 'package:pos/features/auth/controller/auth_ctrl.dart';
import 'package:pos/features/filter/view/filter_bar.dart';
import 'package:pos/features/parties/controller/parties_ctrl.dart';
import 'package:pos/features/parties/view/party_name_builder.dart';
import 'package:pos/features/payment_accounts/controller/payment_accounts_ctrl.dart';
import 'package:pos/features/payment_accounts/view/local/account_name_builder.dart';
import 'package:pos/features/payment_accounts/view/payment_accounts_view.dart';
import 'package:pos/features/settings/controller/settings_ctrl.dart';
import 'package:pos/features/transactions/controller/transactions_ctrl.dart';
import 'package:pos/main.export.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

part '_trx_add_dialog.dart';

const _headings = [
  TableHeading.positional('#', 50.0),
  TableHeading.positional('Trx No'),
  TableHeading.positional('To'),
  TableHeading.positional('From'),
  TableHeading.positional('Amount', 300.0),
  TableHeading.positional('Account', 250),
  TableHeading.positional('Type', 250, Alignment.center),
  TableHeading.positional('Date', 250, Alignment.center),
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

      body: Column(
        children: [
          FilterBar(
            hintText: 'Search by trx no, name, email or phone',
            types: TransactionType.values,
            accounts: accountList,
            onSearch: (q) => trxCtrl().search(q),
            onReset: () => trxCtrl().refresh(),
            showDateRange: true,
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
  const TrxTable({
    super.key,
    required this.logs,
    this.excludes = const [],
    this.showFooter = false,
    this.accountAmounts = true,
  });

  final List<TransactionLog> logs;
  final List<String> excludes;
  final bool showFooter;
  final bool accountAmounts;

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
          minimumWidth: heading.minWidth ?? 150,
          label: Container(
            padding: Pads.med(),
            alignment: alignment,
            child: Text(heading.name),
          ),
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
          'Trx No' => DataGridCell(
            columnName: head.name,
            value: Wrap(
              spacing: Insets.xs,
              runSpacing: Insets.xs,
              children: [
                Text(data.trxNo),
                SmallButton(icon: LuIcons.copy, onPressed: () => Copier.copy(data.trxNo)),
              ],
            ),
          ),
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
                if (accountAmounts) ...[
                  if (data.customInfo case {'pre': final pre}) SpacedText(left: 'Pre', right: pre),
                  if (data.customInfo case {'post': final post}) SpacedText(left: 'Post', right: post),
                ],
              ],
            ),
          ),
          'Type' => DataGridCell(
            columnName: head.name,
            value: ShadBadge.secondary(child: Text(data.type.name.titleCase)).colored(data.type.color),
          ),
          'Date' => DataGridCell(
            columnName: head.name,
            value: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(data.date.formatDate()),
                Text(data.date.ago),
              ],
            ),
          ),
          'Action' => DataGridCell(
            columnName: head.name,
            value: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ShadButton(
                  size: ShadButtonSize.sm,
                  leading: const Icon(LuIcons.eye),
                  onPressed: () {
                    showShadDialog(
                      context: context,
                      builder: (context) => _TrxViewDialog(trx: data),
                    );
                  },
                ).colored(Colors.blue),
              ],
            ),
          ),
          _ => DataGridCell(columnName: head.name, value: Text(data.toString())),
        };
      },

      footer: (!showFooter || context.layout.isMobile)
          ? null
          : DecoContainer(
              color: context.colors.border,
              padding: Pads.med(),
              height: 80,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                spacing: Insets.xl,
                children: [
                  SpacedText(
                    left: 'Total in ',
                    right: logs.where((e) => e.isIncome == true).map((e) => e.amount).sum.currency(),
                    crossAxisAlignment: CrossAxisAlignment.center,
                    useFlexible: false,
                    style: context.text.list.primary(context),
                    styleBuilder: (l, r) => (l, r),
                  ),
                  const ShadSeparator.vertical(margin: Pads.zero, color: Colors.black),
                  SpacedText(
                    left: 'Total Out ',
                    right: logs.where((e) => e.isIncome == false).map((e) => e.amount).sum.currency(),
                    crossAxisAlignment: CrossAxisAlignment.center,
                    useFlexible: false,
                    style: context.text.list.textColor(Colors.amber.shade900),
                    styleBuilder: (l, r) => (l, r),
                  ),
                  const ShadSeparator.vertical(margin: Pads.zero, color: Colors.black),
                  SpacedText(
                    left: 'Total Return ',
                    right: logs.fromTypes([TransactionType.returned]).map((e) => e.amount).sum.currency(),
                    crossAxisAlignment: CrossAxisAlignment.center,
                    useFlexible: false,
                    style: context.text.list.error(context),
                    styleBuilder: (l, r) => (l, r),
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
        Text(name ?? '--', style: context.text.list, maxLines: 1),
        if (phone != null) Text(phone ?? '--', maxLines: 1),
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
          if (trx.isBetweenAccount) const ShadBadge(child: Text('Account balance transfer')),
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

            ShadCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: Insets.sm,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('TRX NO:', style: context.text.list),
                      Row(
                        spacing: Insets.sm,
                        children: [
                          Text(trx.trxNo, style: context.text.list.primary(context)),
                          SmallButton(
                            icon: LuIcons.copy,
                            onPressed: () => Copier.copy(trx.trxNo),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const Divider(),
                  if (trx.record != null)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Related Invoice:', style: context.text.list),

                        Row(
                          spacing: Insets.sm,
                          children: [
                            Text(trx.record!.invoiceNo, style: context.text.list.primary(context)),
                            Row(
                              spacing: Insets.med,
                              children: [
                                SmallButton(
                                  icon: LuIcons.copy,
                                  onPressed: () => Copier.copy(trx.record!.invoiceNo),
                                ),
                                SmallButton(
                                  icon: LuIcons.arrowUpRight,
                                  onPressed: () {
                                    context.nPop();
                                    if (trx.record!.type.isSale) {
                                      RPaths.saleDetails(trx.record!.id).pushNamed(context);
                                    } else {
                                      RPaths.purchaseDetails(trx.record!.id).pushNamed(context);
                                    }
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Amount:', style: context.text.list),
                      Text(trx.amount.currency(), style: context.text.list),
                    ],
                  ),
                  if (trx.payMethod != null)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Payment method:', style: context.text.list),
                        Text(trx.payMethod!.name, style: context.text.list),
                      ],
                    ),
                  if (trx.account != null)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Account:', style: context.text.list),
                        Row(
                          spacing: Insets.sm,
                          children: [
                            Text(trx.account?.name ?? '--', style: context.text.list),
                            SmallButton(
                              icon: LuIcons.arrowUpRight,
                              onPressed: () {
                                context.nPop();
                                showShadDialog(
                                  context: context,
                                  builder: (context) => AccountViewDialog(acc: trx.account!),
                                );
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Date:', style: context.text.list),
                      Text(trx.date.formatDate(), style: context.text.list),
                    ],
                  ),
                  if (trx.note != null)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Note:', style: context.text.list),
                        Text(trx.note ?? '--', style: context.text.list),
                      ],
                    ),

                  if (trx.file != null)
                    Row(
                      spacing: Insets.sm,
                      children: [
                        const ShadAvatar(LuIcons.file),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(trx.file!.name, style: context.text.p),
                              Text(trx.file!.ext),
                            ],
                          ),
                        ),
                        ShadIconButton(
                          icon: const Icon(LuIcons.download),
                          onPressed: () async {
                            final path = await trx.file!.download();
                            if (!context.mounted) return;
                            Toast.show(
                              context,
                              'Downloaded',
                              action: (id) => SmallButton(
                                icon: LuIcons.externalLink,
                                onPressed: () => OpenFilex.open(path),
                              ),
                            );
                          },
                        ).toolTip('Download'),
                      ],
                    ),

                  if (trx.customInfo.isNotEmpty)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Custom info:', style: context.text.list),
                        Column(
                          children: [
                            for (final MapEntry(:key, :value) in trx.customInfo.entries)
                              Text('$key $value', style: context.text.list),
                          ],
                        ),
                      ],
                    ),

                  // if (trx.customInfo.isNotEmpty) Text('Custom info:', style: context.theme.decoration.labelStyle),
                  // for (final MapEntry(:key, :value) in trx.customInfo.entries)
                  //   SpacedText(left: key, right: value, styleBuilder: (l, r) => (l, r)),
                ],
              ),
            ),

            //! trx info
          ],
        ),
      ),
    );
  }
}
