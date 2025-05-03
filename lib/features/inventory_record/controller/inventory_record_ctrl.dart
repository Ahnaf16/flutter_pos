import 'package:fpdart/fpdart.dart';
import 'package:pos/features/inventory_record/repository/inventory_repo.dart';
import 'package:pos/main.export.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'inventory_record_ctrl.g.dart';

@riverpod
class InventoryCtrl extends _$InventoryCtrl {
  final _repo = locate<InventoryRepo>();
  @override
  Future<List<InventoryRecord>> build(RecordType type) async {
    final staffs = await _repo.getRecords(type);
    return staffs.fold((l) {
      Toast.showErr(Ctx.context, l);
      return [];
    }, identity);
  }

  // Future<Result> createUnit(QMap form) async {
  //   final res = await _repo.createInventory(form);
  //   return res.fold(leftResult, (r) {
  //     ref.invalidateSelf();
  //     return rightResult('Record created successfully');
  //   });
  // }

  // Future<Result> updateUnit(InventoryRecord record) async {
  //   final res = await _repo.updateRecord(record);
  //   return res.fold(leftResult, (r) {
  //     ref.invalidateSelf();
  //     return rightResult('Record updated successfully');
  //   });
  // }
}
