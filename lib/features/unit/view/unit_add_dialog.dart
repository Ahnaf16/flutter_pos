import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:pos/features/unit/controller/unit_ctrl.dart';
import 'package:pos/main.export.dart';

class UnitAddDialog extends HookConsumerWidget {
  const UnitAddDialog({super.key, this.unit});

  final ProductUnit? unit;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formKey = useMemoized(GlobalKey<FormBuilderState>.new);
    final actionTxt = unit == null ? 'Add' : 'Update';
    return ShadDialog(
      title: Text('$actionTxt Unit'),
      description: Text(unit == null ? 'Fill the form and add a new unit' : 'Fill the form to update ${unit!.name}'),
      actions: [
        ShadButton.destructive(onPressed: () => context.nPop(), child: const Text('Cancel')),
        SubmitButton(
          onPressed: (l) async {
            final state = formKey.currentState!;
            if (!state.saveAndValidate()) return;
            final data = state.value;

            final ctrl = ref.read(unitCtrlProvider.notifier);
            (bool, String)? result;

            if (unit == null) {
              l.truthy();
              result = await ctrl.createUnit(data);
              l.falsey();
            } else {
              final updated = unit?.marge(data);
              if (updated == null) return;
              l.truthy();
              result = await ctrl.updateUnit(updated);
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
          initialValue: unit?.toMap() ?? {},
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: Insets.med,
            children: [
              ShadTextField(name: 'name', label: 'Name', hintText: 'eg. Kilogram', isRequired: true),
            ],
          ),
        ),
      ),
    );
  }
}
