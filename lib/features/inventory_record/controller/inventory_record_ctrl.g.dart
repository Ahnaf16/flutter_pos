// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'inventory_record_ctrl.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$inventoryCtrlHash() => r'83e8ca905704e9582792b807f19c540a291f90de';

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

abstract class _$InventoryCtrl
    extends BuildlessAutoDisposeAsyncNotifier<List<InventoryRecord>> {
  late final RecordType? type;

  FutureOr<List<InventoryRecord>> build(
    RecordType? type,
  );
}

/// See also [InventoryCtrl].
@ProviderFor(InventoryCtrl)
const inventoryCtrlProvider = InventoryCtrlFamily();

/// See also [InventoryCtrl].
class InventoryCtrlFamily extends Family<AsyncValue<List<InventoryRecord>>> {
  /// See also [InventoryCtrl].
  const InventoryCtrlFamily();

  /// See also [InventoryCtrl].
  InventoryCtrlProvider call(
    RecordType? type,
  ) {
    return InventoryCtrlProvider(
      type,
    );
  }

  @override
  InventoryCtrlProvider getProviderOverride(
    covariant InventoryCtrlProvider provider,
  ) {
    return call(
      provider.type,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'inventoryCtrlProvider';
}

/// See also [InventoryCtrl].
class InventoryCtrlProvider extends AutoDisposeAsyncNotifierProviderImpl<
    InventoryCtrl, List<InventoryRecord>> {
  /// See also [InventoryCtrl].
  InventoryCtrlProvider(
    RecordType? type,
  ) : this._internal(
          () => InventoryCtrl()..type = type,
          from: inventoryCtrlProvider,
          name: r'inventoryCtrlProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$inventoryCtrlHash,
          dependencies: InventoryCtrlFamily._dependencies,
          allTransitiveDependencies:
              InventoryCtrlFamily._allTransitiveDependencies,
          type: type,
        );

  InventoryCtrlProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.type,
  }) : super.internal();

  final RecordType? type;

  @override
  FutureOr<List<InventoryRecord>> runNotifierBuild(
    covariant InventoryCtrl notifier,
  ) {
    return notifier.build(
      type,
    );
  }

  @override
  Override overrideWith(InventoryCtrl Function() create) {
    return ProviderOverride(
      origin: this,
      override: InventoryCtrlProvider._internal(
        () => create()..type = type,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        type: type,
      ),
    );
  }

  @override
  AutoDisposeAsyncNotifierProviderElement<InventoryCtrl, List<InventoryRecord>>
      createElement() {
    return _InventoryCtrlProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is InventoryCtrlProvider && other.type == type;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, type.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin InventoryCtrlRef
    on AutoDisposeAsyncNotifierProviderRef<List<InventoryRecord>> {
  /// The parameter `type` of this provider.
  RecordType? get type;
}

class _InventoryCtrlProviderElement
    extends AutoDisposeAsyncNotifierProviderElement<InventoryCtrl,
        List<InventoryRecord>> with InventoryCtrlRef {
  _InventoryCtrlProviderElement(super.provider);

  @override
  RecordType? get type => (origin as InventoryCtrlProvider).type;
}

String _$inventoryReturnCtrlHash() =>
    r'8a869fa8f3f015d2428d7d121da926258d3cf648';

abstract class _$InventoryReturnCtrl
    extends BuildlessAutoDisposeAsyncNotifier<List<ReturnRecord>> {
  late final bool? isSale;

  FutureOr<List<ReturnRecord>> build(
    bool? isSale,
  );
}

/// See also [InventoryReturnCtrl].
@ProviderFor(InventoryReturnCtrl)
const inventoryReturnCtrlProvider = InventoryReturnCtrlFamily();

/// See also [InventoryReturnCtrl].
class InventoryReturnCtrlFamily extends Family<AsyncValue<List<ReturnRecord>>> {
  /// See also [InventoryReturnCtrl].
  const InventoryReturnCtrlFamily();

  /// See also [InventoryReturnCtrl].
  InventoryReturnCtrlProvider call(
    bool? isSale,
  ) {
    return InventoryReturnCtrlProvider(
      isSale,
    );
  }

  @override
  InventoryReturnCtrlProvider getProviderOverride(
    covariant InventoryReturnCtrlProvider provider,
  ) {
    return call(
      provider.isSale,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'inventoryReturnCtrlProvider';
}

/// See also [InventoryReturnCtrl].
class InventoryReturnCtrlProvider extends AutoDisposeAsyncNotifierProviderImpl<
    InventoryReturnCtrl, List<ReturnRecord>> {
  /// See also [InventoryReturnCtrl].
  InventoryReturnCtrlProvider(
    bool? isSale,
  ) : this._internal(
          () => InventoryReturnCtrl()..isSale = isSale,
          from: inventoryReturnCtrlProvider,
          name: r'inventoryReturnCtrlProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$inventoryReturnCtrlHash,
          dependencies: InventoryReturnCtrlFamily._dependencies,
          allTransitiveDependencies:
              InventoryReturnCtrlFamily._allTransitiveDependencies,
          isSale: isSale,
        );

  InventoryReturnCtrlProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.isSale,
  }) : super.internal();

  final bool? isSale;

  @override
  FutureOr<List<ReturnRecord>> runNotifierBuild(
    covariant InventoryReturnCtrl notifier,
  ) {
    return notifier.build(
      isSale,
    );
  }

  @override
  Override overrideWith(InventoryReturnCtrl Function() create) {
    return ProviderOverride(
      origin: this,
      override: InventoryReturnCtrlProvider._internal(
        () => create()..isSale = isSale,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        isSale: isSale,
      ),
    );
  }

  @override
  AutoDisposeAsyncNotifierProviderElement<InventoryReturnCtrl,
      List<ReturnRecord>> createElement() {
    return _InventoryReturnCtrlProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is InventoryReturnCtrlProvider && other.isSale == isSale;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, isSale.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin InventoryReturnCtrlRef
    on AutoDisposeAsyncNotifierProviderRef<List<ReturnRecord>> {
  /// The parameter `isSale` of this provider.
  bool? get isSale;
}

class _InventoryReturnCtrlProviderElement
    extends AutoDisposeAsyncNotifierProviderElement<InventoryReturnCtrl,
        List<ReturnRecord>> with InventoryReturnCtrlRef {
  _InventoryReturnCtrlProviderElement(super.provider);

  @override
  bool? get isSale => (origin as InventoryReturnCtrlProvider).isSale;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
