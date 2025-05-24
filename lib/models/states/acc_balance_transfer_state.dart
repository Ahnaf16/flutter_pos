import 'package:pos/main.export.dart';

class AccBalanceTransferState {
  const AccBalanceTransferState({this.from, this.to, this.amount = 0});

  final PaymentAccount? from;
  final PaymentAccount? to;
  final num amount;

  factory AccBalanceTransferState.fromMap(Map<String, dynamic> map) {
    return AccBalanceTransferState(
      from: PaymentAccount.fromMap(map['from']),
      to: PaymentAccount.fromMap(map['to']),
      amount: map.parseNum('amount'),
    );
  }

  String? validate() {
    if (from == null) return 'From account is required';
    if (to == null) return 'To account is required';
    if (amount <= 0) return 'Amount must be greater than 0';
    if (amount > from!.amount) return 'Amount cannot be greater than available balance';
    return null;
  }

  Map<String, dynamic> toMap() {
    return {
      'from': from?.toMap(),
      'to': to?.toMap(),
      'amount': amount,
    };
  }
}
