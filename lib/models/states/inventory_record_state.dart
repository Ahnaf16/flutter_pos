import 'package:pos/main.export.dart';

class InventoryRecordState {
  final Parti? parti;
  final List<InventoryDetails> details;
  final PaymentAccount? account;
  final num amount;
  final num vat;
  final num shipping;
  final num discount;
  final DiscountType discountType;
  final num dueBalance;

  const InventoryRecordState({
    this.parti,
    this.details = const [],
    this.account,
    this.amount = 0,
    this.vat = 0,
    this.discount = 0,
    this.discountType = DiscountType.flat,
    this.shipping = 0,
    this.dueBalance = 0,
  });

  InventoryRecordState copyWith({
    ValueGetter<Parti?>? parti,
    List<InventoryDetails>? details,
    ValueGetter<PaymentAccount?>? account,
    num? amount,
    num? vat,
    num? shipping,
    num? discount,
    DiscountType? discountType,
    num? dueBalance,
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
      dueBalance: dueBalance ?? this.dueBalance,
    );
  }

  num calculateDiscount(RecordType type) =>
      discountType == DiscountType.flat ? discount : (subtotal(type) * discount) / 100;

  num subtotal(RecordType type) => details.map((e) => e.totalPriceByType(type)).sum;

  num totalPriceSale(RecordType type) => (subtotal(type) + shipping + vat) - calculateDiscount(type);

  num get dueSale => totalPriceSale(RecordType.sale) - amount - dueBalance;

  bool get hasDue => dueSale > 0;
  bool get hasBalance => dueSale < 0;

  bool get partiHasBalance => parti?.due.isNegative ?? false;

  InventoryRecord? toInventoryRecord(RecordType type) {
    if (parti == null) return null;
    if (account == null) return null;

    return InventoryRecord(
      id: '',
      parti: parti!,
      details: details,
      account: account!,
      amount: amount,
      vat: vat,
      discount: discount,
      discountType: discountType,
      shipping: shipping,
      status: hasDue ? InventoryStatus.unpaid : InventoryStatus.paid,
      date: DateTime.now(),
      type: type,
      dueBalance: dueBalance,
    );
  }
}
