import 'package:nanoid2/nanoid2.dart';
import 'package:pos/main.export.dart';

class InventoryRecordState {
  final Party? parti;
  final List<InventoryDetails> details;
  final PaymentAccount? account;
  final num paidAmount;
  final num vat;
  final num shipping;
  final num discount;
  final DiscountType discountType;
  final RecordType type;

  InventoryRecordState({
    required this.type,
    this.parti,
    this.details = const [],
    this.account,
    this.paidAmount = 0,
    this.vat = 0,
    this.discount = 0,
    this.discountType = DiscountType.flat,
    this.shipping = 0,
  });

  QMap toMap() => {
    'parti': parti?.toMap(),
    'details': details.map((e) => e.toMap()).toList(),
    'account': account?.toMap(),
    'amount': paidAmount,
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
      paidAmount: amount ?? paidAmount,
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

  num get due => totalPrice() - paidAmount;

  bool get hasDue => due > 0;
  bool get hasExtra => due < 0;

  bool get partiHasBalance => parti?.due.isNegative ?? false;
  bool get partiHasDue => (parti?.due ?? 0) > 0;

  Party? get getParti => parti;

  bool get isWalkIn => parti?.isWalkIn ?? true;

  InventoryRecord toInventoryRecord(AppUser user) {
    InventoryStatus status = InventoryStatus.paid;
    if (paidAmount == 0) status = InventoryStatus.unpaid;
    if (paidAmount > 0 && paidAmount < totalPrice()) status = InventoryStatus.partial;

    return InventoryRecord(
      id: '',
      invoiceNo: 'pos${nanoid(length: 8, alphabet: '0123456789')}',
      party: parti,
      details: details,
      account: account,
      paidAmount: paidAmount,
      initialPayAmount: paidAmount,
      vat: vat,
      discount: discount,
      discountType: discountType,
      calcDiscount: calculateDiscount(),
      shipping: shipping,
      status: status,
      date: DateTime.now(),
      type: type,
      isWalkIn: isWalkIn,
      createdBy: user,
      paymentLogs: [],
    );
  }
}
