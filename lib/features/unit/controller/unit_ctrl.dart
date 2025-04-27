import 'package:fpdart/fpdart.dart';
import 'package:pos/features/unit/repository/unit_repo.dart';
import 'package:pos/main.export.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'unit_ctrl.g.dart';

@riverpod
class UnitCtrl extends _$UnitCtrl {
  final _repo = locate<ProductUnitRepo>();
  @override
  Future<List<ProductUnit>> build() async {
    final staffs = await _repo.getUnits();
    return staffs.fold((l) {
      Toast.showErr(Ctx.context, l);
      return [];
    }, identity);
  }

  Future<Result> createStaff(QMap formData) async {
    final res = await _repo.createUnit(formData);
    return res.fold(leftResult, (r) {
      ref.invalidateSelf();
      return rightResult('Unit created successfully');
    });
  }
}
