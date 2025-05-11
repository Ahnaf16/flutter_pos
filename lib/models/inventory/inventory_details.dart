import 'package:appwrite/models.dart';
import 'package:pos/main.export.dart';

class InventoryDetails {
  const InventoryDetails({
    required this.id,
    required this.product,
    required this.stock,
    required this.quantity,
    required this.price,
  });
  final String id;

  final Product product;
  final Stock stock;
  final int quantity;
  final num price;

  factory InventoryDetails.fromDoc(Document doc) {
    final data = doc.data;
    return InventoryDetails(
      id: doc.$id,
      product: Product.fromMap(data['products']),
      stock: Stock.fromMap(data['stock']),
      quantity: data['quantity'],
      price: data['price'],
    );
  }

  factory InventoryDetails.fromMap(Map<String, dynamic> map) {
    return InventoryDetails(
      id: map.parseAwField(),
      product: Product.fromMap(map['products']),
      stock: Stock.fromMap(map['stock']),
      quantity: map.parseInt('quantity'),
      price: map.parseNum('price'),
    );
  }

  static InventoryDetails? tryParse(dynamic value) {
    try {
      if (value case final Document doc) return InventoryDetails.fromDoc(doc);
      if (value case final Map map) return InventoryDetails.fromMap(map.toStringKey());
      return null;
    } catch (e) {
      return null;
    }
  }

  InventoryDetails marge(Map<String, dynamic> map) {
    return InventoryDetails(
      id: map.tryParseAwField() ?? id,
      product: map['product'] == null ? product : Product.fromMap(map['product']),
      stock: map['stock'] == null ? stock : Stock.fromMap(map['stock']),
      quantity: map.parseInt('quantity', quantity),
      price: map.parseNum('price', fallBack: price),
    );
  }

  Map<String, dynamic> toMap() => {
    'id': id,
    'products': product.toMap(),
    'stock': stock.toMap(),
    'quantity': quantity,
    'price': price,
  };

  Map<String, dynamic> toAwPost() => {'products': product.id, 'stock': stock.id, 'quantity': quantity, 'price': price};

  InventoryDetails copyWith({String? id, Product? product, Stock? stock, int? quantity, num? price}) {
    return InventoryDetails(
      id: id ?? this.id,
      product: product ?? this.product,
      stock: stock ?? this.stock,
      quantity: quantity ?? this.quantity,
      price: price ?? this.price,
    );
  }

  num totalPrice([int? qty]) => (qty ?? quantity) * price;
}
