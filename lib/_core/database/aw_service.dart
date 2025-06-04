import 'dart:io';

import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart';
import 'package:flutter/foundation.dart';
import 'package:fpdart/fpdart.dart';
import 'package:pos/main.export.dart';

export 'package:appwrite/appwrite.dart' show ID;

part 'aw_helper.dart';

mixin AwHandler {
  final account = locate<AwAccount>();
  final storage = locate<AwStorage>();
  final db = locate<AwDatabase>();

  FutureReport<T> handler<T>({required Future<T> Function() call}) async {
    return await _handler<T>(call: call);
  }
}

class AwDatabase {
  final _db = locate<Databases>();

  FutureReport<Document> create(AwId collId, {required Map data, String? docId, List<String>? permissions}) async {
    final documentId = docId ?? ID.unique();

    catAw({'collId': collId.id, 'docId': documentId, 'data': data}, '${collId.name} create');

    return await _handler<Document>(
      call: () async {
        final doc = await _db.createDocument(
          databaseId: AWConst.databaseId.id,
          collectionId: collId.id,
          documentId: documentId,
          data: data,
          permissions: permissions,
        );
        catAw(doc.toMap(), '${collId.name} created');
        return doc;
      },
      errorMsg: 'Error creating document ${collId.name}',
    );
  }

  FutureReport<Document> update(AwId collId, String docId, {required Map data, List<String>? permissions}) async {
    catAw({'collId': collId.id, 'docId': docId, 'data': data}, '${collId.name} update');
    return await _handler<Document>(
      call: () async {
        final doc = await _db.updateDocument(
          databaseId: AWConst.databaseId.id,
          collectionId: collId.id,
          documentId: docId,
          data: data,
          permissions: permissions,
        );
        catAw(doc.toMap(), '${collId.name} updated');
        return doc;
      },
      errorMsg: 'Error creating document ${collId.name}',
    );
  }

  FutureReport<DocumentList> getList(AwId collId, {List<String>? queries}) async {
    catAw({'collId': collId.id, 'queries': queries}, '${collId.name} get List');
    return await _handler<DocumentList>(
      call: () async {
        final list = await _db.listDocuments(
          databaseId: AWConst.databaseId.id,
          collectionId: collId.id,
          queries: [...?queries, Query.orderDesc(r'$createdAt')],
        );
        catAw(list.toMap(), '${collId.name} list');
        return list;
      },
      errorMsg: 'Not found ${collId.name}',
    );
  }

  FutureReport<Document> get(AwId collId, String docId, {List<String>? queries}) async {
    catAw({'collId': collId.id, 'docId': docId, 'queries': queries}, '${collId.name} get');

    return await _handler<Document>(
      call: () async {
        final data = await _db.getDocument(
          databaseId: AWConst.databaseId.id,
          collectionId: collId.id,
          documentId: docId,
          queries: queries,
        );
        catAw(data.toMap(), collId.name);
        return data;
      },
      errorMsg: 'Not found ${collId.name} $docId',
    );
  }

  FutureReport<Unit> delete(AwId collId, String docId) async {
    catAw({'collId': collId.id, 'docId': docId}, '${collId.name} delete');

    return await _handler<Unit>(
      call: () async {
        await _db.deleteDocument(databaseId: AWConst.databaseId.id, collectionId: collId.id, documentId: docId);
        catAw('${collId.name} :: $docId deleted');
        return unit;
      },
      errorMsg: 'Not found ${collId.name} $docId',
    );
  }
}

class AwStorage {
  final _storage = locate<Storage>();

  FutureReport<File> createFile(PFile file, {Function(UploadProgress)? onProgress}) async {
    catAw({'name': file.name, 'path': file.path}, 'Creating File');

    InputFile inputFile;

    if (kIsWeb) {
      final b = file.bytes;
      if (b == null) return failure('Unable to read file');
      inputFile = InputFile.fromBytes(bytes: b, filename: file.name);
    } else {
      final p = file.path;
      if (p == null) return failure('Unable to read file');
      inputFile = InputFile.fromPath(path: p, filename: file.name);
    }

    return await _handler<File>(
      call: () async {
        final file = await _storage.createFile(
          bucketId: AWConst.storageId.id,
          fileId: ID.unique(),
          file: inputFile,
          onProgress: onProgress,
        );
        catAw(file.toMap(), 'File Created');
        return file;
      },
      errorMsg: 'Error creating file',
    );
  }

  FutureReport<Unit> deleteFile(String id) async {
    catAw('Deleting File $id', 'Delete File');

    return await _handler<Unit>(
      call: () async {
        await _storage.deleteFile(bucketId: AWConst.storageId.id, fileId: id);
        return unit;
      },
      errorMsg: 'Error deleting file',
    );
  }

  Future<Uint8List> imgPreview(String id) async {
    return await _storage.getFileView(bucketId: AWConst.storageId.id, fileId: id);
  }

  Future<Uint8List> download(String id) async {
    return await _storage.getFileDownload(bucketId: AWConst.storageId.id, fileId: id);
  }
}

class AwAccount {
  final account = locate<Account>();

  FutureReport<User> create({
    required String userId,
    required String email,
    required String password,
    String? name,
  }) async {
    catAw({'userId': userId, 'email': email, 'name': name, 'password': password}, 'create account');
    return await _handler<User>(
      call: () async {
        final data = await account.create(userId: userId, email: email, password: password);
        catAw(data.toMap(), 'Account created');
        return data;
      },
      errorMsg: 'Error creating account',
    );
  }

  FutureReport<Session> createSession(String email, String password) async {
    catAw({'email': email, 'password': password}, 'create session');

    return await _handler<Session>(
      call: () async {
        final data = await account.createEmailPasswordSession(email: email, password: password);
        catAw(data.toMap(), 'Session created');
        return data;
      },
      errorMsg: 'Error creating Session',
    );
  }

  FutureReport<Unit> deleteSessions() async {
    catAw('Deleting session', 'Account');
    return await _handler<Unit>(
      call: () async {
        await account.deleteSessions();
        return unit;
      },
      errorMsg: 'Error deleting Session',
    );
  }

  FutureReport<User> user() async {
    catAw('Getting current user', 'Account');
    return await _handler<User>(call: () async => account.get(), errorMsg: 'Error getting user');
  }
}
