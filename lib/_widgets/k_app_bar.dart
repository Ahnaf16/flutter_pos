import 'package:pos/main.export.dart';

class KAppBar extends StatelessWidget implements PreferredSizeWidget {
  const KAppBar({
    super.key,
    this.title,
    this.actions = const [],
    this.leading,
    this.bottom,
    this.bottomHeight,
    this.actionGap = Insets.sm,
    this.actionGapEnd = Insets.med,
  });

  final String? title;
  final List<Widget> actions;
  final Widget? leading;
  final Widget? bottom;
  final Size? bottomHeight;
  final double actionGap;
  final double? actionGapEnd;

  @override
  Widget build(BuildContext context) {
    final actionCopy = actions.toList();

    for (var i = actionCopy.length; i-- > 0;) {
      if (i == actionCopy.length - 1) actionCopy.insert(i + 1, Gap(actionGapEnd ?? actionGap));
      if (i > 0) actionCopy.insert(i, Gap(actionGap));
    }

    return AppBar(
      title: title == null ? null : Text(title!),
      actions: actionCopy,
      leading: leading,
      bottom: bottom == null ? null : PreferredSize(preferredSize: bottomHeight ?? preferredSize, child: bottom!),
      centerTitle: false,
      toolbarHeight: preferredSize.height,
      scrolledUnderElevation: 0,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 10);
}
