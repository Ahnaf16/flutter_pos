import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:pos/features/parties/controller/parties_ctrl.dart';
import 'package:pos/main.export.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

const _headings = [
  TableHeading(name: 'Name'),
  TableHeading(name: 'Phone', max: 500.0, alignment: Alignment.center),
  TableHeading(name: 'Due/Balance', max: 400.0),
  TableHeading(name: 'Action', max: 200.0, alignment: Alignment.centerRight),
];

class PartiesView extends HookConsumerWidget {
  const PartiesView({super.key, this.isCustomer = false});
  final bool isCustomer;

  static Future<WalkIn?> showAddDialog(BuildContext context, bool isCustomer) async {
    return showShadDialog(
      context: context,
      builder: (context) => _PartiAddDialog(isCustomer: isCustomer),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final partiList = ref.watch(partiesCtrlProvider(isCustomer));
    final partiCtrl = useCallback(() => ref.read(partiesCtrlProvider(isCustomer).notifier), [isCustomer]);

    return BaseBody(
      title: isCustomer ? 'Customers' : 'Suppliers',
      actions: [
        ShadButton(
          child: const Text('Create'),
          onPressed: () {
            showShadDialog(
              context: context,
              builder: (context) => _PartiAddDialog(isCustomer: isCustomer),
            );
          },
        ),
      ],
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 300,
            child: ShadTextField(
              hintText: 'Search by name, phone or email',
              onChanged: (v) => partiCtrl().search(v ?? ''),
              showClearButton: true,
            ),
          ),
          const Gap(Insets.med),
          Expanded(
            child: partiList.when(
              loading: () => const Loading(),
              error: (e, s) => ErrorView(e, s, prov: partiesCtrlProvider),
              data: (parties) {
                return DataTableBuilder<Party, TableHeading>(
                  rowHeight: 100,
                  items: parties,
                  headings: _headings,
                  headingBuilder: (heading) {
                    return GridColumn(
                      columnName: heading.name,
                      columnWidthMode: ColumnWidthMode.fill,
                      maximumWidth: heading.max,
                      minimumWidth: 200,
                      label: Container(padding: Pads.med(), alignment: heading.alignment, child: Text(heading.name)),
                    );
                  },
                  cellAlignmentBuilder: (h) => _headings.fromName(h).alignment,
                  cellBuilder: (data, head) {
                    return switch (head.name) {
                      'Name' => DataGridCell(columnName: head.name, value: _PartyNameBuilder(data)),
                      'Phone' => DataGridCell(
                        columnName: head.name,
                        value: Row(
                          spacing: Insets.xs,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(data.phone),
                            SmallButton(icon: LuIcons.copy, onPressed: () => Copier.copy(data.phone)),
                          ],
                        ),
                      ),
                      'Due/Balance' => DataGridCell(
                        columnName: head.name,
                        value: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (data.hasDue())
                              SpacedText(
                                left: 'Due',
                                right: data.due.currency(),
                                styleBuilder: (r, l) => (r, context.text.small.textColor(data.dueColor())),
                              )
                            else
                              SpacedText(
                                left: 'Balance',
                                right: data.due.abs().currency(),
                                styleBuilder: (r, l) => (r, context.text.small.textColor(data.dueColor())),
                              ),
                          ],
                        ),
                      ),
                      'Action' => DataGridCell(
                        columnName: head.name,
                        value: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            PopOverBuilder(
                              children: (context, hide) => [
                                PopOverButton(
                                  icon: const Icon(LuIcons.eye),
                                  onPressed: () {
                                    if (isCustomer) RPaths.customerDetails(data.id).pushNamed(context);
                                    if (!isCustomer) RPaths.supplierDetails(data.id).pushNamed(context);
                                  },
                                  child: const Text('View'),
                                ),
                                PopOverButton(
                                  icon: const Icon(LuIcons.pen),
                                  onPressed: () async {
                                    hide();
                                    await showShadDialog(
                                      context: context,
                                      builder: (context) => _PartiAddDialog(parti: data, isCustomer: isCustomer),
                                    );
                                  },
                                  child: const Text('Update'),
                                ),
                                if (data.isCustomer && data.due != 0)
                                  PopOverButton(
                                    icon: Icon(data.hasDue() ? LuIcons.handCoins : LuIcons.arrowLeftRight),
                                    onPressed: () {
                                      hide();
                                      if (data.hasDue()) {
                                        RPaths.customerDueManagement.pushNamed(context, extra: data);
                                      }

                                      if (data.hasBalance()) {
                                        final query = {'isTransfer': 'true'};
                                        RPaths.customerDueManagement.pushNamed(context, query: query, extra: data);
                                      }
                                    },
                                    child: Text(data.hasDue() ? 'Due adjustment' : 'Transfer Balance'),
                                  ),

                                if (data.hasBalance() && !data.isCustomer)
                                  PopOverButton(
                                    icon: const Icon(LuIcons.handCoins),
                                    onPressed: () {
                                      hide();
                                      RPaths.supplierDueManagement.pushNamed(context, extra: data);
                                    },
                                    child: const Text('Due clearance'),
                                  ),

                                PopOverButton(
                                  icon: const Icon(LuIcons.trash),
                                  onPressed: () async {
                                    hide();
                                    await showShadDialog(
                                      context: context,
                                      builder: (c) => _PartyDeleteDialog(partiCtrl: partiCtrl, data: data),
                                    );
                                  },
                                  isDestructive: true,
                                  child: const Text('Delete'),
                                ),
                              ],
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
          ),
        ],
      ),
    );
  }
}

class _PartyDeleteDialog extends StatelessWidget {
  const _PartyDeleteDialog({
    required this.partiCtrl,
    required this.data,
  });

  final PartiesCtrl Function() partiCtrl;
  final Party data;

  @override
  Widget build(BuildContext context) {
    return ShadDialog.alert(
      title: Text('Delete ${data.isCustomer ? 'Customer' : 'Supplier'}'),
      description: Text.rich(
        TextSpan(
          children: [
            TextSpan(text: 'Are you sure you want to delete ${data.name}?\n\n'),

            if (data.due != 0) ...[
              TextSpan(text: data.name, style: context.text.small.bold),
              TextSpan(text: ' has ', style: context.text.muted),
              TextSpan(
                text: '${data.hasDue() ? 'due' : 'balance'} of ${data.due.abs().currency()}.',
                style: context.text.small.bold,
              ),

              TextSpan(
                text: '\nDeleting without clearing ${data.hasDue() ? 'due' : 'balance'} is not recommended.',
                style: context.text.small.error(context),
              ),
            ] else
              TextSpan(text: '\nThis action cannot be undone.', style: context.text.small.error(context)),
          ],
        ),
      ),
      actions: [
        ShadButton(onPressed: () => context.nPop(), child: const Text('Cancel')),
        SubmitButton(
          variant: ShadButtonVariant.destructive,
          onPressed: (l) async {
            l.truthy();
            await partiCtrl().delete(data.id);
            l.falsey();
            if (context.mounted) context.nPop();
          },
          child: const Text('Delete'),
        ),
      ],
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
      crossAxisAlignment: CrossAxisAlignment.start,
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
              Text(parti.address ?? '--', maxLines: 2, overflow: TextOverflow.ellipsis),
            ],
          ),
        ),
      ],
    );
  }
}

class _PartiAddDialog extends HookConsumerWidget {
  const _PartiAddDialog({this.parti, this.isCustomer = false});

  final Party? parti;
  final bool isCustomer;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formKey = useMemoized(GlobalKey<FormBuilderState>.new);
    final actionTxt = parti == null ? 'Add' : 'Update';
    final type = isCustomer ? PartiType.customer : PartiType.supplier;

    final selectedFile = useState<PFile?>(null);

    return ShadDialog(
      title: Text('$actionTxt ${type.name}'),
      description: Text(
        parti == null ? 'Fill the form and to add a new ${type.name}' : 'Fill the form to update ${parti!.name}',
      ),
      actions: [
        ShadButton.destructive(onPressed: () => context.nPop(), child: const Text('Cancel')),

        SubmitButton(
          onPressed: (l) async {
            final state = formKey.currentState!;
            if (!state.saveAndValidate()) return;
            final data = QMap.from(state.value);

            final ctrl = ref.read(partiesCtrlProvider(isCustomer).notifier);
            (bool, String)? result;

            if (parti == null) {
              l.truthy();
              final (ok, msg) = await ctrl.checkAvailability(data['phone']);
              l.falsey();

              if (!ok) {
                state.fields['phone']?.invalidate(msg);
                return;
              }

              data.addAll({'type': type.name});

              l.truthy();
              result = await ctrl.createParti(data, selectedFile.value);
              l.falsey();
            } else {
              final updated = parti?.marge(data);
              if (updated == null) return;

              if (updated.phone != parti!.phone) {
                final (ok, msg) = await ctrl.checkAvailability(updated.phone);
                if (!ok) return state.fields['phone']?.invalidate(msg);
              }

              l.truthy();
              result = await ctrl.updateParti(updated, selectedFile.value);
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
          initialValue: parti?.toMap() ?? {},
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: Insets.med,
            children: [
              ShadTextField(name: 'name', label: 'Name', isRequired: true),
              ShadTextField(name: 'phone', label: 'Phone', isRequired: true),

              ShadTextField(name: 'email', label: 'Email'),
              ShadTextField(name: 'address', label: 'Address'),

              ShadInputDecorator(
                label: const Text('Profile image'),
                child: Padding(
                  padding: Pads.padding(top: 5),
                  child: GestureDetector(
                    onTap: () async {
                      if (selectedFile.value != null) return;
                      final files = await fileUtil.pickImages(multi: false);
                      final file = files.fold(identityNull, (r) => r.firstOrNull);
                      selectedFile.set(file);
                    },
                    child: ShadCard(
                      height: 150,

                      padding: Pads.med(),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (parti?.photo case final String photo)
                              Row(
                                spacing: Insets.med,
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  HostedImage.square(AwImg(photo), dimension: 120, radius: Corners.med),
                                  if (selectedFile.value != null) ...[
                                    const Icon(LuIcons.arrowLeftRight, size: 40),
                                    ImagePickedView(
                                      img: FileImg(selectedFile.value!),
                                      size: 120,
                                      onDelete: () => selectedFile.set(null),
                                    ),
                                  ] else
                                    const Icon(LuIcons.cloudUpload, size: 40),
                                ],
                              )
                            else if (selectedFile.value != null)
                              Row(
                                spacing: Insets.med,
                                children: [
                                  ImagePickedView(
                                    img: FileImg(selectedFile.value!),
                                    size: 120,
                                    onDelete: () => selectedFile.set(null),
                                  ),
                                  Text(selectedFile.value!.name, style: context.text.muted),
                                ],
                              )
                            else ...[
                              const Icon(LuIcons.cloudUpload, size: 40),
                              Text('Drag and drop your image here', style: context.text.muted),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class PartiViewDialog extends HookConsumerWidget {
  const PartiViewDialog({super.key, required this.parti});

  final Party parti;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ShadDialog(
      title: const Text('Parti'),
      description: Row(
        spacing: Insets.sm,
        children: [
          Text('Details of ${parti.name}'),
          ShadBadge.outline(child: Text(parti.type.name)),
        ],
      ),

      actions: [ShadButton.destructive(onPressed: () => context.nPop(), child: const Text('Cancel'))],
      child: Container(
        padding: Pads.padding(v: Insets.med),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: Insets.sm,
          children: [
            if (parti.photo != null) HostedImage.square(parti.getPhoto, dimension: 80, radius: Corners.med),

            SpacedText(left: 'Name', right: parti.name, styleBuilder: (l, r) => (l, r.bold)),
            SpacedText(
              left: 'Phone Number',
              right: parti.phone,
              styleBuilder: (l, r) => (l, r.bold),
              trailing: SmallButton(icon: LuIcons.copy, onPressed: () => Copier.copy(parti.phone)),
            ),

            SpacedText(
              left: 'Email',
              right: parti.email ?? '--',
              styleBuilder: (l, r) => (l, r.bold),
              trailing: SmallButton(icon: LuIcons.copy, onPressed: () => Copier.copy(parti.email)),
            ),

            SpacedText(
              left: 'Address',
              right: parti.address ?? '--',
              styleBuilder: (l, r) => (l, r.bold),
              builder: (r) => Text(r),
              crossAxisAlignment: CrossAxisAlignment.center,
            ),
            SpacedText(
              left: parti.hasDue() ? 'Due' : 'Balance',
              right: parti.due.abs().currency(),
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
                              TextSpan(text: ' ${parti.due.abs().currency()}', style: context.text.small.bold),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
