import 'package:fpdart/fpdart.dart';
import 'package:pos/features/settings/repository/config_repo.dart';
import 'package:pos/main.export.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'settings_ctrl.g.dart';

@Riverpod(keepAlive: true)
class ConfigCtrl extends _$ConfigCtrl {
  final _repo = locate<ConfigRepo>();
  @override
  Config build() {
    init();
    return Config.def();
  }

  Future<Config> init() async {
    final (err, config) = await _repo.getConfig().toRecord();

    if (config != null) {
      final sp = locate<SP>();
      await sp.currencySymbol.setValue(config.currencySymbol);
      await sp.symbolOnLeft.setValue(config.symbolLeft);

      state = config;
    }
    return state;
  }

  FVoid checkAccount() async {
    final config = await init();
    final acc = config.defAccount;
    if (acc != null && !acc.isActive) {
      await _repo.updateConfig(config.copyWith(defAccount: () => null));
      await init();
      ref.invalidate(configCtrlAsyncProvider);
    }
  }

  Future<Result> updateConfig(QMap formData) async {
    final user = state.marge(formData);

    final res = await _repo.updateConfig(user);
    return res.fold(leftResult, (r) {
      ref.invalidateSelf();
      return rightResult('Settings updated successfully');
    });
  }
}

@Riverpod(keepAlive: true)
class ConfigCtrlAsync extends _$ConfigCtrlAsync {
  final _repo = locate<ConfigRepo>();
  @override
  FutureOr<Config> build() async {
    final res = await _repo.getConfig();
    return res.fold(failToErr, identity);
  }

  Future<Result> updateConfig(Config data, [PFile? image]) async {
    final res = await _repo.updateConfig(data, image);
    return res.fold(leftResult, (r) {
      ref.invalidateSelf();
      ref.invalidate(configCtrlProvider);
      return rightResult('Settings updated successfully');
    });
  }
}
