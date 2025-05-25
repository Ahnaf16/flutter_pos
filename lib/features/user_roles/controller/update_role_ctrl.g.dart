// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'update_role_ctrl.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$updateRoleCtrlHash() => r'3ce7f0c22dfe6bc0748beabb9743e5c72dba877d';

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

abstract class _$UpdateRoleCtrl
    extends BuildlessAutoDisposeAsyncNotifier<UserRole?> {
  late final String? id;

  FutureOr<UserRole?> build(String? id);
}

/// See also [UpdateRoleCtrl].
@ProviderFor(UpdateRoleCtrl)
const updateRoleCtrlProvider = UpdateRoleCtrlFamily();

/// See also [UpdateRoleCtrl].
class UpdateRoleCtrlFamily extends Family<AsyncValue<UserRole?>> {
  /// See also [UpdateRoleCtrl].
  const UpdateRoleCtrlFamily();

  /// See also [UpdateRoleCtrl].
  UpdateRoleCtrlProvider call(String? id) {
    return UpdateRoleCtrlProvider(id);
  }

  @override
  UpdateRoleCtrlProvider getProviderOverride(
    covariant UpdateRoleCtrlProvider provider,
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
  String? get name => r'updateRoleCtrlProvider';
}

/// See also [UpdateRoleCtrl].
class UpdateRoleCtrlProvider
    extends AutoDisposeAsyncNotifierProviderImpl<UpdateRoleCtrl, UserRole?> {
  /// See also [UpdateRoleCtrl].
  UpdateRoleCtrlProvider(String? id)
    : this._internal(
        () => UpdateRoleCtrl()..id = id,
        from: updateRoleCtrlProvider,
        name: r'updateRoleCtrlProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$updateRoleCtrlHash,
        dependencies: UpdateRoleCtrlFamily._dependencies,
        allTransitiveDependencies:
            UpdateRoleCtrlFamily._allTransitiveDependencies,
        id: id,
      );

  UpdateRoleCtrlProvider._internal(
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
  FutureOr<UserRole?> runNotifierBuild(covariant UpdateRoleCtrl notifier) {
    return notifier.build(id);
  }

  @override
  Override overrideWith(UpdateRoleCtrl Function() create) {
    return ProviderOverride(
      origin: this,
      override: UpdateRoleCtrlProvider._internal(
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
  AutoDisposeAsyncNotifierProviderElement<UpdateRoleCtrl, UserRole?>
  createElement() {
    return _UpdateRoleCtrlProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is UpdateRoleCtrlProvider && other.id == id;
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
mixin UpdateRoleCtrlRef on AutoDisposeAsyncNotifierProviderRef<UserRole?> {
  /// The parameter `id` of this provider.
  String? get id;
}

class _UpdateRoleCtrlProviderElement
    extends AutoDisposeAsyncNotifierProviderElement<UpdateRoleCtrl, UserRole?>
    with UpdateRoleCtrlRef {
  _UpdateRoleCtrlProviderElement(super.provider);

  @override
  String? get id => (origin as UpdateRoleCtrlProvider).id;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
