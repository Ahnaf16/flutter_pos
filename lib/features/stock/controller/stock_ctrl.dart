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

  Future<Result> createStock(QMap formData) async {
    final res = await _repo.createStock(formData);
    return res.fold(leftResult, (r) {
      ref.invalidateSelf();
      return rightResult('Stock created successfully');
    });
  }
}

final mockStock = [
  for (var j = 0; j < 20; j++)
    Product(
      id: '${randomInt(100, 100000).run()}',
      name: 'product ${j + 1}',
      description: null,
      sku: null,
      photo: null,
      unit: ProductUnit(id: '${randomInt(100, 100000).run()}', name: 'Pcs', unitName: 'pcs', isActive: true),
      stock: [
        for (var i = 0; i < 10; i++)
          Stock(
            id: '${randomInt(100, 100000).run()}',
            purchasePrice: randomInt(100, 100000).run(),
            salesPrice: randomInt(100, 100000).run(),
            wholesalePrice: randomInt(100, 100000).run(),
            dealerPrice: randomInt(100, 100000).run(),
            quantity: randomInt(10, 300).run(),
            warehouse: WareHouse(
              id: '${randomInt(100, 100000).run()}',
              name: 'warehouse ${i + 1}',
              address: 'address',
              isDefault: i == 0,
              contactNumber: '39423746',
            ),
            createdAt: DateTime.now().subtract(Duration(days: i)),
          ),
      ],
      manageStock: true,
      manufacturer: 'manufacturer',
    ),
];
