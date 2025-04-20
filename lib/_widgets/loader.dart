import 'package:pos/main.export.dart';

class Loading extends StatelessWidget {
  const Loading({super.key, this.size = 20, this.onSurface = false, this.value});

  final double size;
  final bool onSurface;
  final double? value;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: size,
      child: CircularProgressIndicator(size: size, onSurface: onSurface, value: value),
    );
  }
}
