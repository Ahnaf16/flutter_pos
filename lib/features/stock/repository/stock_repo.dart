import 'package:appwrite/models.dart';
import 'package:pos/main.export.dart';

class StockRepo with AwHandler {
  FutureReport<Document> createStock(QMap form) async {
    form.addAll({'createdAt': DateTime.now().toIso8601String()});

    final stock = Stock.fromMap(form);
    final doc = await db.create(AWConst.collections.stock, data: stock.toAwPost());
    return doc;
  }

  FutureReport<Document> updateStock(Stock stock) async {
    final doc = await db.update(AWConst.collections.stock, stock.id, data: stock.toAwPost());
    return doc;
  }

  FutureReport<List<Stock>> getStocks() async {
    return await db.getList(AWConst.collections.stock).convert((docs) => docs.convertDoc(Stock.fromDoc));
  }

  FutureReport<Stock> getStockById(String id) async {
    return await db.get(AWConst.collections.stock, id).convert(Stock.fromDoc);
  }
}
