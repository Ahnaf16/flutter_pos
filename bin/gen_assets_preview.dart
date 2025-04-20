// ignore_for_file: depend_on_referenced_packages

import 'dart:io';

import 'package:path/path.dart' show join;

void log(Object? o) => stdout.writeln(o);

const String _start = '  /// File path: ';
const String _end = '.svg';

bool _startsAndEndWith(String line) =>
    line.startsWith(_start) && line.endsWith(_end);

void main(List<String> args) async {
  final assetsFile = File('lib/_core/strings/assets.gen.dart');

  if (!assetsFile.existsSync()) return log('assets file not found');

  final content = await assetsFile.readAsString();
  final lines = content.split('\n');
  int count = 0;
  for (var line in lines) {
    if (_startsAndEndWith(line)) {
      final path = line.substring(_start.length);
      final absolutePath = join(Directory.current.path, path);
      final htmlDartDoc = _toHtml(absolutePath);
      lines[lines.indexOf(line)] = htmlDartDoc;
      count++;
    }
  }

  await assetsFile.writeAsString(lines.join('\n'));

  log('Replaced $count docs');
}

String _toHtml(String path) => '/// <img src="$path" width="50" height="50"/>';
