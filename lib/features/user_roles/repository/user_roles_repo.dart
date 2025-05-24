import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart';
import 'package:fpdart/fpdart.dart';
import 'package:pos/main.export.dart';

class UserRolesRepo with AwHandler {
  FutureReport<List<UserRole>> getRoles() async {
    return await db.getList(AWConst.collections.role).convert((docs) => docs.convertDoc(UserRole.fromDoc));
  }

  FutureReport<UserRole> getRoleById(String id) async {
    return await db.get(AWConst.collections.role, id).convert(UserRole.fromDoc);
  }

  FutureReport<Document> createRole(UserRole role) async {
    return await db.create(AWConst.collections.role, data: role.toAwPost());
  }

  FutureReport<Document> updateRole(UserRole role, [bool checkUser = false]) async {
    if (checkUser) {
      final (err, docs) = await db
          .getList(AWConst.collections.users, queries: [Query.equal('role', role.id)])
          .toRecord();

      if ((docs?.total ?? 0) > 0) return failure('Cannot update role as it is assigned to users');
    }
    return await db.update(AWConst.collections.role, role.id, data: role.toAwPost());
  }

  FutureReport<Unit> deleteRole(UserRole role, [bool checkUser = false]) async {
    if (checkUser) {
      final (err, docs) = await db
          .getList(AWConst.collections.users, queries: [Query.equal('role', role.id)])
          .toRecord();

      if ((docs?.total ?? 0) > 0) return failure('Cannot delete role as it is assigned to users');
    }
    return await db.delete(AWConst.collections.role, role.id);
  }
}
