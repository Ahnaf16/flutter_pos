import 'package:pos/main.export.dart';

class SmallButton extends StatelessWidget {
  const SmallButton({
    super.key,
    this.child,
    this.icon,
    this.onPressed,
    this.size,
    this.variant = ShadButtonVariant.ghost,
  });

  final Widget? child;
  final IconData? icon;
  final double? size;
  final VoidCallback? onPressed;
  final ShadButtonVariant variant;

  @override
  Widget build(BuildContext context) {
    return ShadButton.raw(
      height: size ?? 20,
      width: size ?? 20,
      padding: Pads.zero,
      decoration: const ShadDecoration(secondaryBorder: ShadBorder.none, secondaryFocusedBorder: ShadBorder.none),
      leading: child ?? Icon(icon),
      onPressed: onPressed,
      variant: variant,
    );
  }
}
