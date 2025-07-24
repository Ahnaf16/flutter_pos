import 'package:pos/main.export.dart';

typedef RP = RolePermissions;

enum RolePermissions {
  manageProduct,
  manageStock,
  manageUnit,
  makeSale,
  returnSale,
  makePurchase,
  returnPurchase,
  manageCustomer,
  manageSupplier,
  manageStaff,
  manageRole,
  manageWarehouse,
  transferStock,
  manageAccounts,
  manageExpanse,
  moneyTransfer,
  transferMoney,
  transactions,
  due;

  static List<RolePermissions> get inventoryGroup => [manageProduct, manageUnit];

  static List<RolePermissions> get salesGroup => [makeSale, returnSale];
  static List<RolePermissions> get purchasesGroup => [makePurchase, returnPurchase];
  static List<RolePermissions> get salesPurchasesGroup => [makeSale, returnSale, makePurchase, returnPurchase];

  static List<RolePermissions> get contactsGroup => [manageCustomer, manageSupplier];

  static List<RolePermissions> get teamsGroup => [manageStaff, manageRole];
  static List<RolePermissions> get logisticsGroup => [manageWarehouse, transferStock];
  static List<RolePermissions> get accountingGroup => [
    manageAccounts,
    manageExpanse,
    moneyTransfer,
    transferMoney,
    transactions,
    due,
  ];
  static bool isInGroup(List<RP> group, List<RP> matchGroup) => group.any(matchGroup.contains);

  String? redirect(List<RolePermissions> p) {
    if (p.contains(this)) return null;
    return RPaths.protected.path;
  }
}
