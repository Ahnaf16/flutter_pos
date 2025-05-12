import 'package:appwrite/models.dart';
import 'package:pos/main.export.dart';

class WareHouse {
  const WareHouse({
    required this.id,
    required this.name,
    required this.address,
    required this.isDefault,
    required this.contactNumber,
    this.contactPerson,
  });

  final String address;
  final String contactNumber;
  final String? contactPerson;
  final String id;
  final bool isDefault;
  final String name;

  factory WareHouse.fromDoc(Document doc) {
    final data = doc.data;
    return WareHouse(
      id: doc.$id,
      name: data[fields.name] ?? '',
      address: data[fields.address] ?? '',
      isDefault: data[fields.isDefault] ?? false,
      contactNumber: data[fields.contactNumber] ?? '',
      contactPerson: data[fields.contactPerson],
    );
  }

  factory WareHouse.fromMap(Map<String, dynamic> map) {
    return WareHouse(
      id: map.parseAwField(),
      name: map[fields.name] ?? '',
      address: map[fields.address] ?? '',
      isDefault: map[fields.isDefault] ?? false,
      contactNumber: map[fields.contactNumber] ?? '',
      contactPerson: map[fields.contactPerson],
    );
  }
  WareHouse marge(Map<String, dynamic> map) {
    return WareHouse(
      id: map.tryParseAwField() ?? id,
      name: map[fields.name] ?? name,
      address: map[fields.address] ?? address,
      isDefault: map[fields.isDefault] ?? isDefault,
      contactNumber: map[fields.contactNumber] ?? contactNumber,
      contactPerson: map[fields.contactPerson] ?? contactPerson,
    );
  }

  static WareHouse? tyrParse(dynamic value) {
    try {
      if (value case final WareHouse wh) return wh;
      if (value case final Document doc) return WareHouse.fromDoc(doc);
      if (value case final Map map) return WareHouse.fromMap(map.toStringKey());
      return null;
    } catch (e) {
      return null;
    }
  }

  Map<String, dynamic> toMap() => {
    'id': id,
    fields.name: name,
    fields.address: address,
    fields.isDefault: isDefault,
    fields.contactNumber: contactNumber,
    fields.contactPerson: contactPerson,
  };

  // if include is null, all fields will be included
  Map<String, dynamic> toAwPost([List<String>? include]) {
    final map = <String, dynamic>{};

    void add(String key, dynamic value) {
      if (include == null || include.contains(key)) {
        map[key] = value;
      }
    }

    add(fields.name, name);
    add(fields.address, address);
    add(fields.isDefault, isDefault);
    add(fields.contactNumber, contactNumber);
    add(fields.contactPerson, contactPerson);

    return map;
  }

  static final fields = _WarehouseFields();

  WareHouse copyWith({
    String? address,
    String? contactNumber,
    ValueGetter<String?>? contactPerson,
    String? id,
    bool? isDefault,
    String? name,
  }) {
    return WareHouse(
      address: address ?? this.address,
      contactNumber: contactNumber ?? this.contactNumber,
      contactPerson: contactPerson != null ? contactPerson() : this.contactPerson,
      id: id ?? this.id,
      isDefault: isDefault ?? this.isDefault,
      name: name ?? this.name,
    );
  }
}

class _WarehouseFields {
  final name = 'name';
  final address = 'address';
  final isDefault = 'is_default';
  final contactNumber = 'contact_number';
  final contactPerson = 'contact_person';
}
