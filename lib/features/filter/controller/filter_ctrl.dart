import 'package:pos/main.export.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'filter_ctrl.g.dart';

@Riverpod(keepAlive: true)
class FilterCtrl extends _$FilterCtrl {
  @override
  FilterState build() {
    return const FilterState();
  }

  void reset() {
    state = const FilterState();
  }

  FilterState clearByType(FilterType type, FilterState value) {
    return value.copyWith(
      from: !type.isDateFrom ? null : () => null,
      to: !type.isDateTo ? null : () => null,
      houses: !type.isHouse ? null : (v) => [],
      accounts: !type.isAccount ? null : (v) => [],
      trxTypes: !type.isType ? null : (v) => [],
      units: !type.isUnit ? null : (v) => [],
      statuses: !type.isStatus ? null : (v) => [],
      roles: !type.isRole ? null : (v) => [],
      start: !type.isNumRange ? null : () => null,
      end: !type.isNumRange ? null : () => null,
    );
  }

  void setState(FilterState value) => state = value;

  // void copyWith({
  //   ValueGetter<DateTime?>? from,
  //   ValueGetter<DateTime?>? to,
  //   ListValueGetter<WareHouse>? houses,
  //   ListValueGetter<PaymentAccount>? accounts,
  //   ListValueGetter<TransactionType>? trxTypes,
  //   ListValueGetter<ProductUnit>? units,
  //   ListValueGetter<InventoryStatus>? statuses,
  //   ListValueGetter<UserRole>? roles,
  //   ValueGetter<num?>? start,
  //   ValueGetter<num?>? end,
  // }) {
  //   state = FilterState(
  //     from: from != null ? from() : state.from,
  //     to: to != null ? to() : state.to,
  //     houses: houses != null ? houses(state.houses) : state.houses,
  //     accounts: accounts != null ? accounts(state.accounts) : state.accounts,
  //     trxTypes: trxTypes != null ? trxTypes(state.trxTypes) : state.trxTypes,
  //     units: units != null ? units(state.units) : state.units,
  //     statuses: statuses != null ? statuses(state.statuses) : state.statuses,
  //     roles: roles != null ? roles(state.roles) : state.roles,
  //     numRange: (start: start != null ? start() : state.numRange.start, end: end != null ? end() : state.numRange.end),
  //   );
  //   if (state.from != null && state.to != null && state.from!.isAfterOrEqualTo(state.to!)) {
  //     state = state.copyWith(to: () => null);
  //   }
  // }
}
