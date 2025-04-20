import 'package:pos/main.export.dart';

class KNavigationRail extends StatefulWidget {
  final Color? backgroundColor;
  final List<NavigationBarItem> children;
  final NavigationRailAlignment alignment;
  final Axis direction;
  final double? spacing;
  final NavigationLabelType labelType;
  final NavigationLabelPosition labelPosition;
  final NavigationLabelSize labelSize;
  final EdgeInsetsGeometry? padding;
  final BoxConstraints? constraints;
  final int? index;
  final ValueChanged<int>? onSelected;
  final double? surfaceOpacity;
  final double? surfaceBlur;
  final bool expanded;
  final bool keepMainAxisSize;
  final bool keepCrossAxisSize;

  const KNavigationRail({
    super.key,
    this.backgroundColor,
    this.alignment = NavigationRailAlignment.center,
    this.direction = Axis.vertical,
    this.spacing,
    this.labelType = NavigationLabelType.selected,
    this.labelPosition = NavigationLabelPosition.bottom,
    this.labelSize = NavigationLabelSize.small,
    this.padding,
    this.constraints,
    this.index,
    this.onSelected,
    this.surfaceOpacity,
    this.surfaceBlur,
    this.expanded = true,
    this.keepMainAxisSize = false,
    this.keepCrossAxisSize = false,
    required this.children,
  });

  @override
  State<KNavigationRail> createState() => _KNavigationRailState();
}

class _KNavigationRailState extends State<KNavigationRail> with NavigationContainerMixin {
  AlignmentGeometry get _alignment {
    switch ((widget.alignment, widget.direction)) {
      case (NavigationRailAlignment.start, Axis.horizontal):
        return AlignmentDirectional.centerStart;
      case (NavigationRailAlignment.center, Axis.horizontal):
        return AlignmentDirectional.topCenter;
      case (NavigationRailAlignment.end, Axis.horizontal):
        return AlignmentDirectional.centerEnd;
      case (NavigationRailAlignment.start, Axis.vertical):
        return AlignmentDirectional.topCenter;
      case (NavigationRailAlignment.center, Axis.vertical):
        return AlignmentDirectional.center;
      case (NavigationRailAlignment.end, Axis.vertical):
        return AlignmentDirectional.bottomCenter;
    }
  }

  void _onSelected(int index) {
    widget.onSelected?.call(index);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scaling = theme.scaling;
    final parentPadding = widget.padding ?? (const EdgeInsets.symmetric(vertical: 8, horizontal: 12) * scaling);
    final directionality = Directionality.of(context);
    final resolvedPadding = parentPadding.resolve(directionality);
    return RepaintBoundary(
      child: Data.inherit(
        data: NavigationControlData(
          containerType: NavigationContainerType.rail,
          parentLabelType: widget.labelType,
          parentLabelPosition: widget.labelPosition,
          parentLabelSize: widget.labelSize,
          parentPadding: resolvedPadding,
          direction: widget.direction,
          selectedIndex: widget.index,
          onSelected: _onSelected,
          expanded: widget.expanded,
          childCount: widget.children.length,
          spacing: widget.spacing ?? (8 * scaling),
          keepCrossAxisSize: widget.keepCrossAxisSize,
          keepMainAxisSize: widget.keepMainAxisSize,
        ),
        child: SurfaceBlur(
          surfaceBlur: widget.surfaceBlur,
          child: Align(
            alignment: _alignment,
            child: Container(
              constraints: widget.constraints,
              color: widget.backgroundColor ?? (theme.colorScheme.background.scaleAlpha(widget.surfaceOpacity ?? 1)),
              child: SingleChildScrollView(
                scrollDirection: widget.direction,
                padding: resolvedPadding,
                child: _wrapIntrinsic(
                  Flex(
                    direction: widget.direction,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: wrapChildren(context, widget.children),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _wrapIntrinsic(Widget child) {
    if (widget.direction == Axis.horizontal) {
      return IntrinsicHeight(child: child);
    }
    return IntrinsicWidth(child: child);
  }
}
