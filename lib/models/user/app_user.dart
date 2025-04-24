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
    this.isUserCreated = false,
    this.password,
    this.authId,
  });

  final String email;
  final String id;
  final String name;
  final String phone;
  final String? photo;
  final UserRole? role;
  final WareHouse? warehouse;

  /// is the user has been created in auth
  final bool isUserCreated;
  final String? password;
  final String? authId;

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
      isUserCreated: data['is_user_created'],
      password: data['password'],
      authId: data['auth_id'],
    );
  }

  factory AppUser.fromMap(Map<String, dynamic> map) {
    return AppUser(
      id: map.parseID() ?? '',
      name: map['name'] ?? '',
      phone: map['phone'] ?? '',
      email: map['email'] ?? '',
      photo: map['photo_id'],
      role: UserRole.tyrParse(map['role']),
      warehouse: WareHouse.tyrParse(map['warehouse']),
      isUserCreated: map.parseBool('is_user_created'),
      password: map['password'],
      authId: map['auth_id'],
    );
  }

  Img get getPhoto => photo == null ? Img.icon(LucideIcons.user) : Img.net(photo!);

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'phone': phone,
    'email': email,
    'photo_id': photo,
    'role': role?.toMap(),
    'warehouse': warehouse?.toMap(),
    'is_user_created': isUserCreated,
    'password': password,
    'auth_id': authId,
  };
  Map<String, dynamic> toAwPost() => {
    'name': name,
    'phone': phone,
    'email': email,
    'photo_id': photo,
    'role': role?.id,
    'warehouse': warehouse?.id,
    'is_user_created': isUserCreated,
    if (password != null) 'password': hashPass(password!),
    'auth_id': authId,
  };

  AppUser copyWith({
    String? email,
    String? id,
    String? name,
    String? phone,
    ValueGetter<String?>? photo,
    ValueGetter<UserRole?>? role,
    ValueGetter<WareHouse?>? warehouse,
    bool? isUserCreated,
    ValueGetter<String?>? password,
    ValueGetter<String?>? authId,
  }) {
    return AppUser(
      email: email ?? this.email,
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      photo: photo != null ? photo() : this.photo,
      role: role != null ? role() : this.role,
      warehouse: warehouse != null ? warehouse() : this.warehouse,
      isUserCreated: isUserCreated ?? this.isUserCreated,
      password: password != null ? password() : this.password,
      authId: authId != null ? authId() : this.authId,
    );
  }
}
