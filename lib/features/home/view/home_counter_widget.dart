import 'package:pos/features/home/controller/home_ctrl.dart';
import 'package:pos/main.export.dart';

class HomeCounterWidget extends ConsumerWidget {
  const HomeCounterWidget(this.start, this.end, {super.key});
  final DateTime? start;
  final DateTime? end;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final counters = ref.watch(homeCountersProvider(start, end));

    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: context.layout.isMobile ? 2 : 4,
        crossAxisSpacing: Insets.med,
        mainAxisSpacing: Insets.med,
        mainAxisExtent: 120,
      ),
      physics: const NeverScrollableScrollPhysics(),
      itemCount: counters.length,
      shrinkWrap: true,
      itemBuilder: (BuildContext context, int index) {
        final MapEntry(key: (title, path, icon), :value) = counters.entries.toList()[index];
        return Stack(
          fit: StackFit.expand,
          children: [
            Builder(
              builder: (context) {
                return ShadCard(
                  padding: Pads.med(),
                  childPadding: Pads.med('t'),
                  title: Row(
                    spacing: Insets.med,
                    children: [
                      Icon(icon),
                      Flexible(child: Text(title, style: context.text.list.op(.5))),
                    ],
                  ),
                  child: OverflowMarquee(child: Text(value.toString(), style: context.text.h4)),
                );
              },
            ),

            Positioned(
              bottom: 15,
              right: 15,
              child: SmallButton(icon: LuIcons.squareArrowOutUpRight, onPressed: () => path.pushNamed(context)),
            ),
          ],
        );
      },
    );
  }
}
