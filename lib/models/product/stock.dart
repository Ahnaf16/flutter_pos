import 'package:appwrite/models.dart';
import 'package:pos/main.export.dart';

class Stock {
  const Stock({
    required this.id,
    required this.purchasePrice,

    // required this.salesPrice,
    required this.quantity,
    required this.warehouse,
    required this.createdAt,
  });

  final String id;
  final num purchasePrice;
  // final num salesPrice;

  final int quantity;
  final WareHouse? warehouse;
  final DateTime createdAt;

  factory Stock.fromDoc(Document doc) {
    final data = doc.data;
    return Stock(
      id: doc.$id,
      purchasePrice: data.parseNum('purchase_price'),
      quantity: data.parseInt('quantity'),
      warehouse: WareHouse.tyrParse(data['warehouse']),
      createdAt: DateTime.parse(doc.$createdAt),
    );
  }

  factory Stock.fromMap(QMap map) {
    return Stock(
      id: map.parseAwField(),
      purchasePrice: map.parseNum('purchase_price'),
      quantity: map.parseInt('quantity'),
      warehouse: WareHouse.tyrParse(map['warehouse']),
      createdAt: DateTime.tryParse(map.tryParseAwField('createdAt') ?? '') ?? DateTime.now(),
    );
  }

  static Stock? tryParse(dynamic value) {
    try {
      if (value case final Stock s) return s;
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

      // salesPrice: map['sales_price'] ?? salesPrice,
      quantity: map['quantity'] ?? quantity,
      warehouse: WareHouse.tyrParse(map['warehouse']) ?? warehouse,
      createdAt: map.tryParseAwField('createdAt') != null
          ? DateTime.parse(map.tryParseAwField('createdAt')!)
          : createdAt,
    );
  }

  QMap toMap() => {
    'id': id,
    'purchase_price': purchasePrice,
    // 'sales_price': salesPrice,
    'quantity': quantity,
    'warehouse': warehouse?.toMap(),
    'createdAt': createdAt.toString(),
  };

  // if include is null, all fields will be included
  Map<String, dynamic> toAwPost([List<String>? include]) {
    final map = <String, dynamic>{};

    void add(String key, dynamic value) {
      if (include == null || include.contains(key)) {
        map[key] = value;
      }
    }

    add(fields.purchasePrice, purchasePrice);
    // add(fields.salesPrice, salesPrice);

    add(fields.quantity, quantity);
    add(fields.warehouse, warehouse?.id);

    return map;
  }

  Stock copyWith({
    String? id,
    num? purchasePrice,
    int? quantity,
    ValueGetter<WareHouse?>? warehouse,
    DateTime? createdAt,
  }) {
    return Stock(
      id: id ?? this.id,
      purchasePrice: purchasePrice ?? this.purchasePrice,
      quantity: quantity ?? this.quantity,
      warehouse: warehouse != null ? warehouse() : this.warehouse,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  static final fields = _StockFields();

  static Stock empty([String? id]) => Stock(
    id: id ?? '',
    purchasePrice: 0,

    // salesPrice: 0,
    quantity: 0,
    warehouse: null,
    createdAt: DateTime.now(),
  );
}

class _StockFields {
  final purchasePrice = 'purchase_price';
  // final salesPrice = 'sales_price';

  final quantity = 'quantity';
  final warehouse = 'warehouse';
}
