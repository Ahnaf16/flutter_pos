import 'package:pos/main.export.dart';

class InventoryRecordState {
  final Party? parti;
  final List<InventoryDetails> details;
  final PaymentAccount? account;
  final num amount;
  final num vat;
  final num shipping;
  final num discount;
  final DiscountType discountType;
  final RecordType type;

  const InventoryRecordState({
    required this.type,
    this.parti,
    this.details = const [],
    this.account,
    this.amount = 0,
    this.vat = 0,
    this.discount = 0,
    this.discountType = DiscountType.flat,
    this.shipping = 0,
  });

  QMap toMap() => {
    'parti': parti?.toMap(),
    'details': details.map((e) => e.toMap()).toList(),
    'account': account?.toMap(),
    'amount': amount,
    'vat': vat,
    'discount': discount,
    'discountType': discountType.name,
    'shipping': shipping,
    'type': type.name,
  };

  InventoryRecordState copyWith({
    ValueGetter<Party?>? parti,
    List<InventoryDetails>? details,
    ValueGetter<PaymentAccount?>? account,
    num? amount,
    num? vat,
    num? shipping,
    num? discount,
    DiscountType? discountType,
    RecordType? type,
    ValueGetter<WalkIn?>? walkIn,
  }) {
    return InventoryRecordState(
      parti: parti != null ? parti() : this.parti,
      details: details ?? this.details,
      account: account != null ? account() : this.account,
      amount: amount ?? this.amount,
      vat: vat ?? this.vat,
      shipping: shipping ?? this.shipping,
      discount: discount ?? this.discount,
      discountType: discountType ?? this.discountType,
      type: type ?? this.type,
    );
  }

  num calculateDiscount() => discountType == DiscountType.flat ? discount : (subtotal() * discount) / 100;

  num subtotal() => details.map((e) => e.totalPrice()).sum;

  num totalPrice() => (subtotal() + shipping + vat) - calculateDiscount();

  num get due => totalPrice() - amount;

  bool get hasDue => due > 0;
  bool get hasBalance => due < 0;

  bool get partiHasBalance => parti?.due.isNegative ?? false;
  bool get partiHasDue => (parti?.due ?? 0) > 0;

  Party? get getParti => parti;

  bool get isWalkIn => parti?.isWalkIn ?? true;

  InventoryRecord toInventoryRecord() {
    return InventoryRecord(
      id: '',
      parti: parti,
      details: details,
      account: account,
      amount: amount,
      vat: vat,
      discount: discount,
      discountType: discountType,
      shipping: shipping,
      status: hasDue ? InventoryStatus.unpaid : InventoryStatus.paid,
      date: DateTime.now(),
      type: type,
      isWalkIn: isWalkIn,
    );
  }
}
