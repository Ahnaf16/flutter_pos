import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart';
import 'package:fpdart/fpdart.dart';
import 'package:pos/features/transactions/repository/transactions_repo.dart';
import 'package:pos/main.export.dart';

class PaymentAccountsRepo with AwHandler {
  final _coll = AWConst.collections.paymentAccount;

  FutureReport<Document> createAccount(QMap form) async {
    final acc = PaymentAccount.fromMap(form);
    final doc = await db.create(_coll, data: acc.toAwPost());
    return doc;
  }

  FutureReport<Document> updateAccount(PaymentAccount acc) async {
    final doc = await db.update(_coll, acc.id, data: acc.toAwPost());
    return doc;
  }

  FutureReport<Document> updateAccountAtomic(String id, PaymentAccount Function(PaymentAccount acc) updateFn) async {
    final (err, acc) = await getAccountById(id).toRecord();
    if (err != null || acc == null) return left(err ?? const Failure('Unable to get account'));

    final doc = await db.update(_coll, id, data: updateFn(acc).toAwPost());
    return doc;
  }

  FutureReport<Document> transfer(AccBalanceTransferState state) async {
    final err = state.validate();
    if (err != null) return failure(err);

    final from = state.from;
    final to = state.to;
    if (from == null || to == null) return failure('accounts are required');

    final result = await updateAccountAtomic(from.id, (a) => a.copyWith(amount: a.amount - state.amount));
    await updateAccountAtomic(to.id, (a) => a.copyWith(amount: a.amount + state.amount));

    await _createTrx(state);

    return result;
  }

  FutureReport<Document> _createTrx(AccBalanceTransferState state) async {
    final repo = locate<TransactionsRepo>();
    final log = TransactionLog.fromTransferState(state);

    final result = await repo.addTransaction(log);
    return result;
  }

  FutureReport<List<PaymentAccount>> getAccounts([bool onlyActive = true]) async {
    return await db
        .getList(_coll, queries: [if (onlyActive) Query.equal('is_active', true)])
        .convert((docs) => docs.convertDoc(PaymentAccount.fromDoc));
  }

  FutureReport<PaymentAccount> getAccountById(String id) async {
    return await db.get(_coll, id).convert(PaymentAccount.fromDoc);
  }

  FutureReport<Unit> deleteAccount(String id) async {
    return await db.delete(_coll, id);
  }
}
