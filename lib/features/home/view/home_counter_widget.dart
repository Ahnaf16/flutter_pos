import 'package:pos/features/home/controller/home_ctrl.dart';
import 'package:pos/main.export.dart';

class HomeCounterWidget extends ConsumerStatefulWidget {
  const HomeCounterWidget(this.start, this.end, {super.key});
  final DateTime? start;
  final DateTime? end;

  @override
  ConsumerState<HomeCounterWidget> createState() => _HomeCounterWidgetState();
}

class _HomeCounterWidgetState extends ConsumerState<HomeCounterWidget> {
  final hoveredIndex = ValueNotifier<int?>(null);

  @override
  Widget build(BuildContext context) {
    final counters = ref.watch(homeCountersProvider(widget.start, widget.end));
    final counterGradients = <String, List<Color>>{
      'Products': [const Color(0xFFE0F7FA).op4, const Color(0xFFB2EBF2)],
      'Sales': [const Color(0xFFE8F5E9).op4, const Color(0xFFC8E6C9)],
      'Purchase': [const Color(0xFFE3F2FD).op4, const Color(0xFFBBDEFB)],
      'Sales Return': [const Color(0xFFFFF3E0).op4, const Color(0xFFFFCCBC)],
      'Purchase Return': [const Color(0xFFF3E5F5).op4, const Color(0xFFE1BEE7)],
      'Customer due': [const Color(0xFFE1F5FE).op4, const Color(0xFFB3E5FC)],
      'Supplier due': [const Color(0xFFFFF9C4).op4, const Color(0xFFFFF176)],
      'Total account balance': [const Color(0xFFFFEBEE).op4, const Color(0xFFFFCDD2)],
    };

    final iconColors = <String, Color>{
      'Products': const Color(0xFF11717F),
      'Sales': const Color(0xFF4B7249),
      'Purchase': const Color(0xFF376086),
      'Sales Return': const Color(0xFFAA582F),
      'Purchase Return': const Color(0xFF91479D),
      'Customer due': const Color(0xFF2D8199),
      'Supplier due': const Color(0xFFB99700),
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
      shrinkWrap: true,
      itemCount: counters.length,
      itemBuilder: (context, index) {
        final MapEntry(key: (title, path, icon), :value) = counters.entries.toList()[index];

        return MouseRegion(
          onEnter: (_) => hoveredIndex.value = index,
          onExit: (_) => hoveredIndex.value = null,
          child: ValueListenableBuilder<int?>(
            valueListenable: hoveredIndex,
            builder: (context, hovered, _) {
              final hover = hovered == index;
              return AnimatedScale(
                scale: hover ? 1.03 : 1.0,
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOut,
                child: GestureDetector(
                  onTap: () => path.pushNamed(context),
                  child: Container(
                    padding: Pads.med(),
                    decoration: BoxDecoration(
                      borderRadius: Corners.medBorder,
                      border: Border.all(color: iconColors[title]!.op3),
                      gradient: LinearGradient(
                        begin: const Alignment(-1.0, -1.0),
                        end: const Alignment(1.0, 1.0),
                        colors: counterGradients[title]!,
                      ),
                      boxShadow: hover
                          ? [
                              BoxShadow(
                                color: iconColors[title]!.op(0.25),
                                blurRadius: 12,
                                offset: const Offset(0, 6),
                              ),
                            ]
                          : [],
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
                            Row(
                              children: [
                                Text('View all', style: context.text.list.op(.5)),
                                const Gap(3),
                                const Icon(Icons.arrow_outward_rounded, size: 15),
                              ],
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
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
