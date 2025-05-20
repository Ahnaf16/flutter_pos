import 'package:flutter/widgets.dart';

class ShopConfig {
  const ShopConfig({this.shopName, this.shopAddress, this.shopLogo});
  final String? shopName;
  final String? shopAddress;
  final String? shopLogo;

  factory ShopConfig.fromMap(Map<String, dynamic> map) {
    return ShopConfig(shopName: map['shop_name'], shopAddress: map['shop_address'], shopLogo: map['shop_logo']);
  }

  ShopConfig marge(Map<String, dynamic> map) {
    return ShopConfig(
      shopName: map['shop_name'] ?? shopName,
      shopAddress: map['shop_address'] ?? shopAddress,
      shopLogo: map['shop_logo'] ?? shopLogo,
    );
  }

  Map<String, dynamic> toMap() => {'shop_name': shopName, 'shop_address': shopAddress, 'shop_logo': shopLogo};

  ShopConfig copyWith({
    ValueGetter<String?>? shopName,
    ValueGetter<String?>? shopAddress,
    ValueGetter<String?>? shopLogo,
  }) {
    return ShopConfig(
      shopName: shopName != null ? shopName() : this.shopName,
      shopAddress: shopAddress != null ? shopAddress() : this.shopAddress,
      shopLogo: shopLogo != null ? shopLogo() : this.shopLogo,
    );
  }
}
