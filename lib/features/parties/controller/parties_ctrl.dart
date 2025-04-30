import 'package:fpdart/fpdart.dart';
import 'package:pos/features/parties/repository/parties_repo.dart';
import 'package:pos/main.export.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'parties_ctrl.g.dart';

@riverpod
class PartiesCtrl extends _$PartiesCtrl {
  final _repo = locate<PartiesRepo>();
  @override
  Future<List<Parti>> build(bool isCustomer) async {
    final staffs = await _repo.getParties(isCustomer ? PartiType.customers : PartiType.suppliers);
    return staffs.fold((l) {
      Toast.showErr(Ctx.context, l);
      return [];
    }, identity);
  }

  Future<Result> createParti(QMap formData, [PFile? file]) async {
    final res = await _repo.createParti(formData, file);
    return res.fold(leftResult, (r) {
      ref.invalidateSelf();
      return rightResult('Parti created successfully');
    });
  }

  Future<Result> updateParti(Parti parti, [PFile? file]) async {
    final res = await _repo.updateParti(parti, file);
    return res.fold(leftResult, (r) {
      return rightResult('Parti updated successfully');
    });
  }
}
