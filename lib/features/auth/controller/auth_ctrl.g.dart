// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_ctrl.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$authCtrlHash() => r'1228180bf817ef7c7e2d91500ca41ec49659f026';

/// See also [AuthCtrl].
@ProviderFor(AuthCtrl)
final authCtrlProvider =
    AutoDisposeAsyncNotifierProvider<AuthCtrl, AppUser?>.internal(
  AuthCtrl.new,
  name: r'authCtrlProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$authCtrlHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$AuthCtrl = AutoDisposeAsyncNotifier<AppUser?>;
String _$authStateSyncHash() => r'444c52ae4aacf8ed327889c961715e0b62297227';

/// See also [AuthStateSync].
@ProviderFor(AuthStateSync)
final authStateSyncProvider =
    AutoDisposeNotifierProvider<AuthStateSync, Option<AppUser>>.internal(
  AuthStateSync.new,
  name: r'authStateSyncProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$authStateSyncHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$AuthStateSync = AutoDisposeNotifier<Option<AppUser>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
