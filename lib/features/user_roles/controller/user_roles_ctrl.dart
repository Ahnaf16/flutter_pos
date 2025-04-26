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
      Toast.showErr(Ctx.context, l);
      return [];
    }, identity);
  }

  Future<Result> createRole(QMap formData) async {
    final res = await _repo.createRole(UserRole.fromMap(formData));
    return res.fold(leftResult, (r) {
      ref.invalidateSelf();
      return rightResult('Role created successfully');
    });
  }

  Future<Result> toggleEnable(bool isEnabled, UserRole role) async {
    final res = await _repo.updateRole(role.copyWith(isEnabled: isEnabled));
    return await res.fold(leftResult, (r) async {
      state = await AsyncValue.guard(() async => build());
      return rightResult('Role updated successfully');
    });
  }
}
