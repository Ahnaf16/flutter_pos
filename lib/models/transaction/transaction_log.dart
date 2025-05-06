import 'package:appwrite/models.dart';
import 'package:fpdart/fpdart.dart';
import 'package:pos/main.export.dart';

enum TransactionType { manual, sale, purchase, expanse }

class TransactionLog {
  const TransactionLog({
    required this.id,
    required this.amount,
    required this.usedDueBalance,
    required this.account,
    required this.parti,
    required this.transactTo,
    required this.transactToPhone,
    required this.transactionBy,
    required this.date,
    required this.type,
    required this.note,
  });

  final String id;
  final num amount;

  /// is parti paid using there due balance
  final num usedDueBalance;
  final PaymentAccount account;

  /// to whom the transaction was made. can be null when type is manual
  final Parti? parti;

  /// plain name of the person to whom the transaction was made
  final String? transactTo;
  final String? transactToPhone;

  /// The user who made the transaction
  final AppUser transactionBy;

  final DateTime date;
  final TransactionType type;
  final String? note;

  factory TransactionLog.fromDoc(Document doc) => TransactionLog.fromMap(doc.data);

  factory TransactionLog.fromMap(Map<String, dynamic> map) => TransactionLog(
    id: map.parseAwField(),
    amount: map.parseNum('amount'),
    usedDueBalance: map.parseNum('used_due_balance'),
    account: PaymentAccount.fromMap(map['payment_account']),
    parti: Parti.tyrParse(map['parties']),
    transactTo: map['transact_to'],
    transactToPhone: map['transact_to_phone'],
    transactionBy: AppUser.fromMap(map['transaction_by']),
    date: DateTime.parse(map['date']),
    note: map['note'],
    type: TransactionType.values.byName(map['transaction_type']),
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
    'parties': parti?.toMap(),
    'transact_to': transactTo,
    'transact_to_phone': transactToPhone,
    'transaction_by': transactionBy.toMap(),
    'date': date.toIso8601String(),
    'transaction_type': type.name,
    'note': note,
  };

  QMap toAwPost() => {
    'amount': amount,
    'used_due_balance': usedDueBalance,
    'payment_account': account.id,
    'parties': parti?.id,
    'transact_to': transactTo,
    'transact_to_phone': transactToPhone,
    'transaction_by': transactionBy.id,
    'date': date.toIso8601String(),
    'transaction_type': type.name,
    'note': note,
  };

  Parti? get getParti {
    if (parti != null) return parti;
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
      parti: parti,
      transactTo: parti?.name,
      transactToPhone: parti?.phone,
      transactionBy: user,
      date: dateNow.run(),
      type: record.type == RecordType.sale ? TransactionType.sale : TransactionType.purchase,
      note: _noteInv(record),
    );
  }

  static TransactionLog fromExpense(Expense ex) {
    return TransactionLog(
      id: '',
      amount: ex.amount,
      usedDueBalance: 0,
      account: ex.account,
      parti: null,
      transactTo: null,
      transactToPhone: null,
      transactionBy: ex.expenseBy,
      date: dateNow.run(),
      type: TransactionType.expanse,
      note: _noteEx(ex),
    );
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
    final type = isSale ? 'Sold' : 'Bought';
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
}
