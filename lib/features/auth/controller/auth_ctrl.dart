import 'package:fpdart/fpdart.dart';
import 'package:pos/features/auth/repository/auth_repo.dart';
import 'package:pos/features/home/controller/home_ctrl.dart';
import 'package:pos/main.export.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'auth_ctrl.g.dart';

@Riverpod(keepAlive: true)
class AuthCtrl extends _$AuthCtrl {
  final _repo = locate<AuthRepo>();

  @override
  FutureOr<AppUser?> build() async {
    final user = await _repo.currentUser();
    return user.fold((l) => null, (r) {
      ref.read(authStateSyncProvider.notifier)._set(r);
      if (!r.isActive) return null;
      return r;
    });
  }

  FVoid reload() async {
    final user = await _repo.currentUser();

    return user.fold((l) => null, (r) {
      ref.read(authStateSyncProvider.notifier)._set(r);
      state = AsyncValue.data(r);
    });
  }

  Future<Result> signIn(String email, String password) async {
    final res = await _repo.signIn(email, password);

    return res.fold(leftResult, (r) async {
      final user = await ref.refresh(authCtrlProvider.future);
      ref.invalidate(currentUserProvider);
      return user == null ? leftResult(const Failure('Failed to login')) : rightResult('Login successful');
    });
  }

  Future<void> signOut() async {
    await _repo.signOut();
    ref.invalidateSelf();
  }
}

@Riverpod(keepAlive: true)
class AuthStateSync extends _$AuthStateSync {
  void _set(AppUser user) {
    if (user.isActive) {
      state = some(user);
    } else {
      state = none();
    }
  }

  @override
  Option<AppUser> build() {
    return none();
  }
}

@Riverpod(keepAlive: true)
FutureOr<AppUser?> currentUser(Ref ref) async {
  final repo = locate<AuthRepo>();
  final user = await repo.currentUser();
  return user.fold(identityNull, (r) {
    if (!r.isActive) return null;
    ref.read(viewingWHProvider.notifier).updateHouse(r.warehouse, r.warehouse);
    return r;
  });
}
