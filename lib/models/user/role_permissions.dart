import 'package:pos/main.export.dart';

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

  static List<RolePermissions> get inventoryGroup => [manageProduct, manageStock, manageUnit];
  static List<RolePermissions> get salesGroup => [makeSale, returnSale];
  static List<RolePermissions> get purchasesGroup => [makePurchase, returnPurchase];
  static List<RolePermissions> get peopleGroup => [manageCustomer, manageSupplier, manageStaff, manageRole];
  static List<RolePermissions> get logisticsGroup => [manageWarehouse, transferStock];
  static List<RolePermissions> get accountingGroup => [
    manageAccounts,
    manageExpanse,
    moneyTransfer,
    transferMoney,
    transactions,
    due,
  ];
  static bool isInGroup(List<RolePermissions> group, List<RolePermissions> matchGroup) =>
      group.any(matchGroup.contains);

  String? redirect(List<RolePermissions> p) {
    if (p.contains(this)) return null;
    return RPaths.protected.path;
  }
}
