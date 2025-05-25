import 'package:appwrite/models.dart';
import 'package:fpdart/fpdart.dart';
import 'package:nanoid2/nanoid2.dart';
import 'package:pos/main.export.dart';

enum TransactionType {
  sale,
  payment,
  returned,
  expanse,
  transfer,
  dueAdjustment;

  bool get isSale => this == TransactionType.sale;
  bool get isPayment => this == TransactionType.payment;
  bool get isReturned => this == TransactionType.returned;
  bool get isExpanse => this == TransactionType.expanse;
  bool get isTransfer => this == TransactionType.transfer;
  bool get isDueAdjustment => this == TransactionType.dueAdjustment;

  Color get color => switch (this) {
    sale => Colors.blue,
    payment => Colors.green,
    returned => Colors.red,
    expanse => Colors.orange,
    transfer => Colors.purple,
    dueAdjustment => Colors.purple,
  };
}

class TransactionLog {
  const TransactionLog({
    required this.id,
    required this.trxNo,
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
    required this.record,
    required this.transactedToShop,
    this.payMethod,
    required this.transferredToAccount,
    required this.isBetweenAccount,
  });

  final String id;
  final String trxNo;
  final num amount;
  final PaymentAccount? account;
  final PaymentAccount? transferredToAccount;

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
  final InventoryRecord? record;
  final bool transactedToShop;
  final bool isBetweenAccount;

  // final bool transactionFromMe;

  factory TransactionLog.fromDoc(Document doc) => TransactionLog.fromMap(doc.data);

  factory TransactionLog.fromMap(Map<String, dynamic> map) => TransactionLog(
    id: map.parseAwField(),
    trxNo: map['trx_no'] ?? '',
    amount: map.parseNum('amount'),
    account: PaymentAccount.tryParse(map['payment_account']),
    transferredToAccount: PaymentAccount.tryParse(map['transferredToAccount']),
    transactedTo: Party.tryParse(map['transaction_to']),
    transactionForm: Party.tryParse(map['transaction_from']),
    customInfo: map.parseCustomInfo('custom_info'),
    transactionBy: AppUser.tryParse(map['transaction_by']),
    date: DateTime.parse(map['date']),
    note: map['note'],
    type: TransactionType.values.byName(map['transaction_type']),
    adjustBalance: map.parseBool('adjust_balance'),
    payMethod: AccountType.values.tryByName(map['pay_method']),
    record: InventoryRecord.tryParse(map['inventoryRecord']),
    transactedToShop: map.parseBool('transacted_to_shop'),
    isBetweenAccount: map.parseBool('betweenAccount'),
  );

  static TransactionLog? tyrParse(dynamic value) {
    try {
      if (value case final TransactionLog t) return t;
      if (value case final Document doc) return TransactionLog.fromDoc(doc);
      if (value case final Map map) return TransactionLog.fromMap(map.toStringKey());
      return null;
    } catch (e, s) {
      catErr('TransactionLog.tryParse', e, s);
      return null;
    }
  }

  QMap toMap() => {
    'id': id,
    'trx_no': trxNo,
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
    'inventoryRecord': record?.toMap(),
    'transacted_to_shop': transactedToShop,
    'betweenAccount': isBetweenAccount,
    'transferredToAccount': transferredToAccount?.toMap(),
  };

  QMap toAwPost() => {
    'amount': amount,
    'trx_no': trxNo,
    'payment_account': account?.id,
    'transaction_to': transactedTo?.id,
    'custom_info': customInfo.toCustomList(),
    'transaction_by': transactionBy?.id,
    'date': date.toIso8601String(),
    'transaction_type': type.name,
    'note': note,
    'transaction_from': transactionForm?.id,
    'pay_method': payMethod?.name,
    'inventoryRecord': record?.id,
    'transacted_to_shop': transactedToShop,
    'transferredToAccount': transferredToAccount?.id,
    'betweenAccount': isBetweenAccount,
  };

  String? validate() {
    final from = transactionForm;
    final to = transactedTo;
    final accTo = transferredToAccount;
    final acc = account;

    if (amount <= 0) return 'Amount must be greater than 0';

    if (isBetweenAccount) {
      if (accTo == null) return 'Please select an account to transfer to';
      if (acc == null) return 'Please select an account to transfer from';
      if (acc.id == accTo.id) return 'Can\'t transfer to same account';
      if (acc.amount < amount) return 'Amount can\'t be more than available balance';
    } else if (type.isPayment) {
      if (to == null) return 'Please select a person to make transaction to';
      if (to.hasDue() && to.due.abs() < amount) return 'Amount can\'t be more than available due';
      if (to.hasBalance() && to.due.abs() < amount) return 'Amount can\'t be more than available balance';
    } else {
      if (from == null) return 'Please select a person to transfer from';
      if (from.id == to?.id) return 'Can\'t transfer to same person';
      if (from.hasDue() && from.due.abs() < amount) return 'Amount can\'t be more than due';
      if (from.hasBalance() && from.due.abs() < amount) return 'Amount can\'t be more than balance';
    }
    return null;
  }

  ({String? name, String? phone}) get effectiveTo {
    if (transactedToShop) return (name: transactionBy?.name, phone: transactionBy?.phone);

    if (isBetweenAccount) return (name: transferredToAccount?.name, phone: null);

    if (type.isTransfer) return (name: customInfo['Name'], phone: customInfo['Phone']);

    return (name: transactedTo?.name, phone: transactedTo?.phone);
  }

  ({String? name, String? phone}) get effectiveFrom {
    if (isBetweenAccount) return (name: account?.name, phone: null);

    final isWalkIn = transactionForm?.isWalkIn ?? (type.isSale);

    final fromName = transactionForm?.name ?? transactionBy?.name;
    final fromPhone = transactionForm?.phone ?? transactionBy?.phone;

    return (name: isWalkIn ? 'Walk In' : fromName, phone: isWalkIn ? null : fromPhone);
  }

  static TransactionLog fromInventoryRecord(InventoryRecord record, AppUser user) {
    final parti = record.party;
    return TransactionLog(
      id: '',
      trxNo: nanoid(length: 8, alphabet: '0123456789'),
      amount: record.paidAmount,
      account: record.account,
      transactedTo: record.type.isSale ? null : parti,
      transactionForm: record.type.isSale ? parti : null,
      customInfo: {},
      transactionBy: user,
      date: dateNow.run(),
      type: switch (record.type) {
        RecordType.purchase => TransactionType.payment,
        RecordType.sale => TransactionType.sale,
      },
      note: _noteInv(record),
      adjustBalance: false,
      record: record,
      transactedToShop: record.type.isSale,
      isBetweenAccount: false,
      transferredToAccount: null,
    );
  }

  static TransactionLog fromExpense(Expense ex) {
    return TransactionLog(
      id: '',
      trxNo: nanoid(length: 8, alphabet: '0123456789'),
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
      record: null,
      transactedToShop: false,
      isBetweenAccount: false,
      transferredToAccount: null,
    );
  }

  static TransactionLog fromReturn(ReturnRecord rec) {
    final isSale = rec.returnedRec?.type.isSale ?? false;
    return TransactionLog(
      id: '',
      trxNo: nanoid(length: 8, alphabet: '0123456789'),
      amount: rec.adjustAccount,
      account: rec.returnedRec?.account,
      transactedTo: rec.isSale ? rec.returnedRec?.party : null,
      transactionForm: rec.isSale ? null : rec.returnedRec?.party,
      customInfo: {},
      transactionBy: rec.returnedBy,
      date: dateNow.run(),
      type: TransactionType.returned,
      note: _noteRe(rec),
      adjustBalance: false,
      record: rec.returnedRec,
      transactedToShop: !isSale,
      isBetweenAccount: false,
      transferredToAccount: null,
    );
  }

  static TransactionLog fromTransferState(AccBalanceTransferState tState) {
    return TransactionLog(
      id: '',
      trxNo: nanoid(length: 8, alphabet: '0123456789'),
      amount: tState.amount,
      account: tState.from,
      transactedTo: null,
      transactionForm: null,
      customInfo: {},
      transactionBy: null,
      date: dateNow.run(),
      type: TransactionType.transfer,
      note: 'Transferred ${tState.amount} from ${tState.from?.name} to ${tState.to?.name}',
      adjustBalance: false,
      record: null,
      transactedToShop: false,
      isBetweenAccount: true,
      transferredToAccount: tState.to,
    );
  }

  static String _noteRe(ReturnRecord rec) {
    final amount = rec.adjustAccount;
    final account = rec.returnedRec?.account?.name;
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
    final parti = record.party;

    final isSale = record.type == RecordType.sale;
    final type = switch (record.type) {
      RecordType.purchase => 'Bought',
      RecordType.sale => 'Sold',
    };

    final length = record.details.length;
    final item = length == 1 ? 'item' : 'items';
    final amount = record.paidAmount;
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
    String? trxNo,
    num? amount,
    ValueGetter<PaymentAccount?>? account,
    ValueGetter<PaymentAccount?>? transferredToAccount,
    ValueGetter<Party?>? transactedTo,
    ValueGetter<Party?>? transactionForm,
    SMap? customInfo,
    ValueGetter<AppUser?>? transactionBy,
    DateTime? date,
    TransactionType? type,
    ValueGetter<String?>? note,
    bool? adjustBalance,
    ValueGetter<AccountType?>? payMethod,
    ValueGetter<InventoryRecord?>? record,
    bool? transactedToShop,
    bool? isBetweenAccount,
  }) {
    return TransactionLog(
      id: id ?? this.id,
      trxNo: trxNo ?? this.trxNo,
      amount: amount ?? this.amount,
      account: account != null ? account() : this.account,
      transferredToAccount: transferredToAccount != null ? transferredToAccount() : this.transferredToAccount,
      transactedTo: transactedTo != null ? transactedTo() : this.transactedTo,
      transactionForm: transactionForm != null ? transactionForm() : this.transactionForm,
      customInfo: customInfo ?? this.customInfo,
      transactionBy: transactionBy != null ? transactionBy() : this.transactionBy,
      date: date ?? this.date,
      type: type ?? this.type,
      note: note != null ? note() : this.note,
      adjustBalance: adjustBalance ?? this.adjustBalance,
      payMethod: payMethod != null ? payMethod() : this.payMethod,
      record: record != null ? record() : this.record,
      transactedToShop: transactedToShop ?? this.transactedToShop,
      isBetweenAccount: isBetweenAccount ?? this.isBetweenAccount,
    );
  }
}
