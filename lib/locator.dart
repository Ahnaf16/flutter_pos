import 'package:appwrite/appwrite.dart';
import 'package:get_it/get_it.dart';
import 'package:pos/features/auth/repository/auth_repo.dart';
import 'package:pos/features/due/repository/due_repo.dart';
import 'package:pos/features/expense/repository/expense_repo.dart';
import 'package:pos/features/inventory_record/repository/inventory_repo.dart';
import 'package:pos/features/inventory_record/repository/return_repo.dart';
import 'package:pos/features/parties/repository/parties_repo.dart';
import 'package:pos/features/payment_accounts/repository/payment_accounts_repo.dart';
import 'package:pos/features/products/repository/products_repo.dart';
import 'package:pos/features/settings/repository/config_repo.dart';
import 'package:pos/features/staffs/repository/staffs_repo.dart';
import 'package:pos/features/stock/repository/stock_repo.dart';
import 'package:pos/features/transactions/repository/transactions_repo.dart';
import 'package:pos/features/unit/repository/unit_repo.dart';
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

  final client = Client(endPoint: AWConst.endpoint, selfSigned: true);
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
  locate.registerLazyIfAbsent<AwAccount>(AwAccount.new);

  locate.registerLazyIfAbsent<ConfigRepo>(ConfigRepo.new);
  locate.registerLazyIfAbsent<AuthRepo>(AuthRepo.new);
  locate.registerLazyIfAbsent<StaffRepo>(StaffRepo.new);
  locate.registerLazyIfAbsent<WarehouseRepo>(WarehouseRepo.new);
  locate.registerLazyIfAbsent<UserRolesRepo>(UserRolesRepo.new);
  locate.registerLazyIfAbsent<ProductRepo>(ProductRepo.new);
  locate.registerLazyIfAbsent<ProductUnitRepo>(ProductUnitRepo.new);
  locate.registerLazyIfAbsent<StockRepo>(StockRepo.new);
  locate.registerLazyIfAbsent<PartiesRepo>(PartiesRepo.new);
  locate.registerLazyIfAbsent<InventoryRepo>(InventoryRepo.new);
  locate.registerLazyIfAbsent<PaymentAccountsRepo>(PaymentAccountsRepo.new);
  locate.registerLazyIfAbsent<DueRepo>(DueRepo.new);
  locate.registerLazyIfAbsent<TransactionsRepo>(TransactionsRepo.new);
  locate.registerLazyIfAbsent<ExpenseRepo>(ExpenseRepo.new);
  locate.registerLazyIfAbsent<ReturnRepo>(ReturnRepo.new);
}
