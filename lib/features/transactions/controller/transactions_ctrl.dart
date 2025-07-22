import 'package:appwrite/appwrite.dart';
import 'package:pos/features/filter/controller/filter_ctrl.dart';
import 'package:pos/features/inventory_record/controller/inventory_record_ctrl.dart';
import 'package:pos/features/parties/controller/parties_ctrl.dart';
import 'package:pos/features/payment_accounts/controller/payment_accounts_ctrl.dart';
import 'package:pos/features/transactions/repository/transactions_repo.dart';
import 'package:pos/main.export.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'transactions_ctrl.g.dart';

@riverpod
class TransactionLogCtrl extends _$TransactionLogCtrl {
  final _repo = locate<TransactionsRepo>();

  final List<TransactionLog> _searchFrom = [];

  @override
  FutureOr<List<TransactionLog>> build() async {
    final fState = ref.watch(filterCtrlProvider);
    final staffs = await _repo.getTransactionLogs(fState);
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
    final list = _searchFrom.where((e) {
      final name = e.transactionForm?.name ?? e.transactedTo?.name ?? e.transactionBy?.name;
      final phn = e.transactionForm?.phone ?? e.transactedTo?.phone ?? e.transactionBy?.phone;
      return e.trxNo.low.contains(query.low) ||
          (name?.low.contains(query.low) ?? false) ||
          (phn?.low.contains(query.low) ?? false);
    }).toList();
    state = AsyncData(list);
  }

  void refresh() async {
    state = AsyncValue.data(_searchFrom);
    ref.invalidateSelf();
  }

  Future<Result> adjustCustomerDue(QMap form, [bool isPayment = false, PFile? file]) async {
    final res = await _repo.adjustCustomerDue(form, isPayment, file);
    return res.fold(leftResult, (r) {
      ref.invalidateSelf();
      ref.invalidate(partiesCtrlProvider);
      ref.invalidate(paymentAccountsCtrlProvider);
      return rightResult('Due adjusted successfully');
    });
  }

  Future<Result> supplierDuePayment(QMap form, [bool isPayment = true, PFile? file]) async {
    final res = await _repo.supplierDuePayment(form, isPayment, file);
    return res.fold(leftResult, (r) {
      ref.invalidateSelf();
      ref.invalidate(partiesCtrlProvider);
      ref.invalidate(paymentAccountsCtrlProvider);
      ref.invalidate(recordsByPartiProvider);
      return rightResult('Due paid successfully');
    });
  }

  Future<Result> transferBalance(QMap form, [PFile? file]) async {
    final res = await _repo.transferBalance(form, file);
    return res.fold(leftResult, (r) {
      ref.invalidateSelf();
      ref.invalidate(partiesCtrlProvider);
      ref.invalidate(paymentAccountsCtrlProvider);
      return rightResult('Balance transferred successfully');
    });
  }
}

@riverpod
Future<List<TransactionLog>> transactionsByParti(Ref ref, String? parti) async {
  if (parti == null) return [];
  final repo = locate<TransactionsRepo>();
  final result = await repo.getTransactionLogs(null, [
    Query.or([Query.equal('transaction_from', parti), Query.equal('transaction_to', parti)]),
  ]);
  return result.fold((l) => [], (r) => r);
}

@riverpod
class TrxFiltered extends _$TrxFiltered {
  final _repo = locate<TransactionsRepo>();
  @override
  List<TransactionLog> build() {
    return [];
  }

  Future<List<TransactionLog>> filter(ShadDateTimeRange? range, TransactionType? type) async {
    final result = await _repo.getTransactionLogs(
      null,
      [_createRangeQuery(range), if (type != null) Query.equal('transaction_type', type.name)].nonNulls.toList(),
    );
    state = result.fold((l) => [], (r) => r);
    return state;
  }

  String? _createRangeQuery(ShadDateTimeRange? range) {
    if (range case ShadDateTimeRange(:final start, :final end)) {
      if (start != null && end != null) {
        return Query.between('date', start.justDate.toIso8601String(), end.nextDay.justDate.toIso8601String());
      } else if (start != null) {
        return Query.greaterThan('date', start.justDate.toIso8601String());
      } else if (end != null) {
        return Query.lessThan('date', end.nextDay.justDate.toIso8601String());
      }
    }
    return null;
  }
}
