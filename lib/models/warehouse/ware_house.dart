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
      name: data['name'] ?? '',
      address: data['address'] ?? '',
      isDefault: data['is_default'] ?? false,
      contactNumber: data['contact_number'] ?? '',
      contactPerson: data['contact_person'],
    );
  }

  factory WareHouse.fromMap(Map<String, dynamic> map) {
    return WareHouse(
      id: map.parseID() ?? '',
      name: map['name'] ?? '',
      address: map['address'] ?? '',
      isDefault: map['is_default'] ?? false,
      contactNumber: map['contact_number'] ?? '',
      contactPerson: map['contact_person'],
    );
  }
  WareHouse marge(Map<String, dynamic> map) {
    return WareHouse(
      id: map.parseID() ?? id,
      name: map['name'] ?? name,
      address: map['address'] ?? address,
      isDefault: map['is_default'] ?? isDefault,
      contactNumber: map['contact_number'] ?? contactNumber,
      contactPerson: map['contact_person'] ?? contactPerson,
    );
  }

  static WareHouse? tyrParse(dynamic value) {
    try {
      if (value case final Document doc) return WareHouse.fromDoc(doc);
      if (value case final Map map) return WareHouse.fromMap(map.toStringKey());
      return null;
    } catch (e) {
      return null;
    }
  }

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'address': address,
    'is_default': isDefault,
    'contact_number': contactNumber,
    'contact_person': contactPerson,
  };

  Map<String, dynamic> toAwPost() => {
    'name': name,
    'address': address,
    'is_default': isDefault,
    'contact_number': contactNumber,
    'contact_person': contactPerson,
  };
}
