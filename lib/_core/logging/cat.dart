import 'dart:developer' as dev;
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

void cat(dynamic msg, [dynamic name]) => Cat._(name?.toString()).log(msg);
void catErr(String name, Object? error, [StackTrace? stackTrace]) => Cat._(name).logErr(error, stackTrace);

class Cat {
  Cat._(this.name);

  final String? name;

  final bool _isDebug = kDebugMode;

  bool get doLog => _isDebug;

  void logErr([Object? err, StackTrace? st]) {
    if (!doLog) return;

    const h = LogHelper(true);
    final sb = StringBuffer();
    sb.writeln(h.start(name));
    sb.writeln(h.jsonMap(1, err));
    if (st != null) {
      sb.writeln(h.start('Stack trace'));
      sb.writeln(h.stackTrace(st));
    }
    sb.writeln(h.end(name));

    if (kDebugMode) {
      dev.log(h.valueParse(sb), name: '\u276f_');
    } else {
      // print(h.valueParse(sb));
    }
  }

  void log(dynamic msg) {
    if (!doLog) return;

    const h = LogHelper(false);
    final sb = StringBuffer();
    sb.writeln(h.start(name));
    sb.writeln(h.jsonMap(1, msg));
    sb.writeln(h.end(name));

    dev.log(h.valueParse(sb), name: '\u276f_');
  }
}

class LogHelper {
  const LogHelper(this.isErr);

  final bool isErr;

  AnsiColor get ansi => AnsiColor();

  String stackTrace(StackTrace stackTrace) {
    StringBuffer buffer = StringBuffer();

    stackTrace.toString().split('\n').forEach((element) {
      buffer.write('$element\n');
    });
    return buffer.toString();
  }

  String jsonMap(int l, dynamic json) {
    StringBuffer buffer = StringBuffer();

    if (json is Map) {
      json.entries.toList().asMap().forEach((index, entry) {
        final isLast = index == json.length - 1;
        final k = entry.key;
        final v = entry.value;

        if (v is Map) {
          final keyPart = '${'  ' * l}${_colorKey(k)}:';
          final vPart = jsonMap(l + 1, v);
          final j = v.isEmpty ? '--' : '\n';
          buffer.write('$keyPart $j$vPart');
        } else if (v is List) {
          final keyPart = '${'  ' * l}${_colorKey(k)}:';
          final vPart = jsonList(l + 1, v);
          final j = v.isEmpty ? '--' : '\n';
          buffer.write('$keyPart $j$vPart');
        }
        //?? file
        // else if (v is FormData) {
        //   buffer.write('${'  ' * l}${_colorKey(k)}:\n${jsonMap(l + 1, v)}');
        // }
        else {
          buffer.write('${'  ' * l}${_keyValue(k, v)}');
        }

        if (!isLast) buffer.write('\n');
      });
    } else if (json is List) {
      buffer.write(jsonList(l, json));
    }
    //?? dio
    //  else if (json is FormData) {
    //   buffer.write(_processFormData(json, l));
    // }
    else {
      buffer.write('${'  ' * l}${_colorValue(json)}');
    }

    return buffer.toString();
  }

  String jsonList(int l, List list) {
    StringBuffer buffer = StringBuffer();

    for (int i = 0; i < list.length; i++) {
      final item = list[i];
      final isLast = i == list.length - 1;
      //?? dio
      if (item is Map || item is List /* || item is FormData */ ) {
        buffer.write('${'  ' * l}-\n${jsonMap(l + 1, item)}');
      } else {
        buffer.write('${'  ' * l}- ${_colorValue(item)}');
      }

      if (!isLast) buffer.write('\n');
    }

    return buffer.toString();
  }

  String valueParse(dynamic value) {
    if (value is String) {
      return _colorValue('"$value"');
    } else if (value is bool || value is num) {
      return _colorValue(value);
    } else if (value == null) {
      return _colorValue('NULL');
    } else if (value is File) {
      return _colorValue('"${value.path}"(FILE)');
    }
    //?? dio
    //  else if (value is MultipartFile) {
    //   return _colorValue('"${value.filename ?? value.toString()}"(MULTIPART)');
    //?? file
    // } else if (value is PlatformFile) {
    //   return _colorValue('"${value.path}"(PLATFORM)');
    // }
    else if (value is DateTime) {
      return _colorValue('"${value.toIso8601String()}"');
    } else {
      return _colorValue('$value');
    }
  }

  String start([String? t]) {
    final dashes = '─' * 30;
    final l = '\n${_line(0, t)}$dashes\n';
    return l;
  }

  String end([String? t]) {
    final dashes = '─' * 30;
    final l = '\n${_line(0, t, '└ ')}$dashes\n';
    return l;
  }

  String kvLine(String key, Object? v) => _line(1, _keyValue(key, v));

  //?? dio
  // String _processFormData(FormData formData, int l) {
  //   String str = '';
  //   for (var field in formData.fields) {
  //     str += '${'  ' * l}${_colorKey(field.key)}: ${_colorValue(field.value)}\n';
  //   }

  //   for (var file in formData.files) {
  //     str +=
  //         '${'  ' * l}${_colorKey(file.key)}: ${_colorValue(file.value.filename ?? file.value.toString())}(MULTIPART)\n';
  //   }

  //   return str;
  // }

  String _keyValue(dynamic key, dynamic value) => '${_colorKey(key)}: ${valueParse(value)}';

  String _line([int layer = 0, String? t, String? p]) {
    final pre = p ?? (layer > 0 ? '├ ' : '┌ ');
    final indent = '  ' * layer;
    return '$indent$pre${t ?? ''} ';
  }

  String _colorKey(dynamic key) => isErr ? ansi.red(key) : ansi.cyan(key);

  String _colorValue(dynamic value) => isErr ? ansi.magenta(value) : ansi.yellow(value);
}

class AnsiColor {
  static const String _black = '\x1B[30m';
  static const String _blue = '\x1B[34m';
  static const String _cyan = '\x1B[36m';
  static const String _green = '\x1B[32m';
  static const String _magenta = '\x1B[35m';
  static const String _red = '\x1B[31m';
  static const String _reset = '\x1B[0m';
  static const String _white = '\x1B[37m';
  static const String _yellow = '\x1B[33m';

  // Color methods
  String black(dynamic v) => '$_black$v$_reset';

  String red(dynamic v) => '$_red$v$_reset';

  String green(dynamic v) => '$_green$v$_reset';

  String yellow(dynamic v) => '$_yellow$v$_reset';

  String blue(dynamic v) => '$_blue$v$_reset';

  String magenta(dynamic v) => '$_magenta$v$_reset';

  String cyan(dynamic v) => '$_cyan$v$_reset';

  String white(dynamic v) => '$_white$v$_reset';

  String color(String text, Color color) => _rgbText(color.r, color.g, color.b, text);

  String _rgbText(double r, double g, double b, String text) => '\x1B[38;2;$r;$g;${b}m$text\x1B[0m';
}
