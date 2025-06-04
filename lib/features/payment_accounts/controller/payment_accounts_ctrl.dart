import 'package:pos/features/payment_accounts/repository/payment_accounts_repo.dart';
import 'package:pos/main.export.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'payment_accounts_ctrl.g.dart';

@riverpod
class PaymentAccountsCtrl extends _$PaymentAccountsCtrl {
  final _repo = locate<PaymentAccountsRepo>();

  final List<PaymentAccount> _searchFrom = [];

  @override
  Future<List<PaymentAccount>> build([bool onlyActive = true]) async {
    final staffs = await _repo.getAccounts(onlyActive);
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
    final list = _searchFrom.where((e) => e.type.name.low.contains(query) || e.name.low.contains(query)).toList();
    state = AsyncData(list);
  }

  FVoid refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async => build(onlyActive));
  }

  Future<Result> createAccount(QMap form) async {
    final res = await _repo.createAccount(form);
    return res.fold(leftResult, (r) {
      ref.invalidate(paymentAccountsCtrlProvider);
      return rightResult('Payment account created successfully');
    });
  }

  Future<Result> updateAccount(PaymentAccount acc) async {
    final res = await _repo.updateAccount(acc);
    return res.fold(leftResult, (r) {
      ref.invalidate(paymentAccountsCtrlProvider);
      return rightResult('Payment account updated successfully');
    });
  }

  Future<Result> transferBalance(AccBalanceTransferState state) async {
    final res = await _repo.transfer(state);
    return res.fold(leftResult, (r) {
      ref.invalidate(paymentAccountsCtrlProvider);
      return rightResult('Balance successfully transferred');
    });
  }

  Future<Result> delete(PaymentAccount acc) async {
    final res = await _repo.deleteAccount(acc.id);
    return res.fold(leftResult, (r) {
      ref.invalidate(paymentAccountsCtrlProvider);
      return rightResult('Account deleted successfully');
    });
  }

  Future<Result> toggleEnable(bool isActive, PaymentAccount acc) async {
    final res = await _repo.updateAccount(acc.copyWith(isActive: isActive));
    return await res.fold(leftResult, (r) async {
      state = await AsyncValue.guard(() async => build(onlyActive));
      return rightResult('Unit updated successfully');
    });
  }
}
