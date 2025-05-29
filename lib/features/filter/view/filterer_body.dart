import 'package:pos/main.export.dart';

class FiltererBody extends StatelessWidget {
  const FiltererBody({
    super.key,
    this.children = const [],
    this.child,
    this.showBack = false,
    this.limitHeight = true,
    this.title,
    this.width,
  });
  final List<Widget> children;
  final Widget? child;
  final bool showBack;
  final String? title;
  final double? width;
  final bool limitHeight;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: limitHeight ? context.height * .4 : double.infinity,
        minWidth: width ?? 200,
      ),
      child:
          child ??
          IntrinsicWidth(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: Insets.xs,
              children: [
                FilterHeader(showBack: showBack, title: title),
                if (showBack || title != null) const ShadSeparator.horizontal(margin: Pads.zero),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  spacing: Insets.xs,
                  children: children,
                ),
              ],
            ),
          ),
    );
  }
}

class FilterHeader extends StatelessWidget {
  const FilterHeader({
    super.key,
    required this.showBack,
    required this.title,
  });

  final bool showBack;
  final String? title;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      spacing: 8,
      children: [
        if (showBack)
          SmallButton(
            onPressed: () => context.nPop(),
            icon: LuIcons.chevronLeft,
          ),
        if (title != null) Text(title!),
      ],
    );
  }
}
