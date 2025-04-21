import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart';
import 'package:fpdart/fpdart.dart';
import 'package:pos/main.export.dart';

class _AwDatabase {
  final _db = locate<Databases>();

  FutureReport<Document> _create(AwId collId, {required Map data}) async {
    try {
      final doc = await _db.createDocument(
        databaseId: AWConst.databaseId.id,
        collectionId: collId.id,
        documentId: ID.unique(),
        data: data,
      );
      return right(doc);
    } on AppwriteException catch (e, s) {
      return failure(e.message ?? 'Error creating document ${collId.name}', s: s, e: e);
    } catch (e, s) {
      return failure('Error creating document ${collId.name}', s: s, e: e);
    }
  }

  FutureReport<DocumentList> _geList(AwId collId, {List<String>? queries}) async {
    try {
      final documents = await _db.listDocuments(
        databaseId: AWConst.databaseId.id,
        collectionId: collId.id,
        queries: queries,
      );
      return right(documents);
    } on AppwriteException catch (e, s) {
      return failure(e.message ?? 'Error creating document ${collId.name}', s: s, e: e);
    } catch (e, s) {
      return failure('Error creating document ${collId.name}', s: s, e: e);
    }
  }
}

class AwService {
  final _db = _AwDatabase();

  FutureReport<Document> createUser({required Map data}) async {
    return await _db._create(AWConst.collections.users, data: data);
  }
}
