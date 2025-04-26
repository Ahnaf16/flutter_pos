import 'package:pos/main.export.dart';

class Loading extends StatelessWidget {
  const Loading({super.key, this.center = true, this.size, this.primary = true, this.strokeWidth, this.value})
    : liner = false;
  const Loading.liner({super.key, this.center = true, this.size, this.primary = true, this.strokeWidth, this.value})
    : liner = true;

  final double? size;
  final bool primary;
  final double? value;
  final double? strokeWidth;
  final bool liner;
  final bool center;

  @override
  Widget build(BuildContext context) {
    final color = primary ? context.colors.primary : context.colors.primaryForeground;
    final defSize = liner ? double.infinity : 20.0;

    Widget loader;
    if (liner) {
      loader = ShadProgress(minHeight: strokeWidth ?? 3, color: color, value: value);
    } else {
      loader = CircularProgressIndicator(color: color, value: value, strokeWidth: strokeWidth ?? 3);
    }
    final widget = SizedBox(height: liner ? null : size ?? defSize, width: size ?? defSize, child: loader);

    return center == true ? Center(child: widget) : widget;
  }
}
