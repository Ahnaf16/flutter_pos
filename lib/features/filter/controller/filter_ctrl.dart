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

  void clearByType(FilterType type) {
    copyWith(
      from: !type.isDateFrom ? null : () => null,
      to: !type.isDateTo ? null : () => null,
      houses: !type.isHouse ? null : (v) => [],
      accounts: !type.isAccount ? null : (v) => [],
      trxTypes: !type.isType ? null : (v) => [],
    );
  }

  void copyWith({
    ValueGetter<String?>? query,
    ValueGetter<DateTime?>? from,
    ValueGetter<DateTime?>? to,
    ListValueGetter<WareHouse>? houses,
    ListValueGetter<PaymentAccount>? accounts,
    ListValueGetter<TransactionType>? trxTypes,
  }) {
    state = FilterState(
      query: query != null ? query() : state.query,
      from: from != null ? from() : state.from,
      to: to != null ? to() : state.to,
      houses: houses != null ? houses(state.houses) : state.houses,
      accounts: accounts != null ? accounts(state.accounts) : state.accounts,
      trxTypes: trxTypes != null ? trxTypes(state.trxTypes) : state.trxTypes,
    );
    if (state.from != null && state.to != null && state.from!.isAfterOrEqualTo(state.to!)) {
      state = state.copyWith(to: () => null);
    }
  }
}
