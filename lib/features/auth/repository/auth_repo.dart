import 'package:appwrite/models.dart';
import 'package:fpdart/fpdart.dart';
import 'package:pos/features/staffs/repository/staffs_repo.dart';
import 'package:pos/main.export.dart';

class AuthRepo with AwHandler {
  FutureReport<Session> signIn(String email, String password) async {
    final res = await handler(
      call: () async {
        await signOut();
        return await account.createEmailPasswordSession(email: email, password: password);
      },
    );
    return res.fold((f) {
      if (f.isWrongCredentials()) return _attemptSilentSignUp(email, password);
      return left(f);
    }, (r) => right(r));
  }

  Future<void> signOut() async {
    await handler(call: () async => await account.deleteSessions());
  }

  FutureReport<Session> _attemptSilentSignUp(String email, String password) async {
    await signOut();
    final user = await locate<StaffRepo>().getNotCreatedStaff(email, password).getOrNull();
    if (user == null) return failure('Credentials mismatch');
    return await handler(
      call: () async {
        await account.create(userId: user.id, email: email, password: password, name: user.name);
        return await account.createEmailPasswordSession(email: email, password: password);
      },
    );
  }

  FutureReport<AppUser> currentUser() async {
    final authUser = await handler(call: () async => await account.get());
    final id = authUser.getOrNull()?.$id;
    if (id == null) return failure('User ID cannot be null');

    return db.get(AWConst.collections.users, id).convert(AppUser.fromDoc);
  }
}
