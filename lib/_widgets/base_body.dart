import 'package:pos/_widgets/k_app_bar.dart';
import 'package:pos/main.export.dart';

class BaseBody extends StatelessWidget {
  const BaseBody({
    super.key,
    required this.title,
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
    required this.body,
  });

  final String title;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: KAppBar(
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
          Expanded(child: body),
        ],
      ),
    );
  }
}
