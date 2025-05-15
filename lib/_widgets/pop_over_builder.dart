import 'package:pos/main.export.dart';

class PopOverBuilder extends HookWidget {
  const PopOverBuilder({super.key, required this.children, this.icon});

  final List<Widget> children;
  final Widget? icon;

  @override
  Widget build(BuildContext context) {
    final popCtrl = useMemoized(ShadPopoverController.new);

    return ShadPopover(
      controller: popCtrl,
      padding: Pads.sm(),
      anchor: const ShadAnchorAuto(followerAnchor: Alignment.bottomLeft, offset: Offset(15, 0)),
      child: ShadButton.ghost(onPressed: () => popCtrl.toggle(), child: const Icon(LuIcons.ellipsisVertical)),
      popover: (context) {
        return IntrinsicWidth(
          child: Column(
            spacing: Insets.xs,
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: children,
          ),
        );
      },
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
  });

  final Widget? child;
  final Widget? icon;
  final VoidCallback? onPressed;
  final bool isDestructive;
  final bool enabled;
  @override
  Widget build(BuildContext context) {
    return ShadButton.raw(
      variant: isDestructive ? ShadButtonVariant.destructive : ShadButtonVariant.ghost,
      size: ShadButtonSize.sm,
      mainAxisAlignment: MainAxisAlignment.start,
      enabled: enabled,
      leading: icon,
      onPressed: onPressed,
      child: child,
    );
  }
}
