import 'package:collection/collection.dart';

import '../../main.export.dart';

extension MapEx<K, V> on Map<K, V> {
  V? firstNoneNull() => isEmpty ? null : values.firstWhereOrNull((e) => e != null);

  V? valueOrFirst(String? key, String? defKey, [V? defaultValue]) {
    return this[key] ?? this[defKey] ?? defaultValue;
  }

  Map<String, V> toStringKey() => map((k, v) => MapEntry('$k', v));

  int parseInt(K key, [int fallBack = 0]) {
    final it = this[key];
    return Parser.toInt(it) ?? fallBack;
  }

  double parseDouble(String key, {double fallBack = 0.0, bool fixed = true}) {
    final it = this[key];
    return Parser.toDouble(it, fixed) ?? fallBack;
  }

  num parseNum(String key, {num fallBack = 0, bool fixed = true}) {
    final it = this[key];
    return Parser.toNum(it, fixed) ?? fallBack;
  }

  bool parseBool<T>(String key, [bool onNull = false]) {
    final it = this[key];
    return Parser.toBool(it) ?? onNull;
  }

  DateTime? parseDate<T>(String key) => Parser.tryDate(this[key]);

  V? notNullOrEmpty(K key) {
    final it = this[key];
    if (it == null) return null;
    if (it is String && it.isEmpty) return null;
    if (it is List && it.isEmpty) return null;
    if (it is Map && it.isEmpty) return null;

    return it;
  }

  String printMap() {
    String str = '';
    forEach((key, value) => str += '$key: ${value.toString}, ');
    return str;
  }

  /// Split the path by dots (.)
  V? get(String path) {
    if (!path.contains('.')) return this[path];

    final keys = path.split('.');
    dynamic value = map;

    for (String key in keys) {
      if (value is Map && value.containsKey(key)) {
        value = value[key];
      } else {
        return null;
      }
    }

    return value;
  }

  List<T> mapList<T>(String k, T Function(QMap map) mapper) {
    return switch (this[k]) {
      {'data': List data} => List<T>.from(data.map((m) => mapper(m))),
      List data => List<T>.from(data.map((m) => mapper(m))),
      _ => <T>[],
    };
  }

  Map<K, T> transformValues<T>(T Function(K key, V value) mapper) {
    return map((key, value) => MapEntry(key, mapper(key, value)));
  }
}

extension RemoveNull<K, V> on Map<K, V?> {
  Map<K, V> removeNull() {
    final result = {...this}..removeWhere((_, v) => v == null);
    return result.map((key, value) => MapEntry(key, value as V));
  }

  Map<K, V> removeNullAndEmpty() {
    final it = removeNull();
    final result =
        it..removeWhere(
          (k, v) => switch (v) {
            _ when v is String && v.isEmpty => true,
            _ when v is List && v.isEmpty => true,
            _ when v is Map && v.isEmpty => true,
            _ => false,
          },
        );
    return result.map((key, value) => MapEntry(key, value));
  }
}
