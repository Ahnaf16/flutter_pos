import 'package:appwrite/appwrite.dart';
import 'package:get_it/get_it.dart';
import 'package:pos/features/auth/repository/auth_repo.dart';
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

Future<void> initDependencies() async {
  final sp = await SP.getInstance();

  final client = Client(endPoint: AWConst.endpoint);
  client.setProject(AWConst.projectId.id).setSelfSigned();

  final account = Account(client);
  final databases = Databases(client);

  locate.registerSingletonIfAbsent<SP>(() => sp);
  locate.registerLazyIfAbsent<Client>(() => client);
  locate.registerLazyIfAbsent<Account>(() => account);
  locate.registerLazyIfAbsent<Databases>(() => databases);
  locate.registerLazyIfAbsent<AwService>(AwService.new);

  locate.registerLazyIfAbsent<AuthRepo>(AuthRepo.new);
}
