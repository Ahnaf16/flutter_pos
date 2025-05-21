import 'package:appwrite/models.dart';
import 'package:pos/main.export.dart';

class ReturnRecord {
  const ReturnRecord({
    required this.id,
    required this.returnedRec,
    required this.returnDate,
    required this.returnedBy,
    required this.note,
    required this.adjustAccount,
    required this.adjustFromParty,
    required this.isSale,
    this.detailsQtyPair = const [],
  });

  final String id;
  final InventoryRecord? returnedRec;
  final DateTime returnDate;
  final AppUser returnedBy;
  final num adjustAccount;
  final num adjustFromParty;
  final String? note;
  final bool isSale;

  /// this stores the [InventoryDetails.id] and ReturnQty in pair
  /// example: [InventoryDetails.id]::[ReturnQty]
  final List<String> detailsQtyPair;

  factory ReturnRecord.fromDoc(Document doc) => ReturnRecord(
    id: doc.$id,
    returnedRec: InventoryRecord.tryParse(doc.data['inventoryRecord']),
    returnDate: DateTime.parse(doc.$createdAt),
    returnedBy: AppUser.fromMap(doc.data['users']),
    note: doc.data['note'],
    adjustAccount: doc.data['deductedFromAccount'],
    adjustFromParty: doc.data['deductedFromParty'],
    isSale: doc.data['isSale'],
    detailsQtyPair: List<String>.from(doc.data['stock_qty_pair']),
  );

  factory ReturnRecord.fromMap(Map<String, dynamic> map) => ReturnRecord(
    id: map.parseAwField(),
    returnedRec: InventoryRecord.tryParse(map['inventoryRecord']),
    returnDate: DateTime.parse(map.parseAwField('createdAt')),
    returnedBy: AppUser.fromMap(map['users']),
    note: map['note'],
    adjustAccount: map.parseNum('deductedFromAccount'),
    adjustFromParty: map.parseNum('deductedFromParty'),
    isSale: map.parseBool('isSale'),
    detailsQtyPair: List<String>.from(map['stock_qty_pair']),
  );

  static ReturnRecord? tryParse(dynamic value) {
    try {
      if (value case final ReturnRecord r) return r;
      if (value case final Document doc) return ReturnRecord.fromDoc(doc);
      if (value case final Map map) return ReturnRecord.fromMap(map.toStringKey());
      return null;
    } catch (e) {
      return null;
    }
  }

  QMap toMap() => {
    'id': id,
    'inventoryRecord': returnedRec?.toMap(),
    'createdAt': returnDate.toIso8601String(),
    'users': returnedBy.toMap(),
    'note': note,
    'deductedFromAccount': adjustAccount,
    'deductedFromParty': adjustFromParty,
    'isSale': isSale,
    'stock_qty_pair': detailsQtyPair,
  };

  QMap toAwPost() => {
    'inventoryRecord': returnedRec?.id,
    'users': returnedBy.id,
    'note': note,
    'deductedFromAccount': adjustAccount,
    'deductedFromParty': adjustFromParty,
    'isSale': isSale,
    'stock_qty_pair': detailsQtyPair,
  };

  num get totalReturn => adjustAccount + adjustFromParty;
}
