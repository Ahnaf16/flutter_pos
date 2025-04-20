import 'package:flutter/material.dart';

class LimitedWidthBox extends StatelessWidget {
  const LimitedWidthBox({super.key, required this.child, required this.maxWidth, this.padding, this.center = true});

  final Widget child;
  final double maxWidth;
  final EdgeInsetsGeometry? padding;
  final bool center;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = constraints.maxWidth;
        final width = screenWidth > maxWidth ? maxWidth : screenWidth;

        final c = Container(width: width, padding: padding, child: child);

        return center ? Center(child: c) : c;
      },
    );
  }
}
