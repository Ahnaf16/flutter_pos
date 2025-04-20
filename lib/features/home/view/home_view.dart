import 'package:pos/main.export.dart';

class HomeView extends HookConsumerWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      headers: [AppBar(title: const Text('Home'))],
      child: SingleChildScrollView(
        padding: context.layout.pagePadding,
        child: Column(mainAxisAlignment: MainAxisAlignment.center, spacing: 20, children: [
          
         
          ],
        ),
      ),
    );
  }
}
