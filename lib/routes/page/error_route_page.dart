import 'package:pos/main.export.dart';

class ErrorRoutePage extends StatelessWidget {
  const ErrorRoutePage({super.key, this.error});
  final Object? error;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('404', style: context.text.h3),
            const SizedBox(height: 5),
            Text('Page not found', style: context.text.large),
            const SizedBox(height: 20),
            Text('$error', style: context.text.base, textAlign: TextAlign.center),
            const SizedBox(height: 20),
            PrimaryButton(
              onPressed: () => RPaths.home.go(context),
              leading: const Icon(Icons.arrow_back),
              child: const Text('Go to home'),
            ),
          ],
        ),
      ),
    );
  }
}
