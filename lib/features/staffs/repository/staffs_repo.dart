import 'package:appwrite/models.dart';
import 'package:pos/main.export.dart';

class StaffRepo with AwHandler {
  FutureReport<Document> createStaff(String password, QMap form) async {
    final data = QMap.from(form);
    final user = AppUser.fromMap(data);

    // final photoPath = user.photo;

    // if (photoPath != null) {
    //   final xFile = XFile(photoPath);
    //   final file = await storage.createFile(xFile.name, xFile.path);

    //   String? error;

    //   file.fold((l) => error = l.message, (r) => data['photo'] = storage.buildUrl(r.$id));

    //   if (error != null) return failure(error ?? 'Error uploading photo');
    // }

    final newUser = await account.create(userId: ID.unique(), email: user.email, password: password, name: user.name);
    cat(newUser.toMap(), 'New User');

    // final doc = await db.create(AWConst.collections.users, newUser.$id, data: data);
    // doc.fold((_) {
    //   storage.deleteFile(data['photo']);
    // }, identityNull);
    // return doc;
    return failure('test');
  }

  FutureReport<List<AppUser>> getStaffs() async {
    return await db.getList(AWConst.collections.users).convert((docs) => docs.convertDoc(AppUser.fromDoc));
  }
}
