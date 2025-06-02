import 'package:pos/main.export.dart';

extension StringEx on String {
  int get asInt => isEmpty ? 0 : int.tryParse(this) ?? 0;

  double get asDouble => double.tryParse(this) ?? 0.0;

  String showUntil(int end, [int start = 0]) {
    return length >= end ? '${substring(start, end)}...' : this;
  }

  String ifEmpty([String onEmpty = 'EMPTY']) {
    return isEmpty ? onEmpty : this;
  }

  /// Gracefully handles null values, and skips the suffix when null
  String safeGet([String? suffix]) {
    return this + (isNotEmpty ? (suffix ?? '') : '');
  }

  bool get isValidEmail {
    final reg = RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+");
    return reg.hasMatch(this);
  }

  String get low => toLowerCase();
  String get up => toUpperCase();
}

extension ValueEx on ValueNotifier<bool> {
  void toggle() => value = !value;

  void falsey() => value = false;
  void truthy() => value = true;
}

extension ValueTEx<T> on ValueNotifier<T> {
  void set(T value) => this.value = value;
}

NumberFormat currencyFormate({num? value, bool compact = false}) {
  final symbol = locate<SP>().currencySymbol.value ?? Config.def().currencySymbol;
  final onLeft = locate<SP>().symbolOnLeft.value ?? Config.def().symbolLeft;

  if (compact) {
    return NumberFormat.compactCurrency(symbol: symbol);
  }

  final String pattern = onLeft ? '$symbol##,##,##,##,##0' : '##,##,##,##,##0$symbol';
  return NumberFormat.currency(customPattern: pattern, decimalDigits: value is int ? 0 : 2);
}

extension NumEx on num {
  String readableByte([int? decimals]) => Parser.formatBytes(toInt(), decimals ?? 2);

  String currency() {
    return currencyFormate(value: this).format(this);
  }

  num get clean => this is double && this % 1 == 0 ? toInt() : this;

  bool get isDecimal => this is double && this % 1 != 0;

  String twoDigits([String padWith = '0']) => toString().padLeft(2, padWith);
}

extension EnumByName<T extends Enum> on Iterable<T> {
  T? tryByName(dynamic name) {
    for (final value in this) {
      if (value.name == name) return value;
    }

    return null;
  }

  List<String> names() => map((e) => e.name).toList();
}
