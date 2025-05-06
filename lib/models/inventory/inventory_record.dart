import 'package:appwrite/models.dart';
import 'package:pos/main.export.dart';

enum RecordType {
  sale,
  purchase;

  bool get isSale => this == RecordType.sale;
  bool get isPurchase => this == RecordType.purchase;
}

enum InventoryStatus { paid, unpaid, returned }

enum DiscountType { flat, percentage }

class InventoryRecord {
  const InventoryRecord({
    required this.id,
    required this.parti,
    required this.details,
    required this.amount,
    required this.account,
    required this.vat,
    required this.discount,
    required this.discountType,
    required this.shipping,
    required this.status,
    required this.date,
    required this.type,
    required this.dueBalance,
  });

  final String id;
  final Parti parti;
  final List<InventoryDetails> details;
  final num amount;
  final PaymentAccount account;
  final num vat;
  final num discount;
  final DiscountType discountType;
  final num shipping;

  /// the amount covered by due_balance from parti
  final num dueBalance;
  final InventoryStatus status;
  final DateTime date;
  final RecordType type;

  factory InventoryRecord.fromDoc(Document doc) {
    final data = doc.data;
    return InventoryRecord(
      id: doc.$id,
      parti: Parti.fromMap(data['parties']),
      details: switch (data['inventory_details']) {
        final List l => l.map((e) => InventoryDetails.tryParse(e)).nonNulls.toList(),
        _ => [],
      },
      amount: data['amount'],
      account: PaymentAccount.fromMap(data['payment_account']),
      vat: data['vat'],
      discount: data['discount'],
      discountType: DiscountType.values.byName(data['discount_type']),
      shipping: data['shipping'],
      status: InventoryStatus.values.byName(data['status']),
      date: DateTime.parse(data['date']),
      type: RecordType.values.byName(data['record_type']),
      dueBalance: data['due_balance'],
    );
  }

  factory InventoryRecord.fromMap(Map<String, dynamic> map) {
    return InventoryRecord(
      id: map.parseAwField(),
      parti: Parti.fromMap(map['parties']),
      details: switch (map['inventory_details']) {
        final List l => l.map((e) => InventoryDetails.tryParse(e)).nonNulls.toList(),
        _ => [],
      },
      amount: map.parseNum('amount'),
      account: PaymentAccount.fromMap(map['payment_account']),
      vat: map.parseNum('vat'),
      discount: map.parseNum('discount'),
      discountType: DiscountType.values.byName(map['discount_type']),
      shipping: map.parseNum('shipping'),
      status: InventoryStatus.values.byName(map['status']),
      date: DateTime.parse(map['date']),
      type: RecordType.values.byName(map['record_type']),
      dueBalance: map.parseNum('due_balance'),
    );
  }
  static InventoryRecord? tryParse(dynamic value) {
    try {
      if (value case final Document doc) return InventoryRecord.fromDoc(doc);
      if (value case final Map map) return InventoryRecord.fromMap(map.toStringKey());
      return null;
    } catch (e) {
      return null;
    }
  }

  InventoryRecord marge(Map<String, dynamic> map) {
    return InventoryRecord(
      id: map.tryParseAwField() ?? id,
      parti: map['parties'] == null ? parti : Parti.fromMap(map['parties']),
      details: switch (map['inventory_details']) {
        final List l => l.map((e) => InventoryDetails.tryParse(e)).nonNulls.toList(),
        _ => details,
      },
      amount: map.parseNum('amount', fallBack: amount),
      account: map['payment_account'] == null ? account : PaymentAccount.fromMap(map['payment_account']),
      vat: map.parseNum('vat', fallBack: vat),
      discount: map.parseNum('discount', fallBack: discount),
      discountType: map['discount_type'] == null ? discountType : DiscountType.values.byName(map['discount_type']),
      shipping: map.parseNum('shipping', fallBack: shipping),
      status: map['status'] == null ? status : InventoryStatus.values.byName(map['status']),
      date: map['date'] == null ? date : DateTime.parse(map['date']),
      type: map['record_type'] == null ? type : RecordType.values.byName(map['record_type']),
      dueBalance: map.parseNum('due_balance', fallBack: dueBalance),
    );
  }

  Map<String, dynamic> toMap() => {
    'id': id,
    'parties': parti.toMap(),
    'inventory_details': details.map((e) => e.toMap()).toList(),
    'amount': amount,
    'payment_account': account.toMap(),
    'vat': vat,
    'discount': discount,
    'discount_type': discountType.name,
    'shipping': shipping,
    'status': status.name,
    'date': date.toIso8601String(),
    'record_type': type.name,
    'due_balance': dueBalance,
  };

  Map<String, dynamic> toAwPost() => {
    'parties': parti.id,
    'inventory_details': details.map((e) => e.id).toList(),
    'amount': amount,
    'payment_account': account.id,
    'vat': vat,
    'discount': discount,
    'discount_type': discountType.name,
    'shipping': shipping,
    'status': status.name,
    'date': date.toIso8601String(),
    'record_type': type.name,
    'due_balance': dueBalance,
  };

  String discountString() => discountType == DiscountType.percentage ? '$discount%' : discount.currency();

  num get total => details.map((e) => e.totalPriceByType(type)).sum;
  num get due => total - amount - dueBalance;

  InventoryRecord copyWith({
    String? id,
    Parti? parti,
    List<InventoryDetails>? details,
    num? amount,
    PaymentAccount? account,
    num? vat,
    num? discount,
    DiscountType? discountType,
    num? shipping,
    num? dueBalance,
    InventoryStatus? status,
    DateTime? date,
    RecordType? type,
  }) {
    return InventoryRecord(
      id: id ?? this.id,
      parti: parti ?? this.parti,
      details: details ?? this.details,
      amount: amount ?? this.amount,
      account: account ?? this.account,
      vat: vat ?? this.vat,
      discount: discount ?? this.discount,
      discountType: discountType ?? this.discountType,
      shipping: shipping ?? this.shipping,
      dueBalance: dueBalance ?? this.dueBalance,
      status: status ?? this.status,
      date: date ?? this.date,
      type: type ?? this.type,
    );
  }
}
