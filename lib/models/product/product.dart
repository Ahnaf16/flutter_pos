import 'package:appwrite/models.dart';
import 'package:pos/main.export.dart';

class Product {
  const Product({
    required this.id,
    required this.name,
    required this.description,
    required this.sku,
    required this.photo,
    required this.unit,
    required this.stock,
    required this.manageStock,
    required this.manufacturer,
  });

  final String id;
  final String name;
  final String? description;
  final String? sku;
  final String? photo;
  final ProductUnit? unit;
  final List<Stock> stock;
  final bool manageStock;
  final String? manufacturer;

  factory Product.fromDoc(Document doc) {
    final data = doc.data;
    return Product(
      id: doc.$id,
      name: data['name'] ?? '',
      description: data['description'],
      sku: data['sku'],
      photo: data['photo'],
      unit: ProductUnit.tryParse(data['unit']),
      stock: switch (data['stock']) {
        final List l => l.map((e) => Stock.tryParse(e)).nonNulls.toList(),
        _ => [],
      },
      manageStock: data.parseBool('manage_stock'),
      manufacturer: data['manufacturer'],
    );
  }

  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map.parseAwField(),
      name: map['name'] ?? '',
      description: map['description'],
      sku: map['sku'],
      photo: map['photo'],
      unit: ProductUnit.tryParse(map['unit']),
      stock: switch (map['stock']) {
        final List l => l.map((e) => Stock.tryParse(e)).nonNulls.toList(),
        _ => [],
      },
      manageStock: map.parseBool('manage_stock'),
      manufacturer: map['manufacturer'],
    );
  }

  static Product? tryParse(dynamic value) {
    try {
      if (value case final Document doc) return Product.fromDoc(doc);
      if (value case final Map map) return Product.fromMap(map.toStringKey());
      return null;
    } catch (e) {
      return null;
    }
  }

  Product marge(Map<String, dynamic> map) {
    return Product(
      id: map.tryParseAwField() ?? id,
      name: map['name'] ?? name,
      description: map['description'] ?? description,
      sku: map['sku'] ?? sku,
      photo: map['photo'] ?? photo,
      unit: map['unit'] == null ? unit : ProductUnit.tryParse(map['unit']) ?? unit,
      stock: switch (map['stock']) {
        final List l => l.map((e) => Stock.tryParse(e)).nonNulls.toList(),
        _ => stock,
      },
      manageStock: map['manage_stock'] ?? manageStock,
      manufacturer: map['manufacturer'] ?? manufacturer,
    );
  }

  Img get getPhoto => photo == null ? Img.icon(LucideIcons.package, 25) : Img.aw(photo!);

  QMap toMap() => {
    'id': id,
    'name': name,
    'description': description,
    'sku': sku,
    'photo': photo,
    'unit': unit?.toMap(),
    'stock': stock.map((e) => e.toMap()).toList(),
    'manage_stock': manageStock,
    'manufacturer': manufacturer,
  };

  QMap toAwPost() => {
    'name': name,
    'description': description,
    'sku': sku,
    'photo': photo,
    'unit': unit?.id,
    'stock': stock.map((e) => e.id).toList(),
    'manage_stock': manageStock,
    'manufacturer': manufacturer,
  };

  Product copyWith({
    String? id,
    String? name,
    ValueGetter<String?>? description,
    ValueGetter<String?>? sku,
    ValueGetter<String?>? photo,
    ValueGetter<ProductUnit?>? unit,
    List<Stock>? stock,
    bool? manageStock,
    String? manufacturer,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description != null ? description() : this.description,
      sku: sku != null ? sku() : this.sku,
      photo: photo != null ? photo() : this.photo,
      unit: unit != null ? unit() : this.unit,
      stock: stock ?? this.stock,
      manageStock: manageStock ?? this.manageStock,
      manufacturer: manufacturer ?? this.manufacturer,
    );
  }

  int get quantity => stock.map((e) => e.quantity).sum;

  String get unitName => unit?.unitName ?? '';

  WareHouse? get warehouse => stock.map((e) => e.warehouse).firstOrNull;

  Stock? getLatestStock() {
    if (stock.isEmpty) return null;
    return stock.reduce((a, b) => a.createdAt.isAfter(b.createdAt) ? a : b);
  }

  Stock? getOldestStock() {
    if (stock.isEmpty) return null;
    return stock.reduce((a, b) => a.createdAt.isBefore(b.createdAt) ? a : b);
  }

  Stock? getEffectiveStock(StockDistPolicy policy) {
    return switch (policy) {
      StockDistPolicy.newerFirst => getLatestStock(),
      StockDistPolicy.olderFirst => getOldestStock(),
    };
  }
}
