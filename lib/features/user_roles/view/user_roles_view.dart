import 'package:pos/features/user_roles/controller/user_roles_ctrl.dart';
import 'package:pos/main.export.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

const _headings = [
  TableHeading.positional('#', 50.0),
  TableHeading.positional('Name', 200.0),
  TableHeading.positional('Permissions'),
  TableHeading.positional('Enabled', 200.0),
  TableHeading.positional('Action', 260.0, Alignment.centerRight),
];

class UserRolesView extends HookConsumerWidget {
  const UserRolesView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rolesList = ref.watch(userRolesCtrlProvider);
    return BaseBody(
      title: 'User Role',
      actions: [
        ShadButton(
          child: const Text('Create New role'),
          onPressed: () {
            RPaths.createRole.pushNamed(context);
          },
        ),
      ],
      body: rolesList.when(
        loading: () => const Loading(),
        error: (e, s) => ErrorView(e, s, prov: userRolesCtrlProvider),
        data: (roles) {
          return DataTableBuilder<UserRole, TableHeading>(
            rowHeight: 100,
            items: roles,
            headings: _headings,
            headingBuilder: (heading) {
              return GridColumn(
                columnName: heading.name,
                columnWidthMode: ColumnWidthMode.fill,
                maximumWidth: heading.max,
                minimumWidth: heading.minWidth ?? 200,
                label: Container(
                  padding: Pads.med(),
                  alignment: heading.alignment,
                  child: Text(heading.name),
                ),
              );
            },
            cellAlignmentBuilder: (head) => _headings.fromName(head).alignment,
            cellBuilder: (data, head) {
              return switch (head.name) {
                '#' => DataGridCell(
                  columnName: head.name,
                  value: Text((roles.indexWhere((e) => e.id == data.id) + 1).toString()),
                ),
                'Name' => DataGridCell(columnName: head.name, value: Text(data.name)),
                'Permissions' => DataGridCell(columnName: head.name, value: _permissionBuilder(data)),
                'Enabled' => DataGridCell(
                  columnName: head.name,
                  value: HookBuilder(
                    builder: (context) {
                      final loading = useState(false);
                      if (loading.value) return const Loading(center: false);
                      return ShadSwitch(
                        value: data.isEnabled,
                        onChanged: (v) async {
                          try {
                            if (loading.value) return;
                            final ctrl = ref.read(userRolesCtrlProvider.notifier);
                            loading.truthy();
                            final result = await ctrl.toggleEnable(v, data);
                            if (context.mounted) result.showToast(context);
                            loading.falsey();
                          } catch (e) {
                            loading.falsey();
                          }
                        },
                      );
                    },
                  ),
                ),
                'Action' => DataGridCell(
                  columnName: head.name,
                  value: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      PopOverButton(
                        dense: true,
                        icon: const Icon(LuIcons.eye),
                        color: Colors.blue,
                        toolTip: 'View',
                        onPressed: () {
                          showShadDialog(
                            context: context,
                            builder: (context) => _RoleViewDialog(role: data),
                          );
                        },
                      ),
                      PopOverButton(
                        dense: true,
                        color: Colors.green,
                        toolTip: 'Edit',
                        icon: const Icon(LuIcons.pen),
                        onPressed: () => RPaths.editRole(data.id).pushNamed(context),
                      ),
                      PopOverButton(
                        dense: true,
                        icon: const Icon(LuIcons.trash),
                        isDestructive: true,
                        toolTip: 'Delete',
                        onPressed: () {
                          showShadDialog(
                            context: context,
                            builder: (c) {
                              return ShadDialog.alert(
                                title: const Text('Delete user role'),
                                description: Text('This will delete ${data.name} role permanently.'),
                                actions: [
                                  ShadButton(onPressed: () => c.nPop(), child: const Text('Cancel')),
                                  ShadButton.destructive(
                                    onPressed: () async {
                                      final res = await ref.read(userRolesCtrlProvider.notifier).delete(data);
                                      if (c.mounted) {
                                        res.showToast(c);
                                        c.nPop();
                                      }
                                    },
                                    child: const Text('Delete'),
                                  ),
                                ],
                              );
                            },
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

  Widget _permissionBuilder(UserRole role) => Builder(
    builder: (context) {
      const limit = 2;
      final limitedRoles = role.permissions.take(limit).map((e) => e.name.titleCase).join(', ');
      final more = role.getPermissions.length > limit ? ' +${role.getPermissions.length - limit} more' : '';
      return Column(
        spacing: Insets.xs,
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [Text('Permissions: ${role.getPermissions.length}'), Text(limitedRoles + more)],
      );
    },
  );
}

class _RoleViewDialog extends HookConsumerWidget {
  const _RoleViewDialog({required this.role});

  final UserRole role;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ShadDialog(
      title: const Text('Permissions'),
      description: Text('Permissions assigned to ${role.name}'),
      actions: [ShadButton.destructive(onPressed: () => context.nPop(), child: const Text('Cancel'))],
      child: Container(
        padding: Pads.padding(v: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: Insets.med,
          children: [
            for (final permission in role.getPermissions)
              Row(
                spacing: Insets.med,
                children: [
                  DecoContainer(width: 10, height: 10, borderRadius: 180, color: context.colors.primary),
                  Text(permission.name.titleCase),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
