import 'package:fpdart/fpdart.dart';
import 'package:pos/features/stock/repository/stock_repo.dart';
import 'package:pos/main.export.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'stock_ctrl.g.dart';

@riverpod
class StockCtrl extends _$StockCtrl {
  final _repo = locate<StockRepo>();
  @override
  Future<List<Stock>> build() async {
    final staffs = await _repo.getStocks();
    return staffs.fold((l) {
      Toast.showErr(Ctx.context, l);
      return [];
    }, identity);
  }

  Future<Result> createStaff(QMap formData) async {
    final res = await _repo.createStock(formData);
    return res.fold(leftResult, (r) {
      ref.invalidateSelf();
      return rightResult('Stock created successfully');
    });
  }
}
