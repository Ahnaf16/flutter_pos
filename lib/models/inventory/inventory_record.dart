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
    required this.invoiceNo,
    required this.party,
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
    this.returnRecord,
    required this.createdBy,
    required this.calcDiscount,
  });

  final String id;
  final String invoiceNo;
  final Party? party;
  final List<InventoryDetails> details;
  final num amount;
  final PaymentAccount? account;
  final num vat;
  final num discount;
  final DiscountType discountType;

  /// calculated discount based on discount type
  final num calcDiscount;
  final num shipping;
  final InventoryStatus status;
  final DateTime date;
  final RecordType type;
  final bool isWalkIn;
  final ReturnRecord? returnRecord;
  final AppUser createdBy;

  factory InventoryRecord.fromDoc(Document doc) {
    final data = doc.data;
    return InventoryRecord(
      id: doc.$id,
      invoiceNo: data['invoice_no'],
      party: Party.tryParse(data['parties']),
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
      returnRecord: ReturnRecord.tryParse(data['returnRecord']),
      createdBy: AppUser.fromMap(data['created_by']),
      calcDiscount: data.parseNum('calculated_discount'),
    );
  }

  factory InventoryRecord.fromMap(Map<String, dynamic> map) {
    return InventoryRecord(
      id: map.parseAwField(),
      invoiceNo: map['invoice_no'],
      party: Party.tryParse(map['parties']),
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
      returnRecord: ReturnRecord.tryParse(map['returnRecord']),
      createdBy: AppUser.fromMap(map['created_by']),
      calcDiscount: map.parseNum('calculated_discount'),
    );
  }
  static InventoryRecord? tryParse(dynamic value) {
    try {
      if (value case final InventoryRecord r) return r;
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
      invoiceNo: map['invoice_no'] ?? invoiceNo,
      party: Party.tryParse(map['parties']) ?? party,
      details: switch (map['inventory_details']) {
        final List l => l.map((e) => InventoryDetails.tryParse(e)).nonNulls.toList(),
        _ => details,
      },
      amount: map.parseNum('amount', fallBack: amount),
      account: PaymentAccount.tryParse(map['payment_account']) ?? account,
      vat: map.parseNum('vat', fallBack: vat),
      discount: map.parseNum('discount', fallBack: discount),
      discountType: map['discount_type'] == null ? discountType : DiscountType.values.byName(map['discount_type']),
      shipping: map.parseNum('shipping', fallBack: shipping),
      status: map['status'] == null ? status : InventoryStatus.values.byName(map['status']),
      date: map['date'] == null ? date : DateTime.parse(map['date']),
      type: map['record_type'] == null ? type : RecordType.values.byName(map['record_type']),
      isWalkIn: map.parseBool('is_walk_in', isWalkIn),
      returnRecord: ReturnRecord.tryParse(map['returnRecord']) ?? returnRecord,
      createdBy: AppUser.tryParse(map['created_by']) ?? createdBy,
      calcDiscount: map.parseNum('calculated_discount', fallBack: calcDiscount),
    );
  }

  Map<String, dynamic> toMap() => {
    'id': id,
    'invoice_no': invoiceNo,
    'parties': party?.toMap(),
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
    'returnRecord': returnRecord?.toMap(),
    'created_by': createdBy.toMap(),
    'calculated_discount': calcDiscount,
  };

  Map<String, dynamic> toAwPost() => {
    'parties': party?.id,
    'invoice_no': invoiceNo,
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
    'created_by': createdBy.id,
    'calculated_discount': calcDiscount,
  };

  Party get getParti => isWalkIn ? Party.fromWalkIn() : party ?? Party.fromWalkIn();

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
    String? invoiceNo,
    ValueGetter<Party?>? party,
    List<InventoryDetails>? details,
    num? amount,
    ValueGetter<PaymentAccount?>? account,
    num? vat,
    num? discount,
    DiscountType? discountType,
    num? calcDiscount,
    num? shipping,
    InventoryStatus? status,
    DateTime? date,
    RecordType? type,
    bool? isWalkIn,
    ValueGetter<ReturnRecord?>? returnRecord,
    AppUser? createdBy,
  }) {
    return InventoryRecord(
      id: id ?? this.id,
      invoiceNo: invoiceNo ?? this.invoiceNo,
      party: party != null ? party() : this.party,
      details: details ?? this.details,
      amount: amount ?? this.amount,
      account: account != null ? account() : this.account,
      vat: vat ?? this.vat,
      discount: discount ?? this.discount,
      discountType: discountType ?? this.discountType,
      calcDiscount: calcDiscount ?? this.calcDiscount,
      shipping: shipping ?? this.shipping,
      status: status ?? this.status,
      date: date ?? this.date,
      type: type ?? this.type,
      isWalkIn: isWalkIn ?? this.isWalkIn,
      returnRecord: returnRecord != null ? returnRecord() : this.returnRecord,
      createdBy: createdBy ?? this.createdBy,
    );
  }
}
