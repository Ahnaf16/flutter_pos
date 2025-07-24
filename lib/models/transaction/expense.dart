import 'package:appwrite/models.dart';
import 'package:pos/main.export.dart';

class Expense {
  const Expense({
    required this.id,
    required this.amount,
    required this.expanseFor,
    required this.account,
    required this.expenseBy,
    required this.date,
    required this.note,
    required this.category,
    this.file,
  });
  final String id;
  final num amount;
  final String expanseFor;
  final PaymentAccount account;
  final AppUser expenseBy;
  final DateTime date;
  final String? note;
  final ExpenseCategory? category;
  final AwFile? file;

  factory Expense.fromDoc(Document doc) => Expense.fromMap(doc.data);

  factory Expense.fromMap(Map<String, dynamic> map) {
    return Expense(
      id: map.parseAwField(),
      amount: map.parseNum('amount'),
      expanseFor: map['expanse_for'],
      account: PaymentAccount.fromMap(map['payment_account']),
      expenseBy: AppUser.fromMap(map['users']),
      date: DateTime.parse(map['date']),
      note: map['note'],
      category: ExpenseCategory.tryParse(map['expanseCategory']),
      file: AwFile.tryParse(map['file']),
    );
  }

  Expense marge(Map<String, dynamic> map) {
    return Expense(
      id: map.tryParseAwField() ?? id,
      amount: map['amount'] ?? amount,
      expanseFor: map['expanse_for'] ?? expanseFor,
      account: map['payment_account'] == null ? account : PaymentAccount.fromMap(map['payment_account']),
      expenseBy: map['users'] == null ? expenseBy : AppUser.fromMap(map['users']),
      date: map['date'] == null ? date : DateTime.parse(map['date']),
      note: map['note'] ?? note,
      category: map['expanseCategory'] == null ? category : ExpenseCategory.fromMap(map['expanseCategory']),
      file: AwFile.tryParse(map['file']) ?? file,
    );
  }

  Map<String, dynamic> toMap() => {
    'id': id,
    'amount': amount,
    'expanse_for': expanseFor,
    'payment_account': account.toMap(),
    'users': expenseBy.toMap(),
    'date': date.toIso8601String(),
    'note': note,
    'expanseCategory': category?.toMap(),
    'file': file?.toMap(),
  };
  QMap toAwPost() => {
    'amount': amount,
    'expanse_for': expanseFor,
    'payment_account': account.id,
    'users': expenseBy.id,
    'date': date.toIso8601String(),
    'note': note,
    'expanseCategory': category?.id,
    'file': file?.id,
  };

  Expense copyWith({
    String? id,
    num? amount,
    String? expanseFor,
    PaymentAccount? account,
    AppUser? expenseBy,
    DateTime? date,
    ValueGetter<String?>? note,
    ExpenseCategory? category,
    ValueGetter<AwFile?>? file,
  }) {
    return Expense(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      expanseFor: expanseFor ?? this.expanseFor,
      account: account ?? this.account,
      expenseBy: expenseBy ?? this.expenseBy,
      date: date ?? this.date,
      note: note != null ? note() : this.note,
      category: category ?? this.category,
      file: file != null ? file() : this.file,
    );
  }
}

class ExpenseCategory {
  const ExpenseCategory({required this.id, required this.name, required this.enabled});

  final String id;
  final String name;
  final bool enabled;

  factory ExpenseCategory.fromDoc(Document doc) => ExpenseCategory.fromMap(doc.data);

  factory ExpenseCategory.fromMap(Map<String, dynamic> map) {
    return ExpenseCategory(id: map.parseAwField(), name: map['name'], enabled: map.parseBool('enabled', true));
  }
  static ExpenseCategory? tryParse(dynamic map) {
    try {
      if (map case final ExpenseCategory a) return a;
      if (map case final Document doc) return ExpenseCategory.fromDoc(doc);
      if (map case final Map m) return ExpenseCategory.fromMap(m.toStringKey());
      return null;
    } catch (e) {
      return null;
    }
  }

  ExpenseCategory marge(Map<String, dynamic> map) {
    return ExpenseCategory(
      id: map.tryParseAwField() ?? id,
      name: map['name'] ?? name,
      enabled: map.parseBool('enabled', enabled),
    );
  }

  Map<String, dynamic> toMap() => {'id': id, 'name': name, 'enabled': enabled};
  QMap toAwPost() => toMap()..removeWhere((key, value) => key == 'id');

  ExpenseCategory copyWith({String? id, String? name, bool? enabled}) {
    return ExpenseCategory(id: id ?? this.id, name: name ?? this.name, enabled: enabled ?? this.enabled);
  }
}
