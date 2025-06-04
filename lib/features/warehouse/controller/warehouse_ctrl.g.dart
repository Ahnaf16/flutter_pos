// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'warehouse_ctrl.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$warehouseDetailsHash() => r'5e93bf1e008107f9dfe01c8432dfc51fc4200f7d';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

/// See also [warehouseDetails].
@ProviderFor(warehouseDetails)
const warehouseDetailsProvider = WarehouseDetailsFamily();

/// See also [warehouseDetails].
class WarehouseDetailsFamily extends Family<AsyncValue<WareHouse?>> {
  /// See also [warehouseDetails].
  const WarehouseDetailsFamily();

  /// See also [warehouseDetails].
  WarehouseDetailsProvider call(String? id) {
    return WarehouseDetailsProvider(id);
  }

  @override
  WarehouseDetailsProvider getProviderOverride(
    covariant WarehouseDetailsProvider provider,
  ) {
    return call(provider.id);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'warehouseDetailsProvider';
}

/// See also [warehouseDetails].
class WarehouseDetailsProvider extends AutoDisposeFutureProvider<WareHouse?> {
  /// See also [warehouseDetails].
  WarehouseDetailsProvider(String? id)
    : this._internal(
        (ref) => warehouseDetails(ref as WarehouseDetailsRef, id),
        from: warehouseDetailsProvider,
        name: r'warehouseDetailsProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$warehouseDetailsHash,
        dependencies: WarehouseDetailsFamily._dependencies,
        allTransitiveDependencies:
            WarehouseDetailsFamily._allTransitiveDependencies,
        id: id,
      );

  WarehouseDetailsProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.id,
  }) : super.internal();

  final String? id;

  @override
  Override overrideWith(
    FutureOr<WareHouse?> Function(WarehouseDetailsRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: WarehouseDetailsProvider._internal(
        (ref) => create(ref as WarehouseDetailsRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        id: id,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<WareHouse?> createElement() {
    return _WarehouseDetailsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is WarehouseDetailsProvider && other.id == id;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, id.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin WarehouseDetailsRef on AutoDisposeFutureProviderRef<WareHouse?> {
  /// The parameter `id` of this provider.
  String? get id;
}

class _WarehouseDetailsProviderElement
    extends AutoDisposeFutureProviderElement<WareHouse?>
    with WarehouseDetailsRef {
  _WarehouseDetailsProviderElement(super.provider);

  @override
  String? get id => (origin as WarehouseDetailsProvider).id;
}

String _$warehouseCtrlHash() => r'4ac69f100cfe3e6c18fe18fbc57cbc17b5a6c6c4';

/// See also [WarehouseCtrl].
@ProviderFor(WarehouseCtrl)
final warehouseCtrlProvider =
    AutoDisposeAsyncNotifierProvider<WarehouseCtrl, List<WareHouse>>.internal(
      WarehouseCtrl.new,
      name: r'warehouseCtrlProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$warehouseCtrlHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$WarehouseCtrl = AutoDisposeAsyncNotifier<List<WareHouse>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
