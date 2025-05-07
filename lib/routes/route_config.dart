import 'dart:async';

import 'package:pos/app_root.dart';
import 'package:pos/features/auth/controller/auth_ctrl.dart';
import 'package:pos/features/auth/view/login_view.dart';
import 'package:pos/features/due/view/due_view.dart';
import 'package:pos/features/expense/view/expense_category_view.dart';
import 'package:pos/features/expense/view/expense_view.dart';
import 'package:pos/features/home/view/home_view.dart';
import 'package:pos/features/inventory_record/view/create_record_view.dart';
import 'package:pos/features/inventory_record/view/inventory_record_view.dart';
import 'package:pos/features/parties/view/parties_view.dart';
import 'package:pos/features/payment_accounts/view/payment_accounts_view.dart';
import 'package:pos/features/products/view/create_product_view.dart';
import 'package:pos/features/products/view/products_view.dart';
import 'package:pos/features/returnPurchases/view/return_purchases_view.dart';
import 'package:pos/features/returnSales/view/return_sales_view.dart';
import 'package:pos/features/settings/controller/settings_ctrl.dart';
import 'package:pos/features/settings/view/settings_view.dart';
import 'package:pos/features/staffs/view/create_staff_view.dart';
import 'package:pos/features/staffs/view/staffs_view.dart';
import 'package:pos/features/stock/view/stock_view.dart';
import 'package:pos/features/stockTransfer/view/stock_transfer_view.dart';
import 'package:pos/features/transactions/view/transactions_view.dart';
import 'package:pos/features/unit/view/unit_view.dart';
import 'package:pos/features/user_roles/view/create_user_role_view.dart';
import 'package:pos/features/user_roles/view/user_roles_view.dart';
import 'package:pos/features/warehouse/view/create_warehouse_view.dart';
import 'package:pos/features/warehouse/view/warehouse_view.dart';
import 'package:pos/main.export.dart';
import 'package:pos/navigation/nav_root.dart';
import 'package:pos/routes/page/maintenance_page.dart';
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
      AppRoute(RPaths.maintenance, (_) => const MaintenancePage()),

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
          AppRoute(
            RPaths.products,
            (_) => const ProductsView(),
            routes: [
              AppRoute(RPaths.createProduct, (_) => const CreateProductView(), parentKey: _shell),
              AppRoute(RPaths.editProduct(':id'), (_) => const CreateProductView(), parentKey: _shell),
            ],
          ),
          //! stock
          AppRoute(RPaths.stock, (_) => const StockView()),
          //! unit
          AppRoute(RPaths.unit, (_) => const UnitView()),
          //! sales
          AppRoute(RPaths.sales, (_) => const InventoryRecordView(type: RecordType.sale)),
          AppRoute(RPaths.createSales, (_) => const CreateRecordView(type: RecordType.sale)),
          //! returnSales
          AppRoute(RPaths.returnSales, (_) => const ReturnSalesView()),
          //! purchases
          AppRoute(RPaths.purchases, (_) => const InventoryRecordView(type: RecordType.purchase)),
          AppRoute(RPaths.createPurchases, (_) => const CreateRecordView(type: RecordType.purchase)),
          //! returnPurchases
          AppRoute(RPaths.returnPurchases, (_) => const ReturnPurchasesView()),
          //! customer
          AppRoute(RPaths.customer, (_) => const PartiesView(isCustomer: true)),
          //! supplier
          AppRoute(RPaths.supplier, (_) => const PartiesView()),
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
          //! expense category
          AppRoute(RPaths.expenseCategory, (_) => const ExpenseCategoryView()),
          //! due
          AppRoute(RPaths.due, (_) => const DueView()),
          //! moneyTransfer
          AppRoute(RPaths.moneyTransfer, (_) => const TransactionsView(type: TransactionType.transfer)),
          //! transactions
          AppRoute(RPaths.transactions, (_) => const TransactionsView()),
          //! payment accounts
          AppRoute(RPaths.paymentAccount, (_) => const PaymentAccountsView()),
          //! settings
          AppRoute(RPaths.settings, (_) => const SettingsView()),
        ],
      ),
    ];
  }

  @override
  GoRouter build() {
    Ctx._key = _root;
    final auth = ref.watch(authCtrlProvider);

    final maintenanceMode = ref.watch(configCtrlProvider.select((s) => s.maintenanceMode));

    FutureOr<String?> redirectLogic(ctx, GoRouterState state) async {
      final current = state.uri.toString();
      cat(current, 'route');

      if (maintenanceMode == true) {
        return RPaths.maintenance.path;
      }

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
