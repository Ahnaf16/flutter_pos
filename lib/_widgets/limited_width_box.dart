import 'package:pos/main.export.dart';

class LimitedWidthBox extends StatelessWidget {
  const LimitedWidthBox({super.key, required this.child, this.maxWidth, this.padding, this.center = true});

  final Widget child;
  final double? maxWidth;
  final EdgeInsetsGeometry? padding;
  final bool center;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = constraints.maxWidth;
        final maxWidth = this.maxWidth ?? screenWidth;
        final width = screenWidth > maxWidth ? maxWidth : screenWidth;

        final c = AnimatedContainer(duration: 250.ms, width: width, padding: padding, child: child);

        return center ? Center(child: c) : c;
      },
    );
  }
}
