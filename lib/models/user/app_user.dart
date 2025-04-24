import 'package:appwrite/models.dart';
import 'package:pos/main.export.dart';

class AppUser {
  const AppUser({
    required this.id,
    required this.name,
    required this.phone,
    required this.email,
    this.photo,
    required this.role,
    required this.warehouse,
  });

  final String email;
  final String id;
  final String name;
  final String phone;
  final String? photo;
  final UserRole? role;
  final WareHouse? warehouse;

  factory AppUser.fromDoc(Document doc) {
    final data = doc.data;

    return AppUser(
      id: doc.$id,
      name: data['name'] ?? '',
      phone: data['phone'] ?? '',
      email: data['email'] ?? '',
      photo: data['photo'],
      role: UserRole.tyrParse(data['role']),
      warehouse: WareHouse.tyrParse(data['warehouse']),
    );
  }

  factory AppUser.fromMap(Map<String, dynamic> map) {
    return AppUser(
      id: map.parseID() ?? '',
      name: map['name'] ?? '',
      phone: map['phone'] ?? '',
      email: map['email'] ?? '',
      photo: map['photo'],
      role: UserRole.tyrParse(map['role']),
      warehouse: WareHouse.tyrParse(map['warehouse']),
    );
  }

  Img get getPhoto => photo == null ? Img.icon(LucideIcons.user) : Img.net(photo!);

  Map<String, dynamic> toMap() => {
    'name': name,
    'phone': phone,
    'email': email,
    'photo': photo,
    'role': role?.toMap(),
    'warehouse': warehouse?.toMap(),
  };
}
