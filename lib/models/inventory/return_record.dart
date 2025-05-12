import 'package:appwrite/models.dart';
import 'package:pos/main.export.dart';

class ReturnRecord {
  const ReturnRecord({
    required this.id,
    required this.returnedRec,
    required this.returnDate,
    required this.returnedBy,
    required this.note,
    required this.deductedFromAccount,
    required this.deductedFromParty,
    required this.isSale,
    this.detailsQtyPair = const [],
  });

  final String id;
  final InventoryRecord returnedRec;
  final DateTime returnDate;
  final AppUser returnedBy;
  final num deductedFromAccount;
  final num deductedFromParty;
  final String? note;
  final bool isSale;

  /// this stores the [InventoryDetails.id] and ReturnQty in pair
  /// example: [InventoryDetails.id]::[ReturnQty]
  final List<String> detailsQtyPair;

  factory ReturnRecord.fromDoc(Document doc) => ReturnRecord(
    id: doc.$id,
    returnedRec: InventoryRecord.fromMap(doc.data['inventoryRecord']),
    returnDate: DateTime.parse(doc.$createdAt),
    returnedBy: AppUser.fromMap(doc.data['users']),
    note: doc.data['note'],
    deductedFromAccount: doc.data['deductedFromAccount'],
    deductedFromParty: doc.data['deductedFromParty'],
    isSale: doc.data['isSale'],
    detailsQtyPair: List<String>.from(doc.data['stock_qty_pair']),
  );

  factory ReturnRecord.fromMap(Map<String, dynamic> map) => ReturnRecord(
    id: map.parseAwField(),
    returnedRec: InventoryRecord.fromMap(map['inventoryRecord']),
    returnDate: DateTime.parse(map.parseAwField('createdAt')),
    returnedBy: AppUser.fromMap(map['users']),
    note: map['note'],
    deductedFromAccount: map.parseNum('deductedFromAccount'),
    deductedFromParty: map.parseNum('deductedFromParty'),
    isSale: map.parseBool('isSale'),
    detailsQtyPair: List<String>.from(map['stock_qty_pair']),
  );

  QMap toMap() => {
    'id': id,
    'inventoryRecord': returnedRec.toMap(),
    'createdAt': returnDate.toIso8601String(),
    'users': returnedBy.toMap(),
    'note': note,
    'deductedFromAccount': deductedFromAccount,
    'deductedFromParty': deductedFromParty,
    'isSale': isSale,
    'stock_qty_pair': detailsQtyPair,
  };

  QMap toAwPost() => {
    'inventoryRecord': returnedRec.id,
    'users': returnedBy.id,
    'note': note,
    'deductedFromAccount': deductedFromAccount,
    'deductedFromParty': deductedFromParty,
    'isSale': isSale,
    'stock_qty_pair': detailsQtyPair,
  };
}
