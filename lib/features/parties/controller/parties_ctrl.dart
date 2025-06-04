import 'package:fpdart/fpdart.dart';
import 'package:pos/features/parties/repository/parties_repo.dart';
import 'package:pos/main.export.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'parties_ctrl.g.dart';

@riverpod
class PartiesCtrl extends _$PartiesCtrl {
  final _repo = locate<PartiesRepo>();

  final List<Party> _searchFrom = [];

  @override
  Future<List<Party>> build(bool? isCustomer) async {
    final types = switch (isCustomer) {
      true => PartiType.customers,
      false => PartiType.suppliers,
      _ => null,
    };
    final staffs = await _repo.getParties(types);
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

  void refresh() async {
    state = AsyncValue.data(_searchFrom);
    ref.invalidateSelf();
  }

  void search(String query) async {
    if (query.isEmpty) {
      state = AsyncValue.data(_searchFrom);
    }
    final list = _searchFrom.where((e) {
      return e.name.low.contains(query.low) ||
          (e.phone.low.contains(query.low)) ||
          (e.email?.low.contains(query.low) ?? false);
    }).toList();
    state = AsyncData(list);
  }

  Future<Result> createParti(QMap formData, [PFile? file]) async {
    final res = await _repo.createParti(formData, file);
    return res.fold(leftResult, (r) {
      ref.invalidate(partiesCtrlProvider);
      return rightResult('Parti created successfully');
    });
  }

  Future<Result> checkAvailability(String phone) async {
    final res = await _repo.checkAvailability(phone);
    return res.fold(leftResult, (_) => rightResult('Phone available'));
  }

  Future<Result> delete(String id) async {
    final res = await _repo.deleteParty(id);
    return res.fold(leftResult, (_) {
      ref.invalidate(partiesCtrlProvider);
      return rightResult('Deleted successfully');
    });
  }

  Future<Result> updateParti(Party parti, [PFile? file]) async {
    final res = await _repo.updateParti(parti, file);
    return res.fold(leftResult, (r) {
      ref.invalidate(partiesCtrlProvider);
      return rightResult('Parti updated successfully');
    });
  }

  Future<Result> updatePartyDue(Party party, num amount, String? note) async {
    final res = await _repo.updateDue(party, amount, !amount.isNegative, note);
    return res.fold(leftResult, (r) {
      ref.invalidate(partiesCtrlProvider);
      return rightResult('Parti updated successfully');
    });
  }
}

@riverpod
FutureOr<Party?> partyDetails(Ref ref, String? id) async {
  if (id == null) return null;

  final repo = locate<PartiesRepo>();

  final party = await repo.getPartiById(id);

  return party.fold((l) {
    Toast.showErr(Ctx.context, l);
    return null;
  }, identity);
}
