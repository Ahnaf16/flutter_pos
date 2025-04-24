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
      Toast.showErr(l);
      return [];
    }, identity);
  }

  FVoid createStaff(String password, QMap formData) async {
    await _repo.createStaff('121212121', {
      'name': 'abab',
      // 'warehouse': '680a07e8001aeae9972c',
      // 'role': '680a082b001d1b08d793',
      'email': 'emem@example.com',
      // 'phone': '+8812121212121',
    });
    // final res = await _repo.createStaff(password, formData);
    // res.fold(Toast.showErr, (r) {
    //   Toast.show('Staff created successfully');
    //   // ref.invalidateSelf();
    // });
  }
}
