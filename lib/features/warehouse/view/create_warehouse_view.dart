import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:pos/features/warehouse/controller/update_warehouse_ctrl.dart';
import 'package:pos/features/warehouse/controller/warehouse_ctrl.dart';
import 'package:pos/main.export.dart';

class CreateWarehouseView extends HookConsumerWidget {
  const CreateWarehouseView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final updatingId = context.param('id');
    final updatingStaff = ref.watch(updateWarehouseCtrlProvider(updatingId));
    final updateCtrl = useCallback(() => ref.read(updateWarehouseCtrlProvider(updatingId).notifier));

    final formKey = useMemoized(GlobalKey<FormBuilderState>.new);

    final actionText = updatingId == null ? 'Create' : 'Update';

    return BaseBody(
      title: '$actionText Warehouse',
      actions: [
        SubmitButton(
          size: ShadButtonSize.lg,
          child: Text(actionText),
          onPressed: (l) async {
            final state = formKey.currentState!;
            if (!state.saveAndValidate()) return;
            final data = state.value;

            (bool, String)? result;

            if (updatingId != null) {
              l.truthy();
              result = await updateCtrl().updateWarehouse(data);
              l.falsey();
            } else {
              l.truthy();
              final ctrl = ref.read(warehouseCtrlProvider.notifier);
              result = await ctrl.createWarehouse(data);
              l.falsey();
            }

            if (result case final Result r) {
              if (!context.mounted) return;
              r.showToast(context);
              if (r.success) context.pop();
            }
          },
        ),
      ],

      body: updatingStaff.when(
        error: (e, s) => ErrorView(e, s, prov: updateWarehouseCtrlProvider(updatingId)),
        loading: () => const Loading(),
        data: (updating) {
          if (updatingId != null && updating == null) return const ErrorView('Warehouse not found', null);

          return SingleChildScrollView(
            child: FormBuilder(
              key: formKey,
              initialValue: updating?.toMap() ?? {},
              child: Column(
                spacing: Insets.xl,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ShadCard(
                    border: const Border(),
                    shadows: const [],
                    padding: Pads.med(),
                    childPadding: Pads.med('t'),
                    title: const Text('Warehouse Details'),
                    description: const Text('Add warehouse names, address and contact details'),
                    childSeparator: const SizedBox(width: 750, child: ShadSeparator.horizontal(thickness: 1)),
                    child: const LimitedWidthBox(
                      maxWidth: 700,
                      center: false,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        spacing: Insets.med,
                        children: [
                          ShadField(
                            name: 'name',
                            label: 'Warehouse Name',
                            hintText: 'Enter warehouse name',
                            isRequired: true,
                          ),
                          ShadField(
                            name: 'address',
                            label: 'Warehouse address',
                            hintText: 'Enter warehouse name',
                            isRequired: true,
                          ),
                          ShadField(
                            name: 'contact_person',
                            label: 'Contact Person',
                            hintText: 'Enter contact persons name',
                          ),
                          ShadField(
                            name: 'contact_number',
                            label: 'Contact Number',
                            hintText: 'Enter contact persons number',
                            isRequired: true,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
