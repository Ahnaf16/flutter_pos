import 'package:fpdart/fpdart.dart';
import 'package:pos/features/staffs/repository/staffs_repo.dart';
import 'package:pos/main.export.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'staffs_ctrl.g.dart';

@riverpod
class StaffsCtrl extends _$StaffsCtrl {
  final _repo = locate<StaffRepo>();
  @override
  Future<List<AppUser>> build() async {
    final staffs = await _repo.getStaffs();
    return staffs.fold((l) {
      Toast.showErr(Ctx.context, l);
      return [];
    }, identity);
  }

  Future<Result> createStaff(String password, QMap formData) async {
    final res = await _repo.createStaff(password, formData);
    return res.fold(leftResult, (r) {
      // ref.invalidateSelf();
      return rightResult('Staff created successfully');
    });
  }
}
