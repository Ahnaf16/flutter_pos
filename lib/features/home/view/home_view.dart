import 'package:pos/main.export.dart';

class HomeView extends HookConsumerWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      headers: const [AppBar()],
      child: SingleChildScrollView(
        padding: context.layout.pagePadding,
        child: const Column(mainAxisAlignment: MainAxisAlignment.center, spacing: 20),
      ),
    );
  }
}
