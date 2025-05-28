import 'dart:math';

import 'package:pos/features/inventory_record/controller/inventory_record_ctrl.dart';
import 'package:pos/features/parties/controller/parties_ctrl.dart';
import 'package:pos/features/payment_accounts/controller/payment_accounts_ctrl.dart';
import 'package:pos/features/products/controller/products_ctrl.dart';
import 'package:pos/features/transactions/controller/transactions_ctrl.dart';
import 'package:pos/main.export.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'home_ctrl.g.dart';

enum TableType { yearly, monthly }

@Riverpod(keepAlive: true)
class ViewingWH extends _$ViewingWH {
  Future<void> updateHouse(WareHouse? house) async {
    if (house?.isDefault == true) {
      state = (my: house, viewing: null);
    } else {
      state = (my: house, viewing: house);
    }
  }

  @override
  ({WareHouse? my, WareHouse? viewing}) build() => (my: null, viewing: null);
}

@Riverpod()
class HomeCounters extends _$HomeCounters {
  @override
  Map<(String, RPath), dynamic> build() {
    final products = ref.watch(productsCtrlProvider).maybeList();
    final inventory = ref.watch(inventoryCtrlProvider(null)).maybeList();
    final returns = ref.watch(inventoryReturnCtrlProvider(null)).maybeList();
    final peoples = ref.watch(partiesCtrlProvider(null)).maybeList();
    final accounts = ref.watch(paymentAccountsCtrlProvider()).maybeList();

    final sales = inventory.where((e) => e.type == RecordType.sale);
    final purchases = inventory.where((e) => e.type == RecordType.purchase);
    final returnSales = returns.where((e) => e.returnedRec?.type == RecordType.sale);
    final returnPurchases = returns.where((e) => e.returnedRec?.type == RecordType.purchase);

    final todaysSales = sales.where((e) => !e.status.isReturned && e.date.isSameDay(DateTime.now()));
    final todaysPurchases = purchases.where((e) => !e.status.isReturned && e.date.isSameDay(DateTime.now()));

    return {
      ('Products', RPaths.products): products.length,
      ('Sales', RPaths.sales): sales.where((e) => !e.status.isReturned).map((e) => e.payable).sum.currency(),
      ('Purchase', RPaths.purchases): purchases.where((e) => !e.status.isReturned).map((e) => e.payable).sum.currency(),
      ('Today\'s Sales', RPaths.sales): todaysSales.map((e) => e.payable).sum.currency(),
      ('Today\'s Purchase', RPaths.purchases): todaysPurchases.map((e) => e.payable).sum.currency(),
      ('Sales Return', RPaths.salesReturn): returnSales.map((e) => e.adjustAccount).sum.currency(),
      ('Purchase Return', RPaths.purchasesReturn): returnPurchases.map((e) => e.adjustAccount).sum.currency(),
      ('Customer due', RPaths.customer): peoples
          .where((e) => e.isCustomer && e.hasDue())
          .map((e) => e.due)
          .sum
          .currency(),
      ('Supplier due', RPaths.supplier): peoples
          .where((e) => !e.isCustomer && e.hasBalance())
          .map((e) => e.due.abs())
          .sum
          .currency(),
      ('Total account balance', RPaths.paymentAccount): accounts.map((e) => e.amount).sum.currency(),
    };
  }
}

@riverpod
class BarDataCtrl extends _$BarDataCtrl {
  @override
  Map<int, List<TransactionLog>> build(TableType type, int month) {
    final now = DateTime.now();

    final trx = ref.watch(transactionLogCtrlProvider()).maybeList().where((e) => e.date.year == now.year);

    final data = <int, List<TransactionLog>>{};

    if (type == TableType.yearly) {
      final trxGroup = trx.groupListsBy((e) => e.date.month);
      for (var month = 1; month <= 12; month++) {
        data[month] = trxGroup[month] ?? [];
      }
    } else {
      final trxGroup = trx.where((e) => e.date.month == month).groupListsBy((e) => e.date.day);
      final length = getMonth(month).daysInMonth;
      for (var day = 1; day <= length; day++) {
        data[day] = trxGroup[day] ?? [];
      }
    }

    return data;
  }
}

@riverpod
class PieDataCtrl extends _$PieDataCtrl {
  @override
  Map<TransactionType, List<TransactionLog>> build() {
    final trx = ref.watch(transactionLogCtrlProvider()).maybeList().groupListsBy((e) => e.type);

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
