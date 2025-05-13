import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart';
import 'package:fpdart/fpdart.dart';
import 'package:pos/features/due/repository/due_repo.dart';
import 'package:pos/main.export.dart';

class PartiesRepo with AwHandler {
  final _coll = AWConst.collections.parties;

  FutureReport<Document> createParti(QMap form, PFile? xfile) async {
    Party parti = Party.fromMap(form);

    if (xfile != null) {
      final file = await storage.createFile(xfile);

      String? error;

      file.fold((l) => error = l.message, (r) => parti = parti.copyWith(photo: () => r.$id));

      if (error != null) return failure(error ?? 'Error uploading photo');
    }

    final doc = await db.create(_coll, data: parti.toAwPost());
    doc.fold((_) {
      if (parti.photo != null) storage.deleteFile(parti.photo!);
    }, identityNull);
    return doc;
  }

  FutureReport<Document> updateParti(Party parti, [PFile? photo]) async {
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

    final doc = await db.update(_coll, parti.id, data: parti.toAwPost());
    if (oldPhoto != null) await storage.deleteFile(oldPhoto!);
    return doc;
  }

  FutureReport<Document> updateDue(Party parti, num amount, bool isAdd, [String? note]) async {
    final (err, doc) = await updateParti(parti.copyWith(due: parti.due + amount)).toRecord();
    if (err != null || doc == null) return left(err ?? const Failure('Error updating due'));
    await locate<DueRepo>().addDueLog(parti, amount, isAdd, note);
    return right(doc);
  }

  FutureReport<List<Party>> getParties(List<PartiType>? type) async {
    return await db
        .getList(_coll, queries: [if (type != null) Query.equal('type', type.map((e) => e.name).toList())])
        .convert((docs) => docs.convertDoc(Party.fromDoc));
  }

  FutureReport<Party> getPartiById(String id) async {
    return await db.get(_coll, id).convert(Party.fromDoc);
  }

  FutureReport<Unit> checkAvailability(String phone) async {
    final (err, docs) = await db.getList(_coll, queries: [Query.equal('phone', phone)]).toRecord();

    if (err != null || docs == null) return left(err ?? const Failure('Error checking phone availability'));

    if (docs.total > 0) return failure('This phone number already exists');
    return right(unit);
  }
}
