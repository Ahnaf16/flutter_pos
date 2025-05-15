import 'package:appwrite/models.dart';
import 'package:fpdart/fpdart.dart';
import 'package:pos/main.export.dart';

enum TransactionType { sale, payment, returned, expanse, transfer, dueAdjustment }

class TransactionLog {
  const TransactionLog({
    required this.id,
    required this.amount,
    required this.account,
    required this.transactedTo,
    required this.transactionForm,
    required this.customInfo,
    required this.transactionBy,
    required this.date,
    required this.type,
    required this.note,
    required this.adjustBalance,
    this.payMethod,
  });

  final String id;
  final num amount;
  final PaymentAccount? account;

  /// to whom the transaction was made. can be null when type is manual
  final Party? transactedTo;

  ///on whose behalf the transaction was made
  final Party? transactionForm;

  /// custom info about the transaction
  final SMap customInfo;

  /// The user who made the transaction
  final AppUser? transactionBy;

  final DateTime date;
  final TransactionType type;
  final String? note;
  final bool adjustBalance;
  final AccountType? payMethod;

  // final bool transactionFromMe;

  factory TransactionLog.fromDoc(Document doc) => TransactionLog.fromMap(doc.data);

  factory TransactionLog.fromMap(Map<String, dynamic> map) => TransactionLog(
    id: map.parseAwField(),
    amount: map.parseNum('amount'),
    account: PaymentAccount.tryParse(map['payment_account']),
    transactedTo: Party.tryParse(map['transaction_to']),
    transactionForm: Party.tryParse(map['transaction_from']),
    customInfo: map.parseCustomInfo('custom_info'),
    transactionBy: AppUser.tryParse(map['transaction_by']),
    date: DateTime.parse(map['date']),
    note: map['note'],
    type: TransactionType.values.byName(map['transaction_type']),
    adjustBalance: map.parseBool('adjust_balance'),
    payMethod: AccountType.values.tryByName(map['pay_method']),
  );

  static TransactionLog? tyrParse(dynamic value) {
    try {
      if (value case final TransactionLog t) return t;
      if (value case final Document doc) return TransactionLog.fromDoc(doc);
      if (value case final Map map) return TransactionLog.fromMap(map.toStringKey());
      return null;
    } catch (e, s) {
      catErr('', e, s);
      return null;
    }
  }

  QMap toMap() => {
    'id': id,
    'amount': amount,
    'payment_account': account?.toMap(),
    'transaction_to': transactedTo?.toMap(),
    'custom_info': customInfo.toCustomList(),
    'transaction_by': transactionBy?.toMap(),
    'date': date.toIso8601String(),
    'transaction_type': type.name,
    'note': note,
    'adjust_balance': adjustBalance,
    'transaction_from': transactionForm?.toMap(),
    'pay_method': payMethod?.name,
  };

  QMap toAwPost() => {
    'amount': amount,
    'payment_account': account?.id,
    'transaction_to': transactedTo?.id,
    'custom_info': customInfo.toCustomList(),
    'transaction_by': transactionBy?.id,
    'date': date.toIso8601String(),
    'transaction_type': type.name,
    'note': note,
    'transaction_from': transactionForm?.id,
    'pay_method': payMethod?.name,
  };

  String? validate() {
    final from = transactionForm;

    if (amount <= 0) return 'Amount must be greater than 0';
    if (from == null) return 'Please select a person to transfer from';
    if (from.id == transactedTo?.id) return 'Can\'t transfer to same person';
    if (from.hasDue() && from.due.abs() < amount) return 'Amount can\'t be more than available due';
    if (from.hasBalance() && from.due.abs() < amount) return 'Transfer amount can\'t be more than available balance';

    return null;
  }

  Party? get getParti => transactedTo;

  static TransactionLog fromInventoryRecord(InventoryRecord record, AppUser user) {
    final parti = record.parti;
    return TransactionLog(
      id: '',
      amount: record.amount,
      account: record.account,
      transactedTo: parti,
      customInfo: {},
      transactionBy: user,
      date: dateNow.run(),
      type: switch (record.type) {
        RecordType.purchase => TransactionType.payment,
        RecordType.sale => TransactionType.sale,
      },
      note: _noteInv(record),
      adjustBalance: false,
      transactionForm: null,
    );
  }

  static TransactionLog fromExpense(Expense ex) {
    return TransactionLog(
      id: '',
      amount: ex.amount,
      account: ex.account,
      transactedTo: null,
      customInfo: {},
      transactionBy: ex.expenseBy,
      date: dateNow.run(),
      type: TransactionType.expanse,
      note: _noteEx(ex),
      adjustBalance: false,
      transactionForm: null,
    );
  }

  static TransactionLog fromReturn(ReturnRecord rec) {
    return TransactionLog(
      id: '',
      amount: rec.deductedFromAccount,

      account: rec.returnedRec.account,
      transactedTo: null,
      customInfo: {},
      transactionBy: rec.returnedBy,
      date: dateNow.run(),
      type: TransactionType.returned,
      note: _noteRe(rec),
      adjustBalance: false,
      transactionForm: null,
    );
  }

  static String _noteRe(ReturnRecord rec) {
    final amount = rec.deductedFromAccount;
    final account = rec.returnedRec.account?.name;
    final date = rec.returnDate.formatDate();
    return ['Returned $amount', rec.isSale ? ' from' : ' to', ' $account', 'on $date'].join(' ');
  }

  static String _noteEx(Expense record) {
    final amount = record.amount;
    final account = record.account.name;
    final date = record.date.formatDate();
    return ['spent $amount', 'from $account', 'for "${record.expanseFor}"', 'on $date'].join(' ');
  }

  static String _noteInv(InventoryRecord record) {
    final parti = record.parti;

    final isSale = record.type == RecordType.sale;
    final type = switch (record.type) {
      RecordType.purchase => 'Bought',
      RecordType.sale => 'Sold',
    };

    final length = record.details.length;
    final item = length == 1 ? 'item' : 'items';
    final amount = record.amount;
    final preposition = isSale ? 'to' : 'from';
    final name = parti?.name;
    final date = record.date.formatDate();
    final account = record.account?.name;

    return [
      '$type $length $item',
      'for $amount',

      if (name != null) '$preposition $name',
      'on $date',
      'using $account',
    ].join(' ');
  }

  TransactionLog copyWith({
    String? id,
    num? amount,
    ValueGetter<PaymentAccount?>? account,
    ValueGetter<Party?>? transactedTo,
    ValueGetter<Party?>? transactionForm,
    SMap? customInfo,
    ValueGetter<AppUser?>? transactionBy,
    DateTime? date,
    TransactionType? type,
    ValueGetter<String?>? note,
    bool? adjustBalance,
    ValueGetter<AccountType?>? payMethod,
  }) {
    return TransactionLog(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      account: account != null ? account() : this.account,
      transactedTo: transactedTo != null ? transactedTo() : this.transactedTo,
      transactionForm: transactionForm != null ? transactionForm() : this.transactionForm,
      customInfo: customInfo ?? this.customInfo,
      transactionBy: transactionBy != null ? transactionBy() : this.transactionBy,
      date: date ?? this.date,
      type: type ?? this.type,
      note: note != null ? note() : this.note,
      adjustBalance: adjustBalance ?? this.adjustBalance,
      payMethod: payMethod != null ? payMethod() : this.payMethod,
    );
  }
}
