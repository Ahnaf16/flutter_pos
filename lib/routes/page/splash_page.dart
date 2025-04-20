import 'package:pos/main.export.dart';

class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(kAppName, style: context.text.large),
            const Gap(60),
            const SizedBox.square(dimension: 25, child: Loading(size: 25)),
          ],
        ),
      ),
    );
  }
}
