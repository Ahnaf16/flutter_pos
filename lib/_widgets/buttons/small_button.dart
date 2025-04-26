import 'package:pos/main.export.dart';

class SmallButton extends StatelessWidget {
  const SmallButton({super.key, this.child, this.icon, this.onPressed});

  final Widget? child;
  final IconData? icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return ShadButton.ghost(
      height: 24,
      width: 24,
      padding: Pads.zero,
      leading: child ?? Icon(icon),
      onPressed: onPressed,
    );
  }
}
