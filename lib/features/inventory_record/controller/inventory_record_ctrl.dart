import 'package:pos/features/inventory_record/repository/inventory_repo.dart';
import 'package:pos/features/inventory_record/repository/return_repo.dart';
import 'package:pos/main.export.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'inventory_record_ctrl.g.dart';

@riverpod
class InventoryCtrl extends _$InventoryCtrl {
  final _repo = locate<InventoryRepo>();
  @override
  Future<List<InventoryRecord>> build(RecordType? type) async {
    final staffs = await _repo.getRecords(type);
    return staffs.fold(
      (l) {
        Toast.showErr(Ctx.context, l);
        return [];
      },
      (r) {
        return r;
      },
    );
  }
}

@riverpod
class InventoryReturnCtrl extends _$InventoryReturnCtrl {
  final _repo = locate<ReturnRepo>();
  @override
  Future<List<ReturnRecord>> build(bool? isSale) async {
    final staffs = await _repo.getRecords(isSale);
    return staffs.fold((l) {
      Toast.showErr(Ctx.context, l);
      return [];
    }, (r) => r);
  }
}
