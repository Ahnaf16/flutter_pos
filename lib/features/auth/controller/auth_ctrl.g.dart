// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_ctrl.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$currentUserHash() => r'ba1b86d3a62ce912cf6ee9409032ed61fd179425';

/// See also [currentUser].
@ProviderFor(currentUser)
final currentUserProvider = FutureProvider<AppUser?>.internal(
  currentUser,
  name: r'currentUserProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$currentUserHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CurrentUserRef = FutureProviderRef<AppUser?>;
String _$authCtrlHash() => r'435e03f1cea2d1b7bf650f9d16a9ee936d488349';

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
String _$authStateSyncHash() => r'20f2b07d48f1ddcf38d07946a93e4e2c5de6107c';

/// See also [AuthStateSync].
@ProviderFor(AuthStateSync)
final authStateSyncProvider =
    NotifierProvider<AuthStateSync, Option<AppUser>>.internal(
  AuthStateSync.new,
  name: r'authStateSyncProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$authStateSyncHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$AuthStateSync = Notifier<Option<AppUser>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
