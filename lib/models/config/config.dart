import 'package:appwrite/models.dart';
import 'package:pos/main.export.dart';

enum StockDistPolicy { newerFirst, olderFirst }

class Config {
  const Config({
    required this.currencySymbol,
    required this.invoicePrefix,
    required this.skuPrefix,
    required this.symbolLeft,
    required this.stockDistPolicy,
    required this.minimumVersion,
    required this.defAccount,
    this.shop = const ShopConfig(),
  });

  final String currencySymbol;
  final String invoicePrefix;
  final String skuPrefix;
  final bool symbolLeft;
  final StockDistPolicy stockDistPolicy;
  final String? minimumVersion;
  final PaymentAccount? defAccount;
  final ShopConfig shop;

  PaymentAccount? get defaultAccount => (defAccount?.isActive ?? false) ? defAccount : null;

  static Config get _def => const Config(
    currencySymbol: '\$',
    invoicePrefix: 'INV',
    skuPrefix: 'SKU',
    symbolLeft: true,
    stockDistPolicy: StockDistPolicy.newerFirst,
    minimumVersion: null,
    defAccount: null,
  );

  factory Config.fromDoc(Document doc) {
    final map = doc.data;
    return Config.fromMap(map);
  }

  factory Config.fromMap(Map<String, dynamic> map) {
    return Config(
      currencySymbol: map['currency_symbol'] ?? _def.currencySymbol,
      symbolLeft: map['currency_symbol_on_left'] ?? _def.symbolLeft,
      stockDistPolicy: StockDistPolicy.values.byName(map['stock_distribution_policy']),
      minimumVersion: map['minimum_version'] ?? _def.minimumVersion,
      defAccount: PaymentAccount.tryParse(map['default_account']),
      shop: ShopConfig.fromMap(map),
      invoicePrefix: map['invoice_prefix'] ?? _def.invoicePrefix,
      skuPrefix: map['sku_prefix'] ?? _def.skuPrefix,
    );
  }

  static Config tryParse(dynamic value) {
    try {
      if (value case final Config c) return c;
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
      currencySymbol: map['currency_symbol'] ?? currencySymbol,
      symbolLeft: map['currency_symbol_on_left'] ?? symbolLeft,
      stockDistPolicy: map['stock_distribution_policy'] == null
          ? stockDistPolicy
          : StockDistPolicy.values.byName(map['stock_distribution_policy']),
      minimumVersion: map['minimum_version'] ?? minimumVersion,
      defAccount: PaymentAccount.tryParse(map['default_account']) ?? defAccount,
      shop: shop.marge(map),
      invoicePrefix: map['invoice_prefix'] ?? invoicePrefix,
      skuPrefix: map['sku_prefix'] ?? skuPrefix,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'currency_symbol': currencySymbol,
      'currency_symbol_on_left': symbolLeft,
      'stock_distribution_policy': stockDistPolicy.name,
      'minimum_version': minimumVersion,
      'default_account': defAccount?.toMap(),
      ...shop.toMap(),
      'invoice_prefix': invoicePrefix,
      'sku_prefix': skuPrefix,
    };
  }

  Map toAwPost() => {
    'currency_symbol': currencySymbol,
    'currency_symbol_on_left': symbolLeft,
    'stock_distribution_policy': stockDistPolicy.name,
    'minimum_version': minimumVersion,
    'default_account': defAccount?.id,
    ...shop.toMap(),
    'invoice_prefix': invoicePrefix,
    'sku_prefix': skuPrefix,
  };

  Config copyWith({
    String? currencySymbol,
    String? invoicePrefix,
    String? skuPrefix,
    bool? symbolLeft,
    StockDistPolicy? stockDistPolicy,
    ValueGetter<String?>? minimumVersion,
    ValueGetter<PaymentAccount?>? defAccount,
    ShopConfig? shop,
  }) {
    return Config(
      currencySymbol: currencySymbol ?? this.currencySymbol,
      invoicePrefix: invoicePrefix ?? this.invoicePrefix,
      skuPrefix: skuPrefix ?? this.skuPrefix,
      symbolLeft: symbolLeft ?? this.symbolLeft,
      stockDistPolicy: stockDistPolicy ?? this.stockDistPolicy,
      minimumVersion: minimumVersion != null ? minimumVersion() : this.minimumVersion,
      defAccount: defAccount != null ? defAccount() : this.defAccount,
      shop: shop ?? this.shop,
    );
  }
}
