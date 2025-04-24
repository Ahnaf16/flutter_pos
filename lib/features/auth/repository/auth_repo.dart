import 'package:appwrite/models.dart';
import 'package:pos/main.export.dart';

class AuthRepo with AwHandler {
  FutureReport<Session> signIn(String email, String password) async {
    final res = await handler(
      call: () async {
        await signOut();
        return await account.createEmailPasswordSession(email: email, password: password);
      },
    );
    return res;
  }

  Future<void> signOut() async {
    await handler(call: () async => await account.deleteSessions());
  }

  FutureReport<AppUser> currentUser() async {
    final authUser = await handler(call: () async => await account.get());
    final id = authUser.getOrNull()?.$id;
    if (id == null) return failure('User ID cannot be null');

    return db.get(AWConst.collections.users, id).convert(AppUser.fromDoc);
  }
}
