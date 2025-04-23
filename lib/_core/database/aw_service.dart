import 'dart:io';

import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart';
import 'package:fpdart/fpdart.dart';
import 'package:pos/main.export.dart';

export 'package:appwrite/appwrite.dart' show ID;

mixin AwHandler {
  final account = locate<Account>();
  // final db = locate<Databases>();
  final db = locate<AwService>();

  FutureReport<T> handler<T>({required Future<T> Function() call}) async {
    return await _AwDatabase()._handler<T>(call: call);
  }
}

class _AwDatabase {
  final _db = locate<Databases>();

  FutureReport<T> _handler<T>({required Future<T> Function() call, String? errorMsg}) async {
    Failure? failure;
    try {
      return right(await call());
    } on SocketException catch (e, st) {
      failure = Failure(e.message, error: e, stackTrace: st);
    } on AppwriteException catch (e, st) {
      failure = Failure(e.message ?? errorMsg ?? kError('AwHandler'), error: e, stackTrace: st);
    } on Failure catch (e, st) {
      failure = e.copyWith(stackTrace: st);
    } catch (e, st) {
      failure = Failure(errorMsg ?? '$e', error: e, stackTrace: st);
    } finally {
      if (failure != null) catErr('AwHandler', failure.message);
    }
    return left(failure);
  }

  FutureReport<Document> _create(AwId collId, String docId, {required Map data}) async {
    return await _handler<Document>(
      call: () async {
        return await _db.createDocument(
          databaseId: AWConst.databaseId.id,
          collectionId: collId.id,
          documentId: ID.unique(),
          data: data,
        );
      },
      errorMsg: 'Error creating document ${collId.name}',
    );
  }

  FutureReport<DocumentList> _getList(AwId collId, {List<String>? queries}) async {
    return await _handler<DocumentList>(
      call: () async {
        return await _db.listDocuments(databaseId: AWConst.databaseId.id, collectionId: collId.id, queries: queries);
      },
      errorMsg: 'Not found ${collId.name}',
    );
  }

  FutureReport<Document> _get(AwId collId, String docId, {List<String>? queries}) async {
    cat({'collId': collId.id, 'docId': docId, 'queries': queries}, 'AwDatabase._get');
    return await _handler<Document>(
      call: () async {
        return await _db.getDocument(
          databaseId: AWConst.databaseId.id,
          collectionId: collId.id,
          documentId: docId,
          queries: queries,
        );
      },
      errorMsg: 'Not found ${collId.name} $docId',
    );
  }
}

class AwService {
  final _db = _AwDatabase();

  FutureReport<Document> createUser({required Map data, String? docId}) async {
    return await _db._create(AWConst.collections.users, docId ?? ID.unique(), data: data);
  }

  FutureReport<DocumentList> getUsers(String id, {List<String>? queries}) async {
    return await _db._getList(AWConst.collections.users, queries: queries);
  }

  FutureReport<AppUser> getUser(String? id) async {
    if (id == null) return failure('User ID cannot be null');
    return await _db._get(AWConst.collections.users, id).convert(AppUser.fromDoc);
  }
}
