import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pos/_widgets/base_body.dart';
import 'package:pos/features/staffs/controller/staffs_ctrl.dart';
import 'package:pos/features/user_roles/controller/user_roles_ctrl.dart';
import 'package:pos/features/warehouse/controller/warehouse_ctrl.dart';
import 'package:pos/main.export.dart';

class CreateStaffView extends HookConsumerWidget {
  const CreateStaffView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final layout = context.layout;
    final formKey = useMemoized(GlobalKey<FormBuilderState>.new);

    final warehouseList = ref.watch(warehouseCtrlProvider);
    final rolesList = ref.watch(userRolesCtrlProvider);

    final searchRole = useState('');
    final searchWarehouse = useState('');

    return BaseBody(
      title: 'Create Staff',
      actions: [
        SubmitButton(
          size: ShadButtonSize.lg,
          child: const Text('Create'),
          onPressed: (l) async {
            final state = formKey.currentState!;
            if (!state.saveAndValidate()) return;
            l.value = true;
            final data = state.value;
            cat(data, 'Form Data');
            final ctrl = ref.read(staffsCtrlProvider.notifier);
            await ctrl.createStaff('12341234', data);
            l.value = false;
          },
        ),
      ],
      body: SingleChildScrollView(
        padding: layout.pagePadding,
        child: FormBuilder(
          key: formKey,
          child: Column(
            spacing: Insets.lg,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Expanded(
                    flex: 2,
                    child: ShadField(name: 'name', label: 'Name', hintText: 'Enter your name', isRequired: true),
                  ),

                  Expanded(
                    child: FormBuilderField<QMap>(
                      name: 'warehouse',
                      validator: FormBuilderValidators.required(),
                      builder: (form) {
                        return ShadInputDecorator(
                          label: const Text('Choose warehouse').required(),
                          error: form.errorText == null ? null : Text(form.errorText!),
                          decoration: context.theme.decoration.copyWith(hasError: form.hasError),
                          child: warehouseList.maybeWhen(
                            orElse: () => ShadCard(padding: kDefInputPadding, child: const Loading()),
                            data: (warehouses) {
                              final filtered = warehouses.where((e) => e.name.low.contains(searchWarehouse.value.low));
                              return LimitedWidthBox(
                                maxWidth: null,
                                child: ShadSelect<WareHouse>.withSearch(
                                  placeholder: const Text('Warehouse'),
                                  options: [
                                    if (filtered.isEmpty)
                                      Padding(padding: Pads.padding(v: 24), child: const Text('No warehouses found')),
                                    ...filtered.map((house) {
                                      return ShadOption(value: house, child: Text(house.name));
                                    }),
                                  ],
                                  selectedOptionBuilder: (context, v) => Text(v.name),
                                  onSearchChanged: searchWarehouse.set,
                                  allowDeselection: true,
                                  onChanged: (v) => form.didChange(v?.toMap()),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
                  ),
                  Expanded(
                    child: FormBuilderField<QMap>(
                      name: 'role',
                      validator: FormBuilderValidators.required(),
                      builder: (form) {
                        return ShadInputDecorator(
                          label: const Text('Choose a role').required(),
                          error: form.errorText == null ? null : Text(form.errorText!),
                          decoration: context.theme.decoration.copyWith(hasError: form.hasError),
                          child: rolesList.maybeWhen(
                            orElse: () => ShadCard(padding: kDefInputPadding, child: const Loading()),
                            data: (roles) {
                              final filtered = roles.where((e) => e.name.low.contains(searchRole.value.low));

                              return LimitedWidthBox(
                                maxWidth: null,
                                child: ShadSelect<UserRole>.withSearch(
                                  placeholder: const Text('Role'),
                                  options: [
                                    if (filtered.isEmpty)
                                      Padding(padding: Pads.padding(v: 24), child: const Text('No roles found')),

                                    ...filtered.map((role) {
                                      return ShadOption(value: role, child: Text(role.name));
                                    }),
                                  ],
                                  selectedOptionBuilder: (context, v) => Text(v.name),
                                  onSearchChanged: searchRole.set,
                                  allowDeselection: true,
                                  onChanged: (v) => form.didChange(v?.toMap()),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
              const Row(
                children: [
                  Expanded(
                    child: ShadField(name: 'email', label: 'Email', hintText: 'Enter your email', isRequired: true),
                  ),
                  Expanded(
                    child: ShadField(name: 'phone', label: 'Phone', hintText: 'Enter your phone', isRequired: true),
                  ),
                ],
              ),
              FormBuilderField<String>(
                name: 'photo_id',
                builder: (form) {
                  return ShadInputDecorator(
                    label: const Text('Profile image'),
                    error: form.errorText == null ? null : Text(form.errorText!),
                    decoration: context.theme.decoration.copyWith(hasError: form.hasError),
                    child: GestureDetector(
                      onTap: () async {
                        if (form.value != null) return;
                        final files = await fileUtil.openGallery(multi: false);
                        final file = files.fold(identityNull, (r) => r.firstOrNull);
                        form.didChange(file?.path);
                      },
                      child: ShadCard(
                        height: 150,
                        padding: Pads.med(),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              if (form.value != null)
                                Row(
                                  spacing: Insets.med,
                                  children: [
                                    Stack(
                                      children: [
                                        HostedImage.square(Img.file(form.value!), radius: Corners.sm, dimension: 120),
                                        Positioned(
                                          top: 5,
                                          right: 5,
                                          child: ShadBadge.destructive(
                                            padding: Pads.xs(),
                                            onPressed: () => form.didChange(null),
                                            child: Icon(
                                              LuIcons.x,
                                              size: 12,
                                              color: context.colors.destructiveForeground,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    Text(XFile(form.value!).name, style: context.text.muted),
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
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
