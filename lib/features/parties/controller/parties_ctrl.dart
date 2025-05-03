import 'package:fpdart/fpdart.dart';
import 'package:pos/features/parties/repository/parties_repo.dart';
import 'package:pos/main.export.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'parties_ctrl.g.dart';

@riverpod
class PartiesCtrl extends _$PartiesCtrl {
  final _repo = locate<PartiesRepo>();
  @override
  Future<List<Parti>> build(bool? isCustomer) async {
    final types = switch (isCustomer) {
      true => PartiType.customers,
      false => PartiType.suppliers,
      _ => null,
    };
    final staffs = await _repo.getParties(types);
    return staffs.fold((l) {
      Toast.showErr(Ctx.context, l);
      return [];
    }, identity);
  }

  Future<Result> createParti(QMap formData, [PFile? file]) async {
    final res = await _repo.createParti(formData, file);
    return res.fold(leftResult, (r) {
      ref.invalidate(partiesCtrlProvider);
      return rightResult('Parti created successfully');
    });
  }

  Future<Result> updateParti(Parti parti, [PFile? file]) async {
    final res = await _repo.updateParti(parti, file);
    return res.fold(leftResult, (r) {
      ref.invalidate(partiesCtrlProvider);
      return rightResult('Parti updated successfully');
    });
  }
}
