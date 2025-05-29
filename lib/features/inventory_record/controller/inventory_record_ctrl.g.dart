// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'inventory_record_ctrl.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$recordsByPartiHash() => r'e5005ec1220afa44b858f1414174f6b2b10ac668';

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

/// See also [recordsByParti].
@ProviderFor(recordsByParti)
const recordsByPartiProvider = RecordsByPartiFamily();

/// See also [recordsByParti].
class RecordsByPartiFamily extends Family<AsyncValue<List<InventoryRecord>>> {
  /// See also [recordsByParti].
  const RecordsByPartiFamily();

  /// See also [recordsByParti].
  RecordsByPartiProvider call(String? parti) {
    return RecordsByPartiProvider(parti);
  }

  @override
  RecordsByPartiProvider getProviderOverride(
    covariant RecordsByPartiProvider provider,
  ) {
    return call(provider.parti);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'recordsByPartiProvider';
}

/// See also [recordsByParti].
class RecordsByPartiProvider
    extends AutoDisposeFutureProvider<List<InventoryRecord>> {
  /// See also [recordsByParti].
  RecordsByPartiProvider(String? parti)
    : this._internal(
        (ref) => recordsByParti(ref as RecordsByPartiRef, parti),
        from: recordsByPartiProvider,
        name: r'recordsByPartiProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$recordsByPartiHash,
        dependencies: RecordsByPartiFamily._dependencies,
        allTransitiveDependencies:
            RecordsByPartiFamily._allTransitiveDependencies,
        parti: parti,
      );

  RecordsByPartiProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.parti,
  }) : super.internal();

  final String? parti;

  @override
  Override overrideWith(
    FutureOr<List<InventoryRecord>> Function(RecordsByPartiRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: RecordsByPartiProvider._internal(
        (ref) => create(ref as RecordsByPartiRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        parti: parti,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<InventoryRecord>> createElement() {
    return _RecordsByPartiProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is RecordsByPartiProvider && other.parti == parti;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, parti.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin RecordsByPartiRef on AutoDisposeFutureProviderRef<List<InventoryRecord>> {
  /// The parameter `parti` of this provider.
  String? get parti;
}

class _RecordsByPartiProviderElement
    extends AutoDisposeFutureProviderElement<List<InventoryRecord>>
    with RecordsByPartiRef {
  _RecordsByPartiProviderElement(super.provider);

  @override
  String? get parti => (origin as RecordsByPartiProvider).parti;
}

String _$recordDetailsHash() => r'6a509e5055f7c0b2498b229290bb0e4751afe428';

/// See also [recordDetails].
@ProviderFor(recordDetails)
const recordDetailsProvider = RecordDetailsFamily();

/// See also [recordDetails].
class RecordDetailsFamily extends Family<AsyncValue<InventoryRecord?>> {
  /// See also [recordDetails].
  const RecordDetailsFamily();

  /// See also [recordDetails].
  RecordDetailsProvider call(String? id) {
    return RecordDetailsProvider(id);
  }

  @override
  RecordDetailsProvider getProviderOverride(
    covariant RecordDetailsProvider provider,
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
  String? get name => r'recordDetailsProvider';
}

/// See also [recordDetails].
class RecordDetailsProvider
    extends AutoDisposeFutureProvider<InventoryRecord?> {
  /// See also [recordDetails].
  RecordDetailsProvider(String? id)
    : this._internal(
        (ref) => recordDetails(ref as RecordDetailsRef, id),
        from: recordDetailsProvider,
        name: r'recordDetailsProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$recordDetailsHash,
        dependencies: RecordDetailsFamily._dependencies,
        allTransitiveDependencies:
            RecordDetailsFamily._allTransitiveDependencies,
        id: id,
      );

  RecordDetailsProvider._internal(
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
    FutureOr<InventoryRecord?> Function(RecordDetailsRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: RecordDetailsProvider._internal(
        (ref) => create(ref as RecordDetailsRef),
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
  AutoDisposeFutureProviderElement<InventoryRecord?> createElement() {
    return _RecordDetailsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is RecordDetailsProvider && other.id == id;
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
mixin RecordDetailsRef on AutoDisposeFutureProviderRef<InventoryRecord?> {
  /// The parameter `id` of this provider.
  String? get id;
}

class _RecordDetailsProviderElement
    extends AutoDisposeFutureProviderElement<InventoryRecord?>
    with RecordDetailsRef {
  _RecordDetailsProviderElement(super.provider);

  @override
  String? get id => (origin as RecordDetailsProvider).id;
}

String _$inventoryCtrlHash() => r'32a2e1cac4a51ce6bf52664b65b30ae05a85ae59';

abstract class _$InventoryCtrl
    extends BuildlessAutoDisposeAsyncNotifier<List<InventoryRecord>> {
  late final RecordType? type;

  FutureOr<List<InventoryRecord>> build(RecordType? type);
}

/// See also [InventoryCtrl].
@ProviderFor(InventoryCtrl)
const inventoryCtrlProvider = InventoryCtrlFamily();

/// See also [InventoryCtrl].
class InventoryCtrlFamily extends Family<AsyncValue<List<InventoryRecord>>> {
  /// See also [InventoryCtrl].
  const InventoryCtrlFamily();

  /// See also [InventoryCtrl].
  InventoryCtrlProvider call(RecordType? type) {
    return InventoryCtrlProvider(type);
  }

  @override
  InventoryCtrlProvider getProviderOverride(
    covariant InventoryCtrlProvider provider,
  ) {
    return call(provider.type);
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
class InventoryCtrlProvider
    extends
        AutoDisposeAsyncNotifierProviderImpl<
          InventoryCtrl,
          List<InventoryRecord>
        > {
  /// See also [InventoryCtrl].
  InventoryCtrlProvider(RecordType? type)
    : this._internal(
        () => InventoryCtrl()..type = type,
        from: inventoryCtrlProvider,
        name: r'inventoryCtrlProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
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
    return notifier.build(type);
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
    extends
        AutoDisposeAsyncNotifierProviderElement<
          InventoryCtrl,
          List<InventoryRecord>
        >
    with InventoryCtrlRef {
  _InventoryCtrlProviderElement(super.provider);

  @override
  RecordType? get type => (origin as InventoryCtrlProvider).type;
}

String _$inventoryReturnCtrlHash() =>
    r'c620b0503eb70ffb024d7828f788627722c4baae';

abstract class _$InventoryReturnCtrl
    extends BuildlessAutoDisposeAsyncNotifier<List<ReturnRecord>> {
  late final bool? isSale;

  FutureOr<List<ReturnRecord>> build(bool? isSale);
}

/// See also [InventoryReturnCtrl].
@ProviderFor(InventoryReturnCtrl)
const inventoryReturnCtrlProvider = InventoryReturnCtrlFamily();

/// See also [InventoryReturnCtrl].
class InventoryReturnCtrlFamily extends Family<AsyncValue<List<ReturnRecord>>> {
  /// See also [InventoryReturnCtrl].
  const InventoryReturnCtrlFamily();

  /// See also [InventoryReturnCtrl].
  InventoryReturnCtrlProvider call(bool? isSale) {
    return InventoryReturnCtrlProvider(isSale);
  }

  @override
  InventoryReturnCtrlProvider getProviderOverride(
    covariant InventoryReturnCtrlProvider provider,
  ) {
    return call(provider.isSale);
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
class InventoryReturnCtrlProvider
    extends
        AutoDisposeAsyncNotifierProviderImpl<
          InventoryReturnCtrl,
          List<ReturnRecord>
        > {
  /// See also [InventoryReturnCtrl].
  InventoryReturnCtrlProvider(bool? isSale)
    : this._internal(
        () => InventoryReturnCtrl()..isSale = isSale,
        from: inventoryReturnCtrlProvider,
        name: r'inventoryReturnCtrlProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
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
    return notifier.build(isSale);
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
  AutoDisposeAsyncNotifierProviderElement<
    InventoryReturnCtrl,
    List<ReturnRecord>
  >
  createElement() {
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
    extends
        AutoDisposeAsyncNotifierProviderElement<
          InventoryReturnCtrl,
          List<ReturnRecord>
        >
    with InventoryReturnCtrlRef {
  _InventoryReturnCtrlProviderElement(super.provider);

  @override
  bool? get isSale => (origin as InventoryReturnCtrlProvider).isSale;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
