import 'package:appwrite/models.dart';
import 'package:pos/main.export.dart';

class PaymentAccount {
  const PaymentAccount({
    required this.id,
    required this.name,
    required this.description,
    required this.amount,
    required this.isActive,
  });
  final String id;
  final String name;
  final String? description;
  final num amount;
  final bool isActive;

  factory PaymentAccount.fromDoc(Document doc) {
    final data = doc.data;
    return PaymentAccount(
      id: doc.$id,
      name: data['name'],
      description: data['description'],
      amount: data['amount'],
      isActive: data['is_active'],
    );
  }

  factory PaymentAccount.fromMap(Map<String, dynamic> map) {
    return PaymentAccount(
      id: map.parseAwField(),
      name: map['name'] ?? '',
      description: map['description'],
      amount: map.parseNum('amount'),
      isActive: map.parseBool('is_active', true),
    );
  }
  static PaymentAccount? tryParse(dynamic value) {
    try {
      if (value case final Document doc) return PaymentAccount.fromDoc(doc);
      if (value case final Map map) return PaymentAccount.fromMap(map.toStringKey());
      return null;
    } catch (e) {
      return null;
    }
  }

  PaymentAccount marge(Map<String, dynamic> map) {
    return PaymentAccount(
      id: map.tryParseAwField() ?? id,
      name: map['name'] ?? name,
      description: map['description'] ?? description,
      amount: map['amount'] ?? amount,
      isActive: map['is_active'] ?? isActive,
    );
  }

  Map<String, dynamic> toMap() {
    return {'id': id, 'name': name, 'description': description, 'amount': amount, 'is_active': isActive};
  }

  Map<String, dynamic> toAwPost() {
    return toMap()..removeWhere((key, value) => key == 'id');
  }

  PaymentAccount copyWith({String? id, String? name, ValueGetter<String?>? description, num? amount, bool? isActive}) {
    return PaymentAccount(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description != null ? description() : this.description,
      amount: amount ?? this.amount,
      isActive: isActive ?? this.isActive,
    );
  }
}
