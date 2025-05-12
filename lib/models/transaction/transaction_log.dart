import 'package:appwrite/models.dart';
import 'package:fpdart/fpdart.dart';
import 'package:pos/main.export.dart';

enum TransactionType { sale, purchase, returned, expanse, transfer }

class TransactionLog {
  const TransactionLog({
    required this.id,
    required this.amount,
    required this.usedDueBalance,
    required this.account,
    required this.transactedTo,
    required this.transactionFormParti,
    required this.transactTo,
    required this.transactToPhone,
    required this.transactionBy,
    required this.date,
    required this.type,
    required this.note,
    required this.adjustBalance,
  });

  final String id;
  final num amount;

  /// is parti paid using there due balance
  final num usedDueBalance;
  final PaymentAccount account;

  /// to whom the transaction was made. can be null when type is manual
  final Parti? transactedTo;

  ///on whose behalf the transaction was made
  final Parti? transactionFormParti;

  /// plain name of the person to whom the transaction was made
  final String? transactTo;
  final String? transactToPhone;

  /// The user who made the transaction
  final AppUser? transactionBy;

  final DateTime date;
  final TransactionType type;
  final String? note;
  final bool adjustBalance;

  // final bool transactionFromMe;

  factory TransactionLog.fromDoc(Document doc) => TransactionLog.fromMap(doc.data);

  factory TransactionLog.fromMap(Map<String, dynamic> map) => TransactionLog(
    id: map.parseAwField(),
    amount: map.parseNum('amount'),
    usedDueBalance: map.parseNum('used_due_balance'),
    account: PaymentAccount.fromMap(map['payment_account']),
    transactedTo: Parti.tyrParse(map['parties']),
    transactionFormParti: Parti.tyrParse(map['transaction_for']),
    transactTo: map['transact_to'],
    transactToPhone: map['transact_to_phone'],
    transactionBy: AppUser.tryParse(map['transaction_by']),
    date: DateTime.parse(map['date']),
    note: map['note'],
    type: TransactionType.values.byName(map['transaction_type']),
    adjustBalance: map.parseBool('adjust_balance'),
  );

  static TransactionLog? tyrParse(dynamic value) {
    try {
      if (value case final TransactionLog t) return t;
      if (value case final Document doc) return TransactionLog.fromDoc(doc);
      if (value case final Map map) return TransactionLog.fromMap(map.toStringKey());
      return null;
    } catch (e) {
      return null;
    }
  }

  QMap toMap() => {
    'id': id,
    'amount': amount,
    'used_due_balance': usedDueBalance,
    'payment_account': account.toMap(),
    'parties': transactedTo?.toMap(),
    'transact_to': transactTo,
    'transact_to_phone': transactToPhone,
    'transaction_by': transactionBy?.toMap(),
    'date': date.toIso8601String(),
    'transaction_type': type.name,
    'note': note,
    'adjust_balance': adjustBalance,
    'transaction_for': transactionFormParti?.toMap(),
  };

  QMap toAwPost() => {
    'amount': amount,
    'used_due_balance': usedDueBalance,
    'payment_account': account.id,
    'parties': transactedTo?.id,
    'transact_to': transactTo,
    'transact_to_phone': transactToPhone,
    'transaction_by': transactionBy?.id,
    'date': date.toIso8601String(),
    'transaction_type': type.name,
    'note': note,
    'transaction_for': transactionFormParti?.id,
  };

  bool _trxToOther() =>
      (transactTo != null && transactTo!.isNotEmpty) || (transactToPhone != null && transactToPhone!.isNotEmpty);

  String? validate(bool fromMe) {
    final from = transactionFormParti;
    if (!fromMe) {
      if (from == null) return 'Please select a party to transfer from';
      if (from.id == transactedTo?.id) return 'Can\'t transfer to same party';
      if (from.hasBalance() && from.due.abs() < amount) return 'Transfer amount can\'t be more than available balance';
    }
    if (transactedTo == null && !_trxToOther()) return 'Please select a party or put their name and phone number';
    return null;
  }

  Parti? get getParti {
    if (transactedTo != null) return transactedTo;
    final name = transactTo;
    final phone = transactToPhone;
    if (name == null || phone == null) return null;
    return Parti.fromWalkIn(WalkIn(name: name, phone: phone));
  }

  static TransactionLog fromInventoryRecord(InventoryRecord record, AppUser user) {
    final parti = record.parti ?? Parti.fromWalkIn(record.walkIn);
    return TransactionLog(
      id: '',
      amount: record.amount,
      usedDueBalance: record.dueBalance,
      account: record.account,
      transactedTo: parti,
      transactTo: parti?.name,
      transactToPhone: parti?.phone,
      transactionBy: user,
      date: dateNow.run(),
      type: switch (record.type) {
        RecordType.purchase => TransactionType.purchase,
        RecordType.sale => TransactionType.sale,
      },
      note: _noteInv(record),
      adjustBalance: false,
      transactionFormParti: null,
    );
  }

  static TransactionLog fromExpense(Expense ex) {
    return TransactionLog(
      id: '',
      amount: ex.amount,
      usedDueBalance: 0,
      account: ex.account,
      transactedTo: null,
      transactTo: null,
      transactToPhone: null,
      transactionBy: ex.expenseBy,
      date: dateNow.run(),
      type: TransactionType.expanse,
      note: _noteEx(ex),
      adjustBalance: false,
      transactionFormParti: null,
    );
  }

  static TransactionLog fromReturn(ReturnRecord rec) {
    return TransactionLog(
      id: '',
      amount: rec.deductedFromAccount,
      usedDueBalance: rec.deductedFromParty,
      account: rec.returnedRec.account,
      transactedTo: null,
      transactTo: null,
      transactToPhone: null,
      transactionBy: rec.returnedBy,
      date: dateNow.run(),
      type: TransactionType.returned,
      note: _noteRe(rec),
      adjustBalance: false,
      transactionFormParti: null,
    );
  }

  static String _noteRe(ReturnRecord rec) {
    final amount = rec.deductedFromAccount;
    final account = rec.returnedRec.account.name;
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
    final parti = record.parti ?? Parti.fromWalkIn(record.walkIn);

    final isSale = record.type == RecordType.sale;
    final type = switch (record.type) {
      RecordType.purchase => 'Bought',
      RecordType.sale => 'Sold',
    };

    final length = record.details.length;
    final item = length == 1 ? 'item' : 'items';
    final amount = record.amount;
    final dueBalance = record.dueBalance;
    final preposition = isSale ? 'to' : 'from';
    final name = parti?.name;
    final date = record.date.formatDate();
    final account = record.account.name;

    return [
      '$type $length $item',
      'for $amount',
      if (dueBalance > 0) 'and used $dueBalance from due balance',
      if (name != null) '$preposition $name',
      'on $date',
      'using $account',
    ].join(' ');
  }

  TransactionLog copyWith({
    String? id,
    num? amount,
    num? usedDueBalance,
    PaymentAccount? account,
    ValueGetter<Parti?>? transactedTo,
    ValueGetter<Parti?>? transactionFormParti,
    ValueGetter<String?>? transactTo,
    ValueGetter<String?>? transactToPhone,
    ValueGetter<AppUser?>? transactionBy,
    DateTime? date,
    TransactionType? type,
    ValueGetter<String?>? note,
    bool? adjustBalance,
  }) {
    return TransactionLog(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      usedDueBalance: usedDueBalance ?? this.usedDueBalance,
      account: account ?? this.account,
      transactedTo: transactedTo != null ? transactedTo() : this.transactedTo,
      transactionFormParti: transactionFormParti != null ? transactionFormParti() : this.transactionFormParti,
      transactTo: transactTo != null ? transactTo() : this.transactTo,
      transactToPhone: transactToPhone != null ? transactToPhone() : this.transactToPhone,
      transactionBy: transactionBy != null ? transactionBy() : this.transactionBy,
      date: date ?? this.date,
      type: type ?? this.type,
      note: note != null ? note() : this.note,
      adjustBalance: adjustBalance ?? this.adjustBalance,
    );
  }
}
