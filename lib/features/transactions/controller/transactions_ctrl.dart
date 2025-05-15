import 'package:pos/features/parties/controller/parties_ctrl.dart';
import 'package:pos/features/transactions/repository/transactions_repo.dart';
import 'package:pos/main.export.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'transactions_ctrl.g.dart';

@riverpod
class TransactionLogCtrl extends _$TransactionLogCtrl {
  final _repo = locate<TransactionsRepo>();

  final List<TransactionLog> _searchFrom = [];

  @override
  FutureOr<List<TransactionLog>> build([TransactionType? type]) async {
    final staffs = await _repo.getTransactionLogs(type);
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
    final list =
        _searchFrom.where((e) {
          final name = e.transactionForm?.name ?? e.transactedTo?.name ?? e.transactionBy?.name;
          final phn = e.transactionForm?.phone ?? e.transactedTo?.phone ?? e.transactionBy?.phone;
          return (name?.low.contains(query.low) ?? false) || (phn?.low.contains(query.low) ?? false);
        }).toList();
    state = AsyncData(list);
  }

  void filter({PaymentAccount? account, TransactionType? type, ShadDateTimeRange? range}) async {
    if (account != null) {
      state = AsyncData(_searchFrom.where((e) => e.account?.id == account.id).toList());
    }

    if (type != null) {
      state = AsyncData(_searchFrom.where((e) => e.type == type).toList());
    }

    if (range case ShadDateTimeRange(:final start, :final end)) {
      final filteredList =
          _searchFrom.where((entry) {
            final date = entry.date.justDate;
            if (start != null && end != null) {
              return date.isAfter(start.justDate) && date.isBefore(end.nextDay.justDate);
            } else if (start != null) {
              return date.isAfter(start.justDate);
            } else if (end != null) {
              return date.isBefore(end.nextDay.justDate);
            }
            return true;
          }).toList();

      state = AsyncData(filteredList);
    }

    if (account == null && type == null && range == null) {
      state = AsyncValue.data(_searchFrom);
    }
  }

  Future<Result> adjustCustomerDue(QMap form) async {
    final res = await _repo.adjustCustomerDue(form);
    return res.fold(leftResult, (r) {
      ref.invalidateSelf();
      ref.invalidate(partiesCtrlProvider);
      return rightResult('Due adjusted successfully');
    });
  }

  Future<Result> supplierDuePayment(QMap form) async {
    final res = await _repo.supplierDuePayment(form);
    return res.fold(leftResult, (r) {
      ref.invalidateSelf();
      ref.invalidate(partiesCtrlProvider);
      return rightResult('Due paid successfully');
    });
  }

  Future<Result> transferBalance(QMap form) async {
    final res = await _repo.transferBalance(form);
    return res.fold(leftResult, (r) {
      ref.invalidateSelf();
      ref.invalidate(partiesCtrlProvider);
      return rightResult('Balance transferred successfully');
    });
  }
}
