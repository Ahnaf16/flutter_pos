import 'package:pos/main.export.dart';
import 'package:pos/navigation/nav_root.dart';

class LimitedWidthBox extends StatelessWidget {
  const LimitedWidthBox({
    super.key,
    required this.child,
    this.maxWidth,
    this.minWidth,
    this.height,
    this.padding,
    this.center = true,
    this.useActualWidth = false,
  });

  final Widget child;
  final double? maxWidth;
  final double? minWidth;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final bool center;
  final bool useActualWidth;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        double screenWidth = constraints.maxWidth;

        if (useActualWidth) {
          final paneSize = NavigationRoot.expandedPaneSize + (Pads.med().left * 2);
          final pagePadding = context.layout.pagePadding;
          screenWidth = context.width - paneSize - pagePadding.left - pagePadding.right - 5;
        }

        final maxWidth = this.maxWidth ?? screenWidth;
        double width = screenWidth > maxWidth ? maxWidth : screenWidth;

        if (minWidth != null) {
          width = width < minWidth! ? minWidth! : width;
        }

        final c = AnimatedContainer(duration: 250.ms, width: width, height: height, padding: padding, child: child);

        return center ? Center(child: c) : c;
      },
    );
  }
}
