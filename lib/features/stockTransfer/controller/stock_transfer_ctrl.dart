import 'package:pos/features/settings/controller/settings_ctrl.dart';
import 'package:pos/features/stock/repository/stock_repo.dart';
import 'package:pos/main.export.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'stock_transfer_ctrl.g.dart';

@riverpod
class StockTransferCtrl extends _$StockTransferCtrl {
  late Config _config;
  final _repo = locate<StockRepo>();

  @override
  StockTransferState build() {
    _config = ref.watch(configCtrlProvider);
    return const StockTransferState();
  }

  void setProduct(Product? product) {
    state = state.copyWith(product: () => product);
  }

  QMap setFrom(WareHouse? warehouse) {
    final stock = state.product?.getEffectiveStock(_config.stockDistPolicy, warehouse?.id);
    state = state.copyWith(
      from: () => warehouse,
      purchasePrice: () => stock?.purchasePrice,
      salesPrice: () => state.product?.salePrice,

      quantity: stock?.quantity,
    );

    // this is to set form fields
    return (stock?.toAwPost() ?? {})..remove('quantity');
  }

  void setTo(WareHouse? warehouse) => state = state.copyWith(to: () => warehouse);

  void setStockData(QMap form) {
    state = state.copyWith(
      purchasePrice: () => form.parseNum('purchase_price'),
      salesPrice: () => form.parseNum('sales_price'),
      wholesalePrice: () => form.parseNum('wholesale_price'),
      dealerPrice: () => form.parseNum('dealer_price'),
      quantity: form.parseInt('quantity'),
    );
  }

  Future<Result> submit() async {
    final res = await _repo.transferStock(state, _config.stockDistPolicy);

    return res.fold(leftResult, (r) {
      ref.invalidateSelf();
      return (true, 'Stock transferred successfully');
    });
  }
}
