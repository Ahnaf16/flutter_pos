import 'package:pos/routes/logic/app_route.dart';

export 'package:go_router/go_router.dart';

class RPaths {
  const RPaths._();

  // auth
  static const splash = RPath('/splash');
  static const welcome = RPath('/welcome');
  static final login = welcome + const RPath('/login');

  // home
  static const home = RPath('/home');

  // products
  static const products = RPath('/products');

  // stock
  static const stock = RPath('/stock');

  // unit
  static const unit = RPath('/unit');

  // sales
  static const sales = RPath('/sales');

  // return sales
  static const returnSales = RPath('/return_sales');

  // purchases
  static const purchases = RPath('/purchases');

  // return purchases
  static const returnPurchases = RPath('/return_purchases');

  // customer
  static const customer = RPath('/customer');

  // supplier
  static const supplier = RPath('/supplier');

  // staffs
  static const staffs = RPath('/staffs');

  // warehouse
  static const warehouse = RPath('/warehouse');

  // stockTransfer
  static const stockTransfer = RPath('/stock_transfer');

  // expense
  static const expense = RPath('/expense');

  // due
  static const due = RPath('/due');

  // moneyTransfer
  static const moneyTransfer = RPath('/money_transfer');

  // transactions
  static const transactions = RPath('/transactions');

  // settings
  static const settings = RPath('/settings');
  static RPath language = settings + const RPath('/language');
}
