import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart';
import 'package:fpdart/fpdart.dart';
import 'package:pos/features/auth/repository/auth_repo.dart';
import 'package:pos/features/inventory_record/repository/inventory_repo.dart';
import 'package:pos/features/parties/repository/parties_repo.dart';
import 'package:pos/features/payment_accounts/repository/payment_accounts_repo.dart';
import 'package:pos/features/stock/repository/stock_repo.dart';
import 'package:pos/features/transactions/repository/transactions_repo.dart';
import 'package:pos/main.export.dart';

class ReturnRepo with AwHandler {
  final String _generalFailure = 'Failed to create record';
  final String _updateAccountFailure = 'Failed to update account amount';

  FutureReport<Document> returnRecord(InventoryRecord record, Map<String, int> data, {bool coverVatShip = true}) async {
    final isSale = record.type.isSale;

    num effectiveOp(num value) => isSale ? value : -value;

    num totalPrice = 0;
    final detailsQtyPair = <String>[];

    final (err, user) = await locate<AuthRepo>().currentUser().toRecord();
    if (err != null || user == null) return left(err ?? const Failure('Unable to getting current user'));

    // //! update stock qty
    for (final MapEntry(:key, :value) in data.entries) {
      final detail = record.details.firstWhere((e) => e.id == key);
      totalPrice = totalPrice + detail.totalPrice(value);

      final qty = effectiveOp(value).toInt();
      detailsQtyPair.add('$key$kSplitPattern$qty');
      final (stockErr, stockData) = await _updateStockQty(detail.stock.id, qty).toRecord();
      if (stockErr != null || stockData == null) return left(stockErr ?? Failure(_generalFailure));
    }

    final vatShip = coverVatShip ? (record.vat + record.shipping) : 0;
    totalPrice = (totalPrice + vatShip) - record.calcDiscount;

    final accountMax = record.paidAmount;

    //! update account amount
    final acc = record.account;
    final effectiveAccBal = (totalPrice >= accountMax ? accountMax : totalPrice);
    if (acc != null) {
      final (accErr, accData) = await _updateAccountAmount(acc.id, effectiveOp(-effectiveAccBal)).toRecord();
      if (accErr != null || accData == null) return left(accErr ?? Failure(_updateAccountFailure));
    }
    final remaining = totalPrice - effectiveAccBal;

    //! update Due
    final Party? parti = record.party;
    if (parti != null && remaining != 0) {
      final (partiErr, partiData) = await _updateDue(parti.id, effectiveOp(-remaining), record.type).toRecord();
      if (partiErr != null || partiData == null) return left(partiErr ?? Failure(_generalFailure));
    }

    final returnRec = ReturnRecord(
      id: ID.unique(),
      returnedRec: record,
      returnDate: dateNow.run(),
      returnedBy: user,
      note: '${data.values.sum} items returned',
      adjustAccount: effectiveAccBal,
      adjustFromParty: remaining,
      isSale: isSale,
      detailsQtyPair: detailsQtyPair,
      account: acc,
    );

    //! update record
    await _updateRecordType(record.id, InventoryStatus.returned);

    //! add transaction log
    await _addTransactionLog(returnRec);

    //! add record
    final doc = await db.create(AWConst.collections.returnRecord, data: returnRec.toAwPost());
    return doc;
  }

  FutureReport<Unit> delete(ReturnRecord record) async {
    final isSale = record.isSale;

    num effectiveOp(num value) => isSale ? value : -value;

    final qtyPair = record.toMap().parseCustomInfo('stock_qty_pair').transformValues((_, v) => v.asInt);

    //! update stock qty
    for (final MapEntry(:key, :value) in qtyPair.entries) {
      final (err, detail) = await _getDetails(key).toRecord();
      if (err != null || detail == null) return left(err ?? Failure(_generalFailure));

      final (stockErr, stockData) = await _updateStockQty(detail.stock.id, -value).toRecord();
      if (stockErr != null || stockData == null) return left(stockErr ?? Failure(_generalFailure));
    }

    //! update account amount
    final acc = record.account;
    if (acc != null) {
      final effectiveAccBal = record.adjustAccount;
      final (accErr, accData) = await _updateAccountAmount(acc.id, effectiveOp(effectiveAccBal)).toRecord();
      if (accErr != null || accData == null) return left(accErr ?? Failure(_updateAccountFailure));
    }

    //! update Due
    final Party? parti = record.returnedRec?.party;
    if (parti != null) {
      final effectiveAccBal = record.adjustFromParty;
      final type = record.isSale ? RecordType.sale : RecordType.purchase;
      final (partiErr, partiData) = await _updateDue(parti.id, effectiveAccBal, type).toRecord();
      if (partiErr != null || partiData == null) return left(partiErr ?? Failure(_generalFailure));
    }

    //! update record
    final rec = record.returnedRec;
    if (rec != null) {
      InventoryStatus type = InventoryStatus.paid;
      if (rec.paidAmount == 0) type = InventoryStatus.unpaid;
      if (rec.paidAmount > 0 && rec.paidAmount < rec.total) type = InventoryStatus.partial;
      await _updateRecordType(rec.id, type);
    }

    return db.delete(AWConst.collections.returnRecord, record.id);
  }

  FutureReport<Document> _updateRecordType(String id, InventoryStatus status) async {
    final repo = locate<InventoryRepo>();
    return await repo.updateType(id, status);
  }

  FutureReport<Document> _updateStockQty(String id, int qty) async {
    final repo = locate<StockRepo>();
    final (err, st) = await repo.getStockById(id).toRecord();

    if (err != null || st == null) return left(err ?? const Failure('Unable to get stock'));
    return await repo.updateStock(st.copyWith(quantity: st.quantity + qty), [Stock.fields.quantity]);
  }

  FutureReport<InventoryDetails> _getDetails(String id) async {
    final repo = locate<InventoryRepo>();
    final (err, detail) = await repo.getInvDetails([Query.equal(r'$id', id)]).toRecord();

    if (err != null || detail == null || detail.isEmpty) return left(err ?? const Failure('Unable to get record'));
    return right(detail.first);
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

  FutureReport<Document> _addTransactionLog(ReturnRecord record) async {
    final repo = locate<TransactionsRepo>();

    final transaction = TransactionLog.fromReturn(record);
    return await repo.addTransaction(transaction);
  }

  FutureReport<List<ReturnRecord>> getRecords(bool? isSale, [FilterState? fl]) async {
    final query = <String?>[];
    if (isSale != null) query.add(Query.equal('isSale', isSale));
    if (fl != null) {
      query.add(fl.queryBuilder(FilterType.account, 'paymentAccount'));
      query.add(fl.queryBuilder(FilterType.dateFrom, '\$createdAt'));
      query.add(fl.queryBuilder(FilterType.dateTo, '\$createdAt'));
    }
    return await db
        .getList(AWConst.collections.returnRecord, queries: query.nonNulls.toList())
        .convert((docs) => docs.convertDoc(ReturnRecord.fromDoc));
  }

  FutureReport<ReturnRecord> getRecordById(String id) async {
    return await db.get(AWConst.collections.returnRecord, id).convert(ReturnRecord.fromDoc);
  }
}
