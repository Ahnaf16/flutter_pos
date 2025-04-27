import 'package:appwrite/models.dart';
import 'package:pos/main.export.dart';

class ProductUnitRepo with AwHandler {
  FutureReport<Document> createUnit(QMap form) async {
    final unit = ProductUnit.fromMap(form);
    final doc = await db.create(AWConst.collections.unit, data: unit.toAwPost());
    return doc;
  }

  FutureReport<Document> updateUnit(ProductUnit unit) async {
    final doc = await db.update(AWConst.collections.unit, unit.id, data: unit.toAwPost());
    return doc;
  }

  FutureReport<List<ProductUnit>> getUnits() async {
    return await db.getList(AWConst.collections.unit).convert((docs) => docs.convertDoc(ProductUnit.fromDoc));
  }

  FutureReport<ProductUnit> getUnitById(String id) async {
    return await db.get(AWConst.collections.unit, id).convert(ProductUnit.fromDoc);
  }
}
