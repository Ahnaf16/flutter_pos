import 'package:appwrite/models.dart';
import 'package:fpdart/fpdart.dart';
import 'package:pos/features/payment_accounts/repository/payment_accounts_repo.dart';
import 'package:pos/features/transactions/repository/transactions_repo.dart';
import 'package:pos/main.export.dart';

class ExpenseRepo with AwHandler {
  FutureReport<Document> createExpenses(QMap form) async {
    final data = QMap.from(form);
    data.addAll({'date': DateTime.now().toIso8601String()});

    final expense = Expense.fromMap(data);

    //! update account amount
    final acc = expense.account;
    final (accErr, accData) = await _updateAccountAmount(acc, expense.amount).toRecord();
    if (accErr != null || accData == null) return left(accErr ?? const Failure('Unable to update account amount'));

    //! add transaction log
    await _addTransactionLog(expense);

    final doc = await db.create(AWConst.collections.expense, data: expense.toAwPost());
    return doc;
  }

  FutureReport<Document> _updateAccountAmount(PaymentAccount account, num amount) async {
    final repo = locate<PaymentAccountsRepo>();
    return await repo.updateAccount(account.copyWith(amount: account.amount - amount));
  }

  FutureReport<Document> _addTransactionLog(Expense ex) async {
    final repo = locate<TransactionsRepo>();
    final transaction = TransactionLog.fromExpense(ex);
    return await repo.addTransaction(transaction);
  }

  FutureReport<Document> updateExpenses(Expense expense) async {
    final doc = await db.update(AWConst.collections.expense, expense.id, data: expense.toAwPost());
    return doc;
  }

  FutureReport<List<Expense>> getExpenses() async {
    return await db.getList(AWConst.collections.expense).convert((docs) => docs.convertDoc(Expense.fromDoc));
  }

  FutureReport<Document> createExpenseCategory(QMap form) async {
    final category = ExpenseCategory.fromMap(form);
    final doc = await db.create(AWConst.collections.expenseCategory, data: category.toAwPost());
    return doc;
  }

  FutureReport<Document> updateExpenseCategory(ExpenseCategory category) async {
    final doc = await db.update(AWConst.collections.expenseCategory, category.id, data: category.toAwPost());
    return doc;
  }

  FutureReport<List<ExpenseCategory>> getExpenseCategory() async {
    return await db
        .getList(AWConst.collections.expenseCategory)
        .convert((docs) => docs.convertDoc(ExpenseCategory.fromDoc));
  }

  FutureReport<Unit> deleteCategory(ExpenseCategory category) async {
    final doc = await db.delete(AWConst.collections.expenseCategory, category.id);

    return doc;
  }
}
