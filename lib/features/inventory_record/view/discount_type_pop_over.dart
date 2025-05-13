import 'package:pos/main.export.dart';

class DiscountTypePopOver extends HookConsumerWidget {
  const DiscountTypePopOver({super.key, required this.type, required this.onTypeChange});

  final DiscountType type;
  final Function(DiscountType type) onTypeChange;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final popCtrl = useMemoized(ShadPopoverController.new);

    return ShadPopover(
      controller: popCtrl,
      anchor: const ShadAnchorAuto(targetAnchor: Alignment.topRight, followerAnchor: Alignment.topCenter),
      padding: Pads.zero,
      popover: (context) {
        return SizedBox(
          width: 150,
          height: 100,
          child: IntrinsicWidth(
            child: SeparatedColumn(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              separatorBuilder: () => const ShadSeparator.horizontal(margin: Pads.zero),
              children: [
                for (final t in DiscountType.values)
                  ShadButton.ghost(
                    mainAxisAlignment: MainAxisAlignment.start,
                    child: Text(t.name.up),
                    onPressed: () {
                      popCtrl.hide();
                      onTypeChange(t);
                    },
                  ),
              ],
            ),
          ),
        );
      },
      child: ShadButton.ghost(
        trailing: const Icon(LuIcons.chevronDown),
        padding: Pads.sm('lr'),
        size: ShadButtonSize.sm,
        height: 32,
        onPressed: () => popCtrl.toggle(),
        child: Text(type.name.up),
      ),
    );
  }
}
