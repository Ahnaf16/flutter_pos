import 'package:fpdart/fpdart.dart';
import 'package:pos/features/payment_accounts/repository/payment_accounts_repo.dart';
import 'package:pos/main.export.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'payment_accounts_ctrl.g.dart';

@riverpod
class PaymentAccountsCtrl extends _$PaymentAccountsCtrl {
  final _repo = locate<PaymentAccountsRepo>();
  @override
  Future<List<PaymentAccount>> build() async {
    final staffs = await _repo.getAccount();
    return staffs.fold((l) {
      Toast.showErr(Ctx.context, l);
      return [];
    }, identity);
  }

  Future<Result> createUnit(QMap form) async {
    final res = await _repo.createAccount(form);
    return res.fold(leftResult, (r) {
      ref.invalidateSelf();
      return rightResult('Payment account created successfully');
    });
  }

  Future<Result> updateUnit(PaymentAccount acc) async {
    final res = await _repo.updateAccount(acc);
    return res.fold(leftResult, (r) {
      ref.invalidateSelf();
      return rightResult('Payment account updated successfully');
    });
  }

  Future<Result> toggleEnable(bool isActive, PaymentAccount acc) async {
    final res = await _repo.updateAccount(acc.copyWith(isActive: isActive));
    return await res.fold(leftResult, (r) async {
      state = await AsyncValue.guard(() async => build());
      return rightResult('Unit updated successfully');
    });
  }
}
