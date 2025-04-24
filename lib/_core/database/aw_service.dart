import 'dart:io';

import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart';
import 'package:fpdart/fpdart.dart';
import 'package:pos/main.export.dart';

export 'package:appwrite/appwrite.dart' show ID;

part 'aw_helper.dart';

mixin AwHandler {
  final account = locate<Account>();
  final storage = locate<AwStorage>();
  final db = locate<AwDatabase>();

  FutureReport<T> handler<T>({required Future<T> Function() call}) async {
    return await _handler<T>(call: call);
  }
}

class AwDatabase {
  final _db = locate<Databases>();

  FutureReport<Document> create(AwId collId, String docId, {required Map data}) async {
    catAw({'collId': collId.id, 'docId': docId, 'data': data}, '${collId.name} create');
    return await _handler<Document>(
      call: () async {
        final doc = await _db.createDocument(
          databaseId: AWConst.databaseId.id,
          collectionId: collId.id,
          documentId: ID.unique(),
          data: data,
        );
        catAw(doc.toMap(), '${collId.name} created');
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
          queries: queries,
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
}

class AwStorage {
  final _storage = locate<Storage>();

  FutureReport<File> createFile(String name, String path, {Function(UploadProgress)? onProgress}) async {
    catAw({'name': name, 'path': path}, 'Creating File');

    return await _handler<File>(
      call: () async {
        final file = await _storage.createFile(
          bucketId: AWConst.storageId.id,
          fileId: ID.unique(),
          file: InputFile.fromPath(path: path, filename: name),
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
        await _storage.deleteFile(bucketId: AWConst.storageId.id, fileId: ID.unique());
        return unit;
      },
      errorMsg: 'Error deleting file',
    );
  }

  String buildUrl(String id) {
    if (id.startsWith('http')) return id;

    final parts = [
      AWConst.endpoint,
      'storage/buckets',
      AWConst.storageId.id,
      'files',
      id,
      'view?project=${AWConst.projectId.id}',
    ];
    return parts.join('/');
  }
}
