import 'package:pos/_widgets/base_body.dart';
import 'package:pos/_widgets/data_table_builder.dart';
import 'package:pos/features/staffs/controller/staffs_ctrl.dart';
import 'package:pos/main.export.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

const _headings = [('Name', double.nan), ('Role', 200.0), ('Warehouse', 200.0), ('Action', 260.0)];

class StaffsView extends HookConsumerWidget {
  const StaffsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final staffList = ref.watch(staffsCtrlProvider);
    return BaseBody(
      title: 'Staffs',
      actions: [
        ShadButton.outline(
          child: const Text('Create Staff'),
          onPressed: () {
            RPaths.createStaffs.pushNamed(context);
          },
        ),
      ],
      body: Padding(
        padding: context.layout.pagePadding,
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
                    value: const Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        ShadButton.secondary(size: ShadButtonSize.sm, leading: Icon(LuIcons.eye)),
                        ShadButton.secondary(size: ShadButtonSize.sm, leading: Icon(LuIcons.pen)),
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
