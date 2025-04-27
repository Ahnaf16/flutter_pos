import 'package:appwrite/models.dart';
import 'package:pos/main.export.dart';

class ProductUnit {
  const ProductUnit({required this.id, required this.name, required this.unitName, required this.isActive});

  final String id;
  final String name;
  final String unitName;
  final bool isActive;

  factory ProductUnit.fromDoc(Document doc) {
    return ProductUnit(
      id: doc.$id,
      name: doc.data['name'],
      unitName: doc.data['unit_name'],
      isActive: doc.data.parseBool('is_active'),
    );
  }

  factory ProductUnit.fromMap(Map<String, dynamic> map) {
    return ProductUnit(
      id: map.parseID() ?? '',
      name: map['name'] ?? '',
      unitName: map['unit_name'] ?? '',
      isActive: map.parseBool('is_active', true),
    );
  }

  static ProductUnit? tryParse(dynamic value) {
    try {
      if (value case final Document doc) return ProductUnit.fromDoc(doc);
      if (value case final Map map) return ProductUnit.fromMap(map.toStringKey());
      return null;
    } catch (e) {
      return null;
    }
  }

  ProductUnit marge(Map<String, dynamic> map) {
    return ProductUnit(
      id: map.parseID() ?? id,
      name: map['name'] ?? name,
      unitName: map['unit_name'] ?? unitName,
      isActive: map['is_active'] ?? isActive,
    );
  }

  QMap toMap() => {'id': id, 'name': name, 'unit_name': unitName, 'is_active': isActive};

  Map<String, dynamic> toAwPost() => toMap()..removeWhere((key, value) => key == 'id');

  ProductUnit copyWith({String? id, String? name, String? unitName, bool? isActive}) {
    return ProductUnit(
      id: id ?? this.id,
      name: name ?? this.name,
      unitName: unitName ?? this.unitName,
      isActive: isActive ?? this.isActive,
    );
  }
}
