import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart';
import 'package:fpdart/fpdart.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pos/main.export.dart';

class StaffRepo with AwHandler {
  FutureReport<Document> createStaff(String password, QMap form) async {
    AppUser user = AppUser.fromMap(form);
    user = user.copyWith(password: () => password);

    final photoPath = user.photo;

    if (photoPath != null) {
      final xFile = XFile(photoPath);
      final file = await storage.createFile(xFile.name, xFile.path);

      String? error;

      file.fold((l) => error = l.message, (r) => user = user.copyWith(photo: () => r.$id));

      if (error != null) return failure(error ?? 'Error uploading photo');
    }

    final doc = await db.create(AWConst.collections.users, data: user.toAwPost());
    doc.fold((_) {
      if (user.photo != null) storage.deleteFile(user.photo!);
    }, identityNull);
    return doc;
  }

  FutureReport<Document> updateStaff(AppUser user, [XFile? photo]) async {
    String? oldPhoto;
    if (photo != null) {
      final file = await storage.createFile(photo.name, photo.path);
      String? error;
      file.fold((l) => error = l.message, (r) {
        oldPhoto = user.photo;
        user = user.copyWith(photo: () => r.$id);
      });

      if (error != null) return failure(error ?? 'Error uploading photo');
    }

    final doc = await db.update(AWConst.collections.users, user.id, data: user.toAwPost());
    doc.fold((_) {
      if (oldPhoto != null) storage.deleteFile(oldPhoto!);
    }, identityNull);
    return doc;
  }

  FutureReport<List<AppUser>> getStaffs() async {
    return await db.getList(AWConst.collections.users).convert((docs) => docs.convertDoc(AppUser.fromDoc));
  }

  FutureReport<Unit> checkEmailAvailability(String email) async {
    final (err, docs) = await db.getList(AWConst.collections.users, queries: [Query.equal('email', email)]).toRecord();

    if (err != null || docs == null) return left(err ?? const Failure('Error checking email availability'));

    if (docs.total > 0) return failure('This email already exists');
    return right(unit);
  }

  FutureReport<AppUser?> getNotCreatedStaff(String email, String pass) async {
    final hash = hashPass(pass);
    final users = await db
        .getList(
          AWConst.collections.users,
          queries: [Query.equal('password', hash), Query.equal('is_user_created', false), Query.equal('email', email)],
        )
        .convert((r) => r.convertDoc(AppUser.fromDoc));

    return users.convert((r) => r.firstOrNull);
  }
}
