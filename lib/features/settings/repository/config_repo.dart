import 'package:appwrite/models.dart';
import 'package:pos/main.export.dart';

class ConfigRepo with AwHandler {
  FutureReport<Config> getConfig() async {
    return await db.get(AWConst.collections.config, AWConst.docs.config.id).convert(Config.fromDoc);
  }

  FutureReport<Document> updateConfig(Config data) async {
    return await db.update(AWConst.collections.config, AWConst.docs.config.id, data: data.toAwPost());
  }
}
