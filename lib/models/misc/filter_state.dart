import 'package:appwrite/appwrite.dart';
import 'package:pos/main.export.dart';

enum FilterType {
  dateFrom,
  dateTo,
  house,
  account,
  unit,
  status,
  roles,
  type;

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

  FilterState copyWith({
    ValueGetter<String?>? query,
    ValueGetter<DateTime?>? from,
    ValueGetter<DateTime?>? to,
    ValueGetter<List<WareHouse>>? houses,
    ValueGetter<List<PaymentAccount>>? accounts,
    ValueGetter<List<TransactionType>>? trxTypes,
    ValueGetter<List<ProductUnit>>? units,
    ValueGetter<List<InventoryStatus>>? statuses,
    ValueGetter<List<UserRole>>? roles,
  }) {
    return FilterState(
      query: query != null ? query() : this.query,
      from: from != null ? from() : this.from,
      to: to != null ? to() : this.to,
      houses: houses != null ? houses() : this.houses,
      accounts: accounts != null ? accounts() : this.accounts,
      trxTypes: trxTypes != null ? trxTypes() : this.trxTypes,
      units: units != null ? units() : this.units,
      statuses: statuses != null ? statuses() : this.statuses,
      roles: roles != null ? roles() : this.roles,
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
