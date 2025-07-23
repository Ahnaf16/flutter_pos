import 'package:pos/main.export.dart';

class BaseBody extends StatelessWidget {
  const BaseBody({
    super.key,
    this.title,
    this.actions = const [],
    this.leading,
    this.bottom,
    this.bottomHeight,
    this.actionGap = Insets.sm,
    this.actionGapEnd,
    this.floatingActionButton,
    this.bottomNavigationBar,
    this.isLoading = false,
    this.appBarSeparator = false,
    this.padding,
    this.alignment = Alignment.topCenter,
    this.scrollable = false,
    this.noAPPBar = false,
    required this.body,
  });

  final String? title;
  final List<Widget> actions;
  final Widget? leading;
  final Widget? bottom;
  final Size? bottomHeight;
  final double actionGap;
  final double? actionGapEnd;
  final Widget? floatingActionButton;
  final Widget? bottomNavigationBar;
  final Widget body;
  final bool isLoading;
  final bool appBarSeparator;
  final EdgeInsetsGeometry? padding;
  final AlignmentGeometry alignment;
  final bool scrollable;
  final bool noAPPBar;

  @override
  Widget build(BuildContext context) {
    Widget child = AnimatedPadding(
      padding: padding ?? Pads.med(),
      duration: 250.ms,
      child: body,
    );

    if (scrollable) {
      child = SingleChildScrollView(child: child);
    }

    return SelectionArea(
      child: Scaffold(
        appBar: noAPPBar
            ? null
            : KAppBar(
                title: title,
                actions: actions,
                leading: leading,
                bottom: bottom,
                bottomHeight: bottomHeight,
                actionGap: actionGap,
                actionGapEnd: actionGapEnd,
              ),
        floatingActionButton: floatingActionButton,
        body: Column(
          children: [
            if (appBarSeparator) const ShadSeparator.horizontal(margin: Pads.zero),
            if (isLoading) const ShadProgress(minHeight: 1),
            Expanded(
              child: Align(alignment: alignment, child: child),
            ),
          ],
        ),
      ),
    );
  }
}
