import 'package:pos/main.export.dart';

class Loading extends StatelessWidget {
  const Loading({super.key, this.size = 20, this.color, this.value});

  final double size;
  final Color? color;
  final double? value;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(dimension: size, child: CircularProgressIndicator(color: color, value: value));
  }
}
