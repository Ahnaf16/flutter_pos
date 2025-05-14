import 'package:appwrite/models.dart';
import 'package:pos/main.export.dart';

class DueLog {
  const DueLog({
    this.id = '',
    required this.amount,
    required this.postAmount,
    required this.isDueAdded,
    required this.date,
    required this.parti,
    this.note,
  });

  final String id;
  final num amount;
  final num postAmount;
  final bool isDueAdded;
  final DateTime date;
  final Party parti;
  final String? note;

  factory DueLog.fromMap(Map<String, dynamic> map) => DueLog(
    id: map.parseAwField(),
    amount: map.parseNum('amount'),
    postAmount: map.parseNum('post_amount'),
    isDueAdded: map.parseBool('is_added'),
    date: DateTime.parse(map['adjustment_date']),
    parti: Party.fromMap(map['parties']),
    note: map['note'],
  );

  factory DueLog.fromDoc(Document doc) {
    final map = doc.data;
    return DueLog(
      id: doc.$id,
      amount: map.parseNum('amount'),
      postAmount: map.parseNum('post_amount'),
      isDueAdded: map.parseBool('is_added'),
      date: DateTime.parse(map['adjustment_date']),
      parti: Party.fromMap(map['parties']),
      note: map['note'],
    );
  }

  Map<String, dynamic> toMap() => {
    'id': id,
    'amount': amount,
    'post_amount': postAmount,
    'is_added': isDueAdded,
    'adjustment_date': date.toIso8601String(),
    'parties': parti.toMap(),
    'note': note,
  };

  Map<String, dynamic> toAwPost() => {
    'amount': amount,
    'post_amount': postAmount,
    'is_added': isDueAdded,
    'adjustment_date': date.toIso8601String(),
    'parties': parti.id,
    'note': note,
  };
}
