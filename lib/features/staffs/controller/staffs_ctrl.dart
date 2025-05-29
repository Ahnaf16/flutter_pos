import 'package:pos/features/filter/controller/filter_ctrl.dart';
import 'package:pos/features/staffs/repository/staffs_repo.dart';
import 'package:pos/main.export.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'staffs_ctrl.g.dart';

@riverpod
class StaffsCtrl extends _$StaffsCtrl {
  final _repo = locate<StaffRepo>();

  final List<AppUser> _searchFrom = [];

  @override
  Future<List<AppUser>> build() async {
    final fState = ref.watch(filterCtrlProvider);

    final staffs = await _repo.getStaffs(fState);
    return staffs.fold(
      (l) {
        Toast.showErr(Ctx.context, l);
        return [];
      },
      (r) {
        _searchFrom.clear();
        _searchFrom.addAll(r);
        return r;
      },
    );
  }

  void search(String query) async {
    if (query.isEmpty) {
      state = AsyncValue.data(_searchFrom);
    }
    query = query.low;
    final list = _searchFrom
        .where((e) => e.name.low.contains(query) || e.phone.low.contains(query) || e.email.low.contains(query))
        .toList();
    state = AsyncData(list);
  }

  void refresh() async {
    state = AsyncValue.data(_searchFrom);
    ref.invalidateSelf();
  }

  Future<Result> createStaff(String password, QMap formData, [PFile? file]) async {
    final res = await _repo.createStaff(password, formData, file);
    return res.fold(leftResult, (r) {
      ref.invalidateSelf();
      return rightResult('Staff created successfully');
    });
  }

  Future<Result> checkAvailability(String email) async {
    final res = await _repo.checkEmailAvailability(email);
    return res.fold(leftResult, (_) => rightResult('Email available'));
  }
}
