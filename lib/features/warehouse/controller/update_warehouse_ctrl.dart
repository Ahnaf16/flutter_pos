import 'package:pos/features/warehouse/controller/warehouse_ctrl.dart';
import 'package:pos/features/warehouse/repository/warehouse_repo.dart';
import 'package:pos/main.export.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'update_warehouse_ctrl.g.dart';

@riverpod
class UpdateWarehouseCtrl extends _$UpdateWarehouseCtrl {
  final _repo = locate<WarehouseRepo>();
  @override
  FutureOr<WareHouse?> build(String? id) async {
    if (id != null) {
      final data = await _repo.getWareHouseById(id);
      return data.fold((l) {
        Toast.showErr(Ctx.context, l);
        return null;
      }, (r) => r);
    }
    return null;
  }

  Future<Result> updateWarehouse(QMap formData) async {
    final current = await future;

    final house = current?.marge(formData);

    if (house == null) return (false, 'Warehouse not found');

    final res = await _repo.updateWareHouse(house);
    return res.fold(leftResult, (r) {
      ref.invalidate(warehouseCtrlProvider);
      return rightResult('Warehouse updated successfully');
    });
  }
}
