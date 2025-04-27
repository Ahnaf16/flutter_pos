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
import 'package:pos/features/staffs/view/create_staff_view.dart';
import 'package:pos/features/staffs/view/staffs_view.dart';
import 'package:pos/features/stock/view/stock_view.dart';
import 'package:pos/features/stockTransfer/view/stock_transfer_view.dart';
import 'package:pos/features/supplier/view/supplier_view.dart';
import 'package:pos/features/transactions/view/transactions_view.dart';
import 'package:pos/features/unit/view/unit_view.dart';
import 'package:pos/features/user_roles/view/create_user_role_view.dart';
import 'package:pos/features/user_roles/view/user_roles_view.dart';
import 'package:pos/features/warehouse/view/create_warehouse_view.dart';
import 'package:pos/features/warehouse/view/warehouse_view.dart';
import 'package:pos/main.export.dart';
import 'package:pos/navigation/nav_root.dart';
import 'package:pos/routes/page/protected_page.dart';

String rootPath = RPaths.home.path;

typedef RouteRedirect = FutureOr<String?> Function(BuildContext, GoRouterState);

final routerProvider = NotifierProvider<AppRouter, GoRouter>(AppRouter.new);

class AppRouter extends Notifier<GoRouter> {
  final _root = GlobalKey<NavigatorState>(debugLabel: 'root');

  final _shell = GlobalKey<NavigatorState>(debugLabel: 'shell');

  GoRouter _appRouter(RouteRedirect? redirect) {
    return GoRouter(
      navigatorKey: _root,
      redirect: redirect,
      initialLocation: rootPath,
      routes: [ShellRoute(routes: _routes, builder: (_, s, c) => AppRoot(key: s.pageKey, child: c))],
      errorBuilder: (_, state) => ErrorRoutePage(error: state.error?.message),
    );
  }

  /// The app router list
  List<RouteBase> get _routes {
    return [
      AppRoute(RPaths.splash, (_) => const SplashPage()),
      AppRoute(RPaths.protected, (_) => const ProtectedPage()),

      //! auth
      AppRoute(RPaths.login, (_) => const LoginView()),

      //! shell
      ShellRoute(
        navigatorKey: _shell,
        builder: (_, s, child) => NavigationRoot(child, key: s.pageKey),
        routes: [
          //! home
          AppRoute(RPaths.home, (_) => const HomeView()),
          //! products
          AppRoute(RPaths.products, (_) => const ProductsView()),
          //! stock
          AppRoute(RPaths.stock, (_) => const StockView()),
          //! unit
          AppRoute(RPaths.unit, (_) => const UnitView()),
          //! sales
          AppRoute(RPaths.sales, (_) => const SalesView()),
          //! returnSales
          AppRoute(RPaths.returnSales, (_) => const ReturnSalesView()),
          //! purchases
          AppRoute(RPaths.purchases, (_) => const PurchasesView()),
          //! returnPurchases
          AppRoute(RPaths.returnPurchases, (_) => const ReturnPurchasesView()),
          //! customer
          AppRoute(RPaths.customer, (_) => const CustomerView()),
          //! supplier
          AppRoute(RPaths.supplier, (_) => const SupplierView()),
          //! staffs
          AppRoute(
            RPaths.staffs,
            (_) => const StaffsView(),
            routes: [
              AppRoute(RPaths.createStaffs, (_) => const CreateStaffView(), parentKey: _shell),
              AppRoute(RPaths.editStaffs(':id'), (_) => const CreateStaffView(), parentKey: _shell),
            ],
          ),
          //! roles
          AppRoute(
            RPaths.roles,
            (_) => const UserRolesView(),
            routes: [
              AppRoute(RPaths.createRole, (_) => const CreateUserRoleView(), parentKey: _shell),
              AppRoute(RPaths.editRole(':id'), (_) => const CreateUserRoleView(), parentKey: _shell),
            ],
          ),
          //! warehouse
          AppRoute(
            RPaths.warehouse,
            (_) => const WarehouseView(),
            routes: [
              AppRoute(RPaths.createWarehouse, (_) => const CreateWarehouseView(), parentKey: _shell),
              AppRoute(RPaths.editWarehouse(':id'), (_) => const CreateWarehouseView(), parentKey: _shell),
            ],
          ),

          //! stockTransfer
          AppRoute(RPaths.stockTransfer, (_) => const StockTransferView()),
          //! expense
          AppRoute(RPaths.expense, (_) => const ExpenseView()),
          //! due
          AppRoute(RPaths.due, (_) => const DueView()),
          //! moneyTransfer
          AppRoute(RPaths.moneyTransfer, (_) => const MoneyTransferView()),
          //! transactions
          AppRoute(RPaths.transactions, (_) => const TransactionsView()),
          //! settings
          AppRoute(
            RPaths.settings,
            (_) => const SettingsView(),
            routes: [AppRoute(RPaths.language, (_) => const LanguageView())],
          ),
        ],
      ),
    ];
  }

  @override
  GoRouter build() {
    Ctx._key = _root;
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
