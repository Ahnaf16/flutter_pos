import 'package:appwrite/models.dart';
import 'package:pos/main.export.dart';

class UserRole {
  const UserRole({required this.id, required this.name, required this.permissions});

  final String id;
  final String name;
  final List<String> permissions;

  factory UserRole.fromDoc(Document doc) {
    final data = doc.data;

    return UserRole(id: doc.$id, name: data['name'] ?? '', permissions: List<String>.from(data['permissions'] ?? []));
  }

  factory UserRole.fromMap(Map<String, dynamic> map) {
    return UserRole(
      id: map.parseID() ?? '',
      name: map['name'] ?? '',
      permissions: List<String>.from(map['permissions'] ?? []),
    );
  }

  static UserRole? tyrParse(dynamic value) {
    try {
      if (value case final Document doc) return UserRole.fromDoc(doc);
      if (value case final Map map) return UserRole.fromMap(map.toStringKey());
      return null;
    } catch (e) {
      return null;
    }
  }

  Map<String, dynamic> toMap() => {'id': id, 'name': name, 'permissions': permissions};
}
