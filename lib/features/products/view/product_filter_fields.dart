import 'package:pos/features/products/controller/products_ctrl.dart';
import 'package:pos/features/unit/controller/unit_ctrl.dart';
import 'package:pos/features/warehouse/controller/warehouse_ctrl.dart';
import 'package:pos/main.export.dart';

class ProductFilterFields extends HookConsumerWidget {
  const ProductFilterFields({super.key, required this.productCtrl});

  final ProductsCtrl Function() productCtrl;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final warehouseList = ref.watch(warehouseCtrlProvider);
    final unitList = ref.watch(unitCtrlProvider);
    final search = useTextEditingController();
    return LimitedWidthBox(
      maxWidth: 800,
      center: false,
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: ShadTextField(
              controller: search,
              hintText: 'Search',
              onChanged: (v) => productCtrl().search(v ?? ''),
              showClearButton: true,
            ),
          ),

          Expanded(
            flex: 2,
            child: warehouseList.maybeWhen(
              orElse: () => ShadCard(padding: kDefInputPadding, child: const Loading()),
              data: (warehouses) {
                return ShadSelectField<WareHouse>(
                  hintText: 'Filter by warehouse',
                  options: warehouses,
                  selectedBuilder: (context, value) => Text(value.name),
                  optionBuilder: (_, value, _) {
                    return ShadOption(value: value, child: Text(value.name));
                  },
                  onChanged: (v) => productCtrl().filter(wh: v),
                );
              },
            ),
          ),
          Expanded(
            child: unitList.maybeWhen(
              orElse: () => ShadCard(padding: kDefInputPadding, child: const Loading()),
              data: (units) {
                return ShadSelectField<ProductUnit>(
                  hintText: 'Filter by unit',
                  options: units,
                  selectedBuilder: (context, value) => Text(value.name),
                  optionBuilder: (_, value, _) {
                    return ShadOption(value: value, child: Text(value.name));
                  },
                  onChanged: (v) => productCtrl().filter(unit: v),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
