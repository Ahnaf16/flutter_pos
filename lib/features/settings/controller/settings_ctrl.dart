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

  FVoid init() async {
    final (err, config) = await _repo.getConfig().toRecord();

    if (config != null) {
      final sp = locate<SP>();
      await sp.currencySymbol.setValue(config.currencySymbol);
      await sp.symbolOnLeft.setValue(config.symbolLeft);

      state = config;
    }
  }
}
