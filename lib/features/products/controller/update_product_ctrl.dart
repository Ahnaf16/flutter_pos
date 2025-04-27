import 'package:pos/features/products/controller/products_ctrl.dart';
import 'package:pos/features/products/repository/products_repo.dart';
import 'package:pos/main.export.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'update_product_ctrl.g.dart';

@riverpod
class UpdateProductCtrl extends _$UpdateProductCtrl {
  final _repo = locate<ProductRepo>();

  @override
  FutureOr<Product?> build(String? id) async {
    if (id != null) {
      final data = await _repo.getProductById(id);
      return data.fold((l) {
        Toast.showErr(Ctx.context, l);
        return null;
      }, (r) => r);
    }
    return null;
  }

  Future<Result> updateProduct(QMap formData, [PFile? file]) async {
    final current = await future;

    final product = current?.marge(formData);

    if (product == null) return (false, 'Product not found');

    final res = await _repo.updateProduct(product, file);
    return res.fold(leftResult, (r) {
      ref.invalidate(productsCtrlProvider);
      return rightResult('Product updated successfully');
    });
  }
}
