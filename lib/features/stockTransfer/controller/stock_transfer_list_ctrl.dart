import 'package:pos/features/filter/controller/filter_ctrl.dart';
import 'package:pos/features/stock/repository/stock_repo.dart';
import 'package:pos/main.export.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'stock_transfer_list_ctrl.g.dart';

@riverpod
class StockTransferListCtrl extends _$StockTransferListCtrl {
  final _repo = locate<StockRepo>();

  final List<StockTransferLog> _searchFrom = [];

  void search(String query) async {
    if (query.isEmpty) {
      state = AsyncValue.data(_searchFrom);
    }
    final list = _searchFrom.where((e) {
      return (e.from?.name.low.contains(query) ?? false) ||
          (e.to?.name.low.contains(query) ?? false) ||
          (e.product?.name.low.contains(query) ?? false);
    }).toList();
    state = AsyncData(list);
  }

  void refresh() async {
    state = AsyncValue.data(_searchFrom);
    ref.invalidateSelf();
  }

  @override
  FutureOr<List<StockTransferLog>> build() async {
    final fState = ref.watch(filterCtrlProvider);
    final data = await _repo.getStockLogs(fState);
    return data.fold(
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
}
