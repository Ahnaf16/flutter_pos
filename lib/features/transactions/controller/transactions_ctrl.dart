import 'package:fpdart/fpdart.dart';
import 'package:pos/features/transactions/repository/transactions_repo.dart';
import 'package:pos/main.export.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'transactions_ctrl.g.dart';

@riverpod
class TransactionLogCtrl extends _$TransactionLogCtrl {
  final _repo = locate<TransactionsRepo>();

  @override
  FutureOr<List<TransactionLog>> build([TransactionType? type]) async {
    final staffs = await _repo.getTransactionLogs(type);
    return staffs.fold((l) {
      Toast.showErr(Ctx.context, l);
      return [];
    }, identity);
  }

  Future<Result> createManual(QMap form) async {
    final res = await _repo.adjustCustomerDue(form);
    return res.fold(leftResult, (r) {
      ref.invalidateSelf();
      return rightResult('Transaction created successfully');
    });
  }
}
