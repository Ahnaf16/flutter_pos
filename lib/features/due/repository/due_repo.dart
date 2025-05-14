import 'package:appwrite/models.dart';
import 'package:fpdart/fpdart.dart';
import 'package:pos/main.export.dart';

class DueRepo with AwHandler {
  final _coll = AWConst.collections.dueLog;

  FutureReport<Document> addDueLog(Party parti, num amount, bool isAdd, [String? note]) async {
    final data = DueLog(
      amount: amount,
      postAmount: parti.due + amount,
      isDueAdded: isAdd,
      date: dateNow.run(),
      parti: parti,
      note: note,
    );
    return await db.create(_coll, data: data.toAwPost());
  }

  FutureReport<List<DueLog>> getDueLogs() async {
    return await db.getList(_coll).convert((docs) => docs.convertDoc(DueLog.fromDoc));
  }

  FutureReport<DueLog> getLogById(String id) async {
    return await db.get(_coll, id).convert(DueLog.fromDoc);
  }
}
