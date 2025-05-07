import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart';
import 'package:fpdart/fpdart.dart';
import 'package:pos/features/parties/repository/parties_repo.dart';
import 'package:pos/features/payment_accounts/repository/payment_accounts_repo.dart';
import 'package:pos/main.export.dart';

class TransactionsRepo with AwHandler {
  final _coll = AWConst.collections.transactions;

  FutureReport<Document> addTransaction(TransactionLog log) async {
    return await db.create(_coll, data: log.toAwPost());
  }

  FutureReport<Document> addManual(QMap form, [bool fromMe = true]) async {
    final data = QMap.from(form);
    data.addAll({'date': DateTime.now().toIso8601String()});
    final log = TransactionLog.fromMap(data);

    if (log.validate(fromMe) != null) return left(Failure(log.validate(fromMe)!));

    Parti? fromParti = log.transactionFormParti;
    if (!fromMe && fromParti != null) {
      final (err, parti) = await _updateDue(fromParti.id, log.amount).toRecord();
      if (err != null || parti == null) return left(err ?? const Failure('Unable to update due'));
      fromParti = Parti.fromDoc(parti);
    }

    Parti? toParti = log.transactedTo;
    if (toParti != null) {
      final (err, parti) = await _updateDue(toParti.id, -log.amount).toRecord();
      if (err != null || parti == null) return left(err ?? const Failure('Unable to update due'));
      toParti = Parti.fromDoc(parti);
    }

    final (err, acc) = await _updateAccountAmount(log.account.id, -log.amount).toRecord();
    if (err != null || acc == null) return left(err ?? const Failure('Unable to update account amount'));

    return await db.create(_coll, data: log.toAwPost());
  }

  FutureReport<Document> _updateAccountAmount(String id, num amount) async {
    final repo = locate<PaymentAccountsRepo>();
    final (err, acc) = await repo.getAccountById(id).toRecord();

    if (err != null || acc == null) return left(err ?? const Failure('Unable to get account'));

    return await repo.updateAccount(acc.copyWith(amount: acc.amount + amount));
  }

  FutureReport<Document> _updateDue(String id, num due) async {
    final repo = locate<PartiesRepo>();
    final (err, parti) = await repo.getPartiById(id).toRecord();

    if (err != null || parti == null) return left(err ?? const Failure('Unable to get account'));
    return await repo.updateDue(parti, due, !due.isNegative, '');
  }

  FutureReport<List<TransactionLog>> getTransactionLogs([TransactionType? type]) async {
    final q = [if (type != null) Query.equal('transaction_type', type.name)];
    return await db.getList(_coll, queries: q).convert((docs) => docs.convertDoc(TransactionLog.fromDoc));
  }
}
