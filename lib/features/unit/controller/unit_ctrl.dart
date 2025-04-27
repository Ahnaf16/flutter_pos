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

  Future<Result> createUnit(QMap form) async {
    final res = await _repo.createUnit(form);
    return res.fold(leftResult, (r) {
      ref.invalidateSelf();
      return rightResult('Unit created successfully');
    });
  }

  Future<Result> updateUnit(ProductUnit unit) async {
    final res = await _repo.updateUnit(unit);
    return res.fold(leftResult, (r) {
      ref.invalidateSelf();
      return rightResult('Unit updated successfully');
    });
  }

  Future<Result> toggleEnable(bool isActive, ProductUnit unit) async {
    final res = await _repo.updateUnit(unit.copyWith(isActive: isActive));
    return await res.fold(leftResult, (r) async {
      state = await AsyncValue.guard(() async => build());
      return rightResult('Unit updated successfully');
    });
  }
}
