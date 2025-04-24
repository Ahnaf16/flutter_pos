import 'package:pos/main.export.dart';

class WarehouseRepo with AwHandler {
  FutureReport<List<WareHouse>> getWareHouses() async {
    return await db.getList(AWConst.collections.warehouse).convert((docs) => docs.convertDoc(WareHouse.fromDoc));
  }
}
