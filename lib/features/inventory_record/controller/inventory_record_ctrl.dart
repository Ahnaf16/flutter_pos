import 'package:appwrite/appwrite.dart';
import 'package:fpdart/fpdart.dart';
import 'package:pos/features/filter/controller/filter_ctrl.dart';
import 'package:pos/features/inventory_record/repository/inventory_repo.dart';
import 'package:pos/features/inventory_record/repository/return_repo.dart';
import 'package:pos/main.export.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'inventory_record_ctrl.g.dart';

@riverpod
class InventoryCtrl extends _$InventoryCtrl {
  final _repo = locate<InventoryRepo>();

  final List<InventoryRecord> _searchFrom = [];

  @override
  Future<List<InventoryRecord>> build(RecordType? type) async {
    final fState = ref.watch(filterCtrlProvider);
    final staffs = await _repo.getRecords(type, fState);
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
    final list = _searchFrom.where((e) {
      return e.details.any((d) => d.product.name.low.contains(query)) ||
          (e.party?.name.low.contains(query) ?? false) ||
          e.invoiceNo.low.contains(query);
    }).toList();
    state = AsyncData(list);
  }

  void refresh() async {
    state = AsyncValue.data(_searchFrom);
    ref.invalidateSelf();
  }
}

@riverpod
class InventoryReturnCtrl extends _$InventoryReturnCtrl {
  final _repo = locate<ReturnRepo>();

  final List<ReturnRecord> _searchFrom = [];

  @override
  Future<List<ReturnRecord>> build(bool? isSale) async {
    final fState = ref.watch(filterCtrlProvider);
    final staffs = await _repo.getRecords(isSale, fState);
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
    final list = _searchFrom.where((e) => (e.returnedRec?.party?.name.low.contains(query) ?? false)).toList();
    state = AsyncData(list);
  }

  void refresh() async {
    state = AsyncValue.data(_searchFrom);
    ref.invalidateSelf();
  }
}

@riverpod
Future<List<InventoryRecord>> recordsByParti(Ref ref, String? parti) async {
  if (parti == null) return [];
  final repo = locate<InventoryRepo>();
  final result = await repo.getRecordFiltered([Query.equal('parties', parti)]);
  return result.fold((l) => [], (r) => r);
}

@riverpod
Future<InventoryRecord?> recordDetails(Ref ref, String? id) async {
  if (id == null) return null;

  final repo = locate<InventoryRepo>();
  final result = await repo.getRecordById(id);
  return result.fold(identityNull, identity);
}
