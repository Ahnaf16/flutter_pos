import 'package:appwrite/models.dart';
import 'package:fpdart/fpdart.dart';
import 'package:pos/features/products/repository/products_repo.dart';
import 'package:pos/main.export.dart';

class StockRepo with AwHandler {
  FutureReport<Document> createStock(QMap form) async {
    final stock = Stock.fromMap(form);
    final doc = await db.create(AWConst.collections.stock, data: stock.toAwPost());
    return doc;
  }

  FutureReport<Document> updateStock(Stock stock, [List<String>? include]) async {
    final doc = await db.update(AWConst.collections.stock, stock.id, data: stock.toAwPost(include));
    return doc;
  }

  FutureReport<List<Stock>> getStocks() async {
    return await db.getList(AWConst.collections.stock).convert((docs) => docs.convertDoc(Stock.fromDoc));
  }

  FutureReport<Stock> getStockById(String id) async {
    return await db.get(AWConst.collections.stock, id).convert(Stock.fromDoc);
  }

  FutureReport<Document> transferStock(StockTransferState tState, StockDistPolicy p) async {
    final vErr = tState.validate();
    if (vErr != null) return failure(vErr);

    final stocks = tState.sortedStocks(p);

    int remainingQty = tState.quantity;
    for (final stock in stocks) {
      if (remainingQty == 0) break;

      final (ett, curStock) = await getStockById(stock.id).toRecord();
      if (ett != null || curStock == null) return left(ett ?? const Failure('Unable to get stock'));

      if (curStock.quantity <= remainingQty) {
        // Use up the whole stock
        await updateStock(curStock.copyWith(quantity: 0), [Stock.fields.quantity]);
        remainingQty -= curStock.quantity;
      } else {
        // Partially use this stock
        await updateStock(curStock.copyWith(quantity: curStock.quantity - remainingQty), [Stock.fields.quantity]);
        remainingQty = 0;
      }
    }

    final sendingStock = tState.constrictStockToSend();

    if (sendingStock == null) return left(const Failure('No stock to send'));

    final (err, st) = await createStock(sendingStock.toMap()).toRecord();
    if (err != null || st == null) return left(err ?? const Failure('Unable to create stock'));

    await _createLog(tState, Stock.fromDoc(st));

    // update product stock
    final (pErr, product) = await _linkStockToProduct(Stock.fromDoc(st), tState.product!).toRecord();
    if (pErr != null || product == null) return left(pErr ?? const Failure('Unable to link stock to product'));

    return right(st);
  }

  FutureReport<Document> _linkStockToProduct(Stock stock, Product product) async {
    final repo = locate<ProductRepo>();
    return await repo.linkStockToProduct(stock, product.id);
  }

  FutureReport<Document> _createLog(StockTransferState tState, Stock stock) async {
    final log = StockTransferLog.fromStockState(tState, stock);
    final doc = await db.create(AWConst.collections.stockTransferLog, data: log.toAwPost());
    return doc;
  }

  FutureReport<Unit> deleteStock(String id) async {
    final doc = await db.delete(AWConst.collections.stock, id);
    return doc;
  }

  FutureReport<List<StockTransferLog>> getStockLogs() async {
    return await db
        .getList(AWConst.collections.stockTransferLog)
        .convert((docs) => docs.convertDoc(StockTransferLog.fromDoc));
  }
}
