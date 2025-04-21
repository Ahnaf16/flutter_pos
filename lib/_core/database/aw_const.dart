typedef AwId = (String id, String name);

extension AwIdX on AwId {
  String get id => this.$1;
  String get name => this.$2;
}

class AWConst {
  const AWConst._();

  static const String endpoint = 'https://fra.cloud.appwrite.io/v1';
  static const AwId projectId = ('68048fb0003cd8a04477', 'flutter_pos');
  static const AwId databaseId = ('6805362c0032bd189cd2', '');
  static const AwId storageId = ('68053f7b0023347615c2', 'pos_bucket');

  static $AWCollections collections = $AWCollections();
}

class $AWCollections {
  AwId get users => ('680536a4003be2a282af', 'users');

  List<AwId> get values => [users];
}
