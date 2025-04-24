import 'dart:async';

import 'package:pos/app_root.dart';
import 'package:pos/features/auth/controller/auth_ctrl.dart';
import 'package:pos/features/auth/view/login_view.dart';
import 'package:pos/features/customer/view/customer_view.dart';
import 'package:pos/features/due/view/due_view.dart';
import 'package:pos/features/expense/view/expense_view.dart';
import 'package:pos/features/home/view/home_view.dart';
import 'package:pos/features/moneyTransfer/view/money_transfer_view.dart';
import 'package:pos/features/products/view/products_view.dart';
import 'package:pos/features/purchases/view/purchases_view.dart';
import 'package:pos/features/returnPurchases/view/return_purchases_view.dart';
import 'package:pos/features/returnSales/view/return_sales_view.dart';
import 'package:pos/features/sales/view/sales_view.dart';
import 'package:pos/features/settings/view/language_view.dart';
import 'package:pos/features/settings/view/settings_view.dart';
import 'package:pos/features/staffs/view/staffs_view.dart';
import 'package:pos/features/stock/view/stock_view.dart';
import 'package:pos/features/stockTransfer/view/stock_transfer_view.dart';
import 'package:pos/features/supplier/view/supplier_view.dart';
import 'package:pos/features/transactions/view/transactions_view.dart';
import 'package:pos/features/unit/view/unit_view.dart';
import 'package:pos/features/warehouse/view/warehouse_view.dart';
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

    //!home

    //!products

    //!stock

    //!unit

    //!sales

    //!returnSales

    //!purchases

    //!returnPurchases

    //!customer

    //!supplier

    //!staffs

    //!warehouse

    //!stockTransfer

    //!due

    //!moneyTransfer

    //!transactions

    //! settings
    AppRoute(RPaths.language, (_) => const LanguageView()),

    //! shell
    ShellRoute(
      navigatorKey: _shellNavigator,
      builder: (_, s, child) => NavigationRoot(child, key: s.pageKey),
      routes: [
        AppRoute(RPaths.home, (_) => const HomeView()),
        AppRoute(RPaths.products, (_) => const ProductsView()),
        AppRoute(RPaths.stock, (_) => const StockView()),
        AppRoute(RPaths.unit, (_) => const UnitView()),
        AppRoute(RPaths.sales, (_) => const SalesView()),
        AppRoute(RPaths.returnSales, (_) => const ReturnSalesView()),
        AppRoute(RPaths.purchases, (_) => const PurchasesView()),
        AppRoute(RPaths.returnPurchases, (_) => const ReturnPurchasesView()),
        AppRoute(RPaths.customer, (_) => const CustomerView()),
        AppRoute(RPaths.supplier, (_) => const SupplierView()),
        AppRoute(RPaths.staffs, (_) => const StaffsView()),
        AppRoute(RPaths.warehouse, (_) => const WarehouseView()),
        AppRoute(RPaths.stockTransfer, (_) => const StockTransferView()),
        AppRoute(RPaths.expense, (_) => const ExpenseView()),
        AppRoute(RPaths.due, (_) => const DueView()),
        AppRoute(RPaths.moneyTransfer, (_) => const MoneyTransferView()),
        AppRoute(RPaths.transactions, (_) => const TransactionsView()),
        AppRoute(RPaths.settings, (_) => const SettingsView()),
      ],
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
