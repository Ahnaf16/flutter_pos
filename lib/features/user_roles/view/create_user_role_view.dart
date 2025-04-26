import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:pos/features/user_roles/controller/update_role_ctrl.dart';
import 'package:pos/features/user_roles/controller/user_roles_ctrl.dart';
import 'package:pos/main.export.dart';

class CreateUserRoleView extends HookConsumerWidget {
  const CreateUserRoleView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final updatingId = context.param('id');
    final updatingStaff = ref.watch(updateRoleCtrlProvider(updatingId));
    final updateCtrl = useCallback(() => ref.read(updateRoleCtrlProvider(updatingId).notifier));

    final formKey = useMemoized(GlobalKey<FormBuilderState>.new);

    final actionText = updatingId == null ? 'Create' : 'Update';

    return BaseBody(
      title: '$actionText Role',
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
              result = await updateCtrl().updateRole(data);
              l.falsey();
            } else {
              l.truthy();
              final ctrl = ref.read(userRolesCtrlProvider.notifier);
              result = await ctrl.createRole(data);
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
        error: (e, s) => ErrorView(e, s, prov: updateRoleCtrlProvider(updatingId)),
        loading: () => const Loading(),
        data: (updating) {
          if (updatingId != null && updating == null) return const ErrorView('Role not found', null);
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
                    title: const Text('User Roles'),
                    description: const Text('Add a Role name and its permissions'),
                    childSeparator: const SizedBox(width: 750, child: ShadSeparator.horizontal(thickness: 1)),
                    child: LimitedWidthBox(
                      maxWidth: 700,
                      center: false,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        spacing: Insets.med,
                        children: [
                          const ShadField(
                            name: 'name',
                            label: 'Role Name',
                            hintText: 'Enter role name',
                            isRequired: true,
                          ),

                          FormBuilderField<bool>(
                            name: 'enabled',
                            builder: (state) {
                              return ShadCard(
                                title: const Text('Enabled'),
                                description: const Text('Is this role enabled?'),
                                trailing: ShadSwitch(value: state.value ?? true, onChanged: state.didChange),
                                rowCrossAxisAlignment: CrossAxisAlignment.center,
                              );
                            },
                          ),
                          FormBuilderField<List<String>>(
                            name: 'permissions',
                            builder: (state) {
                              return ShadCard(
                                title: const Text('Permissions'),
                                description: const Text('Select permissions for this role'),
                                childPadding: Pads.med('t'),
                                child: Column(
                                  spacing: Insets.med,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    for (final permission in RolePermissions.values)
                                      ShadCheckbox(
                                        value: state.value?.contains(permission.name) ?? false,
                                        label: Text(permission.name.titleCase),
                                        onChanged: (value) {
                                          final permissions = state.value?.toList() ?? [];
                                          if (value) {
                                            permissions.add(permission.name);
                                          } else {
                                            permissions.remove(permission.name);
                                          }
                                          state.didChange(permissions);
                                        },
                                      ),
                                  ],
                                ),
                              );
                            },
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
