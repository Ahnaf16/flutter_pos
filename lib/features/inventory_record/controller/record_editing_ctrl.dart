import 'package:pos/features/inventory_record/controller/inventory_record_ctrl.dart';
import 'package:pos/features/inventory_record/repository/inventory_repo.dart';
import 'package:pos/features/inventory_record/repository/return_repo.dart';
import 'package:pos/features/payment_accounts/controller/payment_accounts_ctrl.dart';
import 'package:pos/features/products/controller/products_ctrl.dart';
import 'package:pos/features/settings/controller/settings_ctrl.dart';
import 'package:pos/main.export.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'record_editing_ctrl.g.dart';

@riverpod
class RecordEditingCtrl extends _$RecordEditingCtrl {
  late Config _config;
  final _repo = locate<InventoryRepo>();

  @override
  InventoryRecordState build(RecordType type) {
    _config = ref.watch(configCtrlProvider);
    return InventoryRecordState(type: type, parti: type.isPurchase ? null : Party.fromWalkIn());
  }

  void addProduct(Product product, {Stock? newStock, WareHouse? warehouse, bool replaceExisting = false}) {
    Stock? stock = newStock;

    if (type.isSale) {
      stock = product.getEffectiveStock(_config.stockDistPolicy, warehouse?.id);
    }

    if (stock == null) {
      final msg = type.isSale ? 'Product out of stock' : 'Add a stock first';
      Toast.showErr(Ctx.context, msg);
      return;
    }

    if (state.details.map((e) => e.product.id).contains(product.id) && type.isSale) {
      final existing = state.details.firstWhere((e) => e.product.id == product.id).stock;
      if (existing.id != stock.id) return;
      // if (stock.quantity <= 0) return;

      return changeProductQuantity(product.id, (q) {
        if (q >= existing.quantity) return q;
        return q + 1;
      });
    }
    final qty = type.isSale ? 1 : stock.quantity;
    final details = InventoryDetails(
      id: '',
      product: product,
      stock: stock,
      price: type.isSale ? product.salePrice : stock.purchasePrice,
      quantity: qty,
      createdDate: DateTime.now(),
    );

    state = state.copyWith(details: [if (!replaceExisting) ...state.details, details]);
  }

  void removeProduct(String pId, String sid) {
    state = state.copyWith(details: state.details.where((e) => e.product.id != pId || e.stock.id != sid).toList());
    if (state.details.isEmpty) {}
  }

  void changeProductQuantity(String pId, int Function(int oldQty) update) {
    if (type == RecordType.purchase) return;

    final updatedDetails = [
      for (final item in state.details)
        if (item.product.id == pId) item.copyWith(quantity: update(item.quantity)) else item,
    ];

    state = state.copyWith(details: updatedDetails);
  }

  void updateStockQuantity(String pId, String sId, int Function(int oldQty) update) {
    if (type == RecordType.sale) return;

    final updatedDetails = [
      for (final item in state.details)
        if (item.product.id == pId && item.stock.id == sId)
          item.copyWith(
            quantity: update(item.quantity),
            stock: item.stock.copyWith(quantity: update(item.stock.quantity)),
          )
        else
          item,
    ];

    state = state.copyWith(details: updatedDetails);
  }

  void updatePrice(InventoryDetails detail, num price) {
    final updatedDetails = [
      for (final item in state.details)
        if (item.product.id == detail.product.id && item.stock.id == detail.stock.id)
          item.copyWith(price: price)
        else
          item,
    ];

    state = state.copyWith(details: updatedDetails);
  }

  void changeQuantity(InventoryDetails detail, int Function(int old) qty) {
    if (type.isPurchase) {
      updateStockQuantity(detail.product.id, detail.stock.id, qty);
    } else {
      changeProductQuantity(detail.product.id, qty);
    }
  }

  void changeParti(Party? parti) {
    state = state.copyWith(parti: () => parti);
  }

  void changeAccount(PaymentAccount? account) {
    state = state.copyWith(account: () => account);
  }

  void changeDiscountType(DiscountType type) {
    state = state.copyWith(discountType: type);
  }

  void setInputsFromMap(QMap data) {
    state = state.copyWith(
      amount: data.parseNum('amount'),
      vat: data.parseNum('vat'),
      discount: data.parseNum('discount'),
      shipping: data.parseNum('shipping'),
      // dueBalance: data.parseNum('due_balance'),
    );
  }

  Future<(Result, InventoryRecord?)> submit({bool ignoreParty = false}) async {
    if (state.parti == null && !ignoreParty) {
      return ((false, 'Please select a ${type.isSale ? 'customer' : 'supplier'}'), null);
    }
    if (state.account == null && state.paidAmount > 0) {
      return ((false, 'Please select a payment account'), null);
    }
    if (state.details.isEmpty) {
      return ((false, 'Please select at least one product'), null);
    }

    if (type.isPurchase) {
      if (state.hasExtra) return ((false, 'Extra amount is not allowed when purchasing'), null);
      return submitPurchase(ignoreParty: ignoreParty);
    } else {
      if (state.isWalkIn && state.hasDue) return ((false, 'Clear due for walk-in customer'), null);
      if (state.isWalkIn && state.hasExtra) return ((false, 'Clear extra amount for walk-in customer'), null);

      return submitSale();
    }
  }

  Future<(Result, InventoryRecord?)> submitPurchase({bool ignoreParty = false}) async {
    final res = await _repo.createPurchase(state, ignoreParty: ignoreParty);

    return res.fold((l) => (leftResult(l), null), (r) {
      ref.invalidate(productsCtrlProvider);
      ref.invalidate(inventoryCtrlProvider);
      ref.invalidate(paymentAccountsCtrlProvider);
      ref.invalidateSelf();
      final inv = InventoryRecord.tryParse(r);
      return ((true, 'Record created successfully'), inv);
    });
  }

  Future<(Result, InventoryRecord?)> submitSale() async {
    final res = await _repo.createSale(state);

    return res.fold((l) => (leftResult(l), null), (r) {
      ref.invalidate(productsCtrlProvider);
      ref.invalidate(inventoryCtrlProvider);
      ref.invalidate(paymentAccountsCtrlProvider);

      ref.invalidateSelf();
      final inv = InventoryRecord.tryParse(r);
      return ((true, 'Record created successfully'), inv);
    });
  }

  Future<Result> returnInventory(InventoryRecord rec, QMap data) async {
    final res = await locate<ReturnRepo>().returnRecord(rec, data.transformValues((_, v) => Parser.toInt(v) ?? 0));

    return res.fold(leftResult, (r) {
      ref.invalidate(inventoryCtrlProvider);
      ref.invalidateSelf();
      return (true, 'Record returned successfully');
    });
  }
}
