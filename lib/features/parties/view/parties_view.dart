import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:pos/features/parties/controller/parties_ctrl.dart';
import 'package:pos/main.export.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

const _headings = [
  TableHeading(name: 'Name'),
  TableHeading(name: 'Phone', max: 300.0, alignment: Alignment.center),
  TableHeading(name: 'Due/Balance', max: 200.0, alignment: Alignment.center),
  TableHeading(name: 'Action', max: 200.0, alignment: Alignment.centerRight),
];

class PartiesView extends HookConsumerWidget {
  const PartiesView({super.key, this.isCustomer = false});
  final bool isCustomer;

  static Future<WalkIn?> showAddDialog(BuildContext context, bool isCustomer, bool showWalkIn) async {
    return showShadDialog<WalkIn>(
      context: context,
      builder: (context) => _PartiAddDialog(isCustomer: isCustomer, showWalkIn: showWalkIn),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final partiList = ref.watch(partiesCtrlProvider(isCustomer));
    return BaseBody(
      title: isCustomer ? 'Customers' : 'Suppliers',
      actions: [
        ShadButton(
          child: const Text('Create'),
          onPressed: () {
            showShadDialog(context: context, builder: (context) => _PartiAddDialog(isCustomer: isCustomer));
          },
        ),
      ],
      body: partiList.when(
        loading: () => const Loading(),
        error: (e, s) => ErrorView(e, s, prov: partiesCtrlProvider),
        data: (parties) {
          return DataTableBuilder<Parti, TableHeading>(
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
                          styleBuilder: (r, l) => (r, context.text.small.error(context)),
                          spaced: false,
                        )
                      else
                        SpacedText(
                          left: 'Balance',
                          right: data.due.abs().currency(),
                          styleBuilder: (r, l) => (r, context.text.small.success()),
                          spaced: false,
                        ),
                    ],
                  ),
                ),
                'Action' => DataGridCell(
                  columnName: head.name,
                  value: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      ShadButton.secondary(
                        size: ShadButtonSize.sm,
                        leading: const Icon(LuIcons.eye),
                        onPressed:
                            () => showShadDialog(context: context, builder: (context) => _PartiViewDialog(parti: data)),
                      ),
                      ShadButton.secondary(
                        size: ShadButtonSize.sm,
                        leading: const Icon(LuIcons.pen),
                        onPressed: () async {
                          await showShadDialog(
                            context: context,
                            builder: (context) => _PartiAddDialog(parti: data, isCustomer: isCustomer),
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
        },
      ),
    );
  }
}

class _PartyNameBuilder extends StatelessWidget {
  const _PartyNameBuilder(this.parti);
  final Parti parti;
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
                  Flexible(child: OverflowMarquee(child: Text(parti.name, style: context.text.list))),
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
  const _PartiAddDialog({this.parti, this.isCustomer = false, this.showWalkIn = false});

  final Parti? parti;
  final bool isCustomer;
  final bool showWalkIn;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formKey = useMemoized(GlobalKey<FormBuilderState>.new);
    final actionTxt = parti == null ? 'Add' : 'Update';

    final walkInEnabled = useState<bool>(false);
    final selectedFile = useState<PFile?>(null);

    return ShadDialog(
      title: Text('$actionTxt Parti'),
      description: Text(
        parti == null ? 'Fill the form and to add a new parti' : 'Fill the form to update ${parti!.name}',
      ),
      actions: [
        ShadButton.destructive(onPressed: () => context.nPop(), child: const Text('Cancel')),
        if (walkInEnabled.value)
          SubmitButton(
            onPressed: (l) async {
              final state = formKey.currentState!;
              if (!state.saveAndValidate()) return;
              final data = QMap.from(state.value);
              final wi = WalkIn.fromMap(data);
              context.nPop(wi);
            },
            child: const Text('Add customer'),
          )
        else
          SubmitButton(
            onPressed: (l) async {
              final state = formKey.currentState!;
              if (!state.saveAndValidate()) return;
              final data = QMap.from(state.value);

              final ctrl = ref.read(partiesCtrlProvider(isCustomer).notifier);
              (bool, String)? result;

              if (parti == null) {
                l.truthy();
                if (isCustomer) {
                  data.addAll({'type': PartiType.customer.name});
                }
                result = await ctrl.createParti(data, selectedFile.value);
                l.falsey();
              } else {
                final updated = parti?.marge(data);
                if (updated == null) return;
                l.truthy();
                result = await ctrl.updateParti(updated, selectedFile.value);
                l.falsey();
              }
              if (result case final Result r) {
                if (!context.mounted) return;
                r.showToast(context);
                if (r.success) context.pop(true);
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
              if (showWalkIn)
                ShadCard(
                  padding: Pads.med(),
                  title: Text('Walk in customer', style: context.text.list),
                  description: Text('When turned on, this customer will not be saved', style: context.text.muted),
                  rowCrossAxisAlignment: CrossAxisAlignment.center,
                  trailing: ShadSwitch(value: walkInEnabled.value, onChanged: walkInEnabled.set),
                ),
              Row(
                children: [
                  Expanded(flex: 2, child: ShadFormField(name: 'name', label: 'Name', isRequired: true)),
                  if (!isCustomer || !walkInEnabled.value)
                    Flexible(
                      child: FormBuilderField<String>(
                        name: 'type',
                        validator: FormBuilderValidators.required(),
                        initialValue: parti?.type.name ?? PartiType.supplier.name,
                        builder: (form) {
                          return ShadInputDecorator(
                            label: const Text('Choose a type').required(),
                            error: form.errorText == null ? null : Text(form.errorText!),
                            decoration: context.theme.decoration.copyWith(hasError: form.hasError),
                            child: LimitedWidthBox(
                              child: ShadSelect<PartiType>(
                                maxWidth: 300,
                                maxHeight: 200,
                                initialValue: form.value == null ? null : PartiType.values.byName(form.value!),
                                placeholder: const Text('Parti type'),
                                itemCount: PartiType.suppliers.length,
                                optionsBuilder: (_, i) {
                                  return ShadOption(
                                    value: PartiType.suppliers[i],
                                    child: Text(PartiType.suppliers[i].name.titleCase),
                                  );
                                },
                                onChanged: (value) => form.didChange(value?.name),
                                selectedOptionBuilder: (context, v) => Text(v.name),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                ],
              ),
              ShadFormField(name: 'phone', label: 'Phone', isRequired: true),
              if (!walkInEnabled.value) ...[
                ShadFormField(name: 'email', label: 'Email'),
                ShadFormField(name: 'address', label: 'Address'),

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
            ],
          ),
        ),
      ),
    );
  }
}

class _PartiViewDialog extends HookConsumerWidget {
  const _PartiViewDialog({required this.parti});

  final Parti parti;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ShadDialog(
      title: const Text('Parti'),
      description: Row(
        spacing: Insets.sm,
        children: [Text('Details of ${parti.name}'), ShadBadge.outline(child: Text(parti.type.name))],
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

            SpacedText(left: 'Name', right: parti.name, styleBuilder: (l, r) => (l, r.bold), spaced: false),
            SpacedText(
              left: 'Phone Number',
              right: parti.phone,
              styleBuilder: (l, r) => (l, r.bold),
              spaced: false,
              trailing: SmallButton(icon: LuIcons.copy, onPressed: () => Copier.copy(parti.phone)),
            ),

            SpacedText(
              left: 'Email',
              right: parti.email ?? '--',
              styleBuilder: (l, r) => (l, r.bold),
              spaced: false,
              trailing: SmallButton(icon: LuIcons.copy, onPressed: () => Copier.copy(parti.email)),
            ),

            SpacedText(
              left: 'Address',
              right: parti.address ?? '--',
              styleBuilder: (l, r) => (l, r.bold),
              spaced: false,
              builder: (r) => Text(r),
              crossAxisAlignment: CrossAxisAlignment.center,
            ),
            SpacedText(
              left: parti.hasDue() ? 'Due' : 'Balance',
              right: parti.due.abs().currency(),
              styleBuilder: (l, r) => (l, r.bold),
              spaced: false,
              builder: (r) => Text(r, style: context.text.small.textColor(parti.dueColor)),
              crossAxisAlignment: CrossAxisAlignment.center,
              trailing:
                  parti.due == 0
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
