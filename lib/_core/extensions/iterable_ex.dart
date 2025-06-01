import 'package:fpdart/fpdart.dart';
import 'package:pos/main.export.dart';

extension IterableEx<T> on Iterable<T> {
  List<T> takeFirst([int listLength = 10]) {
    final itemCount = length;
    final takeCount = itemCount > listLength ? listLength : itemCount;
    return take(takeCount).toList();
  }

  List<T> filterByDate(DateTime date, DateTime Function(T item) getDate) {
    return where((item) {
      final itemDate = getDate(item);
      return itemDate.eqvYearMonthDay(date.justDate);
    }).toList();
  }

  List<T> filterByDateRange(DateTime? start, DateTime? end, DateTime Function(T item) getDate) {
    return where((item) {
      final itemDate = getDate(item);
      final isAfterStart = start == null || itemDate.isAfter(start);
      final isBeforeEnd = end == null || itemDate.isBefore(end);
      return isAfterStart && isBeforeEnd;
    }).toList();
  }
}

extension ListEx<T> on List<T?> {
  List<T> removeNull() {
    return where((e) => e != null).map((e) => e!).toList();
  }
}

extension ListMapEx on List<Map> {
  List<Map<String, num>> toNumMap() {
    return map((e) => e.map((k, v) => MapEntry('$k', Parser.toNum(v) ?? 0))).toList();
  }
}
