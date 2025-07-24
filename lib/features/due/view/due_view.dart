import 'package:pos/features/due/controller/due_ctrl.dart';
import 'package:pos/features/filter/view/filter_bar.dart';
import 'package:pos/main.export.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

const _headings = [
  TableHeading.positional('#', 80.0),
  TableHeading.positional('Name'),
  TableHeading.positional('Balance', 200),
  TableHeading.positional('Amount', 230),
  TableHeading.positional('Before', 230),
  TableHeading.positional('After', 230),
  TableHeading.positional('Date', 230),
  TableHeading.positional('Action', 80),
];

class DueView extends HookConsumerWidget {
  const DueView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dueList = ref.watch(dueLogCtrlProvider);
    final dueCtrl = useCallback(() => ref.read(dueLogCtrlProvider.notifier));

    return BaseBody(
      title: 'Due logs',
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          FilterBar(
            hintText: 'Search by name, email or phone',

            onSearch: (q) => dueCtrl().search(q),
            onReset: () => dueCtrl().refresh(),
            showDateRange: true,
          ),

          Expanded(
            child: dueList.when(
              loading: () => const Loading(),
              error: (e, s) => ErrorView(e, s, prov: dueLogCtrlProvider),
              data: (dues) {
                return DataTableBuilder<DueLog, TableHeading>(
                  rowHeight: 100,
                  items: dues,
                  headings: _headings,
                  headingBuilderIndexed: (heading, i) {
                    final alignment = heading.alignment;
                    return GridColumn(
                      columnName: heading.name,
                      columnWidthMode: ColumnWidthMode.fill,
                      maximumWidth: heading.max,
                      minimumWidth: heading.minWidth ?? 150,
                      label: Container(padding: Pads.med(), alignment: alignment, child: Text(heading.name)),
                    );
                  },
                  cellAlignment: Alignment.centerLeft,
                  cellAlignmentBuilder: (h) => _headings.fromName(h).alignment,
                  cellBuilder: (data, head) {
                    return switch (head.name) {
                      '#' => DataGridCell(columnName: head.name, value: Text((dues.indexOf(data) + 1).toString())),
                      'Name' => DataGridCell(columnName: head.name, value: _PartyNameBuilder(data.parti)),
                      'Balance' => DataGridCell(columnName: head.name, value: _BalanceNameBuilder(data.parti)),
                      'Amount' => DataGridCell(
                        columnName: head.name,
                        value: Text(
                          data.amount.abs().currency(),
                        ),
                      ),
                      'Before' => DataGridCell(
                        columnName: head.name,
                        value: Text(
                          data.oldAmount.currency(),
                        ),
                      ),
                      'After' => DataGridCell(
                        columnName: head.name,
                        value: Text(
                          data.postAmount.currency(),
                        ),
                      ),
                      'Date' => DataGridCell(
                        columnName: head.name,
                        value: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(data.date.formatDate()),
                            const Gap(3),
                            Text(
                              data.date.ago,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w300,
                              ),
                            ),
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
                              onPressed: () => showShadDialog(
                                context: context,
                                builder: (context) => _PartiViewDialog(log: data),
                              ),
                            ).colored(Colors.blue).toolTip('View'),
                          ],
                        ),
                      ),
                      _ => DataGridCell(columnName: head.name, value: Text(data.toString())),
                    };
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _PartyNameBuilder extends StatelessWidget {
  const _PartyNameBuilder(this.parti);
  final Party parti;
  @override
  Widget build(BuildContext context) {
    return Row(
      spacing: Insets.med,
      mainAxisSize: MainAxisSize.min,
      children: [
        CircleImage(parti.getPhoto, borderWidth: 1, radius: 20),

        Flexible(
          child: Column(
            spacing: Insets.xs,
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                spacing: Insets.sm,
                children: [
                  Flexible(
                    child: OverflowMarquee(child: Text(parti.name, style: context.text.list)),
                  ),
                  if (!parti.isCustomer)
                    ShadBadge.outline(
                      child: Text(
                        parti.type.name,
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w300),
                      ),
                    ),
                ],
              ),
              Text(parti.phone),
              if (parti.hasDue()) Text('Due: ${parti.due.abs().currency()}'),
            ],
          ),
        ),
      ],
    );
  }
}

class _BalanceNameBuilder extends StatelessWidget {
  const _BalanceNameBuilder(this.parti);
  final Party parti;
  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: Insets.xs,
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(parti.due.abs().currency() ?? 0.currency()),
      ],
    );
  }
}

class _PartiViewDialog extends HookConsumerWidget {
  const _PartiViewDialog({required this.log});

  final DueLog log;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final parti = log.parti;
    return ShadDialog(
      title: const Text('Due log'),
      description: const Text('Details of Due'),

      actions: [ShadButton.destructive(onPressed: () => context.nPop(), child: const Text('Cancel'))],
      child: Container(
        padding: Pads.padding(v: Insets.med),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: Insets.sm,
          children: [
            //! parti
            ShadCard(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                spacing: Insets.med,
                children: [
                  if (parti.photo != null) HostedImage.square(parti.getPhoto, dimension: 80, radius: Corners.med),

                  Flexible(
                    child: Column(
                      spacing: Insets.sm,
                      children: [
                        SpacedText(
                          left: 'Name',
                          right: parti.name,
                          styleBuilder: (l, r) => (l, r),
                          crossAxisAlignment: CrossAxisAlignment.center,
                        ),
                        SpacedText(
                          left: 'Phone Number',
                          right: parti.phone,
                          styleBuilder: (l, r) => (l, r),
                          crossAxisAlignment: CrossAxisAlignment.center,
                          onTap: (left, right) => Copier.copy(right),
                        ),

                        SpacedText(
                          left: 'Email',
                          right: parti.email ?? '--',
                          styleBuilder: (l, r) => (l, r),
                          crossAxisAlignment: CrossAxisAlignment.center,
                          onTap: (left, right) => Copier.copy(right),
                        ),

                        SpacedText(
                          left: 'Address',
                          right: parti.address ?? '--',
                          styleBuilder: (l, r) => (l, r),
                          crossAxisAlignment: CrossAxisAlignment.center,
                        ),
                        SpacedText(
                          left: 'Current Due',
                          right: parti.due.currency(),
                          styleBuilder: (l, r) => (l, r),
                          builder: (r) => Text(r, style: context.text.small.textColor(parti.dueColor())),
                          crossAxisAlignment: CrossAxisAlignment.center,
                          trailing: parti.due == 0
                              ? null
                              : ShadTooltip(
                                  child: const Icon(LuIcons.info),
                                  builder: (context) {
                                    return Text.rich(
                                      TextSpan(
                                        children: [
                                          TextSpan(text: '${parti.name} '),
                                          TextSpan(
                                            text: parti.due.isNegative ? 'Owe' : 'Will pay',
                                            style: context.text.small,
                                          ),
                                          const TextSpan(text: ' you'),
                                          TextSpan(
                                            text: ' ${parti.due.abs().currency()}',
                                            style: context.text.small,
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            //! log info
            const Gap(Insets.sm),
            SpacedText(
              left: log.isDueAdded ? 'Added to due' : 'Subtracted from due',
              right: log.amount.abs().currency(),
              styleBuilder: (l, r) => (l, r),
            ),
            SpacedText(left: 'Post amount', right: log.postAmount.currency(), styleBuilder: (l, r) => (l, r)),
            SpacedText(left: 'Date', right: log.date.formatDate(), styleBuilder: (l, r) => (l, r)),
            SpacedText(left: 'Note', right: log.note ?? '--', styleBuilder: (l, r) => (l, context.text.muted)),
          ],
        ),
      ),
    );
  }
}
