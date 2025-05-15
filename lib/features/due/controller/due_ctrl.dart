import 'package:pos/features/due/repository/due_repo.dart';
import 'package:pos/main.export.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'due_ctrl.g.dart';

@riverpod
class DueLogCtrl extends _$DueLogCtrl {
  final _repo = locate<DueRepo>();

  final List<DueLog> _searchFrom = [];

  @override
  FutureOr<List<DueLog>> build() async {
    final staffs = await _repo.getDueLogs();
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
          return e.parti.name.low.contains(query) ||
              e.parti.phone.low.contains(query) ||
              (e.parti.email?.low.contains(query) ?? false);
        }).toList();
    state = AsyncData(list);
  }

  void filter({ShadDateTimeRange? range}) async {
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

    if (range == null) {
      state = AsyncValue.data(_searchFrom);
    }
  }
}
