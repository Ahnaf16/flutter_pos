// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'parties_ctrl.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$partiesCtrlHash() => r'1d6b229a0ec0dab5696615089b24b3813e188e49';

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

abstract class _$PartiesCtrl
    extends BuildlessAutoDisposeAsyncNotifier<List<Parti>> {
  late final bool? isCustomer;

  FutureOr<List<Parti>> build(
    bool? isCustomer,
  );
}

/// See also [PartiesCtrl].
@ProviderFor(PartiesCtrl)
const partiesCtrlProvider = PartiesCtrlFamily();

/// See also [PartiesCtrl].
class PartiesCtrlFamily extends Family<AsyncValue<List<Parti>>> {
  /// See also [PartiesCtrl].
  const PartiesCtrlFamily();

  /// See also [PartiesCtrl].
  PartiesCtrlProvider call(
    bool? isCustomer,
  ) {
    return PartiesCtrlProvider(
      isCustomer,
    );
  }

  @override
  PartiesCtrlProvider getProviderOverride(
    covariant PartiesCtrlProvider provider,
  ) {
    return call(
      provider.isCustomer,
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
  String? get name => r'partiesCtrlProvider';
}

/// See also [PartiesCtrl].
class PartiesCtrlProvider
    extends AutoDisposeAsyncNotifierProviderImpl<PartiesCtrl, List<Parti>> {
  /// See also [PartiesCtrl].
  PartiesCtrlProvider(
    bool? isCustomer,
  ) : this._internal(
          () => PartiesCtrl()..isCustomer = isCustomer,
          from: partiesCtrlProvider,
          name: r'partiesCtrlProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$partiesCtrlHash,
          dependencies: PartiesCtrlFamily._dependencies,
          allTransitiveDependencies:
              PartiesCtrlFamily._allTransitiveDependencies,
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
  FutureOr<List<Parti>> runNotifierBuild(
    covariant PartiesCtrl notifier,
  ) {
    return notifier.build(
      isCustomer,
    );
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
  AutoDisposeAsyncNotifierProviderElement<PartiesCtrl, List<Parti>>
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
mixin PartiesCtrlRef on AutoDisposeAsyncNotifierProviderRef<List<Parti>> {
  /// The parameter `isCustomer` of this provider.
  bool? get isCustomer;
}

class _PartiesCtrlProviderElement
    extends AutoDisposeAsyncNotifierProviderElement<PartiesCtrl, List<Parti>>
    with PartiesCtrlRef {
  _PartiesCtrlProviderElement(super.provider);

  @override
  bool? get isCustomer => (origin as PartiesCtrlProvider).isCustomer;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
