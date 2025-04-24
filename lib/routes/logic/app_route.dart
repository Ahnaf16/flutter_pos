import 'package:pos/main.export.dart';

class AppRoute extends GoRoute {
  AppRoute(
    RPath path,
    Widget Function(GoRouterState s) builder, {
    List<GoRoute> routes = const [],
    super.redirect,
    Function(GoRouterState s)? onPop,
    bool canPop = true,
    GlobalKey<NavigatorState>? parentKey,
  }) : super(
         path: path.pathWithParams,
         name: path.name,
         onExit: (c, s) {
           onPop?.call(s);
           return canPop;
         },
         routes: routes,
         parentNavigatorKey: parentKey,

         pageBuilder: (context, state) {
           return MaterialPage(child: builder(state));
         },
       );
}

class RPath {
  const RPath(this.path, [this.pathParams = const {}]);

  final String path;
  final SMap pathParams;

  String get pathWithParams {
    if (pathParams.isEmpty) return path;
    return '$path/${pathParams.entries.map((e) => ':${e.key}').toList().join('/')}';
  }

  void push(BuildContext context, {QMap query = const {}, Object? extra}) {
    query = query.map((k, v) => MapEntry(k, '$v'));
    final route = Uri(path: path, queryParameters: query).toString();
    context.push(route, extra: extra);
  }

  void pushNamed(BuildContext context, {QMap query = const {}, Object? extra}) {
    query = query.map((k, v) => MapEntry(k, '$v'));
    context.pushNamed(name, pathParameters: pathParams, queryParameters: query, extra: extra);
  }

  void go(BuildContext context, {QMap query = const {}, Object? extra}) {
    final route = Uri(path: path, queryParameters: query).toString();
    return context.go(route, extra: extra);
  }

  void goNamed(BuildContext context, {QMap query = const {}, Object? extra}) {
    return context.goNamed(name, pathParameters: pathParams, queryParameters: query, extra: extra);
  }

  String get name => nameFromPath(path);

  String get title => name.replaceAll('_', ' ').replaceAll('-', ' ').titleCase;

  RPath operator +(RPath newPath) => RPath('$path${newPath.path}');

  static String nameFromPath(String path) {
    final parts = path.split('/');
    final last = parts.last;
    if (!last.contains(':')) return last;
    final name = last.split(':').first;
    return name;
  }
}
