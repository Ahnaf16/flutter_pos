import 'package:pos/features/auth/controller/auth_ctrl.dart';
import 'package:pos/features/warehouse/repository/warehouse_repo.dart';
import 'package:pos/main.export.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'warehouse_ctrl.g.dart';

@riverpod
class WarehouseCtrl extends _$WarehouseCtrl {
  final _repo = locate<WarehouseRepo>();
  @override
  Future<List<WareHouse>> build() async {
    final staffs = await _repo.getWareHouses();
    return staffs.fold(
      (l) {
        Toast.showErr(Ctx.context, l);
        return [];
      },
      (r) {
        r.sort((a, b) => a.isDefault ? -1 : 1);
        return r;
      },
    );
  }

  Future<Result> createWarehouse(QMap formData) async {
    final res = await _repo.createWareHouse(WareHouse.fromMap(formData));
    return res.fold(leftResult, (r) {
      ref.invalidateSelf();
      return rightResult('Warehouse created successfully');
    });
  }

  Future<Result> changeDefault(WareHouse newDefault) async {
    final res = await _repo.changeDefault(newDefault);
    return res.fold(leftResult, (r) {
      ref.invalidateSelf();
      ref.invalidate(currentUserProvider);
      return rightResult('Default warehouse changed');
    });
  }
}
