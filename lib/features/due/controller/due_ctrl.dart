import 'package:pos/features/due/repository/due_repo.dart';
import 'package:pos/features/filter/controller/filter_ctrl.dart';
import 'package:pos/main.export.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'due_ctrl.g.dart';

@riverpod
class DueLogCtrl extends _$DueLogCtrl {
  final _repo = locate<DueRepo>();

  final List<DueLog> _searchFrom = [];

  @override
  FutureOr<List<DueLog>> build() async {
    final fState = ref.watch(filterCtrlProvider);

    final staffs = await _repo.getDueLogs(fState);
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
      return e.parti.name.low.contains(query) ||
          e.parti.phone.low.contains(query) ||
          (e.parti.email?.low.contains(query) ?? false);
    }).toList();
    state = AsyncData(list);
  }

  FVoid refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async => build());
  }
}
