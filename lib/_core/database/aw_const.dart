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
  static $AWDocs docs = $AWDocs();
}

class $AWCollections {
  AwId get config => ('6805c476002d4333ccb1', 'config');
  AwId get expanse => ('6806529f0034aec8d975', 'expanse');
  AwId get inventoryDetails => ('68064a58002fe1687f71', 'inventoryDetails');
  AwId get inventoryReport => ('680628f40031fda735e1', 'inventoryReport');
  AwId get parties => ('680629bf003151f6f6ad', 'parties');
  AwId get paymentAccount => ('68063141003974052255', 'paymentAccount');
  AwId get products => ('6805c655000722776983', 'products');
  AwId get role => ('6805c0c30020316ea3e6', 'role');
  AwId get stock => ('6805dbf9001793b1a019', 'stock');
  AwId get transactions => ('680653b7000d496a9473', 'transactions');
  AwId get unit => ('6805dc02001027cde1e6', 'unit');
  AwId get users => ('680536a4003be2a282af', 'users');
  AwId get warehouse => ('6805bdcd00107f585ff2', 'warehouse');

  List<AwId> get values => [
    config,
    expanse,
    inventoryDetails,
    inventoryReport,
    parties,
    paymentAccount,
    products,
    role,
    stock,
    transactions,
    unit,
    users,
    warehouse,
  ];
}

class $AWDocs {
  AwId get config => ('APP_CONFIG', 'config');

  List<AwId> get values => [config];
}
