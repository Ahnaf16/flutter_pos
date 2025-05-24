import 'package:appwrite/models.dart';
import 'package:pos/main.export.dart';

class PaymentLog {
  const PaymentLog({
    required this.id,
    required this.record,
    required this.paymentDate,
    this.note,
    required this.payAmount,
  });

  final String id;
  final InventoryRecord? record;
  final DateTime paymentDate;
  final String? note;
  final num payAmount;

  factory PaymentLog.fromDoc(Document doc) {
    return PaymentLog.fromMap(doc.data);
  }

  factory PaymentLog.fromMap(Map<String, dynamic> map) {
    return PaymentLog(
      id: map.parseAwField(),
      record: InventoryRecord.tryParse(map['record']),
      paymentDate: DateTime.parse(map['payment_date']),
      note: map['note'],
      payAmount: map.parseNum('paid_amount'),
    );
  }

  static PaymentLog? tryParse(dynamic value) {
    try {
      if (value case final PaymentLog p) return p;
      if (value case final Document d) return PaymentLog.fromDoc(d);
      if (value case final Map m) return PaymentLog.fromMap(m.toStringKey());
      return null;
    } catch (e) {
      return null;
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'record': record?.toMap(),
      'payment_date': paymentDate.toIso8601String(),
      'note': note,
      'paid_amount': payAmount,
    };
  }

  Map<String, dynamic> toAwPost() {
    return {
      'record': record?.id,
      'payment_date': paymentDate.toIso8601String(),
      'note': note,
      'paid_amount': payAmount,
    };
  }

  PaymentLog copyWith({
    String? id,
    InventoryRecord? record,
    DateTime? paymentDate,
    ValueGetter<String?>? note,
    num? payAmount,
  }) {
    return PaymentLog(
      id: id ?? this.id,
      record: record ?? this.record,
      paymentDate: paymentDate ?? this.paymentDate,
      note: note != null ? note() : this.note,
      payAmount: payAmount ?? this.payAmount,
    );
  }
}
