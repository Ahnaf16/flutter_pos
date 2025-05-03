import 'package:pos/features/inventory_record/repository/inventory_repo.dart';
import 'package:pos/features/parties/controller/parties_ctrl.dart';
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
  InventoryRecordState build() {
    _config = ref.watch(configCtrlProvider);
    return const InventoryRecordState();
  }

  void addProduct(Product product) {
    final stock = product.getEffectiveStock(_config.stockDistPolicy);
    if (stock == null) {
      Toast.showErr(Ctx.context, 'Product out of stock');
      return;
    }

    if (state.details.map((e) => e.product.id).contains(product.id)) {
      return changeQuantity(product.id, (q) => q + 1);
    }

    final details = InventoryDetails(id: '', product: product, stock: stock, quantity: 1);

    state = state.copyWith(details: [...state.details, details]);
  }

  void removeProduct(String pId) {
    state = state.copyWith(details: state.details.where((e) => e.product.id != pId).toList());
    if (state.details.isEmpty) {}
  }

  void changeQuantity(String pId, int Function(int old) qty) {
    final list = state.details.toList();

    final index = list.indexWhere((e) => e.product.id == pId);
    if (index == -1) return;

    list[index] = list[index].copyWith(quantity: qty(list[index].quantity));

    state = state.copyWith(details: list);
  }

  void changeParti(Parti? parti) {
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
    );
  }

  FVoid submitSale() async {
    if (state.parti == null) {
      return Toast.showErr(Ctx.context, 'Please select a party');
    }
    if (state.account == null) {
      return Toast.showErr(Ctx.context, 'Please select a payment account');
    }
    if (state.details.isEmpty) {
      return Toast.showErr(Ctx.context, 'Please select at least one product');
    }

    final res = await _repo.createSale(state);

    res.fold((l) => Toast.showErr(Ctx.context, l), (r) {
      Toast.show(Ctx.context, 'Record created successfully');
      ref.invalidate(productsCtrlProvider);
      ref.invalidate(paymentAccountsCtrlProvider);
      if (state.hasDue) {
        ref.invalidate(partiesCtrlProvider);
      }
    });
  }
}
