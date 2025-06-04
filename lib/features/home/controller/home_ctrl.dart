import 'dart:math';

import 'package:pos/features/inventory_record/controller/inventory_record_ctrl.dart';
import 'package:pos/features/parties/controller/parties_ctrl.dart';
import 'package:pos/features/payment_accounts/controller/payment_accounts_ctrl.dart';
import 'package:pos/features/products/controller/products_ctrl.dart';
import 'package:pos/features/transactions/controller/transactions_ctrl.dart';
import 'package:pos/main.export.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'home_ctrl.g.dart';

@Riverpod(keepAlive: true)
class ViewingWH extends _$ViewingWH {
  Future<void> updateHouse(WareHouse? house, WareHouse? my) async {
    if (house?.isDefault == true) {
      state = (my: my ?? state.my, viewing: null);
    } else {
      state = (my: my ?? state.my, viewing: house);
    }
  }

  @override
  ({WareHouse? my, WareHouse? viewing}) build() => (my: null, viewing: null);
}

@Riverpod()
class HomeCounters extends _$HomeCounters {
  @override
  Map<(String, RPath, IconData), dynamic> build(DateTime? start, DateTime? end) {
    final products = ref.watch(productsCtrlProvider).maybeList().filterByDateRange(start, end, (e) => e.createdAt);
    final inventory = ref.watch(inventoryCtrlProvider(null)).maybeList().filterByDateRange(start, end, (e) => e.date);
    final returns = ref
        .watch(inventoryReturnCtrlProvider(null))
        .maybeList()
        .filterByDateRange(start, end, (e) => e.returnDate);
    final peoples = ref.watch(partiesCtrlProvider(null)).maybeList();
    final accounts = ref.watch(paymentAccountsCtrlProvider()).maybeList();

    final sales = inventory.where((e) => e.type == RecordType.sale);
    final purchases = inventory.where((e) => e.type == RecordType.purchase);
    final returnSales = returns.where((e) => e.returnedRec?.type == RecordType.sale);
    final returnPurchases = returns.where((e) => e.returnedRec?.type == RecordType.purchase);

    return {
      ('Products', RPaths.products, LuIcons.box): products.length,
      ('Sales', RPaths.sales, LuIcons.shoppingCart): sales
          .where((e) => !e.status.isReturned)
          .map((e) => e.payable)
          .sum
          .currency(),
      ('Purchase', RPaths.purchases, LuIcons.scrollText): purchases
          .where((e) => !e.status.isReturned)
          .map((e) => e.payable)
          .sum
          .currency(),
      ('Sales Return', RPaths.salesReturn, LuIcons.undo): returnSales.map((e) => e.adjustAccount).sum.currency(),
      ('Purchase Return', RPaths.purchasesReturn, LuIcons.redo): returnPurchases
          .map((e) => e.adjustAccount)
          .sum
          .currency(),
      ('Customer due', RPaths.customer, LuIcons.handCoins): peoples
          .where((e) => e.isCustomer && e.hasDue())
          .map((e) => e.due)
          .sum
          .currency(),
      ('Supplier due', RPaths.supplier, LuIcons.handCoins): peoples
          .where((e) => !e.isCustomer && e.hasBalance())
          .map((e) => e.due.abs())
          .sum
          .currency(),
      ('Total account balance', RPaths.paymentAccount, LuIcons.creditCard): accounts
          .map((e) => e.amount)
          .sum
          .currency(),
    };
  }
}

@riverpod
class BarDataCtrl extends _$BarDataCtrl {
  @override
  Map<int, List<TransactionLog>> build(DateTime? start, DateTime? end) {
    final trx = ref.watch(transactionLogCtrlProvider).maybeList().filterByDateRange(start, end, (e) => e.date);

    final data = <int, List<TransactionLog>>{};

    final trxGroup = trx.groupListsBy((e) => e.date.month);
    for (var month = 1; month <= 12; month++) {
      data[month] = trxGroup[month] ?? [];
    }

    return data;
  }
}

@riverpod
class PieDataCtrl extends _$PieDataCtrl {
  @override
  Map<TransactionType, List<TransactionLog>> build() {
    final trx = ref.watch(transactionLogCtrlProvider).maybeList().groupListsBy((e) => e.type);

    final data = <TransactionType, List<TransactionLog>>{};

    for (final type in TransactionType.values) {
      data[type] = trx[type] ?? [];
    }

    return data;
  }
}

DateTime getMonth(int month, [int? day]) => DateTime.now().copyWith(month: month, day: day).justDate;
String getMonthName(int month, [int? day]) => getMonth(month, day).formatDate('MMM');

// ignore: unused_element
List<TransactionLog> get _trxMock {
  return List.generate(
    100,
    (index) {
      final rnd = Random(index);
      return TransactionLog(
        id: index.toString(),
        trxNo: index.toString(),
        amount: rnd.nextInt(3000),
        account: null,
        transactedTo: null,
        transactionForm: null,
        customInfo: {},
        transactionBy: null,
        date: DateTime.now().copyWith(month: rnd.nextInt(12), day: rnd.nextInt(30)),
        type: TransactionType.values[rnd.nextInt(TransactionType.values.length)],
        note: null,
        adjustBalance: false,
        record: null,
        transactedToShop: false,
        transferredToAccount: null,
        isBetweenAccount: false,
        isIncome: rnd.nextBool(),
      );
    },
  );
}
