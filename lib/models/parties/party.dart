import 'package:appwrite/models.dart';
import 'package:pos/main.export.dart';

enum PartiType {
  customer,
  supplier;

  static List<PartiType> get customers => [customer];
  static List<PartiType> get suppliers => [supplier];
}

class Party {
  final String id;
  const Party({
    required this.id,
    required this.name,
    required this.phone,
    required this.email,
    required this.address,
    required this.due,
    required this.photo,
    required this.type,
    this.isWalkIn = false,
  });

  final String name;
  final String phone;
  final String? email;
  final String? address;
  final num due;
  final String? photo;
  final PartiType type;
  final bool isWalkIn;

  Img get getPhoto => photo == null ? Img.icon(LuIcons.user) : Img.aw(photo!);

  bool get isCustomer => type == PartiType.customer;

  Color dueColor() {
    if (due == 0) return Colors.grey;
    // if (!isCustomer) return (hasBalance() ? Colors.red : Colors.green);
    return (hasDue() ? Colors.red : Colors.green);
  }

  bool hasDue() => due > 0;
  bool hasBalance() => due < 0;

  factory Party.fromDoc(Document doc) {
    final map = doc.data;
    return Party(
      id: doc.$id,
      name: map['name'] ?? '',
      phone: map['phone'] ?? '',
      email: map['email'],
      address: map['address'],
      due: map.parseNum('due'),
      photo: map['photo'],
      type: PartiType.values.byName(map['type']),
    );
  }

  factory Party.fromMap(Map<String, dynamic> map) => Party(
    id: map.parseAwField(),
    name: map['name'] ?? '',
    phone: map['phone'] ?? '',
    email: map['email'],
    address: map['address'],
    due: map.parseNum('due'),
    photo: map['photo'],
    type: PartiType.values.byName(map['type']),
  );

  static Party? tryParse(dynamic value) {
    try {
      if (value case final Party p) return p;
      if (value case final Document doc) return Party.fromDoc(doc);
      if (value case final Map map) return Party.fromMap(map.toStringKey());
      return null;
    } catch (e) {
      return null;
    }
  }

  static Party fromWalkIn([String? name]) {
    return Party(
      id: '',
      name: name ?? 'Walk In',
      phone: '--',
      email: null,
      address: null,
      due: 0,
      photo: null,
      type: PartiType.customer,
      isWalkIn: true,
    );
  }

  static Party fromCustom([String? name]) {
    return Party(
      id: '',
      name: name ?? 'Custom',
      phone: '',
      email: null,
      address: null,
      due: 0,
      photo: null,
      type: PartiType.supplier,
      isWalkIn: true,
    );
  }

  Party marge(Map<String, dynamic> map) {
    return Party(
      id: map.tryParseAwField() ?? id,
      name: map['name'] ?? name,
      phone: map['phone'] ?? phone,
      email: map['email'] ?? email,
      address: map['address'] ?? address,
      due: map.parseNum('due', fallBack: due),
      photo: map['photo'] ?? photo,
      type: map['type'] == null ? type : PartiType.values.byName(map['type']),
    );
  }

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'phone': phone,
    'email': email,
    'address': address,
    'due': due,
    'photo': photo,
    'type': type.name,
  };

  Map<String, dynamic> toAwPost() => toMap()..removeWhere((key, value) => key == 'id');

  Party copyWith({
    String? id,
    String? name,
    String? phone,
    ValueGetter<String?>? email,
    ValueGetter<String?>? address,
    num? due,
    ValueGetter<String?>? photo,
    PartiType? type,
  }) {
    return Party(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email != null ? email() : this.email,
      address: address != null ? address() : this.address,
      due: due ?? this.due,
      photo: photo != null ? photo() : this.photo,
      type: type ?? this.type,
    );
  }
}

class WalkIn {
  const WalkIn({this.name, this.phone});

  final String? name;
  final String? phone;

  static WalkIn? fromMap(Map<String, dynamic> map) {
    final name = map['name'] ?? map['walk_in_name'];
    final phone = map['phone'] ?? map['walk_in_phone'];
    if (name == null || phone == null) return null;

    return WalkIn(name: name, phone: phone);
  }

  QMap toMap() => {'walk_in_name': name, 'walk_in_phone': phone};
}
