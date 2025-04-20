import 'package:get_it/get_it.dart';
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
  //? SP
  final sp = await SP.getInstance();
  locate.registerSingletonIfAbsent<SP>(() => sp);
  //? SP
}
