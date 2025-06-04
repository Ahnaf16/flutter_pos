import 'package:fpdart/fpdart.dart';
import 'package:pos/features/expense/repository/expense_repo.dart';
import 'package:pos/features/filter/controller/filter_ctrl.dart';
import 'package:pos/main.export.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'expense_ctrl.g.dart';

@riverpod
class ExpenseCtrl extends _$ExpenseCtrl {
  final _repo = locate<ExpenseRepo>();

  final List<Expense> _searchFrom = [];

  @override
  Future<List<Expense>> build() async {
    final fState = ref.watch(filterCtrlProvider);

    final staffs = await _repo.getExpenses(fState);
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
    final list = _searchFrom.where((e) {
      return e.expenseBy.name.low.contains(query) ||
          e.expenseBy.phone.low.contains(query) ||
          e.expenseBy.email.low.contains(query) ||
          e.expanseFor.low.contains(query) ||
          e.category.name.low.contains(query);
    }).toList();
    state = AsyncData(list);
  }

  void refresh() async {
    state = AsyncValue.data(_searchFrom);
    ref.invalidateSelf();
  }

  Future<Result> createExpense(QMap form, PFile? file) async {
    final res = await _repo.createExpenses(form, file);
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

  Future<Result> delete(ExpenseCategory category) async {
    final res = await _repo.deleteCategory(category);
    return await res.fold(leftResult, (r) {
      ref.invalidateSelf();
      return rightResult('Category deleted successfully');
    });
  }
}
