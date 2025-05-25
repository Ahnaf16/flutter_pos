import 'package:appwrite/models.dart';
import 'package:pos/main.export.dart';

class StockTransferLog {
  const StockTransferLog({
    required this.id,
    required this.product,
    required this.from,
    required this.to,
    required this.stock,
    required this.date,
    required this.user,
  });

  final String id;
  final Product? product;
  final WareHouse? from;
  final WareHouse? to;
  final Stock? stock;
  final DateTime date;
  final AppUser? user;

  factory StockTransferLog.fromDoc(Document doc) => StockTransferLog.fromMap(doc.data);

  factory StockTransferLog.fromMap(Map<String, dynamic> map) {
    return StockTransferLog(
      id: map.parseAwField(),
      product: Product.tryParse(map['product']),
      from: WareHouse.tyrParse(map['from']),
      to: WareHouse.tyrParse(map['to']),
      stock: Stock.tryParse(map['stock']),
      date: DateTime.parse(map['date']),
      user: AppUser.tryParse(map['user']),
    );
  }

  factory StockTransferLog.fromStockState(StockTransferState tState, Stock stock) {
    return StockTransferLog(
      id: '',
      product: tState.product,
      from: tState.from,
      to: tState.to,
      stock: stock,
      date: DateTime.now(),
      user: null,
    );
  }

  static StockTransferLog? tryParse(dynamic map) {
    try {
      if (map case final StockTransferLog log) return log;
      if (map case final Document doc) return StockTransferLog.fromDoc(doc);
      if (map case final Map m) return StockTransferLog.fromMap(m.toStringKey());
    } catch (e) {
      return null;
    }
    return null;
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'product': product?.toMap(),
      'from': from?.toMap(),
      'to': to?.toMap(),
      'stock': stock?.toMap(),
      'date': date.toIso8601String(),
      'user': user?.toMap(),
    };
  }

  Map<String, dynamic> toAwPost() {
    return {
      'product': product?.id,
      'from': from?.id,
      'to': to?.id,
      'stock': stock?.id,
      'date': date.toIso8601String(),
      'user': user?.id,
    };
  }

  StockTransferLog copyWith({
    String? id,
    ValueGetter<Product?>? product,
    ValueGetter<WareHouse?>? from,
    ValueGetter<WareHouse?>? to,
    ValueGetter<Stock?>? stock,
    DateTime? date,
    AppUser? user,
  }) {
    return StockTransferLog(
      id: id ?? this.id,
      product: product != null ? product() : this.product,
      from: from != null ? from() : this.from,
      to: to != null ? to() : this.to,
      stock: stock != null ? stock() : this.stock,
      date: date ?? this.date,
      user: user ?? this.user,
    );
  }
}
