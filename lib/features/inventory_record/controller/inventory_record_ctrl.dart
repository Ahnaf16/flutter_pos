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
    final staffs = await _repo.getRecords(type);
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
    final list =
        _searchFrom.where((e) {
          return e.details.any((d) => d.product.name.low.contains(query.low)) ||
              (e.parti?.name.low.contains(query.low) ?? false);
        }).toList();
    state = AsyncData(list);
  }

  void filter({PaymentAccount? account, InventoryStatus? status, ShadDateTimeRange? range}) async {
    if (account != null) {
      state = AsyncData(_searchFrom.where((e) => e.account?.id == account.id).toList());
    }

    if (status != null) {
      state = AsyncData(_searchFrom.where((e) => e.status == status).toList());
    }

    if (range case ShadDateTimeRange(:final start, :final end)) {
      final filteredList =
          _searchFrom.where((entry) {
            final date = entry.date.justDate;
            if (start != null && end != null) {
              return date.isAfter(start.justDate) && date.isBefore(end.nextDay.justDate);
            } else if (start != null) {
              return date.isAfter(start.justDate);
            } else if (end != null) {
              return date.isBefore(end.nextDay.justDate);
            }
            return true;
          }).toList();

      state = AsyncData(filteredList);
    }

    if (account == null && status == null && range == null) {
      state = AsyncValue.data(_searchFrom);
    }
  }
}

@riverpod
class InventoryReturnCtrl extends _$InventoryReturnCtrl {
  final _repo = locate<ReturnRepo>();

  final List<ReturnRecord> _searchFrom = [];

  @override
  Future<List<ReturnRecord>> build(bool? isSale) async {
    final staffs = await _repo.getRecords(isSale);
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
    final list = _searchFrom.where((e) => (e.returnedRec.parti?.name.low.contains(query.low) ?? false)).toList();
    state = AsyncData(list);
  }

  void filter({PaymentAccount? account, ShadDateTimeRange? range}) async {
    if (account != null) {
      state = AsyncData(_searchFrom.where((e) => e.returnedRec.account?.id == account.id).toList());
    }

    if (range case ShadDateTimeRange(:final start, :final end)) {
      final filteredList =
          _searchFrom.where((entry) {
            final date = entry.returnDate.justDate;
            if (start != null && end != null) {
              return date.isAfter(start.justDate) && date.isBefore(end.nextDay.justDate);
            } else if (start != null) {
              return date.isAfter(start.justDate);
            } else if (end != null) {
              return date.isBefore(end.nextDay.justDate);
            }
            return true;
          }).toList();

      state = AsyncData(filteredList);
    }

    if (account == null && range == null) {
      state = AsyncValue.data(_searchFrom);
    }
  }
}
