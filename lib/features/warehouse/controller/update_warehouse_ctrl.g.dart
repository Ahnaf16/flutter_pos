// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'update_warehouse_ctrl.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$updateWarehouseCtrlHash() =>
    r'533d1ffd9fac7fefa7abbcd63bdb60143f494e63';

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

abstract class _$UpdateWarehouseCtrl
    extends BuildlessAutoDisposeAsyncNotifier<WareHouse?> {
  late final String? id;

  FutureOr<WareHouse?> build(String? id);
}

/// See also [UpdateWarehouseCtrl].
@ProviderFor(UpdateWarehouseCtrl)
const updateWarehouseCtrlProvider = UpdateWarehouseCtrlFamily();

/// See also [UpdateWarehouseCtrl].
class UpdateWarehouseCtrlFamily extends Family<AsyncValue<WareHouse?>> {
  /// See also [UpdateWarehouseCtrl].
  const UpdateWarehouseCtrlFamily();

  /// See also [UpdateWarehouseCtrl].
  UpdateWarehouseCtrlProvider call(String? id) {
    return UpdateWarehouseCtrlProvider(id);
  }

  @override
  UpdateWarehouseCtrlProvider getProviderOverride(
    covariant UpdateWarehouseCtrlProvider provider,
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
  String? get name => r'updateWarehouseCtrlProvider';
}

/// See also [UpdateWarehouseCtrl].
class UpdateWarehouseCtrlProvider
    extends
        AutoDisposeAsyncNotifierProviderImpl<UpdateWarehouseCtrl, WareHouse?> {
  /// See also [UpdateWarehouseCtrl].
  UpdateWarehouseCtrlProvider(String? id)
    : this._internal(
        () => UpdateWarehouseCtrl()..id = id,
        from: updateWarehouseCtrlProvider,
        name: r'updateWarehouseCtrlProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$updateWarehouseCtrlHash,
        dependencies: UpdateWarehouseCtrlFamily._dependencies,
        allTransitiveDependencies:
            UpdateWarehouseCtrlFamily._allTransitiveDependencies,
        id: id,
      );

  UpdateWarehouseCtrlProvider._internal(
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
  FutureOr<WareHouse?> runNotifierBuild(
    covariant UpdateWarehouseCtrl notifier,
  ) {
    return notifier.build(id);
  }

  @override
  Override overrideWith(UpdateWarehouseCtrl Function() create) {
    return ProviderOverride(
      origin: this,
      override: UpdateWarehouseCtrlProvider._internal(
        () => create()..id = id,
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
  AutoDisposeAsyncNotifierProviderElement<UpdateWarehouseCtrl, WareHouse?>
  createElement() {
    return _UpdateWarehouseCtrlProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is UpdateWarehouseCtrlProvider && other.id == id;
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
mixin UpdateWarehouseCtrlRef
    on AutoDisposeAsyncNotifierProviderRef<WareHouse?> {
  /// The parameter `id` of this provider.
  String? get id;
}

class _UpdateWarehouseCtrlProviderElement
    extends
        AutoDisposeAsyncNotifierProviderElement<UpdateWarehouseCtrl, WareHouse?>
    with UpdateWarehouseCtrlRef {
  _UpdateWarehouseCtrlProviderElement(super.provider);

  @override
  String? get id => (origin as UpdateWarehouseCtrlProvider).id;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
