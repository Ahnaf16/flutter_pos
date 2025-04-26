import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:pos/_widgets/base_body.dart';
import 'package:pos/features/user_roles/controller/user_roles_ctrl.dart';
import 'package:pos/main.export.dart';

class CreateUserRoleView extends HookConsumerWidget {
  const CreateUserRoleView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formKey = useMemoized(GlobalKey<FormBuilderState>.new);

    return BaseBody(
      title: 'Create Role',
      actions: [
        SubmitButton(
          size: ShadButtonSize.lg,
          child: const Text('Create'),
          onPressed: (l) async {
            final state = formKey.currentState!;
            if (!state.saveAndValidate()) return;
            final data = state.value;
            cat(data, 'role data');
            l.truthy();
            final ctrl = ref.read(userRolesCtrlProvider.notifier);
            final result = await ctrl.createRole(data);
            l.falsey();

            if (result case final Result r) {
              if (!context.mounted) return;
              r.showToast(context);
              if (r.success) context.pop();
            }
          },
        ),
      ],

      body: SingleChildScrollView(
        child: FormBuilder(
          key: formKey,
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
                childSeparator: SizedBox(
                  width: context.width * 0.5,
                  child: const ShadSeparator.horizontal(thickness: 1),
                ),
                child: LimitedWidthBox(
                  maxWidth: 700,
                  center: false,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: Insets.med,
                    children: [
                      const ShadField(name: 'name', label: 'Role Name', hintText: 'Enter role name', isRequired: true),

                      FormBuilderField<bool>(
                        name: 'enabled',
                        initialValue: true,
                        builder: (state) {
                          return ShadCard(
                            title: const Text('Enabled'),
                            description: const Text('Is this role enabled?'),
                            trailing: ShadSwitch(value: state.value ?? false, onChanged: state.didChange),
                            rowCrossAxisAlignment: CrossAxisAlignment.center,
                          );
                        },
                      ),
                      FormBuilderField<List<String>>(
                        name: 'permissions',
                        initialValue: const [],
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
      ),
    );
  }
}
