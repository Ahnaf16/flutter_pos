import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart';
import 'package:fpdart/fpdart.dart';
import 'package:pos/main.export.dart';

class WarehouseRepo with AwHandler {
  FutureReport<List<WareHouse>> getWareHouses([List<String>? queries]) async {
    return await db
        .getList(AWConst.collections.warehouse, queries: queries)
        .convert((docs) => docs.convertDoc(WareHouse.fromDoc));
  }

  FutureReport<WareHouse> getWareHouseById(String id) async {
    return await db.get(AWConst.collections.warehouse, id).convert(WareHouse.fromDoc);
  }

  FutureReport<Document> createWareHouse(WareHouse data) async {
    return await db.create(AWConst.collections.warehouse, data: data.toAwPost());
  }

  FutureReport<Document> updateWareHouse(WareHouse data, [List<String>? include]) async {
    return await db.update(AWConst.collections.warehouse, data.id, data: data.toAwPost(include));
  }

  FutureReport<WareHouse> changeDefault(WareHouse newDefault) async {
    final query = [Query.equal('is_default', true)];
    final (err, docs) = await getWareHouses(query).toRecord();
    if (err != null || docs == null) return left(err ?? const Failure('Unable to get warehouses'));
    final defWh = WareHouse.tyrParse(docs.firstOrNull);

    if (defWh != null) {
      if (defWh.id == newDefault.id) return right(defWh);
      await updateWareHouse(defWh.copyWith(isDefault: false), [WareHouse.fields.isDefault]);
    }
    newDefault = newDefault.copyWith(isDefault: true);
    return await updateWareHouse(newDefault, [WareHouse.fields.isDefault]).convert(WareHouse.fromDoc);
  }
}
