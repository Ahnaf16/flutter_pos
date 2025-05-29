import 'package:appwrite/models.dart';
import 'package:fpdart/fpdart.dart';
import 'package:pos/features/auth/repository/auth_repo.dart';
import 'package:pos/features/inventory_record/repository/inventory_repo.dart';
import 'package:pos/features/parties/repository/parties_repo.dart';
import 'package:pos/features/payment_accounts/repository/payment_accounts_repo.dart';
import 'package:pos/main.export.dart';

class TransactionsRepo with AwHandler {
  final _coll = AWConst.collections.transactions;

  FutureReport<Document> addTransaction(TransactionLog log) async {
    return await db.create(_coll, data: log.toAwPost());
  }

  FutureReport<Document> adjustCustomerDue(QMap form, [bool isPayment = false]) async {
    final data = QMap.from(form);
    data.addAll({'date': DateTime.now().toIso8601String()});
    TransactionLog log = TransactionLog.fromMap(data);

    if (log.validate() != null) return left(Failure(log.validate()!));

    log = log.copyWith(isIncome: () => !isPayment);

    if (log.transactionBy == null) {
      final (err, user) = await locate<AuthRepo>().currentUser().toRecord();
      if (err != null || user == null) return left(err ?? const Failure('Unable to get current user'));
      log = log.copyWith(transactionBy: () => user);
    }

    Party? parti = isPayment ? log.transactedTo : log.transactionForm;

    if (parti != null && !parti.isWalkIn) {
      final (err, pDoc) = await _updateDue(parti.id, isPayment ? log.amount : -log.amount).toRecord();
      if (err != null || pDoc == null) return left(err ?? const Failure('Unable to update due'));
      parti = Party.fromDoc(pDoc);
    }

    final account = log.account;
    if (account != null) {
      final amount = isPayment ? -log.amount : log.amount;
      log = log.copyWith(customInfo: {'pre': account.amount.currency(), 'post': (account.amount + amount).currency()});
      final (err, acc) = await _updateAccountAmount(account.id, amount).toRecord();
      if (err != null || acc == null) return left(err ?? const Failure('Unable to update account amount'));
    }

    //! change status for unpaid invoice
    if (!isPayment) {
      await locate<InventoryRepo>().updateUnpaidInvoices(parti?.id, log.amount);
    }

    return await db.create(_coll, data: log.toAwPost());
    // return left(const Failure('___WIP___'));
  }

  FutureReport<Document> supplierDuePayment(QMap form, [bool isPayment = true]) async {
    final data = QMap.from(form);
    data.addAll({'date': DateTime.now().toIso8601String()});
    TransactionLog log = TransactionLog.fromMap(data);

    if (log.validate() != null) return left(Failure(log.validate()!));

    log = log.copyWith(isIncome: () => !isPayment);

    if (log.transactionBy == null) {
      final (err, user) = await locate<AuthRepo>().currentUser().toRecord();
      if (err != null || user == null) return left(err ?? const Failure('Unable to get current user'));
      log = log.copyWith(transactionBy: () => user);
    }

    Party? parti = isPayment ? log.transactedTo : log.transactionForm;
    if (parti != null && !parti.isWalkIn) {
      final (err, pDoc) = await _updateDue(parti.id, isPayment ? log.amount : -log.amount).toRecord();
      if (err != null || pDoc == null) return left(err ?? const Failure('Unable to update due'));
      parti = Party.fromDoc(pDoc);
    }

    final account = log.account;
    if (account != null) {
      final amount = isPayment ? -log.amount : log.amount;
      log = log.copyWith(customInfo: {'pre': account.amount.currency(), 'post': (account.amount + amount).currency()});
      final (err, acc) = await _updateAccountAmount(account.id, amount).toRecord();
      if (err != null || acc == null) return left(err ?? const Failure('Unable to update account amount'));
    }

    //! change status for unpaid invoice
    if (isPayment) {
      await locate<InventoryRepo>().updateUnpaidInvoices(parti?.id, log.amount);
    }

    return await db.create(_coll, data: log.toAwPost());
  }

  FutureReport<Document> transferBalance(QMap form) async {
    final data = QMap.from(form);
    data.addAll({'date': DateTime.now().toIso8601String()});
    TransactionLog log = TransactionLog.fromMap(data);
    if (log.validate() != null) return left(Failure(log.validate()!));

    log = log.copyWith(isIncome: () => false);

    if (log.transactionBy == null) {
      final (err, user) = await locate<AuthRepo>().currentUser().toRecord();
      if (err != null || user == null) return left(err ?? const Failure('Unable to get current user'));
      log = log.copyWith(transactionBy: () => user);
    }

    Party? fromParti = log.transactionForm;
    if (fromParti != null && !fromParti.isWalkIn) {
      final (err, parti) = await _updateDue(fromParti.id, log.amount).toRecord();
      if (err != null || parti == null) return left(err ?? const Failure('Unable to update due'));
      fromParti = Party.fromDoc(parti);
    }
    final account = log.account;
    if (account != null) {
      log = log.copyWith(
        customInfo: {'pre': account.amount.currency(), 'post': (account.amount - log.amount).currency()},
      );
      final (err, acc) = await _updateAccountAmount(account.id, -log.amount).toRecord();
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

  FutureReport<List<TransactionLog>> getTransactionLogs([FilterState? fl, List<String>? queries]) async {
    final query = <String?>[...?queries];

    if (fl != null) {
      query.add(fl.queryBuilder(FilterType.account, 'payment_account'));
      query.add(fl.queryBuilder(FilterType.type, 'transaction_type'));
      query.add(fl.queryBuilder(FilterType.dateFrom, 'date'));
      query.add(fl.queryBuilder(FilterType.dateTo, 'date'));
    }

    return await db
        .getList(_coll, queries: query.nonNulls.toList())
        .convert((docs) => docs.convertDoc(TransactionLog.fromDoc));
  }
}
