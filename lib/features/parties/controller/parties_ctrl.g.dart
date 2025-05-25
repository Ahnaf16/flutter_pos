// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'parties_ctrl.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$partyDetailsHash() => r'25a900fa63cbe4dcd0e943da5d33fe363be1b47e';

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

/// See also [partyDetails].
@ProviderFor(partyDetails)
const partyDetailsProvider = PartyDetailsFamily();

/// See also [partyDetails].
class PartyDetailsFamily extends Family<AsyncValue<Party?>> {
  /// See also [partyDetails].
  const PartyDetailsFamily();

  /// See also [partyDetails].
  PartyDetailsProvider call(String? id) {
    return PartyDetailsProvider(id);
  }

  @override
  PartyDetailsProvider getProviderOverride(
    covariant PartyDetailsProvider provider,
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
  String? get name => r'partyDetailsProvider';
}

/// See also [partyDetails].
class PartyDetailsProvider extends AutoDisposeFutureProvider<Party?> {
  /// See also [partyDetails].
  PartyDetailsProvider(String? id)
    : this._internal(
        (ref) => partyDetails(ref as PartyDetailsRef, id),
        from: partyDetailsProvider,
        name: r'partyDetailsProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$partyDetailsHash,
        dependencies: PartyDetailsFamily._dependencies,
        allTransitiveDependencies:
            PartyDetailsFamily._allTransitiveDependencies,
        id: id,
      );

  PartyDetailsProvider._internal(
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
    FutureOr<Party?> Function(PartyDetailsRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: PartyDetailsProvider._internal(
        (ref) => create(ref as PartyDetailsRef),
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
  AutoDisposeFutureProviderElement<Party?> createElement() {
    return _PartyDetailsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is PartyDetailsProvider && other.id == id;
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
mixin PartyDetailsRef on AutoDisposeFutureProviderRef<Party?> {
  /// The parameter `id` of this provider.
  String? get id;
}

class _PartyDetailsProviderElement
    extends AutoDisposeFutureProviderElement<Party?>
    with PartyDetailsRef {
  _PartyDetailsProviderElement(super.provider);

  @override
  String? get id => (origin as PartyDetailsProvider).id;
}

String _$partiesCtrlHash() => r'2f377d32e8f571c7829acbcf63b81d0446ef857a';

abstract class _$PartiesCtrl
    extends BuildlessAutoDisposeAsyncNotifier<List<Party>> {
  late final bool? isCustomer;

  FutureOr<List<Party>> build(bool? isCustomer);
}

/// See also [PartiesCtrl].
@ProviderFor(PartiesCtrl)
const partiesCtrlProvider = PartiesCtrlFamily();

/// See also [PartiesCtrl].
class PartiesCtrlFamily extends Family<AsyncValue<List<Party>>> {
  /// See also [PartiesCtrl].
  const PartiesCtrlFamily();

  /// See also [PartiesCtrl].
  PartiesCtrlProvider call(bool? isCustomer) {
    return PartiesCtrlProvider(isCustomer);
  }

  @override
  PartiesCtrlProvider getProviderOverride(
    covariant PartiesCtrlProvider provider,
  ) {
    return call(provider.isCustomer);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'partiesCtrlProvider';
}

/// See also [PartiesCtrl].
class PartiesCtrlProvider
    extends AutoDisposeAsyncNotifierProviderImpl<PartiesCtrl, List<Party>> {
  /// See also [PartiesCtrl].
  PartiesCtrlProvider(bool? isCustomer)
    : this._internal(
        () => PartiesCtrl()..isCustomer = isCustomer,
        from: partiesCtrlProvider,
        name: r'partiesCtrlProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$partiesCtrlHash,
        dependencies: PartiesCtrlFamily._dependencies,
        allTransitiveDependencies: PartiesCtrlFamily._allTransitiveDependencies,
        isCustomer: isCustomer,
      );

  PartiesCtrlProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.isCustomer,
  }) : super.internal();

  final bool? isCustomer;

  @override
  FutureOr<List<Party>> runNotifierBuild(covariant PartiesCtrl notifier) {
    return notifier.build(isCustomer);
  }

  @override
  Override overrideWith(PartiesCtrl Function() create) {
    return ProviderOverride(
      origin: this,
      override: PartiesCtrlProvider._internal(
        () => create()..isCustomer = isCustomer,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        isCustomer: isCustomer,
      ),
    );
  }

  @override
  AutoDisposeAsyncNotifierProviderElement<PartiesCtrl, List<Party>>
  createElement() {
    return _PartiesCtrlProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is PartiesCtrlProvider && other.isCustomer == isCustomer;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, isCustomer.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin PartiesCtrlRef on AutoDisposeAsyncNotifierProviderRef<List<Party>> {
  /// The parameter `isCustomer` of this provider.
  bool? get isCustomer;
}

class _PartiesCtrlProviderElement
    extends AutoDisposeAsyncNotifierProviderElement<PartiesCtrl, List<Party>>
    with PartiesCtrlRef {
  _PartiesCtrlProviderElement(super.provider);

  @override
  bool? get isCustomer => (origin as PartiesCtrlProvider).isCustomer;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
