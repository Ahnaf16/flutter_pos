import 'package:flutter/material.dart';

class DecoContainer extends StatelessWidget {
  const DecoContainer({
    super.key,
    this.color,
    this.borderColor = Colors.transparent,
    this.borderWidth = 0,
    this.borderRadius = 0,
    this.width,
    this.height,
    this.child,
    this.ignorePointer = false,
    this.shadows,
    this.clipChild = false,
    this.padding,
    this.alignment,
    this.margin,
  }) : duration = const Duration(),
       curve = Curves.linear;

  const DecoContainer.animated({
    required this.duration,
    this.curve = Curves.linear,
    super.key,
    this.color,
    this.borderColor = Colors.transparent,
    this.borderWidth = 0,
    this.borderRadius = 0,
    this.width,
    this.height,
    this.child,
    this.ignorePointer = false,
    this.shadows,
    this.clipChild = false,
    this.padding,
    this.alignment,
    this.margin,
  });

  final Alignment? alignment;
  final Color? borderColor;
  final double borderRadius;
  final double borderWidth;
  final Widget? child;
  final bool clipChild;
  final Color? color;
  final Duration duration;
  final double? height;
  final bool ignorePointer;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final List<BoxShadow>? shadows;
  final double? width;
  final Curve curve;

  @override
  Widget build(BuildContext context) {
    // Create border if we have both a color and width
    BoxBorder? border;
    if (borderColor != null && borderWidth != 0) {
      border = Border.all(color: borderColor!, width: borderWidth);
    }
    // Create decoration
    BoxDecoration dec = BoxDecoration(
      color: color,
      border: border,
      borderRadius: BorderRadius.circular(borderRadius),
      boxShadow: shadows,
    );

    return IgnorePointer(
      ignoring: ignorePointer,
      child: AnimatedContainer(
        duration: duration,
        curve: curve,
        decoration: dec,
        width: width,
        height: height,
        padding: padding,
        margin: margin,
        alignment: alignment,
        child:
            clipChild
                ? ClipRRect(
                  borderRadius: BorderRadius.circular(borderRadius),
                  child: child,
                )
                : child,
      ),
    );
  }
}
