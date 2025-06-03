import 'package:pos/main.export.dart';

class PopOverBuilder extends HookWidget {
  const PopOverBuilder({super.key, required this.children, this.icon, this.actionSpread = false});

  final List<Widget> Function(BuildContext context, Function() hide) children;
  final Widget? icon;
  final bool actionSpread;

  @override
  Widget build(BuildContext context) {
    final popCtrl = useMemoized(ShadPopoverController.new);

    if (actionSpread) {
      return Row(mainAxisAlignment: MainAxisAlignment.end, children: children(context, () {}));
    }

    return ShadPopover(
      controller: popCtrl,
      padding: Pads.sm(),
      anchor: const ShadAnchorAuto(followerAnchor: Alignment.bottomLeft, offset: Offset(15, 0)),
      popover: (context) {
        return IntrinsicWidth(
          child: Column(
            spacing: Insets.xs,
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: children(context, popCtrl.hide),
          ),
        );
      },
      child: ShadButton.ghost(onPressed: () => popCtrl.toggle(), child: const Icon(LuIcons.ellipsisVertical)),
    );
  }
}

class PopOverButton extends StatelessWidget {
  const PopOverButton({
    super.key,
    this.child,
    this.icon,
    this.onPressed,
    this.isDestructive = false,
    this.enabled = true,
    this.dense = false,
    this.color,
    this.toolTip,
  });

  final Widget? child;
  final Widget? icon;
  final VoidCallback? onPressed;
  final bool isDestructive;
  final bool enabled;
  final bool dense;
  final Color? color;
  final String? toolTip;

  @override
  Widget build(BuildContext context) {
    if (dense) {
      return ShadIconButton.ghost(
        foregroundColor: isDestructive ? context.colors.destructive : context.colors.foreground,
        hoverBackgroundColor: isDestructive ? context.colors.destructive.op1 : null,
        hoverForegroundColor: isDestructive ? context.colors.destructive : context.colors.foreground,
        enabled: enabled,
        icon: icon ?? const SizedBox(),
        onPressed: onPressed,
      ).colored(color ?? (isDestructive ? context.colors.destructive : null)).toolTip(toolTip);
    }
    return ConstrainedBox(
      constraints: const BoxConstraints(minWidth: 150),
      child: ShadButton.ghost(
        foregroundColor: isDestructive ? context.colors.destructive : context.colors.foreground,
        hoverBackgroundColor: isDestructive ? context.colors.destructive.op1 : null,
        size: ShadButtonSize.sm,
        mainAxisAlignment: MainAxisAlignment.start,
        enabled: enabled,
        leading: icon,
        onPressed: onPressed,
        child: child,
      ).colored(color ?? (isDestructive ? context.colors.destructive : null)),
    );
  }
}
