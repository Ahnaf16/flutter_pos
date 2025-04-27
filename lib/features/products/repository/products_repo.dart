import 'package:appwrite/models.dart';
import 'package:pos/main.export.dart';

class ProductRepo with AwHandler {
  FutureReport<Document> createProduct(QMap form, PFile? xfile) async {
    Product product = Product.fromMap(form);

    if (xfile != null) {
      final file = await storage.createFile(xfile);

      String? error;

      file.fold((l) => error = l.message, (r) => product = product.copyWith(photo: () => r.$id));

      if (error != null) return failure(error ?? 'Error uploading photo');
    }

    final doc = await db.create(AWConst.collections.products, data: product.toAwPost());
    doc.fold((_) {
      if (product.photo != null) storage.deleteFile(product.photo!);
    }, identityNull);
    return doc;
  }

  FutureReport<Document> updateProduct(Product product, [PFile? photo]) async {
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

    final doc = await db.update(AWConst.collections.products, product.id, data: product.toAwPost());
    if (oldPhoto != null) await storage.deleteFile(oldPhoto!);
    return doc;
  }

  FutureReport<List<Product>> getProducts() async {
    return await db.getList(AWConst.collections.products).convert((docs) => docs.convertDoc(Product.fromDoc));
  }

  FutureReport<Product> getProductById(String id) async {
    return await db.get(AWConst.collections.products, id).convert(Product.fromDoc);
  }
}
