import 'package:appwrite/models.dart';
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

  FutureReport<Document> updateRole(UserRole role) async {
    return await db.update(AWConst.collections.role, role.id, data: role.toAwPost());
  }
}
