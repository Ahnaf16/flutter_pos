import 'package:appwrite/models.dart';
import 'package:pos/main.export.dart';

enum RecordType {
  sale,
  purchase;

  bool get isSale => this == RecordType.sale;
  bool get isPurchase => this == RecordType.purchase;
}

enum InventoryStatus {
  paid,
  unpaid,
  returned;

  bool get isPaid => this == InventoryStatus.paid;
  bool get isUnpaid => this == InventoryStatus.unpaid;
  bool get isReturned => this == InventoryStatus.returned;
}

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
    required this.isWalkIn,
  });

  final String id;
  final Party? parti;
  final List<InventoryDetails> details;
  final num amount;
  final PaymentAccount? account;
  final num vat;
  final num discount;
  final DiscountType discountType;
  final num shipping;
  final InventoryStatus status;
  final DateTime date;
  final RecordType type;
  final bool isWalkIn;

  factory InventoryRecord.fromDoc(Document doc) {
    final data = doc.data;
    return InventoryRecord(
      id: doc.$id,
      parti: Party.tryParse(data['parties']),
      details: switch (data['inventory_details']) {
        final List l => l.map((e) => InventoryDetails.tryParse(e)).nonNulls.toList(),
        _ => [],
      },
      amount: data['amount'],
      account: PaymentAccount.tryParse(data['payment_account']),
      vat: data['vat'],
      discount: data['discount'],
      discountType: DiscountType.values.byName(data['discount_type']),
      shipping: data['shipping'],
      status: InventoryStatus.values.byName(data['status']),
      date: DateTime.parse(data['date']),
      type: RecordType.values.byName(data['record_type']),
      isWalkIn: data['is_walk_in'],
    );
  }

  factory InventoryRecord.fromMap(Map<String, dynamic> map) {
    return InventoryRecord(
      id: map.parseAwField(),
      parti: Party.tryParse(map['parties']),
      details: switch (map['inventory_details']) {
        final List l => l.map((e) => InventoryDetails.tryParse(e)).nonNulls.toList(),
        _ => [],
      },
      amount: map.parseNum('amount'),
      account: PaymentAccount.tryParse(map['payment_account']),
      vat: map.parseNum('vat'),
      discount: map.parseNum('discount'),
      discountType: DiscountType.values.byName(map['discount_type']),
      shipping: map.parseNum('shipping'),
      status: InventoryStatus.values.byName(map['status']),
      date: DateTime.parse(map['date']),
      type: RecordType.values.byName(map['record_type']),
      isWalkIn: map.parseBool('is_walk_in'),
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
      parti: map['parties'] == null ? parti : Party.tryParse(map['parties']) ?? parti,
      details: switch (map['inventory_details']) {
        final List l => l.map((e) => InventoryDetails.tryParse(e)).nonNulls.toList(),
        _ => details,
      },
      amount: map.parseNum('amount', fallBack: amount),
      account: map['payment_account'] == null ? account : PaymentAccount.tryParse(map['payment_account']),
      vat: map.parseNum('vat', fallBack: vat),
      discount: map.parseNum('discount', fallBack: discount),
      discountType: map['discount_type'] == null ? discountType : DiscountType.values.byName(map['discount_type']),
      shipping: map.parseNum('shipping', fallBack: shipping),
      status: map['status'] == null ? status : InventoryStatus.values.byName(map['status']),
      date: map['date'] == null ? date : DateTime.parse(map['date']),
      type: map['record_type'] == null ? type : RecordType.values.byName(map['record_type']),
      isWalkIn: map.parseBool('is_walk_in', isWalkIn),
    );
  }

  Map<String, dynamic> toMap() => {
    'id': id,
    'parties': parti?.toMap(),
    'inventory_details': details.map((e) => e.toMap()).toList(),
    'amount': amount,
    'payment_account': account?.toMap(),
    'vat': vat,
    'discount': discount,
    'discount_type': discountType.name,
    'shipping': shipping,
    'status': status.name,
    'date': date.toIso8601String(),
    'record_type': type.name,
    'is_walk_in': isWalkIn,
  };

  Map<String, dynamic> toAwPost() => {
    'parties': parti?.id,
    'inventory_details': details.map((e) => e.id).toList(),
    'amount': amount,
    'payment_account': account?.id,
    'vat': vat,
    'discount': discount,
    'discount_type': discountType.name,
    'shipping': shipping,
    'status': status.name,
    'date': date.toIso8601String(),
    'record_type': type.name,
    'is_walk_in': isWalkIn,
  };

  Party? get getParti => parti;

  String discountString() => discountType == DiscountType.percentage ? '$discount%' : discount.currency();

  num calculateDiscount() => discountType == DiscountType.flat ? discount : (subtotal * discount) / 100;

  num get subtotal => details.map((e) => e.totalPrice()).sum;
  num get total => (subtotal + shipping + vat) - calculateDiscount();

  num get due => total - amount;

  bool get hasDue => due > 0;
  bool get hasBalance => due < 0;

  num get payable => hasDue ? amount : amount + due;

  InventoryRecord copyWith({
    String? id,
    ValueGetter<Party?>? parti,
    List<InventoryDetails>? details,
    num? amount,
    PaymentAccount? account,
    num? vat,
    num? discount,
    DiscountType? discountType,
    num? shipping,
    InventoryStatus? status,
    DateTime? date,
    RecordType? type,
    bool? isWalkIn,
  }) {
    return InventoryRecord(
      id: id ?? this.id,
      parti: parti != null ? parti() : this.parti,
      details: details ?? this.details,
      amount: amount ?? this.amount,
      account: account ?? this.account,
      vat: vat ?? this.vat,
      discount: discount ?? this.discount,
      discountType: discountType ?? this.discountType,
      shipping: shipping ?? this.shipping,
      status: status ?? this.status,
      date: date ?? this.date,
      type: type ?? this.type,
      isWalkIn: isWalkIn ?? this.isWalkIn,
    );
  }
}
