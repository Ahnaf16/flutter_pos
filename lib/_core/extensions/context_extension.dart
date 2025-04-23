import 'package:pos/main.export.dart';

extension RouteEx on BuildContext {
  GoRouter get route => GoRouter.of(this);
  GoRouterState get routeState => GoRouterState.of(this);

  T? tryGetExtra<T>() {
    if (routeState.extra case final T t) return t;
    return null;
  }

  Map<String, String> get pathParams => routeState.pathParameters;
  String? param(String key) => pathParams[key];
  Map<String, String> get queryParams => routeState.uri.queryParameters;

  String? query(String key) => queryParams[key];

  String? queryDecode(String key) => queryParams.containsKey(key) ? decodeUri(queryParams[key]!) : null;

  void nPop<T extends Object?>([T? result]) => Navigator.of(this).pop(result);

  Future<T?> nPush<T extends Object?>(Widget page, {bool? fullScreen}) {
    final route = MaterialPageRoute<T>(builder: (c) => page, fullscreenDialog: fullScreen ?? false);

    return Navigator.of(this).push<T>(route);
  }

  Future<T?> nPushReplace<T extends Object?>(Widget page) {
    final route = MaterialPageRoute<T>(builder: (c) => page);
    return Navigator.of(this).pushReplacement(route);
  }
}

extension ContextEx on BuildContext {
  MediaQueryData get mq => MediaQuery.of(this);

  Size get size => MediaQuery.sizeOf(this);
  double get height => size.height;
  double get width => size.width;

  ShadThemeData get theme => ShadTheme.of(this);

  ShadTextTheme get text => theme.textTheme;
  ShadColorScheme get colors => theme.colorScheme;

  ShadTextTheme textFromGoogle(GoogleFontBuilder fontBuilder) =>
      ShadTextTheme.fromGoogleFont(fontBuilder, textTheme: text);

  Brightness get bright => theme.brightness;

  bool get isDark => bright == Brightness.dark;
  bool get isLight => bright == Brightness.light;

  Layouts get layout => Layouts.of(this);
}
