import 'package:pos/features/staffs/controller/staffs_ctrl.dart';
import 'package:pos/features/user_roles/controller/user_roles_ctrl.dart';
import 'package:pos/features/warehouse/controller/warehouse_ctrl.dart';
import 'package:pos/main.export.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

const _headings = [('Name', double.nan), ('Role', 200.0), ('Warehouse', 200.0), ('Action', 260.0)];

class StaffsView extends HookConsumerWidget {
  const StaffsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final staffList = ref.watch(staffsCtrlProvider);
    final staffCtrl = useCallback(() => ref.read(staffsCtrlProvider.notifier));

    final warehouseList = ref.watch(warehouseCtrlProvider);
    final roleList = ref.watch(userRolesCtrlProvider);

    return BaseBody(
      title: 'Staffs',
      actions: [
        ShadButton(
          child: const Text('Create Staff'),
          onPressed: () {
            RPaths.createStaffs.pushNamed(context);
          },
        ),
      ],
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SizedBox(
                width: 350,
                child: ShadTextField(
                  hintText: 'Search',
                  onChanged: (v) => staffCtrl().search(v ?? ''),
                  showClearButton: true,
                ),
              ),
              SizedBox(
                width: 250,
                child: warehouseList.maybeWhen(
                  orElse: () => ShadCard(padding: kDefInputPadding, child: const Loading()),
                  data: (warehouses) {
                    return ShadSelectField<WareHouse>(
                      hintText: 'Warehouse',
                      options: warehouses,
                      selectedBuilder: (context, value) => Text(value.name),
                      optionBuilder: (_, value, _) {
                        return ShadOption(value: value, child: Text(value.name));
                      },
                      onChanged: (v) => staffCtrl().filter(wh: v),
                    );
                  },
                ),
              ),
              SizedBox(
                width: 250,
                child: roleList.maybeWhen(
                  orElse: () => ShadCard(padding: kDefInputPadding, child: const Loading()),
                  data: (accounts) {
                    return ShadSelectField<UserRole>(
                      hintText: 'Account',
                      options: accounts,
                      selectedBuilder: (context, value) => Text(value.name),
                      optionBuilder: (_, value, _) {
                        return ShadOption(value: value, child: Text(value.name));
                      },
                      onChanged: (v) => staffCtrl().filter(role: v),
                    );
                  },
                ),
              ),
            ],
          ),
          const Gap(Insets.med),
          Expanded(
            child: staffList.when(
              loading: () => const Loading(),
              error: (e, s) => ErrorView(e, s, prov: staffsCtrlProvider),
              data: (staffs) {
                return DataTableBuilder<AppUser, (String, double)>(
                  rowHeight: 100,
                  items: staffs,
                  headings: _headings,
                  headingBuilder: (heading) {
                    return GridColumn(
                      columnName: heading.$1,
                      columnWidthMode: ColumnWidthMode.fill,
                      maximumWidth: heading.$2,
                      minimumWidth: 200,
                      label: Container(
                        padding: Pads.med(),
                        alignment: heading.$1 == 'Action' ? Alignment.centerRight : Alignment.centerLeft,
                        child: Text(heading.$1),
                      ),
                    );
                  },
                  cellAlignment: Alignment.centerLeft,
                  cellBuilder: (data, head) {
                    return switch (head.$1) {
                      'Name' => DataGridCell(columnName: head.$1, value: _nameCellBuilder(data)),
                      'Warehouse' => DataGridCell(columnName: head.$1, value: Text(data.warehouse?.name ?? '--')),
                      'Role' => DataGridCell(columnName: head.$1, value: Text(data.role?.name ?? '--')),
                      'Action' => DataGridCell(
                        columnName: head.$1,
                        value: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            ShadButton.secondary(
                              size: ShadButtonSize.sm,
                              leading: const Icon(LuIcons.eye),
                              onPressed:
                                  () => showShadDialog(
                                    context: context,
                                    builder: (context) => _StaffViewDialog(user: data),
                                  ),
                            ),
                            ShadButton.secondary(
                              size: ShadButtonSize.sm,
                              leading: const Icon(LuIcons.pen),
                              onPressed: () => RPaths.editStaffs(data.id).pushNamed(context),
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

  Widget _nameCellBuilder(AppUser staff) => Builder(
    builder: (context) {
      return Row(
        spacing: Insets.med,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleImage(staff.getPhoto, borderWidth: 1, radius: 20),

          Flexible(
            child: Column(
              spacing: Insets.xs,
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                OverflowMarquee(child: Text(staff.name, style: context.text.list)),
                OverflowMarquee(child: Text('Phone: ${staff.phone}')),
                OverflowMarquee(child: Text('Email: ${staff.email}')),
              ],
            ),
          ),
        ],
      );
    },
  );
}

class _StaffViewDialog extends HookConsumerWidget {
  const _StaffViewDialog({required this.user});

  final AppUser user;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ShadDialog(
      title: const Text('Staff'),
      description: Text('Details of ${user.name}'),

      actions: [ShadButton.destructive(onPressed: () => context.nPop(), child: const Text('Cancel'))],
      child: Container(
        padding: Pads.padding(v: Insets.med),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: Insets.sm,
          children: [
            if (user.photo != null) HostedImage.square(user.getPhoto, dimension: 80, radius: Corners.med),

            SpacedText(left: 'Name', right: user.name, styleBuilder: (l, r) => (l, r.bold)),
            SpacedText(
              left: 'Phone Number',
              right: user.phone,
              styleBuilder: (l, r) => (l, r.bold),
              trailing: SmallButton(icon: LuIcons.copy, onPressed: () => Copier.copy(user.phone)),
            ),
            SpacedText(
              left: 'Email',
              right: user.email,
              styleBuilder: (l, r) => (l, r.bold),
              trailing: SmallButton(icon: LuIcons.copy, onPressed: () => Copier.copy(user.email)),
            ),
            SpacedText(
              left: 'Role',
              right: user.role?.name ?? '--',
              styleBuilder: (l, r) => (l, r.bold),
              builder: (r) => ShadBadge(padding: Pads.padding(v: Insets.xs, h: Insets.med), child: Text(r)),
              crossAxisAlignment: CrossAxisAlignment.center,
            ),
            SpacedText(
              left: 'Warehouse',
              right: user.warehouse?.name ?? '--',
              styleBuilder: (l, r) => (l, r.bold),
              builder: (r) => ShadBadge(padding: Pads.padding(v: Insets.xs, h: Insets.med), child: Text(r)),
              crossAxisAlignment: CrossAxisAlignment.center,
            ),
          ],
        ),
      ),
    );
  }
}
