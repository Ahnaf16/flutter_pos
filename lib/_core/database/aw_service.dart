import 'dart:io';

import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart';
import 'package:fpdart/fpdart.dart';
import 'package:pos/main.export.dart';

mixin AwHandler {
  FutureReport<T> handler<T>({required Future<T> Function() call}) async {
    Failure? failure;
    try {
      return right(await call());
    } on SocketException catch (e, st) {
      failure = Failure(e.message, error: e, stackTrace: st);
    } on AppwriteException catch (e, st) {
      failure = Failure(e.message ?? 'Error', error: e, stackTrace: st);
    } on Failure catch (e, st) {
      failure = e.copyWith(stackTrace: st);
    } catch (e, st) {
      failure = Failure('$e', error: e, stackTrace: st);
    } finally {
      if (failure != null) catErr('AwHandler', failure.message);
    }
    return left(failure);
  }
}

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
