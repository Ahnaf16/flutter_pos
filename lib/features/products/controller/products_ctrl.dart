import 'package:fpdart/fpdart.dart';
import 'package:pos/features/products/repository/products_repo.dart';
import 'package:pos/main.export.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'products_ctrl.g.dart';

@riverpod
class ProductsCtrl extends _$ProductsCtrl {
  final _repo = locate<ProductRepo>();
  @override
  Future<List<Product>> build() async {
    final staffs = await _repo.getProducts();
    return staffs.fold((l) {
      Toast.showErr(Ctx.context, l);
      return [];
    }, identity);
  }

  Future<Result> createStaff(QMap formData, [PFile? file]) async {
    final res = await _repo.createProduct(formData, file);
    return res.fold(leftResult, (r) {
      ref.invalidateSelf();
      return rightResult('Product created successfully');
    });
  }
}
