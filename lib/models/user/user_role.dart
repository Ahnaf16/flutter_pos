import 'package:appwrite/models.dart';
import 'package:pos/main.export.dart';

class UserRole {
  const UserRole({required this.id, required this.name, required this.permissions, this.isEnabled = true});

  final String id;
  final String name;
  final bool isEnabled;
  final List<RolePermissions> permissions;

  factory UserRole.fromDoc(Document doc) {
    final data = doc.data;

    return UserRole(
      id: doc.$id,
      name: data['name'] ?? '',
      isEnabled: data['enabled'] ?? true,
      permissions: switch (data['permissions']) {
        final List l => l.map((e) => RolePermissions.values.byName(e)).toList(),
        _ => [],
      },
    );
  }

  factory UserRole.fromMap(Map<String, dynamic> map) {
    return UserRole(
      id: map.parseID() ?? '',
      name: map['name'] ?? '',
      isEnabled: map['enabled'] ?? true,
      permissions: switch (map['permissions']) {
        final List l => l.map((e) => RolePermissions.values.byName(e)).toList(),
        _ => [],
      },
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

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'enabled': isEnabled,
    'permissions': permissions.map((e) => e.name).toList(),
  };
  Map<String, dynamic> toAwPost() => toMap()..removeWhere((key, value) => key == 'id');

  UserRole copyWith({String? id, String? name, bool? isEnabled, List<RolePermissions>? permissions}) {
    return UserRole(
      id: id ?? this.id,
      name: name ?? this.name,
      isEnabled: isEnabled ?? this.isEnabled,
      permissions: permissions ?? this.permissions,
    );
  }
}
