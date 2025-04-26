import 'package:appwrite/models.dart';
import 'package:pos/main.export.dart';

class WarehouseRepo with AwHandler {
  FutureReport<List<WareHouse>> getWareHouses() async {
    return await db.getList(AWConst.collections.warehouse).convert((docs) => docs.convertDoc(WareHouse.fromDoc));
  }

  FutureReport<WareHouse> getWareHouseById(String id) async {
    return await db.get(AWConst.collections.warehouse, id).convert(WareHouse.fromDoc);
  }

  FutureReport<Document> createWareHouse(WareHouse data) async {
    return await db.create(AWConst.collections.warehouse, data: data.toAwPost());
  }

  FutureReport<Document> updateWareHouse(WareHouse data) async {
    return await db.update(AWConst.collections.warehouse, data.id, data: data.toAwPost());
  }

  // FutureReport<Document> createWareHouse(WareHouse data) async {
  //   return await db.create(AWConst.collections.warehouse, data: data.toAwPost());
  // }
}
