import 'package:fpdart/fpdart.dart';
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
    return staffs.fold((l) {
      Toast.showErr(l);
      return [];
    }, identity);
  }
}
