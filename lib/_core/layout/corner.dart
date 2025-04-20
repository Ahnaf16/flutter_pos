import 'package:flutter/widgets.dart';

class Corners {
  const Corners._();

  /// 4 px
  static const double xs = 4;

  /// 8 px
  static const double sm = 8;

  /// 12 px
  static const double med = 12;

  /// 16 px
  static const double lg = 16;

  /// 24 px
  static const double xl = 24;

  /// 32 px
  static const double xxl = 32;

  /// 999
  static const double circle = 999;

  /// 4 px
  static const xsRadius = Radius.circular(xs);

  /// 8 px
  static const smRadius = Radius.circular(sm);

  /// 12 px
  static const mdRadius = Radius.circular(med);

  /// 16 px
  static const lgRadius = Radius.circular(lg);

  /// 24 px
  static const xlRadius = Radius.circular(xl);

  /// 32 px
  static const xxlRadius = Radius.circular(xxl);

  /// 999
  static const circleRadius = Radius.circular(circle);

  /// 4 px
  static const xsBorder = BorderRadius.all(xsRadius);

  /// 8 px
  static const smBorder = BorderRadius.all(smRadius);

  /// 12 px
  static const mdBorder = BorderRadius.all(mdRadius);

  /// 16 px
  static const lgBorder = BorderRadius.all(lgRadius);

  /// 24 px
  static const xlBorder = BorderRadius.all(xlRadius);

  /// 32 px
  static const xxlBorder = BorderRadius.all(xxlRadius);

  /// 999
  static const circleBorder = BorderRadius.all(circleRadius);
}
