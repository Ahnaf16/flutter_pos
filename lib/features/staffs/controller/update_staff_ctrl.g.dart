// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'update_staff_ctrl.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$updateStaffCtrlHash() => r'558d057011d44af4a820d56d5bfcaca28e1a7085';

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

abstract class _$UpdateStaffCtrl
    extends BuildlessAutoDisposeAsyncNotifier<AppUser?> {
  late final String? id;

  FutureOr<AppUser?> build(
    String? id,
  );
}

/// See also [UpdateStaffCtrl].
@ProviderFor(UpdateStaffCtrl)
const updateStaffCtrlProvider = UpdateStaffCtrlFamily();

/// See also [UpdateStaffCtrl].
class UpdateStaffCtrlFamily extends Family<AsyncValue<AppUser?>> {
  /// See also [UpdateStaffCtrl].
  const UpdateStaffCtrlFamily();

  /// See also [UpdateStaffCtrl].
  UpdateStaffCtrlProvider call(
    String? id,
  ) {
    return UpdateStaffCtrlProvider(
      id,
    );
  }

  @override
  UpdateStaffCtrlProvider getProviderOverride(
    covariant UpdateStaffCtrlProvider provider,
  ) {
    return call(
      provider.id,
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
  String? get name => r'updateStaffCtrlProvider';
}

/// See also [UpdateStaffCtrl].
class UpdateStaffCtrlProvider
    extends AutoDisposeAsyncNotifierProviderImpl<UpdateStaffCtrl, AppUser?> {
  /// See also [UpdateStaffCtrl].
  UpdateStaffCtrlProvider(
    String? id,
  ) : this._internal(
          () => UpdateStaffCtrl()..id = id,
          from: updateStaffCtrlProvider,
          name: r'updateStaffCtrlProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$updateStaffCtrlHash,
          dependencies: UpdateStaffCtrlFamily._dependencies,
          allTransitiveDependencies:
              UpdateStaffCtrlFamily._allTransitiveDependencies,
          id: id,
        );

  UpdateStaffCtrlProvider._internal(
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
  FutureOr<AppUser?> runNotifierBuild(
    covariant UpdateStaffCtrl notifier,
  ) {
    return notifier.build(
      id,
    );
  }

  @override
  Override overrideWith(UpdateStaffCtrl Function() create) {
    return ProviderOverride(
      origin: this,
      override: UpdateStaffCtrlProvider._internal(
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
  AutoDisposeAsyncNotifierProviderElement<UpdateStaffCtrl, AppUser?>
      createElement() {
    return _UpdateStaffCtrlProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is UpdateStaffCtrlProvider && other.id == id;
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
mixin UpdateStaffCtrlRef on AutoDisposeAsyncNotifierProviderRef<AppUser?> {
  /// The parameter `id` of this provider.
  String? get id;
}

class _UpdateStaffCtrlProviderElement
    extends AutoDisposeAsyncNotifierProviderElement<UpdateStaffCtrl, AppUser?>
    with UpdateStaffCtrlRef {
  _UpdateStaffCtrlProviderElement(super.provider);

  @override
  String? get id => (origin as UpdateStaffCtrlProvider).id;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
