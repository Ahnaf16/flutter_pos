import 'package:pos/main.export.dart';

export 'package:go_router/go_router.dart';

class RPaths {
  const RPaths._();

  // auth
  static const splash = RPath('/splash');
  static const welcome = RPath('/welcome');
  static final login = welcome + const RPath('/login');

  // home
  static RPath home = const RPath('/home');

  // products
  static RPath products = const RPath('/products');

  // stock
  static RPath stock = const RPath('/stock');

  // unit
  static RPath unit = const RPath('/unit');

  // sales
  static RPath sales = const RPath('/sales');

  // return sales
  static RPath returnSales = const RPath('/return_sales');

  // purchases
  static RPath purchases = const RPath('/purchases');

  // return purchases
  static RPath returnPurchases = const RPath('/return_purchases');

  // customer
  static RPath customer = const RPath('/customer');

  // supplier
  static RPath supplier = const RPath('/supplier');

  // staffs
  static RPath staffs = const RPath('/staffs');
  static RPath createStaffs = const RPath('/create_staffs');
  static RPath editStaffs(String id) => RPath('/edit_staff', {'id': id});

  // roles
  static RPath roles = const RPath('/roles');
  static RPath createRole = const RPath('/create_role');
  static RPath editRole(String id) => RPath('/edit_role', {'id': id});

  // warehouse
  static RPath warehouse = const RPath('/warehouse');
  static RPath createWarehouse = const RPath('/create_warehouse');
  static RPath editWarehouse(String id) => RPath('/edit_warehouse', {'id': id});

  // stockTransfer
  static RPath stockTransfer = const RPath('/stock_transfer');

  // expense
  static RPath expense = const RPath('/expense');

  // due
  static RPath due = const RPath('/due');

  // moneyTransfer
  static RPath moneyTransfer = const RPath('/money_transfer');

  // transactions
  static RPath transactions = const RPath('/transactions');

  // settings
  static RPath settings = const RPath('/settings');
  static RPath language = settings + const RPath('/language');
}
