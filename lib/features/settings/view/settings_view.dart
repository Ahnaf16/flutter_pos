import 'package:pos/main.export.dart';

class SettingsView extends HookConsumerWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),

      body: SingleChildScrollView(
        child: Column(
          children: [
            ListTile(
              onTap: () => RPaths.language.push(context),
              leading: const Icon(Icons.language),
              title: const Text('Language'),
            ),
          ],
        ),
      ),
    );
  }
}
