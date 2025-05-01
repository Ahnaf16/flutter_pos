import 'package:fpdart/fpdart.dart';
import 'package:pos/features/auth/repository/auth_repo.dart';
import 'package:pos/main.export.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'auth_ctrl.g.dart';

@riverpod
class AuthCtrl extends _$AuthCtrl {
  final _repo = locate<AuthRepo>();

  @override
  FutureOr<AppUser?> build() async {
    final user = await _repo.currentUser();
    return user.fold((l) => null, (r) {
      ref.read(authStateSyncProvider.notifier)._set(r);
      return r;
    });
  }

  Future<Result> signIn(String email, String password) async {
    final res = await _repo.signIn(email, password);

    return res.fold(leftResult, (r) {
      ref.invalidateSelf();
      return rightResult('Login successful');
    });
  }

  Future<void> signOut() async {
    await _repo.signOut();
    ref.invalidateSelf();
  }
}

@riverpod
class AuthStateSync extends _$AuthStateSync {
  void _set(AppUser user) => state = some(user);

  @override
  Option<AppUser> build() {
    return none();
  }
}

@riverpod
FutureOr<AppUser?> currentUser(Ref ref) async {
  final repo = locate<AuthRepo>();
  final user = await repo.currentUser();
  return user.fold((l) => null, (r) {
    ref.read(authStateSyncProvider.notifier)._set(r);
    return r;
  });
}
