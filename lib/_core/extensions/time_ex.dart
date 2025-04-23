import 'package:pos/main.export.dart';

extension TimeOfDayEx on TimeOfDay {
  String formatTime([String pattern = 'hh:mm:ss']) {
    final hours = hour.twoDigits();
    final minutes = minute.twoDigits();
    final seconds = 0.twoDigits();

    return pattern.replaceAll('hh', hours).replaceAll('mm', minutes).replaceAll('ss', seconds);
  }
}

extension DateTimeEx on DateTime {
  String formatDate([String pattern = 'dd-MM-yyyy']) {
    return DateFormat(pattern).format(this);
  }

  String formatFull([String pattern = 'dd-MM-yyyy hh:mm:ss a']) {
    return DateFormat(pattern).format(this);
  }

  DateTime get justDateCheckUtc {
    if (isUtc) return DateTime.utc(year, month, day);
    return DateTime(year, month, day);
  }

  DateTime get justDate => DateTime(year, month, day);

  /// Returns the date as `MM/dd/yyyy`
  String get postString => formatDate('MM/dd/yyyy');

  DateTime startOfMonth() => DateTime(year, month);
  DateTime nextMonth() => DateTime(year, month + 1);

  DateTime endOfMonth() => DateTime(year, month + 1).subtract(const Duration(days: 1));

  DateTime fromDay(int day) {
    final last = endOfMonth().day;
    if (day > last) return endOfMonth();
    return DateTime(year, month, day);
  }

  DateTime changeDate(DateTime date) =>
      DateTime(date.year, date.month, date.day, hour, minute, second, millisecond, microsecond);

  String greeting() {
    if (hour < 12) return 'Morning';
    if (hour < 17) return 'Afternoon';
    if (hour < 20) return 'Evening';

    return 'Night';
  }

  bool eqvMonthYear(DateTime other) => month == other.month && year == other.year;

  bool isTimeExpired(Duration? timeLimit) {
    if (timeLimit == null) return false;
    final now = isUtc ? DateTime.now().toUtc() : DateTime.now();
    final expirationTime = add(timeLimit);
    return now.isAfter(expirationTime);
  }

  String? remainingTimeFromNow() {
    final now = isUtc ? DateTime.now().toUtc() : DateTime.now();
    final Duration remainingTime = difference(now);
    if (remainingTime.isNegative) return null;
    return remainingTime.readable;
  }

  DateTime toUtcIfNot() {
    if (isUtc) return this;
    return toUtc();
  }

  DateTime get startOfWeek {
    final daysToSubtract = (weekday == DateTime.sunday) ? 0 : weekday;
    return subtract(Duration(days: daysToSubtract));
  }

  DateTime get endOfWeek => startOfWeek.add(const Duration(days: 6));

  bool isWithinAMonth() {
    final today = DateTime.now().justDate;
    final dob = DateTime(today.year, month, day);

    final after = dob.isAfterOrEqualTo(today);
    final before = dob.isBeforeOrEqualTo(today.add(30.days));

    return after && before;
  }

  DateTime margeTime(DateTime time, [bool isUtc = true]) {
    if (isUtc) return DateTime.utc(year, month, day, time.hour, time.minute, time.second);
    return DateTime(year, month, day, time.hour, time.minute, time.second);
  }

  bool isAfterOrEqualTo(DateTime dateTime) {
    final isAtSameMomentAs = dateTime.isAtSameMomentAs(this);
    return isAtSameMomentAs || isAfter(dateTime);
  }

  bool isBeforeOrEqualTo(DateTime dateTime) {
    final isAtSameMomentAs = dateTime.isAtSameMomentAs(this);
    return isAtSameMomentAs || isBefore(dateTime);
  }
}

extension DateTimeRangeEx on DateTimeRange {
  /// Returns the date range as `MM/dd/yyyy-MM/dd/yyyy`
  String get postString => '${start.postString}-${end.postString}';
}

extension DurationEx on Duration {
  String get readable {
    final hours = inHours.twoDigits();
    final minutes = inMinutes.remainder(60).twoDigits();
    final seconds = inSeconds.remainder(60).twoDigits();

    final formattedString =
        '${hours.toString().padLeft(2, '0')}:'
        '${minutes.toString().padLeft(2, '0')} '
        '${seconds.toString().padLeft(2, '0')}';

    return formattedString;
  }

  String format([String pattern = 'hh:mm:ss']) {
    final days = inDays.twoDigits();
    final hours = inHours.twoDigits();
    final minutes = inMinutes.remainder(60).twoDigits();
    final seconds = inSeconds.remainder(60).twoDigits();

    return pattern.replaceAll('dd', days).replaceAll('hh', hours).replaceAll('mm', minutes).replaceAll('ss', seconds);
  }
}

extension DurationConvEx on int {
  Duration durationFromUnit(String unit) => switch (unit) {
    'hour' => Duration(hours: this),
    'minute' => Duration(minutes: this),
    'second' => Duration(seconds: this),
    _ => Duration(minutes: this),
  };
}
