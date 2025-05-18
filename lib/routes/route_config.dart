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
import 'package:pos/features/inventory_record/view/return_view.dart';
import 'package:pos/features/parties/view/parties_view.dart';
import 'package:pos/features/parties/view/party_details_view.dart';
import 'package:pos/features/payment_accounts/view/payment_accounts_view.dart';
import 'package:pos/features/products/view/create_product_view.dart';
import 'package:pos/features/products/view/product_details_view.dart';
import 'package:pos/features/products/view/products_view.dart';
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

  /// The app router list
  List<RouteBase> _routes(List<RolePermissions> p) {
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
            redirect: (_, _) => RolePermissions.manageProduct.redirect(p),
            routes: [
              AppRoute(RPaths.createProduct, (_) => const CreateProductView(), parentKey: _shell),
              AppRoute(RPaths.editProduct(':id'), (_) => const CreateProductView(), parentKey: _shell),
              AppRoute(RPaths.productDetails(':id'), (_) => const ProductDetailsView(), parentKey: _shell),
            ],
          ),
          //! stock
          AppRoute(RPaths.stock, redirect: (_, _) => RolePermissions.manageStock.redirect(p), (_) => const StockView()),
          //! unit
          AppRoute(RPaths.unit, redirect: (_, _) => RolePermissions.manageUnit.redirect(p), (_) => const UnitView()),

          //! sales
          AppRoute(
            RPaths.sales,
            redirect: (_, _) => RolePermissions.makeSale.redirect(p),
            (_) => const InventoryRecordView(type: RecordType.sale),
          ),

          //! new sales
          AppRoute(
            RPaths.createSales,
            redirect: (_, _) => RolePermissions.makeSale.redirect(p),
            (_) => const CreateRecordView(type: RecordType.sale),
          ),

          //! sales_return
          AppRoute(
            RPaths.salesReturn,
            redirect: (_, _) => RolePermissions.returnSale.redirect(p),
            (_) => const ReturnView(isSale: true),
          ),

          //! purchases
          AppRoute(
            RPaths.purchases,
            redirect: (_, _) => RolePermissions.makePurchase.redirect(p),
            (_) => const InventoryRecordView(type: RecordType.purchase),
            routes: [
              AppRoute(
                RPaths.createPurchases,
                redirect: (_, _) => RolePermissions.manageProduct.redirect(p),
                (_) => const CreateRecordView(type: RecordType.purchase),
              ),
            ],
          ),

          //! purchases_return
          AppRoute(
            RPaths.purchasesReturn,
            redirect: (_, _) => RolePermissions.returnPurchase.redirect(p),
            (_) => const ReturnView(isSale: false),
          ),

          //! customer
          AppRoute(
            RPaths.customer,
            redirect: (_, _) => RolePermissions.manageCustomer.redirect(p),
            (_) => const PartiesView(isCustomer: true),
            routes: [AppRoute(RPaths.customerDetails(':id'), (_) => const PartyDetailsView(), parentKey: _shell)],
          ),
          //! supplier
          AppRoute(
            RPaths.supplier,
            redirect: (_, _) => RolePermissions.manageSupplier.redirect(p),
            (_) => const PartiesView(),
            routes: [AppRoute(RPaths.supplierDetails(':id'), (_) => const PartyDetailsView(), parentKey: _shell)],
          ),
          //! staffs
          AppRoute(
            RPaths.staffs,
            redirect: (_, _) => RolePermissions.manageStaff.redirect(p),
            (_) => const StaffsView(),
            routes: [
              AppRoute(RPaths.createStaffs, (_) => const CreateStaffView(), parentKey: _shell),
              AppRoute(RPaths.editStaffs(':id'), (_) => const CreateStaffView(), parentKey: _shell),
            ],
          ),
          //! roles
          AppRoute(
            RPaths.roles,
            redirect: (_, _) => RolePermissions.manageRole.redirect(p),
            (_) => const UserRolesView(),
            routes: [
              AppRoute(RPaths.createRole, (_) => const CreateUserRoleView(), parentKey: _shell),
              AppRoute(RPaths.editRole(':id'), (_) => const CreateUserRoleView(), parentKey: _shell),
            ],
          ),

          //! warehouse
          AppRoute(
            RPaths.warehouse,
            redirect: (_, _) => RolePermissions.manageWarehouse.redirect(p),
            (_) => const WarehouseView(),
            routes: [
              AppRoute(RPaths.createWarehouse, (_) => const CreateWarehouseView(), parentKey: _shell),
              AppRoute(RPaths.editWarehouse(':id'), (_) => const CreateWarehouseView(), parentKey: _shell),
            ],
          ),
          //! stockTransfer
          AppRoute(
            RPaths.stockTransfer,
            redirect: (_, _) => RolePermissions.transferStock.redirect(p),
            (_) => const StockTransferView(),
          ),

          //! payment accounts
          AppRoute(
            RPaths.paymentAccount,
            redirect: (_, _) => RolePermissions.manageAccounts.redirect(p),
            (_) => const PaymentAccountsView(),
          ),
          //! expense
          AppRoute(
            RPaths.expense,
            redirect: (_, _) => RolePermissions.manageExpanse.redirect(p),
            (_) => const ExpenseView(),
          ),
          //! expense category
          AppRoute(
            RPaths.expenseCategory,
            redirect: (_, _) => RolePermissions.manageExpanse.redirect(p),
            (_) => const ExpenseCategoryView(),
          ),
          //! moneyTransfer
          AppRoute(
            RPaths.dueManagement,
            redirect: (_, _) => RolePermissions.transferMoney.redirect(p),
            (_) => const TransactionsView(type: TransactionType.transfer),
          ),
          //! transactions
          AppRoute(
            RPaths.transactions,
            redirect: (_, _) => RolePermissions.transactions.redirect(p),
            (_) => const TransactionsView(),
          ),
          //! due
          AppRoute(RPaths.due, redirect: (_, _) => RolePermissions.due.redirect(p), (_) => const DueView()),

          //! settings
          AppRoute(RPaths.settings, (_) => const SettingsView()),
        ],
      ),
    ];
  }

  GoRouter _appRouter(RouteRedirect? redirect, List<RolePermissions> permissions) {
    return GoRouter(
      navigatorKey: _root,
      redirect: redirect,
      initialLocation: rootPath,
      routes: [ShellRoute(routes: _routes(permissions), builder: (_, s, c) => AppRoot(key: s.pageKey, child: c))],
      errorBuilder: (_, state) => ErrorRoutePage(error: state.error?.message),
    );
  }

  @override
  GoRouter build() {
    Ctx._key = _root;
    final auth = ref.watch(authCtrlProvider);

    // final maintenanceMode = ref.watch(configCtrlProvider.select((s) => s.maintenanceMode));

    FutureOr<String?> redirectLogic(ctx, GoRouterState state) async {
      final current = state.uri.toString();
      cat(current, 'route');

      final user = await ref.read(authCtrlProvider.future);

      if (user == null && !current.contains(RPaths.login.path)) {
        cat('redirect to login');
        return RPaths.login.path;
      }
      if (user != null && current.contains(RPaths.login.path)) {
        cat('redirect to home');
        return RPaths.home.path;
      }

      return null;
    }

    return _appRouter(redirectLogic, auth.valueOrNull?.role?.getPermissions ?? []);
  }
}

class Ctx {
  const Ctx._();
  static GlobalKey<NavigatorState>? _key;
  static BuildContext? get maybeContext => _key?.currentContext;
  static BuildContext get context => maybeContext == null ? throw Exception('Ctx.context not found') : maybeContext!;
}
