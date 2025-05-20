import 'package:appwrite/models.dart';
import 'package:pos/main.export.dart';

class ProductUnit {
  const ProductUnit({required this.id, required this.name, required this.isActive});

  final String id;
  final String name;
  final bool isActive;

  factory ProductUnit.fromDoc(Document doc) {
    return ProductUnit(id: doc.$id, name: doc.data['name'], isActive: doc.data.parseBool('is_active'));
  }

  factory ProductUnit.fromMap(Map<String, dynamic> map) {
    return ProductUnit(id: map.parseAwField(), name: map['name'] ?? '', isActive: map.parseBool('is_active', true));
  }

  static ProductUnit? tryParse(dynamic value) {
    try {
      if (value case final ProductUnit u) return u;
      if (value case final Document doc) return ProductUnit.fromDoc(doc);
      if (value case final Map map) return ProductUnit.fromMap(map.toStringKey());
      return null;
    } catch (e) {
      return null;
    }
  }

  ProductUnit marge(Map<String, dynamic> map) {
    return ProductUnit(
      id: map.tryParseAwField() ?? id,
      name: map['name'] ?? name,
      isActive: map['is_active'] ?? isActive,
    );
  }

  QMap toMap() => {'id': id, 'name': name, 'unit_name': name, 'is_active': isActive};

  Map<String, dynamic> toAwPost() => toMap()..removeWhere((key, value) => key == 'id');

  ProductUnit copyWith({String? id, String? name, bool? isActive}) {
    return ProductUnit(id: id ?? this.id, name: name ?? this.name, isActive: isActive ?? this.isActive);
  }
}
