import 'package:pos/main.export.dart';

class SmallButton extends StatelessWidget {
  const SmallButton({super.key, this.child, this.icon, this.onPressed, this.size});

  final Widget? child;
  final IconData? icon;
  final double? size;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return ShadButton.ghost(
      height: size ?? 24,
      width: size ?? 24,
      size: ShadButtonSize.sm,
      padding: Pads.zero,
      leading: child ?? Icon(icon),
      onPressed: onPressed,
    );
  }
}
