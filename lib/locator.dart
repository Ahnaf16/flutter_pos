import 'package:appwrite/appwrite.dart';
import 'package:get_it/get_it.dart';
import 'package:pos/features/auth/repository/auth_repo.dart';
import 'package:pos/features/staffs/repository/staffs_repo.dart';
import 'package:pos/features/user_roles/repository/user_roles_repo.dart';
import 'package:pos/features/warehouse/repository/warehouse_repo.dart';
import 'package:pos/main.export.dart';

extension GetItEX on GetIt {
  void registerLazyIfAbsent<T extends Object>(T Function() factoryFunc) {
    if (!isRegistered<T>()) registerLazySingleton(factoryFunc);
  }

  void registerLazyAsyncIfAbsent<T extends Object>(Future<T> Function() f) {
    if (!isRegistered<T>()) registerLazySingletonAsync(f);
  }
}

final locate = GetIt.instance;

final fileUtil = locate<FileUtil>();

Future<void> initDependencies() async {
  final sp = await SP.getInstance();

  final client = Client(endPoint: AWConst.endpoint);
  client.setProject(AWConst.projectId.id).setSelfSigned();

  final account = Account(client);
  final databases = Databases(client);
  final storage = Storage(client);

  locate.registerSingletonIfAbsent<SP>(() => sp);
  locate.registerSingletonIfAbsent<FileUtil>(() => FileUtil());
  locate.registerLazyIfAbsent<Client>(() => client);
  locate.registerLazyIfAbsent<Account>(() => account);
  locate.registerLazyIfAbsent<Databases>(() => databases);
  locate.registerLazyIfAbsent<Storage>(() => storage);
  locate.registerLazyIfAbsent<AwDatabase>(AwDatabase.new);
  locate.registerLazyIfAbsent<AwStorage>(AwStorage.new);

  locate.registerLazyIfAbsent<AuthRepo>(AuthRepo.new);
  locate.registerLazyIfAbsent<StaffRepo>(StaffRepo.new);
  locate.registerLazyIfAbsent<WarehouseRepo>(WarehouseRepo.new);
  locate.registerLazyIfAbsent<UserRolesRepo>(UserRolesRepo.new);
}
