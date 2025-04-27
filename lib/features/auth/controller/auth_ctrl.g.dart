// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_ctrl.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$authCtrlHash() => r'9cc368f1b25b4c2eb212d3dff8f7d962f48b44ce';

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
String _$authStateSyncHash() => r'ce0ebce6b23705468eb30bad278efe5aec7e6ba7';

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
