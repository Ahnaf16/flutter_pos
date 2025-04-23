import 'package:appwrite/models.dart';
import 'package:pos/main.export.dart';

class AuthRepo with AwHandler {
  Future<void> signIn(String email, String password) async {
    // Implement sign-in logic here
  }

  Future<void> signOut() async {
    // Implement sign-out logic here
  }

  Future<void> register(String email, String password) async {
    // Implement registration logic here
  }

  FutureReport<User> currentUser() async {
    return handler(call: () async => await awAccount.get());
  }
}
