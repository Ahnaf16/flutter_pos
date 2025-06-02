import 'package:appwrite/models.dart';
import 'package:fpdart/fpdart.dart';
import 'package:pos/main.export.dart';

class ConfigRepo with AwHandler {
  FutureReport<Config> getConfig() async {
    return await db.get(AWConst.collections.config, AWConst.docs.config.id).convert(Config.fromDoc);
  }

  FutureReport<Document> updateConfig(Config data, [PFile? image]) async {
    String? oldPhoto;

    if (image != null) {
      final (err, file) = await storage.createFile(image).toRecord();
      if (err != null || file == null) return left(err ?? const Failure('Error uploading photo'));

      oldPhoto = data.shop.shopLogo;
      data = data.copyWith(shop: data.shop.copyWith(shopLogo: () => file.$id));
    }

    final doc = await db.update(AWConst.collections.config, AWConst.docs.config.id, data: data.toAwPost());
    if (oldPhoto != null) await storage.deleteFile(oldPhoto);
    return doc;
  }
}

class FileRepo with AwHandler {
  FutureReport<AwFile> createNew(PFile file) async {
    final (err, sFile) = await storage.createFile(file).toRecord();
    if (err != null || sFile == null) return left(err ?? const Failure('Error uploading file'));

    final data = AwFile.fromFile(sFile.$id, file);

    final doc = await db.create(AWConst.collections.files, docId: sFile.$id, data: data.toAwPost());

    if (doc.isLeft()) {
      await storage.deleteFile(sFile.$id);
    }
    return doc.convert(AwFile.fromDoc);
  }
}
