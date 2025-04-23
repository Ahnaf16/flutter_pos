import 'package:pos/main.export.dart';

class Loading extends StatelessWidget {
  const Loading({super.key, this.size = 20, this.primary = true, this.strokeWidth, this.value});

  final double size;
  final bool primary;
  final double? value;
  final double? strokeWidth;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: size,
      child: CircularProgressIndicator(
        color: primary ? context.colors.primary : context.colors.primaryForeground,
        value: value,
        strokeWidth: strokeWidth ?? 3,
      ),
    );
  }
}
