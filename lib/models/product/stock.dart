import 'package:appwrite/models.dart';
import 'package:pos/main.export.dart';

class Stock {
  const Stock({
    required this.id,
    required this.purchasePrice,
    required this.salesPrice,
    required this.wholesalePrice,
    required this.dealerPrice,
    required this.quantity,
    required this.warehouse,
    required this.createdAt,
  });

  final String id;
  final num purchasePrice;
  final num salesPrice;
  final num wholesalePrice;
  final num dealerPrice;
  final int quantity;
  final WareHouse? warehouse;
  final DateTime createdAt;

  factory Stock.fromDoc(Document doc) {
    final data = doc.data;
    return Stock(
      id: doc.$id,
      purchasePrice: data.parseNum('purchase_price'),
      salesPrice: data.parseNum('sales_price'),
      wholesalePrice: data.parseNum('wholesale_price'),
      dealerPrice: data.parseNum('dealer_price'),
      quantity: data.parseInt('quantity'),
      warehouse: WareHouse.tyrParse(data['warehouse']),
      createdAt: DateTime.parse(doc.$createdAt),
    );
  }

  static Stock empty() => Stock(
    id: '',
    purchasePrice: 0,
    salesPrice: 0,
    wholesalePrice: 0,
    dealerPrice: 0,
    quantity: 0,
    warehouse: null,
    createdAt: DateTime.now(),
  );

  num get getProfitLoss {
    return (salesPrice - purchasePrice) * quantity;
  }

  bool get isProfitable => getProfitLoss > 0;

  factory Stock.fromMap(QMap map) {
    return Stock(
      id: map.parseAwField(),
      purchasePrice: map.parseNum('purchase_price'),
      salesPrice: map.parseNum('sales_price'),
      wholesalePrice: map.parseNum('wholesale_price'),
      dealerPrice: map.parseNum('dealer_price'),
      quantity: map.parseInt('quantity'),
      warehouse: WareHouse.tyrParse(map['warehouse']),
      createdAt: DateTime.parse(map.parseAwField('createdAt')),
    );
  }

  static Stock? tryParse(dynamic value) {
    try {
      if (value case final Document doc) return Stock.fromDoc(doc);
      if (value case final Map map) return Stock.fromMap(map.toStringKey());
      return null;
    } catch (e) {
      return null;
    }
  }

  Stock marge(Map<String, dynamic> map) {
    return Stock(
      id: map.tryParseAwField() ?? id,
      purchasePrice: map['purchase_price'] ?? purchasePrice,
      salesPrice: map['sales_price'] ?? salesPrice,
      wholesalePrice: map['wholesale_price'] ?? wholesalePrice,
      dealerPrice: map['dealer_price'] ?? dealerPrice,
      quantity: map['quantity'] ?? quantity,
      warehouse: WareHouse.tyrParse(map['warehouse']) ?? warehouse,
      createdAt:
          map.tryParseAwField('createdAt') != null ? DateTime.parse(map.tryParseAwField('createdAt')!) : createdAt,
    );
  }

  QMap toMap() => {
    'id': id,
    'purchase_price': purchasePrice,
    'sales_price': salesPrice,
    'wholesale_price': wholesalePrice,
    'dealer_price': dealerPrice,
    'quantity': quantity,
    'warehouse': warehouse?.toMap(),
    'createdAt': createdAt.toString(),
  };

  Map<String, dynamic> toAwPost() => {
    'purchase_price': purchasePrice,
    'sales_price': salesPrice,
    'wholesale_price': wholesalePrice,
    'dealer_price': dealerPrice,
    'quantity': quantity,
    'warehouse': warehouse?.id,
  };

  Stock copyWith({
    String? id,
    num? purchasePrice,
    num? salesPrice,
    num? wholesalePrice,
    num? dealerPrice,
    int? quantity,
    ValueGetter<WareHouse?>? warehouse,
    DateTime? createdAt,
  }) {
    return Stock(
      id: id ?? this.id,
      purchasePrice: purchasePrice ?? this.purchasePrice,
      salesPrice: salesPrice ?? this.salesPrice,
      wholesalePrice: wholesalePrice ?? this.wholesalePrice,
      dealerPrice: dealerPrice ?? this.dealerPrice,
      quantity: quantity ?? this.quantity,
      warehouse: warehouse != null ? warehouse() : this.warehouse,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
