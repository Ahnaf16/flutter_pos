import 'package:fpdart/fpdart.dart';
import 'package:pos/features/due/repository/due_repo.dart';
import 'package:pos/main.export.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'due_ctrl.g.dart';

@riverpod
class DueLogCtrl extends _$DueLogCtrl {
  final _repo = locate<DueRepo>();

  @override
  FutureOr<List<DueLog>> build() async {
    final staffs = await _repo.getDueLogs();
    return staffs.fold((l) {
      Toast.showErr(Ctx.context, l);
      return [];
    }, identity);
  }
}
