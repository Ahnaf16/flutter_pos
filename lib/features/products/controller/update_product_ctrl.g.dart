// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'update_product_ctrl.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$updateProductCtrlHash() => r'62a988023eace38c22d2acbc9f7eb7cbfe4f5dc1';

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

abstract class _$UpdateProductCtrl
    extends BuildlessAutoDisposeAsyncNotifier<Product?> {
  late final String? id;

  FutureOr<Product?> build(String? id);
}

/// See also [UpdateProductCtrl].
@ProviderFor(UpdateProductCtrl)
const updateProductCtrlProvider = UpdateProductCtrlFamily();

/// See also [UpdateProductCtrl].
class UpdateProductCtrlFamily extends Family<AsyncValue<Product?>> {
  /// See also [UpdateProductCtrl].
  const UpdateProductCtrlFamily();

  /// See also [UpdateProductCtrl].
  UpdateProductCtrlProvider call(String? id) {
    return UpdateProductCtrlProvider(id);
  }

  @override
  UpdateProductCtrlProvider getProviderOverride(
    covariant UpdateProductCtrlProvider provider,
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
  String? get name => r'updateProductCtrlProvider';
}

/// See also [UpdateProductCtrl].
class UpdateProductCtrlProvider
    extends AutoDisposeAsyncNotifierProviderImpl<UpdateProductCtrl, Product?> {
  /// See also [UpdateProductCtrl].
  UpdateProductCtrlProvider(String? id)
    : this._internal(
        () => UpdateProductCtrl()..id = id,
        from: updateProductCtrlProvider,
        name: r'updateProductCtrlProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$updateProductCtrlHash,
        dependencies: UpdateProductCtrlFamily._dependencies,
        allTransitiveDependencies:
            UpdateProductCtrlFamily._allTransitiveDependencies,
        id: id,
      );

  UpdateProductCtrlProvider._internal(
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
  FutureOr<Product?> runNotifierBuild(covariant UpdateProductCtrl notifier) {
    return notifier.build(id);
  }

  @override
  Override overrideWith(UpdateProductCtrl Function() create) {
    return ProviderOverride(
      origin: this,
      override: UpdateProductCtrlProvider._internal(
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
  AutoDisposeAsyncNotifierProviderElement<UpdateProductCtrl, Product?>
  createElement() {
    return _UpdateProductCtrlProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is UpdateProductCtrlProvider && other.id == id;
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
mixin UpdateProductCtrlRef on AutoDisposeAsyncNotifierProviderRef<Product?> {
  /// The parameter `id` of this provider.
  String? get id;
}

class _UpdateProductCtrlProviderElement
    extends AutoDisposeAsyncNotifierProviderElement<UpdateProductCtrl, Product?>
    with UpdateProductCtrlRef {
  _UpdateProductCtrlProviderElement(super.provider);

  @override
  String? get id => (origin as UpdateProductCtrlProvider).id;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
