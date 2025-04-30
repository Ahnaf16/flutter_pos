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
    this.isAccountCreated = false,
    this.password,
  });

  final String email;
  final String id;
  final String name;
  final String phone;
  final String? photo;
  final UserRole? role;
  final WareHouse? warehouse;

  /// is the user has been created in auth
  final bool isAccountCreated;
  final String? password;

  factory AppUser.fromDoc(Document doc) {
    final data = doc.data;

    return AppUser(
      id: doc.$id,
      name: data['name'] ?? '',
      phone: data['phone'] ?? '',
      email: data['email'] ?? '',
      photo: data['photo_id'],
      role: UserRole.tyrParse(data['role']),
      warehouse: WareHouse.tyrParse(data['warehouse']),
      isAccountCreated: data['is_user_created'],
      password: data['password'],
    );
  }

  factory AppUser.fromMap(Map<String, dynamic> map) {
    return AppUser(
      id: map.parseAwField(),
      name: map['name'] ?? '',
      phone: map['phone'] ?? '',
      email: map['email'] ?? '',
      photo: map['photo_id'],
      role: UserRole.tyrParse(map['role']),
      warehouse: WareHouse.tyrParse(map['warehouse']),
      isAccountCreated: map.parseBool('is_user_created'),
      password: map['password'],
    );
  }

  AppUser marge(Map<String, dynamic> map) {
    return AppUser(
      id: map.tryParseAwField() ?? id,
      email: map['email'] ?? email,
      name: map['name'] ?? name,
      phone: map['phone'] ?? phone,
      photo: map['photo_id'] ?? photo,
      role: map['role'] == null ? role : UserRole.tyrParse(map['role']),
      warehouse: map['warehouse'] == null ? warehouse : WareHouse.tyrParse(map['warehouse']),
      isAccountCreated: map.parseBool('is_user_created', isAccountCreated),
      password: map['password'] ?? password,
    );
  }

  Img get getPhoto => photo == null ? Img.icon(LucideIcons.user) : AwImg(photo!);

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'phone': phone,
    'email': email,
    'photo_id': photo,
    'role': role?.toMap(),
    'warehouse': warehouse?.toMap(),
    'is_user_created': isAccountCreated,
    'password': password,
  };
  Map<String, dynamic> toAwPost() => {
    'name': name,
    'phone': phone,
    'email': email,
    'photo_id': photo,
    'role': role?.id,
    'warehouse': warehouse?.id,
    'is_user_created': isAccountCreated,
    'password': password != null ? hashPass(password!) : null,
  };

  AppUser copyWith({
    String? email,
    String? id,
    String? name,
    String? phone,
    ValueGetter<String?>? photo,
    ValueGetter<UserRole?>? role,
    ValueGetter<WareHouse?>? warehouse,
    bool? isAccountCreated,
    ValueGetter<String?>? password,
  }) {
    return AppUser(
      email: email ?? this.email,
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      photo: photo != null ? photo() : this.photo,
      role: role != null ? role() : this.role,
      warehouse: warehouse != null ? warehouse() : this.warehouse,
      isAccountCreated: isAccountCreated ?? this.isAccountCreated,
      password: password != null ? password() : this.password,
    );
  }
}
