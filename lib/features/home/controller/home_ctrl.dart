import 'package:pos/features/inventory_record/controller/inventory_record_ctrl.dart';
import 'package:pos/features/parties/controller/parties_ctrl.dart';
import 'package:pos/features/payment_accounts/controller/payment_accounts_ctrl.dart';
import 'package:pos/features/products/controller/products_ctrl.dart';
import 'package:pos/main.export.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'home_ctrl.g.dart';

@Riverpod(keepAlive: true)
class ViewingWH extends _$ViewingWH {
  Future<void> updateHouse(WareHouse? house) async {
    if (house?.isDefault == true) return state = null;
    state = house;
  }

  @override
  WareHouse? build() => null;
}

@Riverpod()
class HomeCounters extends _$HomeCounters {
  @override
  Map<(String, RPath), dynamic> build() {
    final products = ref.watch(productsCtrlProvider).maybeList();
    final inventory = ref.watch(inventoryCtrlProvider(null)).maybeList();
    final returns = ref.watch(inventoryReturnCtrlProvider(null)).maybeList();
    final peoples = ref.watch(partiesCtrlProvider(null)).maybeList();
    final accounts = ref.watch(PaymentAccountsCtrlProvider()).maybeList();

    final sales = inventory.where((e) => e.type == RecordType.sale);
    final purchases = inventory.where((e) => e.type == RecordType.purchase);
    final returnSales = returns.where((e) => e.returnedRec.type == RecordType.sale);
    final returnPurchases = returns.where((e) => e.returnedRec.type == RecordType.purchase);

    final todaysSales = sales.where((e) => !e.status.isReturned && e.date.isSameDay(DateTime.now()));
    final todaysPurchases = purchases.where((e) => !e.status.isReturned && e.date.isSameDay(DateTime.now()));

    return {
      ('Products', RPaths.products): products.length,
      ('Total Stock', RPaths.stock): products.map((e) => e.quantity).sum,
      ('Sales', RPaths.sales): sales.where((e) => !e.status.isReturned).map((e) => e.payable).sum.currency(),
      ('Purchase', RPaths.purchases): purchases.where((e) => !e.status.isReturned).map((e) => e.payable).sum.currency(),
      ('Today\'s Sales', RPaths.sales): todaysSales.map((e) => e.payable).sum.currency(),
      ('Today\'s Purchase', RPaths.purchases): todaysPurchases.map((e) => e.payable).sum.currency(),
      ('Sales Return', RPaths.salesReturn): returnSales.map((e) => e.deductedFromAccount).sum.currency(),
      ('Purchase Return', RPaths.purchasesReturn): returnPurchases.map((e) => e.deductedFromAccount).sum.currency(),
      ('Customer due', RPaths.customer):
          peoples.where((e) => e.isCustomer && e.hasDue()).map((e) => e.due).sum.currency(),
      ('Supplier due', RPaths.supplier):
          peoples.where((e) => !e.isCustomer && e.hasBalance()).map((e) => e.due.abs()).sum.currency(),
      ('Total account balance', RPaths.paymentAccount): accounts.map((e) => e.amount).sum.currency(),
    };
  }
}
