import 'package:pos/main.export.dart';

export 'package:go_router/go_router.dart';

class RPaths {
  const RPaths._();

  // auth
  static const splash = RPath('/splash');
  static const maintenance = RPath('/maintenance');
  static const protected = RPath('/protected');
  static const welcome = RPath('/welcome');
  static final login = welcome + const RPath('/login');

  static const moreTools = RPath('/more_tools');

  // home
  static RPath home = const RPath('/home');

  // products
  static RPath products = const RPath('/products');
  static RPath productDetails(String id) => RPath('/details', {'id': id});
  static RPath createProduct = const RPath('/create_product');
  static RPath editProduct(String id) => RPath('/edit_product', {'id': id});

  // unit
  static RPath unit = const RPath('/unit');

  // sales
  static RPath sales = const RPath('/sales');
  static RPath createSales = const RPath('/create_sale');
  static RPath saleDetails(String id) => RPath('/sale_details', {'id': id});

  // sales return
  static RPath salesReturn = const RPath('/sales_return');

  // purchases
  static RPath purchases = const RPath('/purchases');
  static RPath createPurchases = const RPath('/create_purchases');
  static RPath purchaseDetails(String id) => RPath('/purchase_details', {'id': id});

  // purchases return
  static RPath purchasesReturn = const RPath('/purchases_return');

  // customer
  static RPath customer = const RPath('/customer');
  static RPath customerDetails(String id) => RPath('/customer_details', {'id': id});
  static RPath customerDueManagement = const RPath('/customer_due_management');
  static RPath customerMoneyTransfer = const RPath('/customer_money_transfer');

  // supplier
  static RPath supplier = const RPath('/supplier');
  static RPath supplierDetails(String id) => RPath('/supplier_details', {'id': id});
  static RPath supplierDueManagement = const RPath('/supplier_due_management');

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
  static RPath warehouseDetails(String id) => RPath('/warehouse_details', {'id': id});

  // stockTransfer
  static RPath stockTransfer = const RPath('/stock_transfer');
  static RPath stockLog = const RPath('/stock_transfer_log');

  // expense
  static RPath expense = const RPath('/expense');
  static RPath expenseCategory = const RPath('/expense_category');

  // due
  static RPath due = const RPath('/due');

  // Payment account
  static RPath paymentAccount = const RPath('/payment_account');

  // due management

  // transactions
  static RPath transactions = const RPath('/transactions');

  // settings
  static RPath settings = const RPath('/settings');
  static RPath language = settings + const RPath('/language');
}
