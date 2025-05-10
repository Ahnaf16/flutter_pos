import 'package:appwrite/models.dart';
import 'package:pos/features/home/controller/home_ctrl.dart';
import 'package:pos/features/products/repository/products_repo.dart';
import 'package:pos/features/stock/repository/stock_repo.dart';
import 'package:pos/main.export.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'products_ctrl.g.dart';

@riverpod
class ProductsCtrl extends _$ProductsCtrl {
  final _repo = locate<ProductRepo>();

  final List<Product> _searchFrom = [];

  @override
  Future<List<Product>> build() async {
    final viewingWh = ref.watch(viewingWHProvider);

    final staffs = await _repo.getProducts();

    return staffs.fold(
      (l) {
        Toast.showErr(Ctx.context, l);
        return [];
      },
      (r) {
        final p = r.filterHouse(viewingWh);
        _searchFrom.clear();
        _searchFrom.addAll(p);
        return p;
      },
    );
  }

  void search(String query) async {
    if (query.isEmpty) {
      state = AsyncValue.data(_searchFrom);
    }

    state = AsyncData(_searchFrom.where((e) => e.name.low.contains(query)).toList());
  }

  Future<Result> createProduct(QMap formData, [PFile? file]) async {
    final data = QMap.from(formData);
    final stockData = data.remove('stock');

    if (stockData != null) {
      final (err, stockDoc) = await _createFirstStock(stockData).toRecord();

      if (err != null || stockDoc == null) return (false, err?.message ?? 'Error creating stock');

      data['stock'] = [Stock.fromDoc(stockDoc).toMap()];
    }

    final res = await _repo.createProduct(data, file);

    return res.fold(leftResult, (r) {
      ref.invalidateSelf();
      return rightResult('Product created successfully');
    });
  }

  FutureReport<Document> _createFirstStock(QMap stockData) async {
    final repo = locate<StockRepo>();
    return await repo.createStock(stockData);
  }
}
