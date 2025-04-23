import 'package:appwrite/models.dart';
import 'package:pos/features/auth/repository/auth_repo.dart';
import 'package:pos/main.export.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'auth_ctrl.g.dart';

@riverpod
class AuthCtrl extends _$AuthCtrl {
  final _repo = locate<AuthRepo>();

  @override
  FutureOr<User?> build() {
    // await Future.delayed(const Duration(seconds: 5));
    final user = _repo.currentUser();
    return null;
    // return user.fold((l) => null, (r) => r);
  }
}
