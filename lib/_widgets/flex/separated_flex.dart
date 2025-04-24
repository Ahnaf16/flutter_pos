import 'package:flutter/material.dart';

class SeparatedRow extends StatelessWidget {
  const SeparatedRow({
    required this.children,
    this.separatorBuilder,
    super.key,
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.crossAxisAlignment = CrossAxisAlignment.center,
    this.mainAxisSize = MainAxisSize.max,
    this.verticalDirection = VerticalDirection.down,
    this.textBaseline = TextBaseline.alphabetic,
    this.textDirection = TextDirection.ltr,
    this.padding = EdgeInsets.zero,
    this.spacing,
  });

  final List<Widget> children;
  final Widget Function()? separatorBuilder;
  final MainAxisAlignment mainAxisAlignment;
  final CrossAxisAlignment crossAxisAlignment;
  final MainAxisSize mainAxisSize;
  final TextBaseline textBaseline;
  final TextDirection textDirection;
  final VerticalDirection verticalDirection;
  final EdgeInsets padding;
  final double? spacing;

  @override
  Widget build(BuildContext context) {
    final copy = children.toList();

    if (separatorBuilder != null) {
      for (var i = copy.length; i-- > 0;) {
        if (i > 0) copy.insert(i, separatorBuilder!());
      }
    }

    final Widget row = Row(
      spacing: spacing ?? 0,
      mainAxisAlignment: mainAxisAlignment,
      crossAxisAlignment: crossAxisAlignment,
      mainAxisSize: mainAxisSize,
      textBaseline: textBaseline,
      textDirection: textDirection,
      verticalDirection: verticalDirection,
      children: copy,
    );
    return Padding(padding: padding, child: row);
  }
}

class SeparatedColumn extends StatelessWidget {
  const SeparatedColumn({
    required this.children,
    required this.separatorBuilder,
    super.key,
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.crossAxisAlignment = CrossAxisAlignment.center,
    this.mainAxisSize = MainAxisSize.max,
    this.verticalDirection = VerticalDirection.down,
    this.textBaseline = TextBaseline.alphabetic,
    this.textDirection = TextDirection.ltr,
    this.padding = EdgeInsets.zero,
  });
  final List<Widget> children;
  final Widget Function() separatorBuilder;
  final MainAxisAlignment mainAxisAlignment;
  final CrossAxisAlignment crossAxisAlignment;
  final MainAxisSize mainAxisSize;
  final TextBaseline textBaseline;
  final TextDirection textDirection;
  final VerticalDirection verticalDirection;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    final copy = children.toList();
    for (var i = copy.length; i-- > 0;) {
      if (i > 0) copy.insert(i, separatorBuilder());
    }
    final col = Column(
      mainAxisAlignment: mainAxisAlignment,
      crossAxisAlignment: crossAxisAlignment,
      mainAxisSize: mainAxisSize,
      textBaseline: textBaseline,
      textDirection: textDirection,
      verticalDirection: verticalDirection,
      children: copy,
    );
    return Padding(padding: padding, child: col);
  }
}
