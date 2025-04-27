import 'package:pos/features/auth/controller/auth_ctrl.dart';
import 'package:pos/features/user_roles/controller/user_roles_ctrl.dart';
import 'package:pos/features/user_roles/repository/user_roles_repo.dart';
import 'package:pos/main.export.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'update_role_ctrl.g.dart';

@riverpod
class UpdateRoleCtrl extends _$UpdateRoleCtrl {
  final _repo = locate<UserRolesRepo>();

  @override
  FutureOr<UserRole?> build(String? id) async {
    if (id != null) {
      final data = await _repo.getRoleById(id);
      return data.fold((l) {
        Toast.showErr(Ctx.context, l);
        return null;
      }, (r) => r);
    }
    return null;
  }

  Future<Result> updateRole(QMap formData) async {
    final current = await future;

    final role = current?.marge(formData);

    if (role == null) return (false, 'Role not found');

    final res = await _repo.updateRole(role);
    return res.fold(leftResult, (r) {
      ref.invalidate(userRolesCtrlProvider);
      ref.invalidate(authCtrlProvider);
      return rightResult('Role updated successfully');
    });
  }
}
