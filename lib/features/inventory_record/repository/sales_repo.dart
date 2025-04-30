import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart';
import 'package:pos/main.export.dart';

class InventoryRepo with AwHandler {
  FutureReport<Document> createInventory(QMap form) async {
    // TODO : add inventory details then link with id
    final record = InventoryRecord.fromMap(form);
    final doc = await db.create(AWConst.collections.inventoryRecord, data: record.toAwPost());
    return doc;
  }

  FutureReport<Document> updateRecord(InventoryRecord record) async {
    final doc = await db.update(AWConst.collections.inventoryRecord, record.id, data: record.toAwPost());
    return doc;
  }

  FutureReport<List<InventoryRecord>> getRecords(RecordType type) async {
    return await db
        .getList(AWConst.collections.inventoryRecord, queries: [Query.equal('record_type', type.name)])
        .convert((docs) => docs.convertDoc(InventoryRecord.fromDoc));
  }

  FutureReport<InventoryRecord> getRecordById(String id) async {
    return await db.get(AWConst.collections.inventoryRecord, id).convert(InventoryRecord.fromDoc);
  }
}
