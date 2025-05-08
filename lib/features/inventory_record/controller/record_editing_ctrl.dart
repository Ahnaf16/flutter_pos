import 'package:pos/features/inventory_record/controller/inventory_record_ctrl.dart';
import 'package:pos/features/inventory_record/repository/inventory_repo.dart';
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
    return InventoryRecordState(type: type);
  }

  void addProduct(Product product, Stock? newStock, String? warehouseId) {
    Stock? stock = newStock;

    if (type.isSale) {
      stock = product.getEffectiveStock(_config.stockDistPolicy, warehouseId);
    }
    if (stock == null) {
      final msg = type.isSale ? 'Product out of stock' : 'Add a stock first';
      Toast.showErr(Ctx.context, msg);
      return;
    }

    if (state.details.map((e) => e.product.id).contains(product.id) && type.isSale) {
      final existing = state.details.firstWhere((e) => e.product.id == product.id).stock.id;
      if (existing != stock.id) return;
      return changeProductQuantity(product.id, (q) => q + 1);
    }
    final qty = type.isSale ? 1 : stock.quantity;
    final details = InventoryDetails(id: '', product: product, stock: stock, quantity: qty);

    state = state.copyWith(details: [...state.details, details]);
  }

  void removeProduct(String pId) {
    state = state.copyWith(details: state.details.where((e) => e.product.id != pId).toList());
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

  void updateStockQuantity(String pId, int Function(int oldQty) update) {
    if (type == RecordType.sale) return;

    final updatedDetails = [
      for (final item in state.details)
        if (item.product.id == pId)
          item.copyWith(
            quantity: update(item.quantity),
            stock: item.stock.copyWith(quantity: update(item.stock.quantity)),
          )
        else
          item,
    ];

    state = state.copyWith(details: updatedDetails);
  }

  void changeQuantity(String pId, int Function(int old) qty) {
    if (type.isPurchase) {
      updateStockQuantity(pId, qty);
    } else {
      changeProductQuantity(pId, qty);
    }
  }

  void changeParti(Parti? parti, WalkIn? wi) {
    state = state.copyWith(parti: () => parti, walkIn: () => wi, dueBalance: 0);
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
      dueBalance: data.parseNum('due_balance'),
    );
  }

  Future<Result> submit() async {
    cat(state.toMap(), 'submit');

    if (state.parti == null && state.walkIn == null) {
      return (false, 'Please select a party');
    }
    if (state.account == null) {
      return (false, 'Please select a payment account');
    }
    if (state.details.isEmpty) {
      return (false, 'Please select at least one product');
    }

    if (type.isPurchase) {
      if (state.partiHasDue && state.dueBalance > (state.parti?.due.abs() ?? 0)) {
        return (false, 'Given due can\'t be more than parti\'s due');
      }
      return submitPurchase();
    } else {
      if (state.isWalkIn && state.hasDue) return (false, 'Clear due for walk-in customer');
      if (state.isWalkIn && state.hasBalance) return (false, 'Clear excess amount for walk-in customer');

      if (state.partiHasBalance && state.dueBalance > (state.parti?.due.abs() ?? 0)) {
        return (false, 'Given balance can\'t be more than available balance');
      }
      return submitSale();
    }
  }

  Future<Result> submitPurchase() async {
    final res = await _repo.createPurchase(state);

    return res.fold(leftResult, (r) {
      ref.invalidate(inventoryCtrlProvider);
      ref.invalidateSelf();
      return (true, 'Record created successfully');
    });
  }

  Future<Result> submitSale() async {
    final res = await _repo.createSale(state);

    return res.fold(leftResult, (r) {
      ref.invalidate(inventoryCtrlProvider);
      ref.invalidateSelf();
      return (true, 'Record created successfully');
    });
  }
}
