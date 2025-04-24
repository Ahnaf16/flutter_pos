import 'package:pos/main.export.dart';

class UserRolesRepo with AwHandler {
  FutureReport<List<UserRole>> getRoles() async {
    return await db.getList(AWConst.collections.role).convert((docs) => docs.convertDoc(UserRole.fromDoc));
  }
}
