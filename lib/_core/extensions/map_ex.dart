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

  String parseAwField([String key = 'id']) {
    return tryParseAwField(key) ?? '';
  }

  String? tryParseAwField([String key = 'id']) {
    final it = this[key] ?? this['\$$key'];
    if (it is String) return it;

    return null;
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
      {'data': final List data} => List<T>.from(data.map((m) => mapper(m))),
      final List data => List<T>.from(data.map((m) => mapper(m))),
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

extension FlattenMapExtension on Map<String, dynamic> {
  /// Flatten map, keeping the key paths (e.g., a.b.c)
  Map<String, dynamic> flatten() {
    return _flatten(this);
  }

  Map<String, dynamic> _flatten(Map<String, dynamic> map, [String prefix = '']) {
    final result = <String, dynamic>{};

    map.forEach((key, value) {
      final newKey = prefix.isEmpty ? key : '$prefix.$key';
      if (value is Map<String, dynamic>) {
        result.addAll(_flatten(value, newKey));
      } else {
        result[newKey] = value;
      }
    });

    return result;
  }

  /// Flatten map, merging all keys without path (might overwrite keys if same name exists)
  Map<String, dynamic> flattenSimple() {
    return _flattenSimple(this);
  }

  Map<String, dynamic> _flattenSimple(Map<String, dynamic> map) {
    final result = <String, dynamic>{};

    map.forEach((key, value) {
      if (value is Map<String, dynamic>) {
        result.addAll(_flattenSimple(value));
      } else {
        result[key] = value;
      }
    });

    return result;
  }
}

extension UnflattenedMapExtension on Map<String, dynamic> {
  /// unflattened a map (e.g., turns 'stock.purchase_price' into {stock: {purchase_price: value}})
  Map<String, dynamic> unflattened() {
    final result = <String, dynamic>{};

    forEach((key, value) {
      final parts = key.split('.');
      Map<String, dynamic> current = result;

      for (var i = 0; i < parts.length; i++) {
        final part = parts[i];

        if (i == parts.length - 1) {
          current[part] = value;
        } else {
          current = current.putIfAbsent(part, () => <String, dynamic>{}) as Map<String, dynamic>;
        }
      }
    });

    return result;
  }
}
