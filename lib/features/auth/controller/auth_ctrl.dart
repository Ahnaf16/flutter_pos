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
    return user.fold((l) => null, (r) => r);
  }

  Future<void> signIn(String email, String password) async {
    final res = await _repo.signIn(email, password);
    res.fold(Toast.showErr, (r) {
      ref.invalidateSelf();
      Toast.show('Login successful');
    });
  }

  Future<void> signOut() async {
    await _repo.signOut();
    ref.invalidateSelf();
  }

  Future<void> register(String email, String password, AppUser user) async {
    await _repo.register(email, password, user);
  }
}
