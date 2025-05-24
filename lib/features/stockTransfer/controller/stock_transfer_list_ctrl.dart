import 'package:fpdart/fpdart.dart';
import 'package:pos/features/stock/repository/stock_repo.dart';
import 'package:pos/main.export.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'stock_transfer_list_ctrl.g.dart';

@riverpod
class StockTransferListCtrl extends _$StockTransferListCtrl {
  final _repo = locate<StockRepo>();

  @override
  FutureOr<List<StockTransferLog>> build() async {
    final data = await _repo.getStockLogs();
    return data.fold((l) {
      Toast.showErr(Ctx.context, l);
      return [];
    }, identity);
  }
}
