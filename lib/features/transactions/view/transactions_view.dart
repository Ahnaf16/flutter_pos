import 'package:pos/features/transactions/controller/transactions_ctrl.dart';
import 'package:pos/main.export.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

const _headings = [
  ('To', double.nan),
  ('From', double.nan),
  ('Amount', 300.0),
  ('Account', 150.0),
  ('Type', 110.0),
  ('Date', 150.0),
  ('Action', 100.0),
];

class TransactionsView extends HookConsumerWidget {
  const TransactionsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final partiList = ref.watch(transactionLogCtrlProvider);
    return BaseBody(
      title: 'Transaction logs',

      body: partiList.when(
        loading: () => const Loading(),
        error: (e, s) => ErrorView(e, s, prov: transactionLogCtrlProvider),
        data: (dues) {
          return DataTableBuilder<TransactionLog, (String, double)>(
            rowHeight: 120,
            items: dues,
            headings: _headings,
            headingBuilderIndexed: (heading, i) {
              final alignment = switch (i) {
                0 => Alignment.centerLeft,
                1 => Alignment.centerLeft,
                2 => Alignment.centerLeft,
                6 => Alignment.centerRight,
                _ => Alignment.center,
              };

              return GridColumn(
                columnName: heading.$1,
                columnWidthMode: ColumnWidthMode.fill,
                maximumWidth: heading.$2,
                minimumWidth: context.layout.isDesktop ? 100 : 200,
                label: Container(padding: Pads.med(), alignment: alignment, child: Text(heading.$1)),
              );
            },
            cellAlignment: Alignment.centerLeft,
            cellAlignmentBuilder: (i) {
              if (i == 'To' || i == 'From') return Alignment.centerLeft;
              if (i == 'Action') return Alignment.centerRight;
              return Alignment.center;
            },
            cellBuilder: (data, head) {
              return switch (head.$1) {
                'To' => DataGridCell(
                  columnName: head.$1,
                  value: _NameBuilder(data.getParti?.name, data.getParti?.phone),
                ),
                'From' => DataGridCell(
                  columnName: head.$1,
                  value: _NameBuilder(data.transactionBy.name, data.transactionBy.phone),
                ),
                'Amount' => DataGridCell(
                  columnName: head.$1,
                  value: Column(
                    spacing: Insets.xs,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SpacedText(left: 'Amount', right: data.amount.currency(), spaced: false),
                      if (data.usedDueBalance > 0)
                        SpacedText(
                          left: data.type == TransactionType.sale ? 'Balance used' : 'Due used',
                          right: data.usedDueBalance.currency(),
                          spaced: false,
                        ),
                    ],
                  ),
                ),
                'Account' => DataGridCell(
                  columnName: head.$1,
                  value: ShadBadge.secondary(child: Text(data.account.name.up)),
                ),
                'Type' => DataGridCell(columnName: head.$1, value: ShadBadge.secondary(child: Text(data.type.name.up))),
                'Date' => DataGridCell(columnName: head.$1, value: Center(child: Text(data.date.formatDate()))),
                'Action' => DataGridCell(
                  columnName: head.$1,
                  value: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      ShadButton.secondary(
                        size: ShadButtonSize.sm,
                        leading: const Icon(LuIcons.eye),
                        onPressed:
                            () => showShadDialog(context: context, builder: (context) => _PartiViewDialog(trx: data)),
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
}

class _NameBuilder extends StatelessWidget {
  const _NameBuilder(this.name, this.phone);
  final String? name;
  final String? phone;
  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: Insets.xs,
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [OverflowMarquee(child: Text(name ?? '--', style: context.text.list)), Text(phone ?? '--')],
    );
  }
}

class _PartiViewDialog extends HookConsumerWidget {
  const _PartiViewDialog({required this.trx});

  final TransactionLog trx;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final TransactionLog(getParti: parti, :transactTo, :transactToPhone, transactionBy: user) = trx;
    return ShadDialog(
      title: const Text('Transaction log'),
      description: Row(
        spacing: Insets.sm,
        children: [const Text('Details of a transaction'), ShadBadge.secondary(child: Text(trx.type.name.up))],
      ),

      actions: [ShadButton.destructive(onPressed: () => context.nPop(), child: const Text('Cancel'))],
      child: Container(
        padding: Pads.padding(v: Insets.med),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: Insets.med,
          children: [
            //! parti
            if (parti != null || transactTo != null || transactToPhone != null)
              ShadCard(
                title: Text('Transacted To', style: context.text.muted),
                childPadding: Pads.sm('t'),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  spacing: Insets.med,
                  children: [
                    if (parti?.getPhoto != null)
                      Flexible(
                        child: ShadCard(
                          height: 80,
                          width: 80,
                          padding: Pads.zero,
                          child: FittedBox(
                            child: HostedImage.square(parti!.getPhoto, dimension: 80, radius: Corners.med),
                          ),
                        ),
                      ),

                    Flexible(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        spacing: Insets.sm,
                        children: [
                          SpacedText(
                            left: 'Name',
                            right: parti?.name ?? transactTo ?? '--',
                            styleBuilder: (l, r) => (l, r.bold),
                            spaced: false,
                            crossAxisAlignment: CrossAxisAlignment.center,
                          ),

                          SpacedText(
                            left: 'Phone Number',
                            right: parti?.phone ?? transactToPhone ?? '--',
                            styleBuilder: (l, r) => (l, r.bold),
                            spaced: false,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            onTap: (left, right) => Copier.copy(right),
                          ),
                          if (parti?.isWalkIn ?? false)
                            ShadBadge.secondary(child: Text('Walk-In', style: context.text.muted)),
                          if (parti != null && !parti.isWalkIn) ...[
                            SpacedText(
                              left: 'Email',
                              right: parti.email ?? '--',
                              styleBuilder: (l, r) => (l, r.bold),
                              spaced: false,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              onTap: (left, right) => Copier.copy(right),
                            ),

                            SpacedText(
                              left: 'Address',
                              right: parti.address ?? '--',
                              styleBuilder: (l, r) => (l, r.bold),
                              spaced: false,
                              crossAxisAlignment: CrossAxisAlignment.center,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),

            //! user
            ShadCard(
              title: Text(
                trx.type == TransactionType.expanse ? 'Expense by' : 'Transacted By',
                style: context.text.muted,
              ),
              childPadding: Pads.sm('t'),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                spacing: Insets.med,
                children: [
                  ShadCard(
                    expanded: false,
                    height: 80,
                    width: 80,
                    padding: Pads.zero,
                    child: FittedBox(child: HostedImage.square(user.getPhoto, dimension: 80)),
                  ),
                  Flexible(
                    child: Column(
                      spacing: Insets.sm,
                      children: [
                        SpacedText(
                          left: 'Name',
                          right: user.name,
                          styleBuilder: (l, r) => (l, r.bold),
                          spaced: false,
                          crossAxisAlignment: CrossAxisAlignment.center,
                        ),

                        SpacedText(
                          left: 'Phone Number',
                          right: user.phone,
                          styleBuilder: (l, r) => (l, r.bold),
                          spaced: false,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          onTap: (left, right) => Copier.copy(right),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            //! trx info
            const Gap(Insets.sm),
            SpacedText(
              left: 'Amount',
              right: trx.amount.currency(),
              styleBuilder: (l, r) => (l, r.bold),
              spaced: false,
            ),
            SpacedText(
              left: 'Used due balance',
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
