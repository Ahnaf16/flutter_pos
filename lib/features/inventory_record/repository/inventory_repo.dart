import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart';
import 'package:fpdart/fpdart.dart';
import 'package:pos/features/auth/repository/auth_repo.dart';
import 'package:pos/features/parties/repository/parties_repo.dart';
import 'package:pos/features/payment_accounts/repository/payment_accounts_repo.dart';
import 'package:pos/features/stock/repository/stock_repo.dart';
import 'package:pos/features/transactions/repository/transactions_repo.dart';
import 'package:pos/main.export.dart';

class InventoryRepo with AwHandler {
  final String _generalFailure = 'Failed to create record';
  final String _emptyFields = 'One or multiple required fields are empty';
  final String _updateAccountFailure = 'Failed to update account amount';

  FutureReport<Document> createSale(InventoryRecordState inventory) async {
    //! add details
    final (detailErr, detailsData) = await _createRecordDetails(inventory.details).toRecord();
    if (detailErr != null || detailsData == null) return left(detailErr ?? Failure(_generalFailure));
    InventoryRecord? record = inventory.copyWith(details: detailsData).toInventoryRecord(RecordType.sale);
    if (record == null) return left(Failure(_emptyFields));

    //! update account amount
    final acc = record.account;
    final (accErr, accData) = await _updateAccountAmount(acc, record.amount).toRecord();
    if (accErr != null || accData == null) return left(detailErr ?? Failure(_updateAccountFailure));

    //! update Due
    Parti? parti = record.parti;
    if (inventory.hasDue || inventory.hasBalance) {
      final (partiErr, partiData) = await _updateDue(parti, inventory.dueSale, record.type).toRecord();
      if (partiErr != null || partiData == null) return left(partiErr ?? Failure(_generalFailure));
      parti = Parti.fromDoc(partiData);
    }

    if (inventory.hasDue && inventory.partiHasBalance) {
      record = record.copyWith(dueBalance: record.dueBalance + inventory.dueSale);
    }

    if (inventory.partiHasBalance && inventory.dueBalance > 0) {
      // [Parti.Due] is already [-] in this case
      final (partiErr, partiData) = await _updateDue(parti, inventory.dueBalance, record.type).toRecord();
      if (partiErr != null || partiData == null) return left(partiErr ?? Failure(_generalFailure));
    }

    //! add transaction log
    await _addTransactionLog(record);

    //! add record
    final doc = await db.create(AWConst.collections.inventoryRecord, data: record.toAwPost());
    return doc;
  }

  FutureReport<List<InventoryDetails>> _createRecordDetails(List<InventoryDetails> details) async {
    final updated = <InventoryDetails>[];
    for (final detail in details) {
      final (e, d) = await db.create(AWConst.collections.inventoryDetails, data: detail.toAwPost()).toRecord();
      if (e != null || d == null) return left(e ?? Failure(_generalFailure));

      final (stockErr, stockData) = await _updateStockQty(detail.stock, detail.quantity).toRecord();
      if (stockErr != null || stockData == null) return left(stockErr ?? Failure(_generalFailure));

      updated.add(InventoryDetails.fromDoc(d));
    }

    return right(updated);
  }

  FutureReport<Document> _updateAccountAmount(PaymentAccount account, num amount) async {
    final repo = locate<PaymentAccountsRepo>();
    return await repo.updateAccount(account.copyWith(amount: account.amount + amount));
  }

  FutureReport<Document> _updateStockQty(Stock stock, int qty) async {
    final repo = locate<StockRepo>();
    return await repo.updateStock(stock.copyWith(quantity: stock.quantity - qty));
  }

  FutureReport<Document> _updateDue(Parti parti, num due, RecordType type) async {
    final repo = locate<PartiesRepo>();
    return await repo.updateDue(parti, due, !due.isNegative, 'Due created from ${type.name}');
  }

  FutureReport<Document> _addTransactionLog(InventoryRecord record) async {
    final repo = locate<TransactionsRepo>();
    final (err, user) = await locate<AuthRepo>().currentUser().toRecord();
    if (err != null || user == null) return left(err ?? const Failure('Unable to getting current user'));

    final transaction = TransactionLog.fromInventoryRecord(record, user);
    return await repo.addTransaction(transaction);
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
