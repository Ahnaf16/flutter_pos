import 'package:pos/features/home/controller/home_ctrl.dart';
import 'package:pos/main.export.dart';

class HomeView extends HookConsumerWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final counters = ref.watch(homeCountersProvider);

    return BaseBody(
      scrollable: true,
      noAPPBar: true,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: Insets.lg,
        children: [
          GridView.builder(
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 300,
              crossAxisSpacing: Insets.med,
              mainAxisSpacing: Insets.med,
              mainAxisExtent: 120,
            ),
            itemCount: counters.length,
            shrinkWrap: true,
            itemBuilder: (BuildContext context, int index) {
              final MapEntry(key: (title, path), :value) = counters.entries.toList()[index];
              return Stack(
                fit: StackFit.expand,
                children: [
                  ShadCard(
                    padding: Pads.med(),
                    childPadding: Pads.med('t'),
                    title: OverflowMarquee(child: Text(title, style: context.text.list.op(.5))),
                    child: OverflowMarquee(child: Text(value.toString(), style: context.text.h4)),
                  ),

                  Positioned(
                    bottom: 15,
                    right: 15,
                    child: SmallButton(icon: LuIcons.squareArrowOutUpRight, onPressed: () => path.pushNamed(context)),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
