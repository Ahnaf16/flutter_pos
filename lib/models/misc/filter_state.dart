import 'package:pos/main.export.dart';

class FilterState {
  const FilterState({this.query, this.from, this.to, this.houses, this.accounts, this.trxTypes});

  final String? query;
  final DateTime? from;
  final DateTime? to;
  final List<WareHouse>? houses;
  final List<PaymentAccount>? accounts;
  final List<TransactionType>? trxTypes;
}
