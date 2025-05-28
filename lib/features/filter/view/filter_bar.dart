import 'package:navigator_resizable/navigator_resizable.dart';
import 'package:pos/main.export.dart';

class FilterBar extends HookConsumerWidget {
  const FilterBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final popCtrl = useMemoized(ShadPopoverController.new);

    return Row(
      children: [
        LimitedWidthBox(
          maxWidth: 250,
          child: ShadTextField(
            hintText: 'Search',
            onChanged: (v) {},
            showClearButton: true,
          ),
        ),
        ShadPopover(
          controller: popCtrl,
          padding: Pads.sm(),
          anchor: const ShadAnchorAuto(targetAnchor: Alignment.bottomRight, offset: Offset(13, 0)),
          popover: (context) => NavigatorResizable(
            child: Navigator(
              onGenerateInitialRoutes: (_, __) => [
                ResizableMaterialPageRoute(
                  builder: (context) => const SizedBox(
                    width: 200,
                    child: TestPage1(),
                  ),
                ),
              ],
            ),
          ),
          child: ShadButton.outline(
            leading: const Icon(LuIcons.funnel),
            child: const Text('Filter'),
            onPressed: () => popCtrl.toggle(),
          ),
        ),

        ShadIconButton.outline(
          icon: const Icon(LuIcons.refreshCw),
          onPressed: () {},
        ),
      ],
    );
  }
}

class TestPage1 extends StatelessWidget {
  const TestPage1({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.purple,
      height: 500,
      width: 200,
      alignment: Alignment.center,
      child: ShadButton(
        child: const Text('Push'),
        onPressed: () {
          Navigator.push(
            context,
            ResizableMaterialPageRoute(
              builder: (context) => const TestPage2(),
            ),
          );
        },
      ),
    );
  }
}

class TestPage2 extends StatelessWidget {
  const TestPage2({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.blue,
      height: 300,
      width: 200,
      alignment: Alignment.center,
      child: ShadButton(
        child: const Text('pop'),
        onPressed: () {
          Navigator.pop(context);
        },
      ),
    );
  }
}
