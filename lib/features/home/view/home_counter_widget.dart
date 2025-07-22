import 'package:pos/features/home/controller/home_ctrl.dart';
import 'package:pos/main.export.dart';

class HomeCounterWidget extends ConsumerWidget {
  const HomeCounterWidget(this.start, this.end, {super.key});
  final DateTime? start;
  final DateTime? end;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final counters = ref.watch(homeCountersProvider(start, end));
    final counterGradients = <String, List<Color>>{
      'Products': [const Color(0xFFD6EFF7), const Color(0xFFb3d9e6)],
      'Sales': [const Color(0xFFE8F7E4), const Color(0xFFc2e4b8)],
      'Purchase': [const Color(0xFFDDEBFA), const Color(0xFFbad3f0)],
      'Sales Return': [const Color(0xFFFFEADB), const Color(0xFFf5c7a4)],
      'Purchase Return': [const Color(0xFFF7E8FB), const Color(0xFFdbbfe9)],
      'Customer due': [const Color(0xFFDDFBFD), const Color(0xFFb4e2e4)],
      'Supplier due': [const Color(0xFFFDEBD0), const Color(0xFFF5CBA7)], // Warm beige to soft orange
      'Total account balance': [const Color(0xFFE8DAEF), const Color(0xFFD2B4DE)],
    };
    final iconColors = <String, Color>{
      'Products': const Color(0xFF11717F),
      'Sales': const Color(0xFF4B7249),
      'Purchase': const Color(0xFF376086),
      'Sales Return': const Color(0xFFAA582F),
      'Purchase Return': const Color(0xFF91479D),
      'Customer due': const Color(0xFF2D8199),
      'Supplier due': const Color(0xFFAA582F),
      'Total account balance': const Color(0xFF91479D),
    };

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
                return Container(
                  padding: Pads.med(),
                  decoration: BoxDecoration(
                    borderRadius: Corners.medBorder,
                    gradient: LinearGradient(
                      begin: const Alignment(-1.0, -1.0),
                      end: const Alignment(1.0, 1.0),
                      colors: counterGradients[title]!,
                    ),
                  ),

                  child: Stack(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(title, style: context.text.list.op(.5), maxLines: 1, overflow: TextOverflow.ellipsis),
                          OverflowMarquee(child: Text(value.toString(), style: context.text.h4)),
                          const Gap(Insets.sm),
                          InkWell(
                            hoverColor: context.colors.primary,
                            onTap: () => path.pushNamed(context),
                            child: Row(
                              children: [
                                Text('View all', style: context.text.list.op(.5)),
                                const Gap(3),
                                const Icon(LuIcons.squareArrowOutUpRight),
                              ],
                            ),
                          ),
                        ],
                      ),
                      Positioned(
                        right: 0,
                        top: 0,
                        child: CircleAvatar(
                          backgroundColor: iconColors[title],
                          radius: 20,
                          child: Icon(icon),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }
}
