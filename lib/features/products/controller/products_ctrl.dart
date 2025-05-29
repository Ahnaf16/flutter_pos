import 'package:fpdart/fpdart.dart';
import 'package:pos/features/filter/controller/filter_ctrl.dart';
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
    final units = ref.watch(filterCtrlProvider.select((s) => s.units));
    final viewingWh = ref.watch(viewingWHProvider);

    final staffs = await _repo.getProducts(fl: FilterState(units: units));

    return staffs.fold(
      (l) {
        Toast.showErr(Ctx.context, l);
        return [];
      },
      (r) {
        final p = r.filterHouse(viewingWh.viewing);
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

    state = AsyncData(
      _searchFrom.where(
        (e) {
          return e.name.low.contains(query) ||
              (e.manufacturer?.low.contains(query) ?? false) ||
              (e.sku?.low.contains(query) ?? false);
        },
      ).toList(),
    );
  }

  void refresh() async {
    state = AsyncValue.data(_searchFrom);
    ref.invalidateSelf();
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

@riverpod
FutureOr<Product?> productDetails(Ref ref, String? id) async {
  if (id == null) return null;

  final repo = locate<ProductRepo>();

  final product = await repo.getProductById(id);

  return product.fold((l) {
    Toast.showErr(Ctx.context, l);
    return null;
  }, identity);
}
