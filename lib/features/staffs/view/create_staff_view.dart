import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:pos/features/staffs/controller/staffs_ctrl.dart';
import 'package:pos/features/staffs/controller/update_staff_ctrl.dart';
import 'package:pos/features/user_roles/controller/user_roles_ctrl.dart';
import 'package:pos/features/warehouse/controller/warehouse_ctrl.dart';
import 'package:pos/main.export.dart';

class CreateStaffView extends HookConsumerWidget {
  const CreateStaffView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final updatingId = context.param('id');
    final updatingStaff = ref.watch(updateStaffCtrlProvider(updatingId));
    final updateCtrl = useCallback(() => ref.read(updateStaffCtrlProvider(updatingId).notifier));

    final formKey = useMemoized(GlobalKey<FormBuilderState>.new);

    final warehouseList = ref.watch(warehouseCtrlProvider);
    final rolesList = ref.watch(userRolesCtrlProvider);

    final searchRole = useState('');
    final searchWarehouse = useState('');

    final selectedFile = useState<PFile?>(null);

    final actionText = updatingId == null ? 'Create' : 'Update';

    return BaseBody(
      title: '$actionText Staff',
      actions: [
        SubmitButton(
          size: ShadButtonSize.lg,
          child: Text(actionText),
          onPressed: (l) async {
            final state = formKey.currentState!;
            if (!state.saveAndValidate()) return;
            final data = state.value;

            final ctrl = ref.read(staffsCtrlProvider.notifier);

            (bool, String)? result;

            if (updatingId != null) {
              l.truthy();
              result = await updateCtrl().updateStaff(data, selectedFile.value);
              l.falsey();
            } else {
              l.truthy();
              final (ok, msg) = await ctrl.checkAvailability(data['email']);
              l.falsey();

              if (!ok) {
                state.fields['email']?.invalidate(msg);
                return;
              }

              result = await showShadDialog<Result>(
                context: context,
                barrierDismissible: false,
                builder: (context) => _CreateStaffDialog(data: data, file: selectedFile.value),
              );
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
        error: (e, s) => ErrorView(e, s, prov: updateStaffCtrlProvider(updatingId)),
        loading: () => const Loading(),
        data: (updating) {
          if (updatingId != null && updating == null) {
            return const ErrorDisplay('No Staff found', description: 'This staff does not exist or has been deleted');
          }
          return SingleChildScrollView(
            child: FormBuilder(
              key: formKey,
              initialValue: updating?.toMap() ?? {},
              child: Column(
                spacing: Insets.lg,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ShadCard(
                    border: const Border(),
                    shadows: const [],
                    padding: Pads.med(),
                    childPadding: Pads.med('t'),
                    title: const Text('Staff Details'),
                    description: const Text('Add staffs name, role, warehouse and contact details'),
                    childSeparator: const SizedBox(width: 700, child: ShadSeparator.horizontal(thickness: 1)),
                    child: LimitedWidthBox(
                      maxWidth: 700,
                      center: false,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        spacing: Insets.med,
                        children: [
                          const ShadField(name: 'name', label: 'Name', hintText: 'Enter your name', isRequired: true),

                          FormBuilderField<QMap>(
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
                                    final filtered = warehouses.where(
                                      (e) => e.name.low.contains(searchWarehouse.value.low),
                                    );
                                    return LimitedWidthBox(
                                      child: ShadSelect<WareHouse>.withSearch(
                                        initialValue: WareHouse.tyrParse(form.value),
                                        placeholder: const Text('Warehouse'),
                                        options: [
                                          if (filtered.isEmpty)
                                            Padding(
                                              padding: Pads.padding(v: 24),
                                              child: const Text('No warehouses found'),
                                            ),
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

                          FormBuilderField<QMap>(
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
                                      child: ShadSelect<UserRole>.withSearch(
                                        initialValue: UserRole.tyrParse(form.value),
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

                          ShadField(
                            name: 'email',
                            label: 'Email',
                            hintText: 'Enter your email',
                            isRequired: true,
                            enabled: updatingId == null,
                            helperText: updatingId == null ? null : 'Email is not editable',
                          ),

                          const ShadField(
                            name: 'phone',
                            label: 'Phone',
                            hintText: 'Enter your phone',
                            isRequired: true,
                          ),

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
                                        if (updating?.photo case final String photo)
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
                  const Gap(Insets.xl),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _CreateStaffDialog extends HookConsumerWidget {
  const _CreateStaffDialog({required this.data, this.file});

  final QMap data;
  final PFile? file;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formKey = useMemoized(GlobalKey<FormBuilderState>.new);

    return ShadDialog(
      title: const Text('Create Staff'),
      description: const Text('Enter a default password so the staff can log in. They can change it later.'),
      actions: [
        ShadButton.destructive(onPressed: () => context.nPop(), child: const Text('Cancel')),
        SubmitButton(
          child: const Text('Create'),
          onPressed: (l) async {
            final state = formKey.currentState!;
            if (!state.saveAndValidate()) return;
            final (pass, confirmPass) = (state.value['pass'].toString(), state.value['confirm_pass'].toString());

            if (pass != confirmPass) {
              state.fields['confirm_pass']?.invalidate('Passwords do not match');
              return;
            }

            l.truthy();
            final ctrl = ref.read(staffsCtrlProvider.notifier);
            final result = await ctrl.createStaff(pass, data, file);
            l.falsey();
            if (context.mounted) context.nPop(result);
          },
        ),
      ],
      child: Container(
        width: 375,
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: FormBuilder(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            spacing: Insets.med,
            children: [
              ShadField(
                name: 'pass',
                label: 'Password',
                hintText: 'Enter a password',
                isRequired: true,
                isPassField: true,
                validators: [FormBuilderValidators.minLength(8)],
              ),
              ShadField(
                name: 'confirm_pass',
                label: 'Confirm Password',
                hintText: 'Confirm your password',
                isRequired: true,
                isPassField: true,
                validators: [FormBuilderValidators.minLength(8)],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
