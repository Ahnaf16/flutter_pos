import 'package:pos/main.export.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'update_warehouse_ctrl.g.dart';

@riverpod
class UpdateWarehouseCtrl extends _$UpdateWarehouseCtrl {
  @override
  FutureOr<WareHouse?> build(String? id) async {
    if (id != null) {}
    return null;
  }
}
