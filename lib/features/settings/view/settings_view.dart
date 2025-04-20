import 'package:pos/main.export.dart';

class SettingsView extends HookConsumerWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      headers: [AppBar(title: const Text('Settings'))],

      child: SingleChildScrollView(
        child: Column(
          children: [
            CardButton(
              onPressed: () => RPaths.language.push(context),
              leading: const Icon(Icons.language),
              child: const Text('Language'),
            ),
          ],
        ),
      ),
    );
  }
}
