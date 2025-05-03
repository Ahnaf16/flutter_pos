import 'package:pos/main.export.dart';

class HoverBuilder extends HookWidget {
  const HoverBuilder({super.key, required this.child, required this.builder});

  final Widget child;
  final Widget Function(bool isHovering, Widget child) builder;

  @override
  Widget build(BuildContext context) {
    final isHovering = useState(false);
    return MouseRegion(
      onEnter: (_) => isHovering.truthy(),
      onExit: (_) => isHovering.falsey(),
      child: builder(isHovering.value, child),
    );
  }
}
