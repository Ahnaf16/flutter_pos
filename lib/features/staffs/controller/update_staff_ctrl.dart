import 'package:pos/features/staffs/controller/staffs_ctrl.dart';
import 'package:pos/features/staffs/repository/staffs_repo.dart';
import 'package:pos/main.export.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'update_staff_ctrl.g.dart';

@riverpod
class UpdateStaffCtrl extends _$UpdateStaffCtrl {
  final _repo = locate<StaffRepo>();

  @override
  FutureOr<AppUser?> build(String? id) async {
    if (id != null) {
      final data = await _repo.getStaffById(id);
      return data.fold((l) {
        Toast.showErr(Ctx.context, l);
        return null;
      }, (r) => r);
    }
    return null;
  }

  Future<Result> updateStaff(QMap formData, [PFile? file]) async {
    final current = await future;

    final user = current?.marge(formData);

    if (user == null) return (false, 'User not found');

    final res = await _repo.updateStaff(user, file);
    return res.fold(leftResult, (r) {
      ref.invalidate(staffsCtrlProvider);
      return rightResult('Staff updated successfully');
    });
  }

  Future<Result> toggleActive() async {
    final current = await future;

    if (current == null) return (false, 'User not found');

    final res = await _repo.toggleActive(current.id, !current.isActive);
    return res.fold(leftResult, (r) {
      ref.invalidate(staffsCtrlProvider);
      return rightResult('Staff ${current.isActive ? 'deactivated' : 'activated'} successfully');
    });
  }
}
