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

  Future<void> register(String email, String password, AppUser user) async {
    final newUser = await account.create(userId: ID.unique(), email: email, password: password, name: user.name);
    await db.createUser(data: user.toMap(), docId: newUser.$id);
  }

  FutureReport<AppUser> currentUser() async {
    final authUser = await handler(call: () async => await account.get());

    return await db.getUser(authUser.getOrNull()?.$id);
  }
}
