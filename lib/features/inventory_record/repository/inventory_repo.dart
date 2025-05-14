import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart';
import 'package:fpdart/fpdart.dart';
import 'package:pos/features/auth/repository/auth_repo.dart';
import 'package:pos/features/parties/repository/parties_repo.dart';
import 'package:pos/features/payment_accounts/repository/payment_accounts_repo.dart';
import 'package:pos/features/products/repository/products_repo.dart';
import 'package:pos/features/stock/repository/stock_repo.dart';
import 'package:pos/features/transactions/repository/transactions_repo.dart';
import 'package:pos/main.export.dart';

class InventoryRepo with AwHandler {
  final String _generalFailure = 'Failed to create record';
  final String _updateAccountFailure = 'Failed to update account amount';

  FutureReport<Document> createSale(InventoryRecordState inventory) async {
    //! add details
    final (detailErr, detailsData) = await _createRecordDetails(inventory.details, true).toRecord();
    if (detailErr != null || detailsData == null) return left(detailErr ?? Failure(_generalFailure));
    final record = inventory.copyWith(details: detailsData).toInventoryRecord();

    //! update account amount
    final acc = record.account;

    final payable = inventory.payable;

    if (acc != null && payable > 0) {
      final (accErr, accData) = await _updateAccountAmount(acc.id, payable).toRecord();
      if (accErr != null || accData == null) return left(accErr ?? Failure(_updateAccountFailure));
    }

    //! update Due
    Party? parti = record.parti;
    // will be null if customer is walk-in
    if (parti != null) {
      if (inventory.hasDue || inventory.hasBalance) {
        // _updateDue adds the due with the parti.due. if due is (-) it will be subtracted
        // when hasBalance, due is (-), so -due will subtract due. will be added as balance
        // when hasDue, due is (+), so +due will add due. will be added as due
        final (partiErr, partiData) = await _updateDue(parti.id, inventory.due, record.type).toRecord();
        if (partiErr != null || partiData == null) return left(partiErr ?? Failure(_generalFailure));
        parti = Party.fromDoc(partiData);
      }
    }

    //! add transaction log
    await _addTransactionLog(record);

    //! add record
    final doc = await db.create(AWConst.collections.inventoryRecord, data: record.toAwPost());
    return doc;
    // return left(const Failure('___'));
  }

  FutureReport<Document> createPurchase(InventoryRecordState inventory) async {
    //! add details
    InventoryRecord record = inventory.toInventoryRecord();
    Party? parti = record.parti;
    if (parti == null) return left(const Failure('Parti is required when purchasing'));

    final (detailErr, detailsData) = await _createRecordDetails(inventory.details, false).toRecord();
    if (detailErr != null || detailsData == null) return left(detailErr ?? Failure(_generalFailure));
    record = record.copyWith(details: detailsData);

    //! update account amount
    final acc = record.account;
    final payable = inventory.hasDue ? record.amount : record.amount + inventory.due;

    // when amount is more then total, we only add the total price to the account. the remaining will go to users due/balance
    // (-) amount because it is a purchase and _updateAccountAmount adds the amount.
    if (acc != null && payable > 0) {
      final (accErr, accData) = await _updateAccountAmount(acc.id, -payable).toRecord();
      if (accErr != null || accData == null) return left(accErr ?? Failure(_updateAccountFailure));
    }

    //! update Due
    if (inventory.hasDue || inventory.hasBalance) {
      // _updateDue adds the due with the parti.due. if due is (-) it will be subtracted
      // when hasBalance, due is (-), so -(-due) will add due. will be added as due
      // when hasDue, due is (+), so -(+due) will subtract due. will be added as balance
      final (partiErr, partiData) = await _updateDue(parti.id, -inventory.due, record.type).toRecord();
      if (partiErr != null || partiData == null) return left(partiErr ?? Failure(_generalFailure));
      parti = Party.fromDoc(partiData);
    }

    // //! add transaction log
    await _addTransactionLog(record);

    // //! add record
    final doc = await db.create(AWConst.collections.inventoryRecord, data: record.toAwPost());
    return doc;
  }

  /// For sale: stock exist, so just create details and update stock qty
  /// For purchase: stock not exist, so create stock and link it the product and details
  FutureReport<List<InventoryDetails>> _createRecordDetails(List<InventoryDetails> details, bool isSale) async {
    final updated = <InventoryDetails>[];
    for (InventoryDetails detail in details) {
      Stock? newStock;
      if (!isSale) {
        final (stockErr, stockData) = await _createStockAndLinkProduct(detail.stock, detail.product).toRecord();
        if (stockErr != null || stockData == null) return left(stockErr ?? Failure(_generalFailure));
        newStock = stockData;
      }

      if (newStock != null) {
        detail = detail.copyWith(stock: newStock);
      }

      final (e, d) = await db.create(AWConst.collections.inventoryDetails, data: detail.toAwPost()).toRecord();
      if (e != null || d == null) return left(e ?? Failure(_generalFailure));

      if (isSale) {
        final (stockErr, stockData) = await _updateStockQty(detail.stock, detail.quantity).toRecord();
        if (stockErr != null || stockData == null) return left(stockErr ?? Failure(_generalFailure));
      }

      updated.add(InventoryDetails.fromDoc(d));
    }

    return right(updated);
  }

  FutureReport<Stock> _createStockAndLinkProduct(Stock stock, Product product) async {
    final repo = locate<StockRepo>();
    final (stockErr, stockData) = await repo.createStock(stock.toMap()).toRecord();
    if (stockErr != null || stockData == null) return left(stockErr ?? Failure(_generalFailure));

    final newStock = Stock.fromDoc(stockData);

    final (pErr, pData) = await _linkStockToProduct(newStock, product).toRecord();
    if (pErr != null || pData == null) return left(pErr ?? Failure(_generalFailure));

    return right(newStock);
  }

  FutureReport<Document> _linkStockToProduct(Stock stock, Product product) async {
    final repo = locate<ProductRepo>();
    return await repo.linkStockToProduct(stock, product.id);
  }

  FutureReport<Document> _updateStockQty(Stock stock, int qty) async {
    final repo = locate<StockRepo>();
    return await repo.updateStock(stock.copyWith(quantity: stock.quantity - qty), [Stock.fields.quantity]);
  }

  FutureReport<Document> _updateAccountAmount(String id, num amount) async {
    final repo = locate<PaymentAccountsRepo>();
    final (err, acc) = await repo.getAccountById(id).toRecord();

    if (err != null || acc == null) return left(err ?? const Failure('Unable to get account'));

    return await repo.updateAccount(acc.copyWith(amount: acc.amount + amount));
  }

  FutureReport<Document> _updateDue(String id, num due, RecordType type) async {
    final repo = locate<PartiesRepo>();
    final (err, parti) = await repo.getPartiById(id).toRecord();

    if (err != null || parti == null) return left(err ?? const Failure('Unable to get account'));
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

  FutureReport<Document> updateType(String id, InventoryStatus status) async {
    final (err, rec) = await getRecordById(id).toRecord();

    if (err != null || rec == null) return left(err ?? const Failure('Unable to get record'));

    return await updateRecord(rec.copyWith(status: status));
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
