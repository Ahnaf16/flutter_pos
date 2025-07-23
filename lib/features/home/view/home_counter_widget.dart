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
      'Products': context.isDark
          ? [const Color(0xFF4B8A99).op(0.5), const Color(0xFF2A5D6A)]
          : [const Color(0xFFE0F7FA).op4, const Color(0xFFB2EBF2)],
      'Sales': context.isDark
          ? [const Color(0xFF5A8B57).op(0.5), const Color(0xFF3B6139)]
          : [const Color(0xFFE8F5E9).op4, const Color(0xFFC8E6C9)],
      'Purchase': context.isDark
          ? [const Color(0xFF5A85B2).op(0.5), const Color(0xFF3A5F8B)]
          : [const Color(0xFFE3F2FD).op4, const Color(0xFFBBDEFB)],
      'Sales Return': context.isDark
          ? [const Color(0xFF9B5B38).op(0.5), const Color(0xFF743F2A)]
          : [const Color(0xFFFFF3E0).op4, const Color(0xFFFFCCBC)],
      'Purchase Return': context.isDark
          ? [const Color(0xFF7B4B8A).op(0.5), const Color(0xFF5C346A)]
          : [const Color(0xFFF3E5F5).op4, const Color(0xFFE1BEE7)],
      'Customer due': context.isDark
          ? [const Color(0xFF4B8BA6).op(0.5), const Color(0xFF2F6276)]
          : [const Color(0xFFE1F5FE).op4, const Color(0xFFB3E5FC)],
      'Supplier due': context.isDark
          ? [const Color(0xFFA68B00).op(0.5), const Color(0xFF7A6500)]
          : [const Color(0xFFFFF9C4).op4, const Color(0xFFFFF176)],
      'Total account balance': context.isDark
          ? [const Color(0xFF8B3F4A).op(0.5), const Color(0xFF6A2F3A)]
          : [const Color(0xFFFFEBEE).op4, const Color(0xFFFFCDD2)],
    };

    final iconColors = <String, Color>{
      'Products': context.isDark ? const Color(0xFF66B3C2) : const Color(0xFF11717F),
      'Sales': context.isDark ? const Color(0xFF73B071) : const Color(0xFF4B7249),
      'Purchase': context.isDark ? const Color(0xFF6B9ED1) : const Color(0xFF376086),
      'Sales Return': context.isDark ? const Color(0xFFD17A4B) : const Color(0xFFAA582F),
      'Purchase Return': context.isDark ? const Color(0xFFA466B8) : const Color(0xFF91479D),
      'Customer due': context.isDark ? const Color(0xFF6AB8D1) : const Color(0xFF2D8199),
      'Supplier due': context.isDark ? const Color(0xFFD1B000) : const Color(0xFFB99700),
      'Total account balance': context.isDark ? const Color(0xFFB85A6B) : const Color(0xFF91479D),
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
                child: InkWell(
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
                            child: Icon(
                              icon,
                              color: Colors.white,
                            ),
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
