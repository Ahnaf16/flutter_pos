import 'package:pos/_widgets/base_body.dart';
import 'package:pos/features/staffs/controller/staffs_ctrl.dart';
import 'package:pos/main.export.dart';

class StaffsView extends HookConsumerWidget {
  const StaffsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const headings = ['Name', 'Role', 'Warehouse', 'Action'];
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
            return ListView.builder(
              itemCount: staffs.length + 1,
              itemBuilder: (BuildContext context, int index) {
                if (index == 0) {
                  return ShadCard(
                    backgroundColor: context.colors.border.op5,
                    padding: Pads.med(),
                    radius: BorderRadius.vertical(
                      top: Corners.medRadius,
                      bottom: staffs.isEmpty ? Corners.medRadius : Radius.zero,
                    ),
                    child: Row(children: [...headings.map((e) => Expanded(child: Text(e)))]),
                  );
                }
                final staff = staffs[index - 1];
                final isLast = index == staffs.length;
                return ShadCard(
                  radius: BorderRadius.vertical(bottom: isLast ? Corners.medRadius : Radius.zero),
                  child: Row(
                    children: [
                      Expanded(
                        child: Row(
                          spacing: Insets.med,
                          crossAxisAlignment: CrossAxisAlignment.start,
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
                        ),
                      ),
                      Expanded(child: Text(staff.role?.name ?? '--')),
                      Expanded(child: Text(staff.warehouse?.name ?? '--')),
                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            ShadButton(size: ShadButtonSize.sm, child: const Icon(LuIcons.pen), onPressed: () {}),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  // SizedBox _divider(BuildContext context) {
  //   return SizedBox(
  //     height: 25,
  //     child: ShadSeparator.vertical(color: context.colors.border, thickness: 2, margin: Pads.sm('lr')),
  //   );
  // }
}
