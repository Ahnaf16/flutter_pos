import 'package:appwrite/models.dart';
import 'package:fpdart/fpdart.dart';
import 'package:pos/features/stock/repository/stock_repo.dart';
import 'package:pos/main.export.dart';

class ProductRepo with AwHandler {
  FutureReport<Document> createProduct(Product product, PFile? xfile) async {
    if (xfile != null) {
      final file = await storage.createFile(xfile);

      String? error;

      file.fold((l) => error = l.message, (r) => product = product.copyWith(photo: () => r.$id));

      if (error != null) return failure(error ?? 'Error uploading photo');
    }

    final doc = await db.create(AWConst.collections.products, data: product.toAwPost(), docId: product.id);
    doc.fold((_) {
      if (product.photo != null) storage.deleteFile(product.photo!);
    }, identityNull);
    return doc;
  }

  FutureReport<Document> updateProduct(Product product, {PFile? photo, List<String>? include}) async {
    String? oldPhoto;

    if (photo != null) {
      final file = await storage.createFile(photo);

      String? error;

      file.fold((l) => error = l.message, (r) {
        oldPhoto = product.photo;
        product = product.copyWith(photo: () => r.$id);
      });

      if (error != null) return failure(error ?? 'Error uploading photo');
    }

    final doc = await db.update(AWConst.collections.products, product.id, data: product.toAwPost(include));
    if (oldPhoto != null) await storage.deleteFile(oldPhoto!);
    return doc;
  }

  FutureReport<Unit> deleteProduct(Product product) async {
    final stockRepo = locate<StockRepo>();
    for (final stock in product.stock) {
      await stockRepo.deleteStock(stock.id);
    }
    final doc = await db.delete(AWConst.collections.products, product.id);

    final photoId = product.photo;
    if (photoId != null) await storage.deleteFile(photoId);
    return doc;
  }

  FutureReport<Document> linkStockToProduct(Stock stock, String productId) async {
    final (err, product) = await getProductById(productId).toRecord();
    if (err != null || product == null) return left(err ?? const Failure('Unable to get product'));
    return await updateProduct(product.copyWith(stock: [...product.stock, stock]), include: [Product.fields.stock]);
  }

  FutureReport<List<Product>> getProducts({WareHouse? warehouse, FilterState? fl}) async {
    final query = <String?>[];
    if (fl != null) query.add(fl.queryBuilder(FilterType.unit, 'unit'));

    return await db
        .getList(AWConst.collections.products, queries: query.nonNulls.toList())
        .convert((docs) => docs.convertDoc(Product.fromDoc));
  }

  FutureReport<Product> getProductById(String id) async {
    return await db.get(AWConst.collections.products, id).convert(Product.fromDoc);
  }
}
