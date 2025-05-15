import 'package:pos/features/home/controller/home_ctrl.dart';
import 'package:pos/features/products/repository/products_repo.dart';
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

  void filter({WareHouse? wh, ProductUnit? unit}) async {
    if (wh != null) {
      state = AsyncData(_searchFrom.filterHouse(wh, false));
    }
    if (unit != null) {
      state = AsyncData(_searchFrom.where((e) => e.unit?.id == unit.id).toList());
    }

    if (wh == null && unit == null) {
      state = AsyncData(_searchFrom);
    }
  }

  Future<(Result, String?)> createProduct(Product product, [PFile? file]) async {
    final res = await _repo.createProduct(product, file);

    return res.fold((l) => (leftResult(l), ''), (r) {
      ref.invalidateSelf();
      return (rightResult('Product created successfully'), r.$id);
    });
  }

  Future<Result> deleteProduct(Product product) async {
    final res = await _repo.deleteProduct(product);

    return res.fold(leftResult, (r) {
      ref.invalidateSelf();
      return rightResult('Product deleted successfully');
    });
  }
}
