import 'package:appwrite/models.dart';
import 'package:fpdart/fpdart.dart';
import 'package:pos/features/staffs/repository/staffs_repo.dart';
import 'package:pos/main.export.dart';

class AuthRepo with AwHandler {
  FutureReport<Session> signIn(String email, String password) async {
    await signOut();

    final res = await account.createSession(email, password);

    if (res.toRecord().error case final Failure f when f.isWrongCredentials()) {
      return _attemptSilentSignUp(email, password);
    }

    return res;
  }

  Future<void> signOut() async => await account.deleteSessions();

  FutureReport<Session> _attemptSilentSignUp(String email, String password) async {
    catAw('Create and link account', '_attemptSilentSignUp');
    final repo = locate<StaffRepo>();

    final user = await repo.getNotCreatedStaff(email, password).getOrNull();
    if (user == null) return failure('Credentials mismatch');

    catAw('Matched user ${user.name}', '_attemptSilentSignUp');

    final (creationErr, _) =
        await account.create(userId: user.id, email: email, password: password, name: user.name).toRecord();

    if (creationErr != null) {
      catAw('Error creating account', '_attemptSilentSignUp');
      return left(creationErr);
    }

    final (updateUserErr, _) =
        await repo.updateStaff(user.copyWith(password: () => null, isAccountCreated: true)).toRecord();

    if (updateUserErr != null) {
      catAw('Failed to update user', '_attemptSilentSignUp');
      return left(updateUserErr);
    }

    return account.createSession(email, password);
  }

  FutureReport<AppUser> currentUser() async {
    final (err, authUser) = await account.user().toRecord();

    if (authUser == null || err != null) return left(err ?? const Failure('User not found'));

    return db.get(AWConst.collections.users, authUser.$id).convert(AppUser.fromDoc);
  }
}
