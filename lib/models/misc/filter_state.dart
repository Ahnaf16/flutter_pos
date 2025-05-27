import 'package:pos/main.export.dart';

class FilterState {
  const FilterState({this.range, this.house, this.query, this.account, this.trxType});

  final String? query;
  final ShadDateTimeRange? range;
  final WareHouse? house;
  final PaymentAccount? account;
  final TransactionType? trxType;
}
