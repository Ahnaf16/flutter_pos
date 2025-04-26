import 'package:pos/main.export.dart';

enum DeviceSize { mobile, tablet, desktop }

class Layouts extends InheritedWidget {
  const Layouts({super.key, required super.child, required this.deviceSize, required this.pagePadding});

  final DeviceSize deviceSize;
  final EdgeInsets pagePadding;

  // Device width breakpoints
  static const double maxMobileWidth = 600;
  static const double maxTabletWidth = 1200;

  static final mobilePadding = Pads.med();
  static final tabletPadding = Pads.xl();
  static final deskTopPadding = Pads.xxl();

  @override
  bool updateShouldNotify(Layouts oldWidget) {
    return pagePadding != oldWidget.pagePadding || deviceSize != oldWidget.deviceSize;
  }

  bool get isDesktop => deviceSize == DeviceSize.desktop;
  bool get isMobile => deviceSize == DeviceSize.mobile;
  bool get isTablet => deviceSize == DeviceSize.tablet;

  Widget builder({required Widget Function() mobile, Widget Function()? tablet, Widget Function()? desktop}) {
    return switch (deviceSize) {
      DeviceSize.mobile => mobile(),
      DeviceSize.tablet => tablet?.call() ?? mobile(),
      DeviceSize.desktop => desktop?.call() ?? tablet?.call() ?? mobile(),
    };
  }

  T build<T>({required T Function() mobile, T Function()? tablet, T Function()? desktop}) {
    return switch (deviceSize) {
      DeviceSize.mobile => mobile(),
      DeviceSize.tablet => tablet?.call() ?? mobile(),
      DeviceSize.desktop => desktop?.call() ?? tablet?.call() ?? mobile(),
    };
  }

  static Layouts of(BuildContext context) {
    final Layouts? result = context.dependOnInheritedWidgetOfExactType<Layouts>();
    assert(result != null, 'No Layouts found in context');
    return result!;
  }

  static Widget init(BuildContext context, Widget? child) {
    if (child == null) return const SizedBox();

    final width = context.width;
    final deviceSize = _deviceSize(width);

    final padding = switch (deviceSize) {
      DeviceSize.mobile => mobilePadding,
      DeviceSize.tablet => tabletPadding,
      DeviceSize.desktop => deskTopPadding,
    };

    return Layouts(pagePadding: padding, deviceSize: deviceSize, child: child);
  }

  static DeviceSize _deviceSize(double width) {
    if (width <= maxMobileWidth) {
      return DeviceSize.mobile;
    } else if (width > maxMobileWidth && width < maxTabletWidth) {
      return DeviceSize.tablet;
    } else {
      return DeviceSize.desktop;
    }
  }
}
