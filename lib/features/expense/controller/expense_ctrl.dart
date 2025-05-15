import 'package:fpdart/fpdart.dart';
import 'package:pos/features/expense/repository/expense_repo.dart';
import 'package:pos/main.export.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'expense_ctrl.g.dart';

@riverpod
class ExpenseCtrl extends _$ExpenseCtrl {
  final _repo = locate<ExpenseRepo>();

  final List<Expense> _searchFrom = [];

  @override
  Future<List<Expense>> build() async {
    final staffs = await _repo.getExpenses();
    return staffs.fold(
      (l) {
        Toast.showErr(Ctx.context, l);
        return [];
      },
      (r) {
        _searchFrom.clear();
        _searchFrom.addAll(r);
        return r;
      },
    );
  }

  void search(String query) async {
    if (query.isEmpty) {
      state = AsyncValue.data(_searchFrom);
    }
    query = query.low;
    final list =
        _searchFrom.where((e) {
          return e.expenseBy.name.low.contains(query) ||
              e.expenseBy.phone.low.contains(query) ||
              e.expenseBy.email.low.contains(query);
        }).toList();
    state = AsyncData(list);
  }

  void filter({PaymentAccount? acc, ExpenseCategory? category}) async {
    if (acc != null) {
      state = AsyncData(_searchFrom.where((e) => e.account.id == acc.id).toList());
    }
    if (category != null) {
      state = AsyncData(_searchFrom.where((e) => e.category.id == category.id).toList());
    }
    if (acc == null && category == null) {
      state = AsyncValue.data(_searchFrom);
    }
  }

  Future<Result> createExpense(QMap form) async {
    final res = await _repo.createExpenses(form);
    return res.fold(leftResult, (r) {
      ref.invalidateSelf();
      return rightResult('Expense created successfully');
    });
  }

  Future<Result> updateExpense(Expense expense) async {
    final res = await _repo.updateExpenses(expense);
    return res.fold(leftResult, (r) {
      ref.invalidateSelf();
      return rightResult('Expense updated successfully');
    });
  }
}

@riverpod
class ExpenseCategoryCtrl extends _$ExpenseCategoryCtrl {
  final _repo = locate<ExpenseRepo>();
  @override
  Future<List<ExpenseCategory>> build() async {
    final staffs = await _repo.getExpenseCategory();
    return staffs.fold((l) {
      Toast.showErr(Ctx.context, l);
      return [];
    }, identity);
  }

  Future<Result> createCategory(QMap form) async {
    final res = await _repo.createExpenseCategory(form);
    return res.fold(leftResult, (r) {
      ref.invalidateSelf();
      return rightResult('Category created successfully');
    });
  }

  Future<Result> updateCategory(ExpenseCategory category) async {
    final res = await _repo.updateExpenseCategory(category);
    return res.fold(leftResult, (r) {
      ref.invalidateSelf();
      return rightResult('Category updated successfully');
    });
  }

  Future<Result> toggleEnable(bool isEnable, ExpenseCategory category) async {
    final res = await _repo.updateExpenseCategory(category.copyWith(enabled: isEnable));
    return await res.fold(leftResult, (r) async {
      state = await AsyncValue.guard(() async => build());
      return rightResult('Category updated successfully');
    });
  }
}
