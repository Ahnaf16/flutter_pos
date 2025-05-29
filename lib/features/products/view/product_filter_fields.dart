import 'package:pos/features/filter/view/filter_bar.dart';
import 'package:pos/features/products/controller/products_ctrl.dart';
import 'package:pos/features/unit/controller/unit_ctrl.dart';
import 'package:pos/main.export.dart';

class ProductFilterFields extends HookConsumerWidget {
  const ProductFilterFields({super.key, required this.productCtrl});

  final ProductsCtrl Function() productCtrl;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // final warehouses = ref.watch(warehouseCtrlProvider).maybeList();
    final units = ref.watch(unitCtrlProvider).maybeList();
    return FilterBar(
      // houses: warehouses,
      hintText: 'Search by product name',
      units: units,
      onSearch: (q) => productCtrl().search(q),
      onReset: () => productCtrl().refresh(),
    );
  }
}
