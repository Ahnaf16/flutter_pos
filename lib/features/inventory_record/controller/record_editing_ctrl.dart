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
    return const InventoryRecordState();
  }

  void addProduct(Product product, Stock? newStock) {
    Stock? stock = newStock;

    if (type == RecordType.sale) {
      stock = product.getEffectiveStock(_config.stockDistPolicy);
    }
    if (stock == null) {
      final msg = type == RecordType.sale ? 'Product out of stock' : 'Add a stock first';
      Toast.showErr(Ctx.context, msg);
      return;
    }

    if (state.details.map((e) => e.product.id).contains(product.id) && type == RecordType.sale) {
      return changeProductQuantity(product.id, (q) => q + 1);
    }

    final details = InventoryDetails(id: '', product: product, stock: stock, quantity: 1);

    state = state.copyWith(details: [...state.details, details]);
  }

  void removeProduct(String pId) {
    state = state.copyWith(details: state.details.where((e) => e.product.id != pId).toList());
    if (state.details.isEmpty) {}
  }

  void changeProductQuantity(String pId, int Function(int old) qty) {
    if (type == RecordType.purchase) return;

    final list = state.details.toList();

    final index = list.indexWhere((e) => e.product.id == pId);
    if (index == -1) return;

    list[index] = list[index].copyWith(quantity: qty(list[index].quantity));

    state = state.copyWith(details: list);
  }

  void updateStockQuantity(String pId, int Function(int old) qty) {
    if (type == RecordType.sale) return;

    final list = state.details.toList();

    final index = list.indexWhere((e) => e.product.id == pId);
    if (index == -1) return;

    list[index] = list[index].copyWith(stock: list[index].stock.copyWith(quantity: qty(list[index].stock.quantity)));

    state = state.copyWith(details: list);
  }

  void changeQuantity(String pId, int Function(int old) qty) {
    if (type == RecordType.purchase) {
      updateStockQuantity(pId, qty);
    } else {
      changeProductQuantity(pId, qty);
    }
  }

  void changeParti(Parti? parti) {
    state = state.copyWith(parti: () => parti, dueBalance: 0);
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
    if (type == RecordType.purchase) {
      return submitPurchase();
    } else {
      return submitSale();
    }
  }

  Future<Result> submitPurchase() async {
    if (state.parti == null) {
      return (false, 'Please select a party');
    }
    if (state.account == null) {
      return (false, 'Please select a payment account');
    }
    if (state.details.isEmpty) {
      return (false, 'Please select at least one product');
    }
    return (false, 'WIP');
  }

  Future<Result> submitSale() async {
    if (state.parti == null) {
      return (false, 'Please select a party');
    }
    if (state.account == null) {
      return (false, 'Please select a payment account');
    }
    if (state.details.isEmpty) {
      return (false, 'Please select at least one product');
    }
    if (state.partiHasBalance && state.dueBalance > (state.parti?.due.abs() ?? 0)) {
      return (false, 'Given balance can\'t be more than available balance');
    }

    final res = await _repo.createSale(state);

    return res.fold(leftResult, (r) {
      ref.invalidate(inventoryCtrlProvider);
      ref.invalidateSelf();
      return (true, 'Record created successfully');
    });
  }
}
