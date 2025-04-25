import 'package:pos/main.export.dart';

typedef Result = (bool success, String msg);

Result leftResult(Failure f) => (false, f.message);

Result rightResult(String msg) => (true, msg);

extension ResultX on Result {
  bool get success => this.$1;
  String get msg => this.$2;

  Result showToast(BuildContext context) {
    if (success) {
      context.showToast(msg);
    } else {
      context.showErr(msg);
    }
    return this;
  }
}
