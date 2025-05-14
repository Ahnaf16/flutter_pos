import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart';
import 'package:fpdart/fpdart.dart';
import 'package:pos/features/auth/repository/auth_repo.dart';
import 'package:pos/features/parties/repository/parties_repo.dart';
import 'package:pos/features/payment_accounts/repository/payment_accounts_repo.dart';
import 'package:pos/main.export.dart';

class TransactionsRepo with AwHandler {
  final _coll = AWConst.collections.transactions;

  FutureReport<Document> addTransaction(TransactionLog log) async {
    return await db.create(_coll, data: log.toAwPost());
  }

  FutureReport<Document> adjustCustomerDue(QMap form) async {
    final data = QMap.from(form);
    data.addAll({'date': DateTime.now().toIso8601String()});
    TransactionLog log = TransactionLog.fromMap(data);

    if (log.validate() != null) return left(Failure(log.validate()!));
    // return left(const Failure('---'));

    Party? fromParti = log.transactionForm;
    if (fromParti != null && !fromParti.isWalkIn) {
      final (err, parti) = await _updateDue(fromParti.id, -log.amount).toRecord();
      if (err != null || parti == null) return left(err ?? const Failure('Unable to update due'));
      fromParti = Party.fromDoc(parti);
    }

    if (log.transactionBy == null) {
      final (err, user) = await locate<AuthRepo>().currentUser().toRecord();
      if (err != null || user == null) return left(err ?? const Failure('Unable to get current user'));
      log = log.copyWith(transactionBy: () => user);
    }

    final account = log.account;
    if (account != null) {
      final (err, acc) = await _updateAccountAmount(account.id, log.amount).toRecord();
      if (err != null || acc == null) return left(err ?? const Failure('Unable to update account amount'));
    }

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
