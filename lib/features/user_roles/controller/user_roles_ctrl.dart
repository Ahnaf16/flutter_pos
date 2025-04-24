import 'package:fpdart/fpdart.dart';
import 'package:pos/features/user_roles/repository/user_roles_repo.dart';
import 'package:pos/main.export.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'user_roles_ctrl.g.dart';

@riverpod
class UserRolesCtrl extends _$UserRolesCtrl {
  final _repo = locate<UserRolesRepo>();
  @override
  FutureOr<List<UserRole>> build() async {
    final staffs = await _repo.getRoles();
    return staffs.fold((l) {
      Toast.showErr(l);
      return [];
    }, identity);
  }
}
