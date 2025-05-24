import 'package:pos/main.export.dart';

class StockTransferState {
  const StockTransferState({
    this.from,
    this.to,
    this.product,
    this.purchasePrice,
    this.wholesalePrice,
    this.dealerPrice,
    this.quantity = 0,
  });

  final WareHouse? from;
  final WareHouse? to;
  final Product? product;
  final num? purchasePrice;
  final num? wholesalePrice;
  final num? dealerPrice;
  final int quantity;

  StockTransferState copyWith({
    ValueGetter<WareHouse?>? from,
    ValueGetter<WareHouse?>? to,
    ValueGetter<Product?>? product,
    ValueGetter<num?>? purchasePrice,
    ValueGetter<num?>? wholesalePrice,
    ValueGetter<num?>? dealerPrice,
    int? quantity,
  }) {
    return StockTransferState(
      from: from != null ? from() : this.from,
      to: to != null ? to() : this.to,
      product: product != null ? product() : this.product,
      purchasePrice: purchasePrice != null ? purchasePrice() : this.purchasePrice,
      wholesalePrice: wholesalePrice != null ? wholesalePrice() : this.wholesalePrice,
      dealerPrice: dealerPrice != null ? dealerPrice() : this.dealerPrice,
      quantity: quantity ?? this.quantity,
    );
  }

  String? validate() {
    if (product == null) return 'product is required';
    if (from == null) return 'Select a warehouse to transfer from';
    if (to == null) return 'Select a destination warehouse';
    if (from?.id == to?.id) return 'Cannot transfer to the same warehouse';
    if (quantity <= 0) return 'quantity must be greater than zero';
    final qtyByHouse = product!.quantityByHouse(from!.id);
    if (quantity > qtyByHouse) return 'quantity must be less than available quantity';
    if (purchasePrice == null) return 'purchase price is required';
    return null;
  }

  QMap toMap() => {
    'from': from?.toMap(),
    'to': to?.toMap(),
    'product': product?.toMap(),
    'purchase_price': purchasePrice,
    'wholesale_price': wholesalePrice,
    'dealer_price': dealerPrice,
    'quantity': quantity,
  };

  List<Stock> sortedStocks(StockDistPolicy p) {
    if (product == null) return [];
    // if (from == null) return [];

    final list = switch (p) {
      StockDistPolicy.newerFirst => product!.sortByNewest(from?.id),
      StockDistPolicy.olderFirst => product!.sortByOldest(from?.id),
    };

    return list;
  }

  Stock? constrictStockToSend() {
    if (to == null) return null;
    final stock = Stock(
      id: '',
      purchasePrice: purchasePrice ?? 0,
      quantity: quantity,
      warehouse: to,
      createdAt: DateTime.now(),
    );
    return stock;
  }
}
