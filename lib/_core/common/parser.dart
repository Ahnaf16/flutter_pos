import 'dart:math';

import 'package:pos/main.export.dart';

class Parser {
  static int? toInt(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }

  static double? toDouble(dynamic value, [bool fixed = true]) {
    if (value == null) return null;
    double? parsedValue;

    if (value is num) {
      parsedValue = value.toDouble();
    } else if (value is String) {
      parsedValue = double.tryParse(value);
    }

    return parsedValue;
  }

  static num? toNum(dynamic value, [bool fixed = true]) {
    if (value == null) return null;
    num? parsedValue;

    if (value is num) {
      parsedValue = value.toDouble();
    } else if (value is String) {
      parsedValue = num.tryParse(value);
    }

    return parsedValue;
  }

  static bool? toBool(dynamic value) {
    if (value is bool) return value;
    if (value == null) return null;

    if (value == '1' || value == 1) return true;
    if (value == '0' || value == 0) return false;
    if (value is String) return bool.tryParse(value);

    return null;
  }

  static QMap toMapped(dynamic data) {
    if (data is QMap) return data;
    if (data is Map) return QMap.from(data.toStringKey());
    if (data is List) return data.asMap().toStringKey();
    return {};
  }

  static List intoList(dynamic data) {
    if (data is List) return data;
    if (data is Map) return data.values.toList();
    return [];
  }

  static DateTime? tryDate(dynamic date) {
    if (date is DateTime) return date;
    if (date is String) return DateTime.tryParse(date);

    return null;
  }

  static String formatBytes(int bytes, [int decimals = 2]) {
    if (bytes <= 0) return '0 B';
    const suffixes = ['B', 'KB', 'MB', 'GB', 'TB', 'PB', 'EB', 'ZB', 'YB'];
    final i = (log(bytes) / log(1024)).floor();
    return '${(bytes / pow(1024, i)).toStringAsFixed(decimals)} ${suffixes[i]}';
  }

  static DateTime dateFromTime(String time, {bool isCrossedDate = false, bool isUtc = true}) {
    final containsTimePeriod = time.low.contains('am') || time.low.contains('pm');

    final isPm = time.low.contains('pm');

    if (containsTimePeriod) {
      time = time.split(' ').first;
    }

    DateTime now = DateTime.now();
    if (isUtc) now = now.toUtc();

    int year = now.year;
    String month = now.month.twoDigits();
    String day = now.day.twoDigits();

    if (isCrossedDate) {
      final nextDay = now.add(const Duration(days: 1));
      year = nextDay.year;
      month = nextDay.month.twoDigits();
      day = nextDay.day.twoDigits();
    }

    final dateString = '$year-$month-$day';

    String joined = '$dateString $time';

    if (isUtc) joined = '${joined}Z';

    if (isPm) {
      return DateTime.parse(joined).add(const Duration(hours: 12));
    }
    return DateTime.parse(joined);
  }

  static DateTime? tryDateFromTime(String? time, {bool isCrossedDate = false}) {
    if (time == null) return null;
    try {
      return dateFromTime(time, isCrossedDate: isCrossedDate);
    } catch (e) {
      return null;
    }
  }

  static String tryFormatDate(dynamic date, [String pattern = 'dd-MM-yyyy']) {
    if (date case final DateTime dt) return dt.formatDate(pattern);
    if (date case final String str) {
      final parsedDate = DateTime.tryParse(str);
      if (parsedDate != null) return parsedDate.formatDate(pattern);

      return str;
    }

    return 'n/a';
  }
}
