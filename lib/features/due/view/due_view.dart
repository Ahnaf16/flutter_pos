import 'package:pos/features/due/controller/due_ctrl.dart';
import 'package:pos/main.export.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

const _headings = [('Name', double.nan), ('Amount', 350.0), ('Date', 250.0), ('Action', 100.0)];

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
        spacing: Insets.med,
        children: [
          Row(
            children: [
              SizedBox(
                width: 350,
                child: ShadTextField(
                  hintText: 'Search',
                  onChanged: (v) => dueCtrl().search(v ?? ''),
                  showClearButton: true,
                ),
              ),
              ShadDatePicker.range(onRangeChanged: (v) => dueCtrl().filter(range: v)),
              ShadIconButton.raw(
                icon: const Icon(LuIcons.x),
                onPressed: () => dueCtrl().filter(),
                variant: ShadButtonVariant.destructive,
              ),
            ],
          ),
          Expanded(
            child: dueList.when(
              loading: () => const Loading(),
              error: (e, s) => ErrorView(e, s, prov: dueLogCtrlProvider),
              data: (dues) {
                return DataTableBuilder<DueLog, (String, double)>(
                  rowHeight: 100,
                  items: dues,
                  headings: _headings,
                  headingBuilderIndexed: (heading, i) {
                    Alignment alignment = i == _headings.length - 1 ? Alignment.centerRight : Alignment.centerLeft;
                    if (i == 2) alignment = Alignment.center;
                    return GridColumn(
                      columnName: heading.$1,
                      columnWidthMode: ColumnWidthMode.fill,
                      maximumWidth: heading.$2,
                      minimumWidth: 200,
                      label: Container(padding: Pads.med(), alignment: alignment, child: Text(heading.$1)),
                    );
                  },
                  cellAlignment: Alignment.centerLeft,
                  cellBuilder: (data, head) {
                    return switch (head.$1) {
                      'Name' => DataGridCell(columnName: head.$1, value: _PartyNameBuilder(data.parti)),
                      'Amount' => DataGridCell(
                        columnName: head.$1,
                        value: Column(
                          spacing: Insets.xs,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SpacedText(
                              left: 'Amount',
                              right: data.amount.abs().currency(),
                              styleBuilder: (l, r) => (l, r.bold),
                            ),
                            SpacedText(
                              left: 'Before',
                              right: data.oldAmount.currency(),
                              styleBuilder: (l, r) {
                                return (l, r.textColor(data.oldAmount > 0 ? Colors.red : Colors.green));
                              },
                            ),
                            SpacedText(
                              left: 'After',
                              right: data.postAmount.currency(),
                              styleBuilder: (l, r) {
                                return (l, r.textColor(data.postAmount > 0 ? Colors.red : Colors.green));
                              },
                            ),
                          ],
                        ),
                      ),
                      'Date' => DataGridCell(
                        columnName: head.$1,
                        value: Center(child: Text(data.date.formatDate())),
                      ),
                      'Action' => DataGridCell(
                        columnName: head.$1,
                        value: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            ShadButton.secondary(
                              size: ShadButtonSize.sm,
                              leading: const Icon(LuIcons.eye),
                              onPressed: () => showShadDialog(
                                context: context,
                                builder: (context) => _PartiViewDialog(log: data),
                              ),
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
                  if (!parti.isCustomer) ShadBadge.outline(child: Text(parti.type.name)),
                ],
              ),
              Text(parti.phone),
              if (parti.hasDue()) Text('Due: ${parti.due.abs().currency()}'),
              if (parti.hasBalance()) Text('Balance: ${parti.due.abs().currency()}'),
            ],
          ),
        ),
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
                          styleBuilder: (l, r) => (l, r.bold),
                          crossAxisAlignment: CrossAxisAlignment.center,
                        ),
                        SpacedText(
                          left: 'Phone Number',
                          right: parti.phone,
                          styleBuilder: (l, r) => (l, r.bold),
                          crossAxisAlignment: CrossAxisAlignment.center,
                          onTap: (left, right) => Copier.copy(right),
                        ),

                        SpacedText(
                          left: 'Email',
                          right: parti.email ?? '--',
                          styleBuilder: (l, r) => (l, r.bold),
                          crossAxisAlignment: CrossAxisAlignment.center,
                          onTap: (left, right) => Copier.copy(right),
                        ),

                        SpacedText(
                          left: 'Address',
                          right: parti.address ?? '--',
                          styleBuilder: (l, r) => (l, r.bold),
                          crossAxisAlignment: CrossAxisAlignment.center,
                        ),
                        SpacedText(
                          left: 'Current Due',
                          right: parti.due.currency(),
                          styleBuilder: (l, r) => (l, r.bold),
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
                                            style: context.text.small.bold,
                                          ),
                                          const TextSpan(text: ' you'),
                                          TextSpan(
                                            text: ' ${parti.due.abs().currency()}',
                                            style: context.text.small.bold,
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
              styleBuilder: (l, r) => (l, r.bold),
            ),
            SpacedText(left: 'Post amount', right: log.postAmount.currency(), styleBuilder: (l, r) => (l, r.bold)),
            SpacedText(left: 'Date', right: log.date.formatDate(), styleBuilder: (l, r) => (l, r.bold)),
            SpacedText(left: 'Note', right: log.note ?? '--', styleBuilder: (l, r) => (l, context.text.muted)),
          ],
        ),
      ),
    );
  }
}
