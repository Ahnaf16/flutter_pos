import 'package:flutter/material.dart';

class IconStack extends StatelessWidget {
  const IconStack({super.key, required this.icons, this.size, this.color});

  final Color? color;

  /// List of [IconData] or [IconDataProps] to draw
  final List<IconData> icons;
  final double? size;

  @override
  Widget build(BuildContext context) {
    List<Widget> ic = [
      for (final icon in icons)
        if (icon case IconDataProps i)
          Icon(i, size: i.size ?? size, color: (i.color ?? color)?.withValues(alpha: i.op))
        else
          Icon(icon, size: size, color: color),
    ];

    return Stack(alignment: Alignment.center, children: ic);
  }
}

class IconDataProps extends IconData {
  const IconDataProps(IconData icon, {this.size, this.color, this.op = 1}) : _icon = icon, super(0);

  final Color? color;
  final double? size;

  /// opacity of the color Min 0 Max 1
  final double op;
  final IconData _icon;

  @override
  int get codePoint => _icon.codePoint;

  @override
  String? get fontFamily => _icon.fontFamily;

  @override
  String? get fontPackage => _icon.fontPackage;

  @override
  bool get matchTextDirection => _icon.matchTextDirection;

  @override
  List<String>? get fontFamilyFallback => _icon.fontFamilyFallback;
}
