import 'package:pos/main.export.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'home_ctrl.g.dart';

@Riverpod(keepAlive: true)
class ViewingWH extends _$ViewingWH {
  Future<void> updateHouse(WareHouse? house) async {
    state = house;
  }

  @override
  WareHouse? build() {
    return null;
  }
}
