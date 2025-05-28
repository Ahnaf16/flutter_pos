import 'package:appwrite/models.dart';
import 'package:pos/main.export.dart';

enum AccountType {
  cash,
  bank,
  mobileBank;

  SMap fixedKeyValue() => switch (this) {
    AccountType.cash => {},
    AccountType.bank => {'Account number': '', 'Branch': ''},
    AccountType.mobileBank => {},
  };

  //  CustomInfo fixedKeyValue() => switch (this) {
  //   AccountType.cash => [],
  //   AccountType.bank => [const MapEntry('Account No', ''), const MapEntry('Branch', '')],
  //   AccountType.mobileBank => [],
  // };
}

class PaymentAccount {
  const PaymentAccount({
    required this.id,
    required this.name,
    required this.description,
    required this.amount,
    required this.isActive,
    required this.type,
    required this.customInfo,
  });
  final String id;
  final String name;
  final String? description;
  final num amount;
  final bool isActive;
  final AccountType type;
  final SMap customInfo;

  factory PaymentAccount.fromDoc(Document doc) {
    final data = doc.data;
    return PaymentAccount(
      id: doc.$id,
      name: data['name'],
      description: data['description'],
      amount: data['amount'],
      isActive: data['is_active'],
      type: AccountType.values.byName(data['type']),
      customInfo: data.parseCustomInfo('custom_info'),
    );
  }

  factory PaymentAccount.fromMap(Map<String, dynamic> map) {
    return PaymentAccount(
      id: map.parseAwField(),
      name: map['name'] ?? '',
      description: map['description'],
      amount: map.parseNum('amount'),
      isActive: map.parseBool('is_active', true),
      type: AccountType.values.byName(map['type']),
      customInfo: map.parseCustomInfo('custom_info'),
    );
  }
  static PaymentAccount? tryParse(dynamic value) {
    try {
      if (value case final PaymentAccount p) return p;
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
      type: map['type'] == null ? type : AccountType.values.byName(map['type']),
      customInfo: map['custom_info'] == null ? customInfo : map.parseCustomInfo('custom_info'),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'amount': amount,
      'is_active': isActive,
      'type': type.name,
      'custom_info': customInfo.toCustomList(),
    };
  }

  Map<String, dynamic> toAwPost() {
    return toMap()..removeWhere((key, value) => key == 'id');
  }

  PaymentAccount copyWith({
    String? id,
    String? name,
    ValueGetter<String?>? description,
    num? amount,
    bool? isActive,
    AccountType? type,
    SMap? customInfo,
  }) {
    return PaymentAccount(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description != null ? description() : this.description,
      amount: amount ?? this.amount,
      isActive: isActive ?? this.isActive,
      type: type ?? this.type,
      customInfo: customInfo ?? this.customInfo,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is PaymentAccount &&
        other.id == id &&
        other.name == name &&
        other.description == description &&
        other.amount == amount &&
        other.isActive == isActive &&
        other.type == type &&
        other.customInfo == customInfo;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        name.hashCode ^
        description.hashCode ^
        amount.hashCode ^
        isActive.hashCode ^
        type.hashCode ^
        customInfo.hashCode;
  }
}
