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
  final String _emptyFields = 'One or multiple required fields are empty';
  final String _updateAccountFailure = 'Failed to update account amount';

  FutureReport<Document> createSale(InventoryRecordState inventory) async {
    //! add details
    final (detailErr, detailsData) = await _createRecordDetails(inventory.details, true).toRecord();
    if (detailErr != null || detailsData == null) return left(detailErr ?? Failure(_generalFailure));
    InventoryRecord? record = inventory.copyWith(details: detailsData).toInventoryRecord();
    if (record == null) return left(Failure(_emptyFields));

    //! update account amount
    final acc = record.account;
    final (accErr, accData) = await _updateAccountAmount(acc.id, record.amount).toRecord();
    if (accErr != null || accData == null) return left(accErr ?? Failure(_updateAccountFailure));

    //! update Due
    Parti? parti = record.parti;
    //only updates th e [DUE]
    // will be null if customer is walk-in
    if (parti != null) {
      if (inventory.hasDue || inventory.hasBalance) {
        // _updateDue adds the due with the parti.due. if due is (-) it will be subtracted
        // when hasBalance, due is (-), so -due will subtract due. will be added as balance
        // when hasDue, due is (+), so +due will add due. will be added as due
        final (partiErr, partiData) = await _updateDue(parti.id, inventory.due, record.type).toRecord();
        if (partiErr != null || partiData == null) return left(partiErr ?? Failure(_generalFailure));
        parti = Parti.fromDoc(partiData);
      }

      if (inventory.hasDue && inventory.partiHasBalance) {
        // when sale has due but parti has balance, the due will be added to record.dueBalance.
        // this due has been already deducted from parti.due
        record = record.copyWith(dueBalance: record.dueBalance + inventory.due);
      }

      if (inventory.partiHasBalance && inventory.dueBalance > 0) {
        // [Parti.Due] is already [-] in this case so adding dueBalance will subtract balance
        final (partiErr, partiData) = await _updateDue(parti.id, inventory.dueBalance, record.type).toRecord();
        if (partiErr != null || partiData == null) return left(partiErr ?? Failure(_generalFailure));
      }
    }

    //! add transaction log
    await _addTransactionLog(record);

    //! add record
    final doc = await db.create(AWConst.collections.inventoryRecord, data: record.toAwPost());
    return doc;
  }

  FutureReport<Document> createPurchase(InventoryRecordState inventory) async {
    //! add details
    final (detailErr, detailsData) = await _createRecordDetails(inventory.details, false).toRecord();
    if (detailErr != null || detailsData == null) return left(detailErr ?? Failure(_generalFailure));
    InventoryRecord? record = inventory.copyWith(details: detailsData).toInventoryRecord();
    if (record == null) return left(Failure(_emptyFields));

    //! update account amount
    final acc = record.account;
    // (-) amount because it is a purchase and _updateAccountAmount adds the amount.
    final (accErr, accData) = await _updateAccountAmount(acc.id, -record.amount).toRecord();
    if (accErr != null || accData == null) return left(accErr ?? Failure(_updateAccountFailure));

    //! update Due
    Parti? parti = record.parti;
    //only updates th e [DUE]
    if (parti == null) return left(const Failure('Parti is required when purchasing'));

    if (inventory.hasDue || inventory.hasBalance) {
      // _updateDue adds the due with the parti.due. if due is (-) it will be subtracted
      // when hasBalance, due is (-), so -(-due) will add due. will be added as due
      // when hasDue, due is (+), so -(+due) will subtract due. will be added as balance
      final (partiErr, partiData) = await _updateDue(parti.id, -inventory.due, record.type).toRecord();
      if (partiErr != null || partiData == null) return left(partiErr ?? Failure(_generalFailure));
      parti = Parti.fromDoc(partiData);
    }

    if (inventory.hasDue && inventory.partiHasDue) {
      // when purchase has due and parti has due, add due to dueBalance
      // this due has been already subtracted from parti.due
      record = record.copyWith(dueBalance: record.dueBalance + inventory.due);
    }

    if (inventory.partiHasDue && inventory.dueBalance > 0) {
      // [Parti.Due] is [+] in this case so subtracting dueBalance will subtract due
      final (partiErr, partiData) = await _updateDue(parti.id, -inventory.dueBalance, record.type).toRecord();
      if (partiErr != null || partiData == null) return left(partiErr ?? Failure(_generalFailure));
    }

    //! add transaction log
    await _addTransactionLog(record);

    //! add record
    final doc = await db.create(AWConst.collections.inventoryRecord, data: record.toAwPost());
    return doc;
  }

  FutureReport<Document> returnSale(InventoryRecord record, Map<String, int> data, {bool coverVatShip = false}) async {
    num totalPrice = 0;
    // //! update stock qty
    for (final MapEntry(:key, :value) in data.entries) {
      final detail = record.details.firstWhere((e) => e.id == key);
      totalPrice = totalPrice + detail.totalPrice(value);

      // final (stockErr, stockData) = await _updateStockQty(detail.stock, -value).toRecord();
      // if (stockErr != null || stockData == null) return left(stockErr ?? Failure(_generalFailure));
    }

    final vatShip = coverVatShip ? (record.vat + record.shipping) : 0;

    totalPrice = (totalPrice + vatShip) - record.discount;

    //! update account amount
    final acc = record.account;
    final minAmount = totalPrice < record.amount ? record.amount : totalPrice;
    cat('minAmount:: $minAmount');

    // final (accErr, accData) = await _updateAccountAmount(acc.id, -minAmount).toRecord();
    // if (accErr != null || accData == null) return left(accErr ?? Failure(_updateAccountFailure));

    final remaining = totalPrice - minAmount;

    //! update Due
    final Parti? parti = record.parti;
    if (parti != null) {
      final due = record.due + record.dueBalance;
      cat('due:: $due');
      cat('remaining:: $remaining');

      if (due >= remaining) {
        cat('${(parti.due) + (-remaining)}');

        // final (partiErr, partiData) = await _updateDue(parti.id, -remaining, record.type).toRecord();
        // if (partiErr != null || partiData == null) return left(partiErr ?? Failure(_generalFailure));
        // parti = Parti.fromDoc(partiData);
      }
    }

    return failure('---WIP---');
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

  FutureReport<List<InventoryRecord>> getRecords(RecordType type) async {
    return await db
        .getList(AWConst.collections.inventoryRecord, queries: [Query.equal('record_type', type.name)])
        .convert((docs) => docs.convertDoc(InventoryRecord.fromDoc));
  }

  FutureReport<InventoryRecord> getRecordById(String id) async {
    return await db.get(AWConst.collections.inventoryRecord, id).convert(InventoryRecord.fromDoc);
  }
}
