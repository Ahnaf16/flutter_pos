import 'package:pos/main.export.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'update_role_ctrl.g.dart';

@riverpod
class UpdateRoleCtrl extends _$UpdateRoleCtrl {
  @override
  FutureOr<UserRole?> build(String? id) async {
    if (id != null) {}
    return null;
  }
}
