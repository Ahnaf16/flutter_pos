import 'dart:async';

import 'package:pos/app_root.dart';
import 'package:pos/features/auth/controller/auth_ctrl.dart';
import 'package:pos/features/auth/view/login_view.dart';
import 'package:pos/features/home/view/home_view.dart';
import 'package:pos/features/settings/view/language_view.dart';
import 'package:pos/features/settings/view/settings_view.dart';
import 'package:pos/main.export.dart';
import 'package:pos/navigation/nav_root.dart';

String rootPath = RPaths.home.path;

typedef RouteRedirect = FutureOr<String?> Function(BuildContext, GoRouterState);

final routerProvider = NotifierProvider<AppRouter, GoRouter>(AppRouter.new);

class AppRouter extends Notifier<GoRouter> {
  final _rootNavigator = GlobalKey<NavigatorState>(debugLabel: 'root');

  final _shellNavigator = GlobalKey<NavigatorState>(debugLabel: 'shell');

  GoRouter _appRouter(RouteRedirect? redirect) {
    return GoRouter(
      navigatorKey: _rootNavigator,
      redirect: redirect,
      initialLocation: rootPath,
      routes: [ShellRoute(routes: _routes, builder: (_, s, c) => AppRoot(key: s.pageKey, child: c))],
      errorBuilder: (_, state) => ErrorRoutePage(error: state.error?.message),
    );
  }

  /// The app router list
  List<RouteBase> get _routes => [
    AppRoute(RPaths.splash, (_) => const SplashPage()),

    //! auth
    AppRoute(RPaths.login, (_) => const LoginView()),

    //! home

    //! settings
    AppRoute(RPaths.language, (_) => const LanguageView()),

    //! shell
    ShellRoute(
      navigatorKey: _shellNavigator,
      builder: (_, s, child) => NavigationRoot(child, key: s.pageKey),
      routes: [AppRoute(RPaths.home, (_) => const HomeView()), AppRoute(RPaths.settings, (_) => const SettingsView())],
    ),
  ];

  @override
  GoRouter build() {
    Ctx._key = _rootNavigator;
    // Toaster.navigator = _rootNavigator;
    final auth = ref.watch(authCtrlProvider);

    FutureOr<String?> redirectLogic(ctx, GoRouterState state) async {
      final current = state.uri.toString();
      cat(current, 'route');

      if (auth.isLoading) {
        return RPaths.splash.path;
      } else if ((auth.value == null || auth.hasError) && !current.contains(RPaths.login.path)) {
        return RPaths.login.path;
      } else if (auth.value != null && current.contains(RPaths.login.path)) {
        return RPaths.home.path;
      }

      return null;
    }

    return _appRouter(redirectLogic);
  }
}

class Ctx {
  const Ctx._();
  static GlobalKey<NavigatorState>? _key;
  static BuildContext? get maybeContext => _key?.currentContext;
  static BuildContext get context => maybeContext == null ? throw Exception('Ctx.context not found') : maybeContext!;
}
