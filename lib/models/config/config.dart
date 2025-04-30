import 'package:appwrite/models.dart';
import 'package:pos/main.export.dart';

enum StockDistPolicy { newerFirst, olderFirst }

class Config {
  const Config({
    required this.maintenanceMode,
    required this.currencySymbol,
    required this.symbolLeft,
    required this.stockDistPolicy,
    required this.minimumVersion,
  });

  final bool maintenanceMode;
  final String currencySymbol;
  final bool symbolLeft;
  final StockDistPolicy stockDistPolicy;
  final String? minimumVersion;

  static Config get _def => const Config(
    maintenanceMode: false,
    currencySymbol: '\$',
    symbolLeft: true,
    stockDistPolicy: StockDistPolicy.newerFirst,
    minimumVersion: null,
  );

  factory Config.fromDoc(Document doc) {
    final map = doc.data;
    return Config(
      maintenanceMode: map['maintenance_mode'] ?? _def.maintenanceMode,
      currencySymbol: map['currency_symbol'] ?? _def.currencySymbol,
      symbolLeft: map['currency_symbol_on_left'] ?? _def.symbolLeft,
      stockDistPolicy: StockDistPolicy.values.byName(map['stock_distribution_policy']),
      minimumVersion: map['minimum_version'] ?? _def.minimumVersion,
    );
  }

  factory Config.fromMap(Map<String, dynamic> map) {
    return Config(
      maintenanceMode: map['maintenance_mode'] ?? _def.maintenanceMode,
      currencySymbol: map['currency_symbol'] ?? _def.currencySymbol,
      symbolLeft: map['currency_symbol_on_left'] ?? _def.symbolLeft,
      stockDistPolicy: StockDistPolicy.values.byName(map['stock_distribution_policy']),
      minimumVersion: map['minimum_version'] ?? _def.minimumVersion,
    );
  }

  static Config tryParse(dynamic value) {
    try {
      if (value case final Document doc) return Config.fromDoc(doc);
      if (value case final Map map) return Config.fromMap(map.toStringKey());
      return _def;
    } catch (e) {
      return _def;
    }
  }

  static Config def() => _def;

  Config marge(Map<String, dynamic> map) {
    return Config(
      maintenanceMode: map['maintenance_mode'] ?? maintenanceMode,
      currencySymbol: map['currency_symbol'] ?? currencySymbol,
      symbolLeft: map['currency_symbol_on_left'] ?? symbolLeft,
      stockDistPolicy: map['stock_distribution_policy'] ?? stockDistPolicy,
      minimumVersion: map['minimum_version'] ?? minimumVersion,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'maintenance_mode': maintenanceMode,
      'currency_symbol': currencySymbol,
      'currency_symbol_on_left': symbolLeft,
      'stock_distribution_policy': stockDistPolicy,
      'minimum_version': minimumVersion,
    };
  }

  Map toAwPost() => toMap();

  Config copyWith({
    bool? maintenanceMode,
    String? currencySymbol,
    bool? symbolLeft,
    StockDistPolicy? stockDistPolicy,
    ValueGetter<String?>? minimumVersion,
  }) {
    return Config(
      maintenanceMode: maintenanceMode ?? this.maintenanceMode,
      currencySymbol: currencySymbol ?? this.currencySymbol,
      symbolLeft: symbolLeft ?? this.symbolLeft,
      stockDistPolicy: stockDistPolicy ?? this.stockDistPolicy,
      minimumVersion: minimumVersion != null ? minimumVersion() : this.minimumVersion,
    );
  }
}
