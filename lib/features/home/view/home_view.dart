import 'package:pos/features/home/view/bar_widget.dart';
import 'package:pos/features/home/view/home_counter_widget.dart';
import 'package:pos/features/home/view/pie_widget.dart';
import 'package:pos/main.export.dart';

class HomeView extends HookConsumerWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const BaseBody(
      scrollable: true,
      noAPPBar: true,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: Insets.lg,
        children: [HomeCounterWidget(), Gap(8), BarWidget(), Gap(8), PieWidget(), Gap(8)],
      ),
    );
  }
}
