import 'package:appwrite/appwrite.dart';
import 'package:pos/main.export.dart';

enum FilterDateRange {
  today,
  yesterday,
  week,
  month,
  year;

  IconData get icon {
    return switch (this) {
      today => LuIcons.calendar,
      yesterday => LuIcons.calendarFold,
      week => LuIcons.calendar1,
      month => LuIcons.calendarDays,
      year => LuIcons.calendarRange,
    };
  }

  String get title {
    return switch (this) {
      today => 'Today',
      yesterday => 'Yesterday',
      week => 'This week',
      month => 'This month',
      year => 'This year',
    };
  }

  (DateTime start, DateTime end) get effectiveDates {
    final now = DateTime.now();
    switch (this) {
      case FilterDateRange.today:
        return (now.startOfDay, now.endOfDay);
      case FilterDateRange.yesterday:
        return (now.previousDay.startOfDay, now.previousDay.endOfDay);
      case FilterDateRange.week:
        return (now.startOfWeek, now.endOfWeek);
      case FilterDateRange.month:
        return (now.startOfMonth, now.endOfMonth);
      case FilterDateRange.year:
        return (now.startOfYear, now.endOfYear);
    }
  }
}

enum FilterType {
  dateFrom,
  dateTo,
  house,
  account,
  unit,
  status,
  roles,
  type,
  numRange;

  IconData get icon {
    return switch (this) {
      dateFrom => LuIcons.calendarArrowDown,
      dateTo => LuIcons.calendarArrowUp,
      house => LuIcons.warehouse,
      account => LuIcons.creditCard,
      unit => LuIcons.ruler,
      status => LuIcons.circleDashed,
      roles => LuIcons.shield,
      type => LuIcons.tags,
      numRange => LuIcons.hash,
    };
  }

  String get title {
    return switch (this) {
      dateFrom => 'From',
      dateTo => 'To',
      house => 'Warehouse',
      account => 'Account',
      unit => 'Unit',
      status => 'Status',
      roles => 'Role',
      type => 'Type',
      numRange => 'Range',
    };
  }

  bool get isDateFrom => this == FilterType.dateFrom;
  bool get isDateTo => this == FilterType.dateTo;
  bool get isDateRange => this == FilterType.dateFrom || this == FilterType.dateTo;
  bool get isHouse => this == FilterType.house;
  bool get isAccount => this == FilterType.account;
  bool get isType => this == FilterType.type;
  bool get isUnit => this == FilterType.unit;
  bool get isStatus => this == FilterType.status;
  bool get isRole => this == FilterType.roles;
  bool get isNumRange => this == FilterType.numRange;
}

class FilterState {
  const FilterState({
    this.query,
    this.from,
    this.to,
    this.houses = const [],
    this.accounts = const [],
    this.trxTypes = const [],
    this.units = const [],
    this.statuses = const [],
    this.roles = const [],
    this.numRange = (start: null, end: null),
  });

  final String? query;
  final DateTime? from;
  final DateTime? to;
  final List<WareHouse> houses;
  final List<PaymentAccount> accounts;
  final List<TransactionType> trxTypes;
  final List<ProductUnit> units;
  final List<InventoryStatus> statuses;
  final List<UserRole> roles;
  final ({num? start, num? end}) numRange;

  FilterState copyWith({
    ValueGetter<String?>? query,
    ValueGetter<DateTime?>? from,
    ValueGetter<DateTime?>? to,
    ListValueGetter<WareHouse>? houses,
    ListValueGetter<PaymentAccount>? accounts,
    ListValueGetter<TransactionType>? trxTypes,
    ListValueGetter<ProductUnit>? units,
    ListValueGetter<InventoryStatus>? statuses,
    ListValueGetter<UserRole>? roles,
    ValueGetter<num?>? start,
    ValueGetter<num?>? end,
  }) {
    return FilterState(
      query: query != null ? query() : this.query,
      from: from != null ? from() : this.from,
      to: to != null ? to() : this.to,
      houses: houses != null ? houses(this.houses) : this.houses,
      accounts: accounts != null ? accounts(this.accounts) : this.accounts,
      trxTypes: trxTypes != null ? trxTypes(this.trxTypes) : this.trxTypes,
      units: units != null ? units(this.units) : this.units,
      statuses: statuses != null ? statuses(this.statuses) : this.statuses,
      roles: roles != null ? roles(this.roles) : this.roles,
      numRange: (start: start != null ? start() : numRange.start, end: end != null ? end() : numRange.end),
    );
  }

  Map<FilterType, String> buildNames() {
    final Map<FilterType, String> names = {};

    if (trxTypes.length == 1) {
      names.addAll({FilterType.type: trxTypes.first.name.titleCase});
    }
    if (trxTypes.length > 1) {
      names.addAll({FilterType.type: '${trxTypes.first.name.titleCase} and ${trxTypes.length - 1} more'});
    }

    //!
    if (statuses.length == 1) {
      names.addAll({FilterType.status: statuses.first.name.titleCase});
    }
    if (statuses.length > 1) {
      names.addAll({FilterType.status: '${statuses.first.name.titleCase} and ${statuses.length - 1} more'});
    }
    //!
    if (accounts.length == 1) {
      names.addAll({FilterType.account: accounts.first.name});
    }
    if (accounts.length > 1) {
      names.addAll({FilterType.account: '${accounts.first.name} and ${accounts.length - 1} more'});
    }

    //!
    if (units.length == 1) {
      names.addAll({FilterType.unit: units.first.name});
    }
    if (units.length > 1) {
      names.addAll({FilterType.unit: '${units.first.name} and ${units.length - 1} more'});
    }

    //!
    if (houses.length == 1) {
      names.addAll({FilterType.house: houses.first.name});
    }
    if (houses.length > 1) {
      names.addAll({FilterType.house: '${houses.first.name} and ${houses.length - 1} more'});
    }

    //!
    if (roles.length == 1) {
      names.addAll({FilterType.house: roles.first.name});
    }
    if (roles.length > 1) {
      names.addAll({FilterType.house: '${roles.first.name} and ${roles.length - 1} more'});
    }

    //!
    if (from != null && to != null) {
      names.addAll({FilterType.dateFrom: '${from!.formatDate('MMM dd, yyyy')} to ${to!.formatDate('MMM dd, yyyy')}'});
    }
    if (from != null && to == null) {
      names.addAll({FilterType.dateFrom: from!.formatDate('MMM dd, yyyy')});
    }

    return names;
  }

  String? queryBuilder(FilterType type, String key) {
    if (type.isDateRange && from != null && to != null) {
      return Query.between(key, from!.justDate.toIso8601String(), to!.nextDay.justDate.toIso8601String());
    }

    switch (type) {
      case FilterType.dateFrom:
      case FilterType.dateTo:
        {
          if (from != null) {
            return Query.between(key, from!.justDate.toIso8601String(), from!.nextDay.justDate.toIso8601String());
          }
          if (to != null) return Query.lessThanEqual(key, to!.justDate.toIso8601String());
          return null;
        }

      case FilterType.numRange:
        {
          if (numRange.start != null && numRange.end != null) {
            return Query.between(key, numRange.start, numRange.end);
          }
          if (numRange.start != null) {
            return Query.greaterThanEqual(key, numRange.start.toString());
          }
          if (numRange.end != null) return Query.lessThanEqual(key, numRange.end.toString());
          return null;
        }

      case FilterType.house:
        {
          if (houses.length == 1) return Query.equal(key, houses.first.id);
          if (houses.length > 1) return Query.or([for (final t in houses) Query.equal(key, t.id)]);
          return null;
        }
      case FilterType.account:
        {
          if (accounts.length == 1) return Query.equal(key, accounts.first.id);
          if (accounts.length > 1) return Query.or([for (final t in accounts) Query.equal(key, t.id)]);
          return null;
        }
      case FilterType.type:
        {
          if (trxTypes.length == 1) return Query.equal(key, trxTypes.first.name);
          if (trxTypes.length > 1) return Query.or([for (final t in trxTypes) Query.equal(key, t.name)]);
          return null;
        }
      case FilterType.unit:
        {
          if (units.length == 1) return Query.equal(key, units.first.id);
          if (units.length > 1) return Query.or([for (final t in units) Query.equal(key, t.id)]);
          return null;
        }
      case FilterType.status:
        {
          if (statuses.length == 1) return Query.equal(key, statuses.first.name);
          if (statuses.length > 1) return Query.or([for (final t in statuses) Query.equal(key, t.name)]);
          return null;
        }
      case FilterType.roles:
        {
          if (roles.length == 1) return Query.equal(key, roles.first.id);
          if (roles.length > 1) return Query.or([for (final t in roles) Query.equal(key, t.id)]);
          return null;
        }
    }
  }
}
