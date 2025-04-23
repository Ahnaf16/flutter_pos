import 'package:appwrite/models.dart';
import 'package:pos/_core/extensions/map_ex.dart';

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
      name: data['name'] ?? '',
      address: data['address'] ?? '',
      isDefault: data['is_default'] ?? false,
      contactNumber: data['contact_number'] ?? '',
      contactPerson: data['contact_person'],
    );
  }

  factory WareHouse.fromMap(Map<String, dynamic> map) {
    return WareHouse(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      address: map['address'] ?? '',
      isDefault: map['is_default'] ?? false,
      contactNumber: map['contact_number'] ?? '',
      contactPerson: map['contact_person'],
    );
  }

  static WareHouse? tyrParse(dynamic value) {
    try {
      if (value case final Document doc) WareHouse.fromDoc(doc);
      if (value case final Map map) WareHouse.fromMap(map.toStringKey());
      return null;
    } catch (e) {
      return null;
    }
  }

  Map<String, dynamic> toMap() => {
    'name': name,
    'address': address,
    'is_default': isDefault,
    'contact_number': contactNumber,
    'contact_person': contactPerson,
  };
}
