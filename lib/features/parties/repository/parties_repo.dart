import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart';
import 'package:pos/main.export.dart';

class PartiesRepo with AwHandler {
  FutureReport<Document> createParti(QMap form, PFile? xfile) async {
    Parti parti = Parti.fromMap(form);

    if (xfile != null) {
      final file = await storage.createFile(xfile);

      String? error;

      file.fold((l) => error = l.message, (r) => parti = parti.copyWith(photo: () => r.$id));

      if (error != null) return failure(error ?? 'Error uploading photo');
    }

    final doc = await db.create(AWConst.collections.parties, data: parti.toAwPost());
    doc.fold((_) {
      if (parti.photo != null) storage.deleteFile(parti.photo!);
    }, identityNull);
    return doc;
  }

  FutureReport<Document> updateParti(Parti parti, [PFile? photo]) async {
    String? oldPhoto;
    if (photo != null) {
      final file = await storage.createFile(photo);
      String? error;
      file.fold((l) => error = l.message, (r) {
        oldPhoto = parti.photo;
        parti = parti.copyWith(photo: () => r.$id);
      });

      if (error != null) return failure(error ?? 'Error uploading photo');
    }

    final doc = await db.update(AWConst.collections.parties, parti.id, data: parti.toAwPost());
    if (oldPhoto != null) await storage.deleteFile(oldPhoto!);
    return doc;
  }

  FutureReport<List<Parti>> getParties(List<PartiType>? type) async {
    return await db
        .getList(
          AWConst.collections.parties,
          queries: [if (type != null) Query.equal('type', type.map((e) => e.name).toList())],
        )
        .convert((docs) => docs.convertDoc(Parti.fromDoc));
  }

  FutureReport<Parti> getPartiById(String id) async {
    return await db.get(AWConst.collections.parties, id).convert(Parti.fromDoc);
  }
}
