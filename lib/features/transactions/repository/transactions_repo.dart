import 'package:appwrite/models.dart';
import 'package:pos/main.export.dart';

class TransactionsRepo with AwHandler {
  final _coll = AWConst.collections.transactions;

  FutureReport<Document> addTransaction(TransactionLog log) async {
    // TODO: update account
    return await db.create(_coll, data: log.toAwPost());
  }

  FutureReport<List<TransactionLog>> getTransactionLogs() async {
    return await db.getList(_coll).convert((docs) => docs.convertDoc(TransactionLog.fromDoc));
  }
}
